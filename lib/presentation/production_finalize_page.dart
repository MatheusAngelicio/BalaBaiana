import 'package:flutter/material.dart';

import '../data/productions_repository.dart';
import '../data/settings_repository.dart';
import '../domain/models/cost_defaults.dart';
import '../domain/models/filling.dart';
import '../domain/models/production_draft.dart';
import '../domain/models/purchase.dart';
import '../domain/models/recipe_base.dart';
import '../domain/services/cost_calculator.dart';
import '../domain/services/production_pricing.dart';
import 'formatters.dart';

class ProductionFinalizePage extends StatelessWidget {
  const ProductionFinalizePage({
    required this.draft,
    required this.syrup,
    required this.base,
    required this.filling,
    required this.purchases,
    required this.productionsRepository,
    super.key,
    this.settingsRepository,
  });

  final ProductionDraft draft;
  final RecipeBase? syrup;
  final RecipeBase base;
  final Filling? filling;
  final List<Purchase> purchases;
  final ProductionsRepository productionsRepository;
  final SettingsRepository? settingsRepository;

  @override
  Widget build(BuildContext context) {
    final settings = settingsRepository ?? SettingsRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar produção')),
      body: FutureBuilder<CostDefaults>(
        future: settings.getCostDefaults(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Não foi possível carregar os custos padrão.'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _FinalizeForm(
            draft: draft,
            syrup: syrup,
            base: base,
            filling: filling,
            purchases: purchases,
            defaults: snapshot.data!,
            productionsRepository: productionsRepository,
          );
        },
      ),
    );
  }
}

class _FinalizeForm extends StatefulWidget {
  const _FinalizeForm({
    required this.draft,
    required this.syrup,
    required this.base,
    required this.filling,
    required this.purchases,
    required this.defaults,
    required this.productionsRepository,
  });

  final ProductionDraft draft;
  final RecipeBase? syrup;
  final RecipeBase base;
  final Filling? filling;
  final List<Purchase> purchases;
  final CostDefaults defaults;
  final ProductionsRepository productionsRepository;

  @override
  State<_FinalizeForm> createState() => _FinalizeFormState();
}

class _FinalizeFormState extends State<_FinalizeForm> {
  final _formKey = GlobalKey<FormState>();
  final _yieldController = TextEditingController();
  late final TextEditingController _packagingController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final packaging = widget.defaults.packagingAndLabelCents;
    _packagingController = TextEditingController(
      text: packaging == 0 ? '' : formatCurrencyInput(packaging),
    );
  }

  @override
  void dispose() {
    _yieldController.dispose();
    _packagingController.dispose();
    super.dispose();
  }

  Map<String, Purchase> get _purchasesById => {
        for (final purchase in widget.purchases) purchase.id: purchase,
      };

  int? get _packagingCents => _packagingController.text.trim().isEmpty
      ? 0
      : parseCurrencyToCents(_packagingController.text, allowZero: true);

  int? get _yieldUnits => int.tryParse(_yieldController.text.trim());

  double? get _syrupCost => widget.draft.syrup == null
      ? 0.0
      : widget.syrup == null
          ? null
          : CostCalculator.recipeBaseProportionalCost(
              recipe: widget.syrup!,
              quantityUsed: widget.draft.syrup!.quantityUsed,
              purchasesById: _purchasesById,
            );

  double? get _baseCost => CostCalculator.recipeBaseProportionalCost(
        recipe: widget.base,
        quantityUsed: widget.draft.base.quantityUsed,
        purchasesById: _purchasesById,
      );

  double? get _fillingCost => widget.draft.filling == null
      ? 0.0
      : widget.filling == null
          ? null
          : CostCalculator.fillingProportionalCost(
              filling: widget.filling!,
              quantityUsed: widget.draft.filling!.quantityUsed,
              purchasesById: _purchasesById,
            );

  ProductionCostBreakdown? get _breakdown {
    final syrupCost = _syrupCost;
    final baseCost = _baseCost;
    final fillingCost = _fillingCost;
    if (syrupCost == null || baseCost == null || fillingCost == null) {
      return null;
    }
    return ProductionCostBreakdown(
      recipeCostCents: ((syrupCost + baseCost + fillingCost) * 100).round(),
    );
  }

  ProductionPricing? get _pricing {
    final breakdown = _breakdown;
    final yieldUnits = _yieldUnits;
    final packaging = _packagingCents;
    if (breakdown == null ||
        yieldUnits == null ||
        yieldUnits <= 0 ||
        packaging == null) {
      return null;
    }
    return ProductionPricing.calculate(
      recipeCostCents: breakdown.recipeCostCents,
      yieldUnits: yieldUnits,
      packagingAndLabelPerUnitCents: packaging,
    );
  }

  Future<void> _finalize() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final pricing = _pricing;
    if (pricing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revise os custos das receitas usadas.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.productionsRepository.finalizeDraft(
        draft: widget.draft,
        yieldUnits: _yieldUnits!,
        profitPercentage: 100,
        pricing: pricing,
        costSnapshot: {
          'syrup': widget.draft.syrup == null
              ? null
              : _recipeSnapshot(
                  recipe: widget.syrup!,
                  selection: widget.draft.syrup!,
                  costCents: (_syrupCost! * 100).round(),
                ),
          'base': _recipeSnapshot(
            recipe: widget.base,
            selection: widget.draft.base,
            costCents: (_baseCost! * 100).round(),
          ),
          'filling': widget.draft.filling == null
              ? null
              : _fillingSnapshot(
                  filling: widget.filling!,
                  selection: widget.draft.filling!,
                  costCents: (_fillingCost! * 100).round(),
                ),
          'calculationRule': 'recipe20_labor100_profit100',
          'profitBasis': 'labor',
          ..._breakdown!.toMap(),
          'costsPerUnitCents': {'packagingAndLabel': _packagingCents!},
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Produção finalizada e salva no histórico.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível finalizar a produção.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Map<String, dynamic> _recipeSnapshot({
    required RecipeBase recipe,
    required ProductionPartSelection selection,
    required int costCents,
  }) =>
      {
        'recipeId': recipe.id,
        'name': recipe.name,
        'quantityUsed': selection.quantityUsed,
        'unit': recipe.yieldUnit.name,
        'costCents': costCents,
        'ingredients': recipe.ingredients.map((item) => item.toMap()).toList(),
      };

  Map<String, dynamic> _fillingSnapshot({
    required Filling filling,
    required ProductionPartSelection selection,
    required int costCents,
  }) =>
      {
        'fillingId': filling.id,
        'name': filling.name,
        'quantityUsed': selection.quantityUsed,
        'unit': filling.yieldUnit.name,
        'costCents': costCents,
        'ingredients': filling.ingredients.map((item) => item.toMap()).toList(),
      };

  @override
  Widget build(BuildContext context) {
    final pricing = _pricing;
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(widget.draft.name,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextFormField(
              controller: _yieldController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Quantas balas renderam?',
                hintText: 'Ex.: 50',
                suffixText: 'balas',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  int.tryParse(value?.trim() ?? '') == null || _yieldUnits! <= 0
                      ? 'Informe um número inteiro maior que zero.'
                      : null,
            ),
            const SizedBox(height: 24),
            Text('Custos e lucro da produção',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text(
                'Valores totais calculados automaticamente a partir dos ingredientes usados na receita.'),
            const SizedBox(height: 12),
            if (_breakdown case final breakdown?) ...[
              _CalculatedAmount(
                  label: 'Custo da receita', cents: breakdown.recipeCostCents),
              _CalculatedAmount(
                  label: 'Custo fixo (20% da receita)',
                  cents: breakdown.fixedCostCents),
              _CalculatedAmount(
                  label: 'Mão de obra (receita + custo fixo)',
                  cents: breakdown.laborCostCents),
              _CalculatedAmount(
                  label: 'Lucro (100% da mão de obra)',
                  cents: breakdown.targetProfitCents),
            ] else
              const Text(
                  'Revise as compras usadas na receita para calcular os custos.'),
            const SizedBox(height: 20),
            TextFormField(
              controller: _packagingController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [CurrencyInputFormatter()],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Embalagem e etiqueta por bala',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              validator: (_) =>
                  _packagingCents == null ? 'Informe um valor válido.' : null,
            ),
            const SizedBox(height: 10),
            const Text(
                'Informe o valor combinado por bala. Ele será multiplicado pelo rendimento e somado aos custos. '
                'Custo fixo, mão de obra e lucro seguem as regras acima.'),
            const SizedBox(height: 20),
            _PricingSummary(pricing: pricing),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _isSaving || pricing == null ? null : _finalize,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56)),
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Finalizar produção'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingSummary extends StatelessWidget {
  const _PricingSummary({required this.pricing});

  final ProductionPricing? pricing;

  @override
  Widget build(BuildContext context) {
    final pricing = this.pricing;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: pricing == null
          ? const Text('Informe o rendimento para calcular o preço sugerido.')
          : Text(
              'Custo total (receita, fixo, mão de obra e embalagem): ${formatCurrency(pricing.totalCostCents)}\n'
              'Custo por bala: ${formatCurrency(pricing.costPerUnitCents)}\n\n'
              'Venda sugerida por bala: ${formatCurrency(pricing.suggestedPriceCents)}\n'
              'Lucro por bala: ${formatCurrency(pricing.profitPerUnitCents)}\n'
              'Venda estimada: ${formatCurrency(pricing.estimatedRevenueCents)}\n'
              'Lucro estimado: ${formatCurrency(pricing.estimatedProfitCents)}\n\n'
              'O preço por bala é arredondado aos centavos; o lucro estimado pode variar alguns centavos.',
              style: Theme.of(context).textTheme.titleSmall,
            ),
    );
  }
}

class _CalculatedAmount extends StatelessWidget {
  const _CalculatedAmount({required this.label, required this.cents});

  final String label;
  final int cents;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            const SizedBox(width: 12),
            Text(formatCurrency(cents),
                style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      );
}
