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
  final RecipeBase syrup;
  final RecipeBase base;
  final Filling filling;
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
  final RecipeBase syrup;
  final RecipeBase base;
  final Filling filling;
  final List<Purchase> purchases;
  final CostDefaults defaults;
  final ProductionsRepository productionsRepository;

  @override
  State<_FinalizeForm> createState() => _FinalizeFormState();
}

class _FinalizeFormState extends State<_FinalizeForm> {
  static const _defaultLabels = {
    'packaging': 'Embalagem por bala',
    'label': 'Etiqueta por bala',
    'labor': 'Mão de obra por bala',
    'fixed': 'Custo fixo por bala',
  };

  final _formKey = GlobalKey<FormState>();
  final _yieldController = TextEditingController();
  final _profitController = TextEditingController(text: '100');
  late final Map<String, TextEditingController> _defaultCostControllers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final defaults = widget.defaults.toMap();
    _defaultCostControllers = {
      for (final entry in _defaultLabels.entries)
        entry.key: TextEditingController(
          text: defaults[entry.key] == 0
              ? ''
              : formatCurrencyInput(defaults[entry.key]!),
        ),
    };
  }

  @override
  void dispose() {
    _yieldController.dispose();
    _profitController.dispose();
    for (final controller in _defaultCostControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, Purchase> get _purchasesById => {
        for (final purchase in widget.purchases) purchase.id: purchase,
      };

  Map<String, int> get _costsPerUnitCents => {
        for (final entry in _defaultCostControllers.entries)
          entry.key: parseCurrencyToCents(entry.value.text) ?? 0,
      };

  int? get _yieldUnits => int.tryParse(_yieldController.text.trim());

  double? get _profitPercentage => parsePositiveNumber(_profitController.text);

  double? get _syrupCost => CostCalculator.recipeBaseProportionalCost(
        recipe: widget.syrup,
        quantityUsed: widget.draft.syrup.quantityUsed,
        purchasesById: _purchasesById,
      );

  double? get _baseCost => CostCalculator.recipeBaseProportionalCost(
        recipe: widget.base,
        quantityUsed: widget.draft.base.quantityUsed,
        purchasesById: _purchasesById,
      );

  double? get _fillingCost => CostCalculator.fillingProportionalCost(
        filling: widget.filling,
        quantityUsed: widget.draft.filling.quantityUsed,
        purchasesById: _purchasesById,
      );

  int get _draftExtraCents => widget.draft.extraCostsCents.values
      .fold(0, (total, value) => total + value);

  int? get _totalCostCents {
    if (_syrupCost == null ||
        _baseCost == null ||
        _fillingCost == null ||
        _yieldUnits == null) {
      return null;
    }
    final ingredientsCents =
        ((_syrupCost! + _baseCost! + _fillingCost!) * 100).round();
    final defaultsCents =
        _costsPerUnitCents.values.fold(0, (total, value) => total + value) *
            _yieldUnits!;
    return ingredientsCents + _draftExtraCents + defaultsCents;
  }

  ProductionPricing? get _pricing {
    if (_totalCostCents == null || _profitPercentage == null) return null;
    return ProductionPricing.calculate(
      totalCostCents: _totalCostCents!,
      yieldUnits: _yieldUnits!,
      profitPercentage: _profitPercentage!,
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
        profitPercentage: _profitPercentage!,
        pricing: pricing,
        costSnapshot: {
          'syrup': _recipeSnapshot(
            recipe: widget.syrup,
            selection: widget.draft.syrup,
            costCents: (_syrupCost! * 100).round(),
          ),
          'base': _recipeSnapshot(
            recipe: widget.base,
            selection: widget.draft.base,
            costCents: (_baseCost! * 100).round(),
          ),
          'filling': _fillingSnapshot(
            filling: widget.filling,
            selection: widget.draft.filling,
            costCents: (_fillingCost! * 100).round(),
          ),
          'draftExtraCostsCents': widget.draft.extraCostsCents,
          'costsPerUnitCents': _costsPerUnitCents,
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
            Text('Custos por bala',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text(
                'Valores sugeridos pelas configurações. Você pode ajustar apenas nesta produção.'),
            const SizedBox(height: 12),
            ..._defaultLabels.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _defaultCostControllers[entry.key],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [CurrencyInputFormatter()],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: entry.value,
                    prefixText: 'R\$ ',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null ||
                          value.trim().isEmpty ||
                          parseCurrencyToCents(value) != null
                      ? null
                      : 'Informe um valor válido.',
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _profitController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Lucro desejado',
                suffixText: '% sobre o custo',
                border: OutlineInputBorder(),
              ),
              validator: (value) => parsePositiveNumber(value ?? '') == null
                  ? 'Informe uma porcentagem maior que zero.'
                  : null,
            ),
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
              'Custo total: ${formatCurrency(pricing.totalCostCents)}\n'
              'Custo por bala: ${formatCurrency(pricing.costPerUnitCents)}\n\n'
              'Venda sugerida por bala: ${formatCurrency(pricing.suggestedPriceCents)}\n'
              'Lucro por bala: ${formatCurrency(pricing.profitPerUnitCents)}\n'
              'Venda estimada: ${formatCurrency(pricing.estimatedRevenueCents)}\n'
              'Lucro estimado: ${formatCurrency(pricing.estimatedProfitCents)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
    );
  }
}
