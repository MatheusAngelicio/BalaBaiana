import 'package:flutter/material.dart';

import '../data/productions_repository.dart';
import '../domain/models/filling.dart';
import '../domain/models/production_draft.dart';
import '../domain/models/purchase.dart';
import '../domain/models/recipe_base.dart';
import '../domain/services/cost_calculator.dart';
import 'formatters.dart';

class ProductionFormPage extends StatefulWidget {
  const ProductionFormPage({
    required this.syrups,
    required this.bases,
    required this.fillings,
    required this.purchases,
    required this.productionsRepository,
    super.key,
    this.draft,
  });

  final List<RecipeBase> syrups;
  final List<RecipeBase> bases;
  final List<Filling> fillings;
  final List<Purchase> purchases;
  final ProductionsRepository productionsRepository;
  final ProductionDraft? draft;

  @override
  State<ProductionFormPage> createState() => _ProductionFormPageState();
}

class _ProductionFormPageState extends State<ProductionFormPage> {
  static const _extraLabels = {
    'packaging': 'Embalagem (total)',
    'label': 'Etiqueta (total)',
    'labor': 'Mão de obra (total)',
    'fixed': 'Custo fixo (total)',
  };

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _syrupQuantityController;
  late final TextEditingController _baseQuantityController;
  late final TextEditingController _fillingQuantityController;
  late final Map<String, TextEditingController> _extraCostControllers;
  String? _syrupId;
  String? _baseId;
  String? _fillingId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final draft = widget.draft;
    _nameController = TextEditingController(text: draft?.name ?? '');
    _syrupId = draft?.syrup.recipeId;
    _baseId = draft?.base.recipeId;
    _fillingId = draft?.filling.recipeId;
    _syrupQuantityController = TextEditingController(
      text: draft == null ? '' : formatQuantity(draft.syrup.quantityUsed),
    );
    _baseQuantityController = TextEditingController(
      text: draft == null ? '' : formatQuantity(draft.base.quantityUsed),
    );
    _fillingQuantityController = TextEditingController(
      text: draft == null ? '' : formatQuantity(draft.filling.quantityUsed),
    );
    _extraCostControllers = {
      for (final entry in _extraLabels.entries)
        entry.key: TextEditingController(
          text: draft == null || (draft.extraCostsCents[entry.key] ?? 0) == 0
              ? ''
              : formatCurrency(draft.extraCostsCents[entry.key]!),
        ),
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _syrupQuantityController.dispose();
    _baseQuantityController.dispose();
    _fillingQuantityController.dispose();
    for (final controller in _extraCostControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  RecipeBase? _findRecipe(List<RecipeBase> recipes, String? id) {
    for (final recipe in recipes) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }

  Filling? _findFilling(String? id) {
    for (final filling in widget.fillings) {
      if (filling.id == id) return filling;
    }
    return null;
  }

  Map<String, Purchase> get _purchasesById => {
        for (final purchase in widget.purchases) purchase.id: purchase,
      };

  Map<String, int> get _extraCostsCents => {
        for (final entry in _extraCostControllers.entries)
          entry.key: parseCurrencyToCents(entry.value.text) ?? 0,
      };

  double? _recipeCost(RecipeBase? recipe, TextEditingController controller) {
    final quantity = parsePositiveNumber(controller.text);
    if (recipe == null || quantity == null) return null;
    return CostCalculator.recipeBaseProportionalCost(
      recipe: recipe,
      quantityUsed: quantity,
      purchasesById: _purchasesById,
    );
  }

  double? _fillingCost(Filling? filling) {
    final quantity = parsePositiveNumber(_fillingQuantityController.text);
    if (filling == null || quantity == null) return null;
    return CostCalculator.fillingProportionalCost(
      filling: filling,
      quantityUsed: quantity,
      purchasesById: _purchasesById,
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final syrup = _findRecipe(widget.syrups, _syrupId)!;
    final base = _findRecipe(widget.bases, _baseId)!;
    final filling = _findFilling(_fillingId)!;
    final syrupCost = _recipeCost(syrup, _syrupQuantityController);
    final baseCost = _recipeCost(base, _baseQuantityController);
    final fillingCost = _fillingCost(filling);
    if (syrupCost == null || baseCost == null || fillingCost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Revise as compras usadas nas receitas selecionadas.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.productionsRepository.saveDraft(
        ProductionDraft(
          id: widget.draft?.id ?? '',
          name: _nameController.text,
          syrup: ProductionPartSelection(
            recipeId: syrup.id,
            quantityUsed: parsePositiveNumber(_syrupQuantityController.text)!,
          ),
          base: ProductionPartSelection(
            recipeId: base.id,
            quantityUsed: parsePositiveNumber(_baseQuantityController.text)!,
          ),
          filling: ProductionPartSelection(
            recipeId: filling.id,
            quantityUsed: parsePositiveNumber(_fillingQuantityController.text)!,
          ),
          extraCostsCents: _extraCostsCents,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Montagem salva. Agora informe o rendimento e o lucro.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar a montagem.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final syrup = _findRecipe(widget.syrups, _syrupId);
    final base = _findRecipe(widget.bases, _baseId);
    final filling = _findFilling(_fillingId);
    final syrupCost = _recipeCost(syrup, _syrupQuantityController);
    final baseCost = _recipeCost(base, _baseQuantityController);
    final fillingCost = _fillingCost(filling);
    final extrasCost =
        _extraCostsCents.values.fold(0, (total, value) => total + value) / 100;
    final hasAllPartCosts =
        syrupCost != null && baseCost != null && fillingCost != null;
    final totalCost =
        (syrupCost ?? 0) + (baseCost ?? 0) + (fillingCost ?? 0) + extrasCost;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.draft == null ? 'Montar produção' : 'Editar montagem'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome da produção',
                  hintText: 'Ex.: Bala baiana de coco',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Informe o nome da produção.'
                    : null,
              ),
              const SizedBox(height: 28),
              Text('Partes da receita',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _RecipePartField(
                label: 'Calda',
                recipes: widget.syrups,
                selectedId: _syrupId,
                quantityController: _syrupQuantityController,
                onChanged: (id) => setState(() => _syrupId = id),
                onQuantityChanged: () => setState(() {}),
                cost: syrupCost,
              ),
              const SizedBox(height: 16),
              _RecipePartField(
                label: 'Base da bala',
                recipes: widget.bases,
                selectedId: _baseId,
                quantityController: _baseQuantityController,
                onChanged: (id) => setState(() => _baseId = id),
                onQuantityChanged: () => setState(() {}),
                cost: baseCost,
              ),
              const SizedBox(height: 16),
              _FillingPartField(
                fillings: widget.fillings,
                selectedId: _fillingId,
                quantityController: _fillingQuantityController,
                onChanged: (id) => setState(() => _fillingId = id),
                onQuantityChanged: () => setState(() {}),
                cost: fillingCost,
              ),
              const SizedBox(height: 28),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('Custos extras',
                    style: Theme.of(context).textTheme.titleMedium),
                subtitle: const Text(
                    'Opcional — informe o total usado nesta produção.'),
                children: _extraLabels.entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: _extraCostControllers[entry.key],
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
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
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasAllPartCosts
                      ? 'Custo atual da produção: ${formatCurrency((totalCost * 100).round())}\n'
                          'Inclui calda, base, recheio e custos extras.'
                      : 'Selecione as três partes e suas quantidades para ver o custo.',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                  'O rendimento e o preço de venda serão definidos na próxima etapa.'),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56)),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar montagem'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipePartField extends StatelessWidget {
  const _RecipePartField({
    required this.label,
    required this.recipes,
    required this.selectedId,
    required this.quantityController,
    required this.onChanged,
    required this.onQuantityChanged,
    required this.cost,
  });

  final String label;
  final List<RecipeBase> recipes;
  final String? selectedId;
  final TextEditingController quantityController;
  final ValueChanged<String?> onChanged;
  final VoidCallback onQuantityChanged;
  final double? cost;

  RecipeBase? get _selected {
    for (final recipe in recipes) {
      if (recipe.id == selectedId) return recipe;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey(label),
          initialValue: selectedId,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: recipes
              .map((recipe) =>
                  DropdownMenuItem(value: recipe.id, child: Text(recipe.name)))
              .toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Selecione uma opção.' : null,
        ),
        if (selected != null) ...[
          const SizedBox(height: 10),
          TextFormField(
            controller: quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => onQuantityChanged(),
            decoration: InputDecoration(
              labelText: 'Quantidade usada',
              suffixText: selected.yieldUnit.symbol,
              border: const OutlineInputBorder(),
            ),
            validator: (value) => parsePositiveNumber(value ?? '') == null
                ? 'Informe a quantidade usada.'
                : null,
          ),
          if (cost != null) ...[
            const SizedBox(height: 6),
            Text(
                'Custo proporcional: ${formatCurrency((cost! * 100).round())}'),
          ],
        ],
      ],
    );
  }
}

class _FillingPartField extends StatelessWidget {
  const _FillingPartField({
    required this.fillings,
    required this.selectedId,
    required this.quantityController,
    required this.onChanged,
    required this.onQuantityChanged,
    required this.cost,
  });

  final List<Filling> fillings;
  final String? selectedId;
  final TextEditingController quantityController;
  final ValueChanged<String?> onChanged;
  final VoidCallback onQuantityChanged;
  final double? cost;

  Filling? get _selected {
    for (final filling in fillings) {
      if (filling.id == selectedId) return filling;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: selectedId,
          decoration: const InputDecoration(
            labelText: 'Recheio ou sabor',
            border: OutlineInputBorder(),
          ),
          items: fillings
              .map((filling) => DropdownMenuItem(
                  value: filling.id, child: Text(filling.name)))
              .toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Selecione uma opção.' : null,
        ),
        if (selected != null) ...[
          const SizedBox(height: 10),
          TextFormField(
            controller: quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => onQuantityChanged(),
            decoration: InputDecoration(
              labelText: 'Quantidade usada',
              suffixText: selected.yieldUnit.symbol,
              border: const OutlineInputBorder(),
            ),
            validator: (value) => parsePositiveNumber(value ?? '') == null
                ? 'Informe a quantidade usada.'
                : null,
          ),
          if (cost != null) ...[
            const SizedBox(height: 6),
            Text(
                'Custo proporcional: ${formatCurrency((cost! * 100).round())}'),
          ],
        ],
      ],
    );
  }
}
