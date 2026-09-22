import 'package:flutter/material.dart';

import '../data/recipe_bases_repository.dart';
import '../domain/models/ingredient.dart';
import '../domain/models/purchase.dart';
import '../domain/models/recipe_base.dart';
import 'formatters.dart';

class RecipeBaseFormPage extends StatefulWidget {
  const RecipeBaseFormPage({
    required this.ingredients,
    required this.purchases,
    required this.recipeBasesRepository,
    super.key,
    this.recipe,
  });

  final List<Ingredient> ingredients;
  final List<Purchase> purchases;
  final RecipeBasesRepository recipeBasesRepository;
  final RecipeBase? recipe;

  @override
  State<RecipeBaseFormPage> createState() => _RecipeBaseFormPageState();
}

class _RecipeBaseFormPageState extends State<RecipeBaseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _yieldController;
  late RecipeBaseType _type;
  late MeasurementBase _yieldUnit;
  late List<RecipeIngredientUsage> _ingredientUsages;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    _nameController = TextEditingController(text: recipe?.name ?? '');
    _yieldController = TextEditingController(
      text: recipe == null ? '' : formatQuantity(recipe.yieldQuantity),
    );
    _type = recipe?.type ?? RecipeBaseType.syrup;
    _yieldUnit = recipe?.yieldUnit ?? MeasurementBase.gram;
    _ingredientUsages = List.of(recipe?.ingredients ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yieldController.dispose();
    super.dispose();
  }

  Future<void> _addIngredient() async {
    if (widget.ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Registre uma compra de ingrediente antes de criar a receita.'),
        ),
      );
      return;
    }

    final usage = await showModalBottomSheet<RecipeIngredientUsage>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RecipeIngredientSheet(
        ingredients: widget.ingredients,
        purchases: widget.purchases,
      ),
    );
    if (usage != null) setState(() => _ingredientUsages.add(usage));
  }

  Future<void> _editIngredient(int index) async {
    final usage = await showModalBottomSheet<RecipeIngredientUsage>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RecipeIngredientSheet(
        ingredients: widget.ingredients,
        purchases: widget.purchases,
        initialUsage: _ingredientUsages[index],
      ),
    );
    if (usage != null) setState(() => _ingredientUsages[index] = usage);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_ingredientUsages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um ingrediente.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.recipeBasesRepository.saveRecipeBase(
        RecipeBase(
          id: widget.recipe?.id ?? '',
          name: _nameController.text,
          type: _type,
          yieldQuantity: parsePositiveNumber(_yieldController.text)!,
          yieldUnit: _yieldUnit,
          ingredients: _ingredientUsages,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.recipe == null
              ? 'Receita criada.'
              : 'Receita atualizada.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar a receita.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredientsById = {
      for (final ingredient in widget.ingredients) ingredient.id: ingredient,
    };
    final purchasesById = {
      for (final purchase in widget.purchases) purchase.id: purchase,
    };
    var totalCost = 0.0;
    for (final usage in _ingredientUsages) {
      final purchase = purchasesById[usage.purchaseId];
      if (purchase != null) {
        totalCost += purchase.costPerBaseUnit * usage.quantityBase;
      }
    }
    final yieldQuantity = parsePositiveNumber(_yieldController.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null
            ? 'Nova receita-base'
            : 'Editar receita-base'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome da receita',
                  hintText: 'Ex.: Calda tradicional',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Informe o nome da receita.'
                    : null,
              ),
              const SizedBox(height: 16),
              SegmentedButton<RecipeBaseType>(
                segments: RecipeBaseType.values
                    .map(
                      (type) => ButtonSegment<RecipeBaseType>(
                        value: type,
                        label: Text(type.label),
                      ),
                    )
                    .toList(),
                selected: {_type},
                onSelectionChanged: (selected) {
                  setState(() => _type = selected.first);
                },
              ),
              const SizedBox(height: 28),
              Text('Ingredientes',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_ingredientUsages.isEmpty)
                const Text('Adicione os ingredientes usados nesta receita.')
              else
                ..._ingredientUsages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final usage = entry.value;
                  final ingredient = ingredientsById[usage.ingredientId];
                  final purchase = purchasesById[usage.purchaseId];
                  final name = ingredient?.name ?? 'Ingrediente não encontrado';
                  final unit = ingredient?.base.symbol ?? '';
                  final subtotal = purchase == null
                      ? 'Compra não encontrada'
                      : formatCurrency(
                          (purchase.costPerBaseUnit * usage.quantityBase * 100)
                              .round(),
                        );
                  return Card(
                    child: ListTile(
                      title: Text(name),
                      subtitle: Text(
                        '${formatQuantity(usage.quantityBase)} $unit • $subtotal',
                      ),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Editar ingrediente',
                            onPressed: () => _editIngredient(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Remover ingrediente',
                            onPressed: () {
                              setState(() => _ingredientUsages.removeAt(index));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar ingrediente'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 28),
              Text('Rendimento',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yieldController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Quantidade produzida',
                        hintText: 'Ex.: 1000',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          parsePositiveNumber(value ?? '') == null
                              ? 'Informe o rendimento.'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 130,
                    child: DropdownButtonFormField<MeasurementBase>(
                      initialValue: _yieldUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unidade',
                        border: OutlineInputBorder(),
                      ),
                      items: MeasurementBase.values
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit.symbol),
                            ),
                          )
                          .toList(),
                      onChanged: (unit) {
                        if (unit != null) setState(() => _yieldUnit = unit);
                      },
                    ),
                  ),
                ],
              ),
              if (_ingredientUsages.isNotEmpty && yieldQuantity != null) ...[
                const SizedBox(height: 16),
                _CostSummary(
                  totalCents: (totalCost * 100).round(),
                  costPerYield: totalCost / yieldQuantity,
                  yieldUnit: _yieldUnit,
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar receita-base'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CostSummary extends StatelessWidget {
  const _CostSummary({
    required this.totalCents,
    required this.costPerYield,
    required this.yieldUnit,
  });

  final int totalCents;
  final double costPerYield;
  final MeasurementBase yieldUnit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Custo total: ${formatCurrency(totalCents)}\n'
        'Custo proporcional: ${formatUnitCost(costPerYield)} por ${yieldUnit.symbol}',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

class RecipeIngredientSheet extends StatefulWidget {
  const RecipeIngredientSheet({
    required this.ingredients,
    required this.purchases,
    this.initialUsage,
    super.key,
  });

  final List<Ingredient> ingredients;
  final List<Purchase> purchases;
  final RecipeIngredientUsage? initialUsage;

  @override
  State<RecipeIngredientSheet> createState() => _RecipeIngredientSheetState();
}

class _RecipeIngredientSheetState extends State<RecipeIngredientSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  late String _ingredientId;
  String? _purchaseId;

  @override
  void initState() {
    super.initState();
    final initialUsage = widget.initialUsage;
    _ingredientId = initialUsage?.ingredientId ?? widget.ingredients.first.id;
    _purchaseId = initialUsage?.purchaseId;
    _quantityController.text =
        initialUsage == null ? '' : formatQuantity(initialUsage.quantityBase);
    if (_purchaseId == null) _selectLatestPurchase();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Ingredient get _ingredient => widget.ingredients.firstWhere(
        (ingredient) => ingredient.id == _ingredientId,
      );

  List<Purchase> get _ingredientPurchases => widget.purchases
      .where((purchase) => purchase.ingredientId == _ingredientId)
      .toList();

  void _selectLatestPurchase() {
    _purchaseId =
        _ingredientPurchases.isEmpty ? null : _ingredientPurchases.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final selectedPurchase = _purchaseId == null
        ? null
        : _ingredientPurchases
            .where((purchase) => purchase.id == _purchaseId)
            .firstOrNull;
    final quantity = parsePositiveNumber(_quantityController.text);
    final costPreview = selectedPurchase != null && quantity != null
        ? selectedPurchase.costPerBaseUnit * quantity
        : null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Adicionar ingrediente',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _ingredientId,
                decoration: const InputDecoration(
                  labelText: 'Ingrediente',
                  border: OutlineInputBorder(),
                ),
                items: widget.ingredients
                    .map(
                      (ingredient) => DropdownMenuItem(
                        value: ingredient.id,
                        child: Text(ingredient.name),
                      ),
                    )
                    .toList(),
                onChanged: (ingredientId) {
                  if (ingredientId == null) return;
                  setState(() {
                    _ingredientId = ingredientId;
                    _selectLatestPurchase();
                  });
                },
              ),
              const SizedBox(height: 12),
              if (_ingredientPurchases.isEmpty)
                const Text(
                    'Este ingrediente ainda não possui uma compra registrada.')
              else
                DropdownButtonFormField<String>(
                  key: ValueKey(_ingredientId),
                  initialValue: _purchaseId,
                  decoration: const InputDecoration(
                    labelText: 'Compra usada',
                    border: OutlineInputBorder(),
                  ),
                  items: _ingredientPurchases
                      .map(
                        (purchase) => DropdownMenuItem(
                          value: purchase.id,
                          child: Text(
                            '${formatQuantity(purchase.quantity)} ${purchase.unit.label} • ${formatCurrency(purchase.priceCents)} • ${formatDate(purchase.purchasedAt)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (purchaseId) {
                    setState(() => _purchaseId = purchaseId);
                  },
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Quantidade usada',
                  suffixText: _ingredient.base.symbol,
                  hintText: 'Ex.: 520',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => parsePositiveNumber(value ?? '') == null
                    ? 'Informe uma quantidade maior que zero.'
                    : null,
              ),
              if (costPreview != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Custo deste ingrediente: ${formatCurrency((costPreview * 100).round())}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _purchaseId == null
                    ? null
                    : () {
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        Navigator.of(context).pop(
                          RecipeIngredientUsage(
                            ingredientId: _ingredientId,
                            purchaseId: _purchaseId!,
                            quantityBase:
                                parsePositiveNumber(_quantityController.text)!,
                          ),
                        );
                      },
                child: const Text('Adicionar à receita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
