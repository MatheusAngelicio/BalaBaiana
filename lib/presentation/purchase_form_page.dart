import 'package:flutter/material.dart';

import '../data/purchases_repository.dart';
import '../domain/models/ingredient.dart';
import '../domain/models/purchase.dart';
import 'formatters.dart';

class PurchaseFormPage extends StatefulWidget {
  const PurchaseFormPage({
    required this.ingredients,
    required this.repository,
    super.key,
  });

  final List<Ingredient> ingredients;
  final PurchasesRepository repository;

  @override
  State<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends State<PurchaseFormPage> {
  static const _newIngredientValue = '__new_ingredient__';

  final _formKey = GlobalKey<FormState>();
  final _ingredientNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  String _ingredientChoice = _newIngredientValue;
  MeasurementBase _newIngredientBase = MeasurementBase.gram;
  PurchaseUnit _purchaseUnit = PurchaseUnit.gram;
  DateTime _purchaseDate = DateTime.now();
  bool _isSaving = false;

  bool get _isNewIngredient => _ingredientChoice == _newIngredientValue;

  Ingredient? get _selectedIngredient {
    for (final ingredient in widget.ingredients) {
      if (ingredient.id == _ingredientChoice) return ingredient;
    }
    return null;
  }

  MeasurementBase get _base => _selectedIngredient?.base ?? _newIngredientBase;

  List<PurchaseUnit> get _availableUnits =>
      PurchaseUnit.values.where((unit) => unit.base == _base).toList();

  @override
  void dispose() {
    _ingredientNameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Data da compra',
    );
    if (selected != null) setState(() => _purchaseDate = selected);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final priceCents = parseCurrencyToCents(_priceController.text)!;
    final quantity = parsePositiveNumber(_quantityController.text)!;
    setState(() => _isSaving = true);

    try {
      final ingredientId = _isNewIngredient
          ? await widget.repository.addIngredient(
              name: _ingredientNameController.text,
              base: _newIngredientBase,
            )
          : _selectedIngredient!.id;

      await widget.repository.addPurchase(
        ingredientId: ingredientId,
        priceCents: priceCents,
        quantity: quantity,
        unit: _purchaseUnit,
        purchasedAt: _purchaseDate,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra registrada com sucesso.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar a compra. Tente novamente.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewPriceCents = parseCurrencyToCents(_priceController.text);
    final previewQuantity = parsePositiveNumber(_quantityController.text);
    final unitCostPreview = previewPriceCents != null && previewQuantity != null
        ? previewPriceCents /
            _purchaseUnit.toBaseQuantity(previewQuantity) /
            100
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar compra')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Ingrediente',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _ingredientChoice,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(
                    value: _newIngredientValue,
                    child: Text('+ Cadastrar novo ingrediente'),
                  ),
                  ...widget.ingredients.map(
                    (ingredient) => DropdownMenuItem(
                      value: ingredient.id,
                      child: Text(ingredient.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _ingredientChoice = value;
                    _purchaseUnit = _availableUnits.first;
                  });
                },
              ),
              if (_isNewIngredient) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ingredientNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome do ingrediente',
                    hintText: 'Ex.: Açúcar',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final name = value?.trim() ?? '';
                    if (name.isEmpty) return 'Informe o nome do ingrediente.';
                    final duplicate = widget.ingredients.any(
                      (ingredient) =>
                          ingredient.name.toLowerCase() == name.toLowerCase(),
                    );
                    return duplicate
                        ? 'Este ingrediente já existe. Selecione-o na lista.'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MeasurementBase>(
                  initialValue: _newIngredientBase,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de medida',
                    border: OutlineInputBorder(),
                  ),
                  items: MeasurementBase.values
                      .map(
                        (base) => DropdownMenuItem(
                          value: base,
                          child: Text(base.label),
                        ),
                      )
                      .toList(),
                  onChanged: (base) {
                    if (base == null) return;
                    setState(() {
                      _newIngredientBase = base;
                      _purchaseUnit = _availableUnits.first;
                    });
                  },
                ),
              ],
              const SizedBox(height: 28),
              Text(
                'Dados da compra',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [CurrencyInputFormatter()],
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Preço total pago',
                  hintText: 'Ex.: 18,00',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => parseCurrencyToCents(value ?? '') == null
                    ? 'Informe um preço maior que zero.'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        hintText: 'Ex.: 5',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          parsePositiveNumber(value ?? '') == null
                              ? 'Informe uma quantidade maior que zero.'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 116,
                    child: DropdownButtonFormField<PurchaseUnit>(
                      key: ValueKey(_base),
                      initialValue: _purchaseUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unidade',
                        border: OutlineInputBorder(),
                      ),
                      items: _availableUnits
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit.label),
                            ),
                          )
                          .toList(),
                      onChanged: (unit) {
                        if (unit != null) setState(() => _purchaseUnit = unit);
                      },
                    ),
                  ),
                ],
              ),
              if (unitCostPreview != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Custo calculado: ${formatUnitCost(unitCostPreview)} por ${_base.symbol}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('Data da compra: ${formatDate(_purchaseDate)}'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar compra'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
