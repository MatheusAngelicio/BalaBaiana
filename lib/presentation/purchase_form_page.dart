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
  final _formKey = GlobalKey<FormState>();
  final _ingredientNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  PurchaseUnit _purchaseUnit = PurchaseUnit.gram;
  DateTime _purchaseDate = DateTime.now();
  bool _isSaving = false;

  Ingredient? get _existingIngredient {
    final name = _ingredientNameController.text.trim().toLowerCase();
    if (name.isEmpty) return null;
    for (final ingredient in widget.ingredients) {
      if (ingredient.name.toLowerCase() == name) return ingredient;
    }
    return null;
  }

  MeasurementBase get _base => _existingIngredient?.base ?? _purchaseUnit.base;

  List<PurchaseUnit> get _availableUnits {
    final existingIngredient = _existingIngredient;
    if (existingIngredient == null) return PurchaseUnit.values;
    return PurchaseUnit.values
        .where((unit) => unit.base == existingIngredient.base)
        .toList();
  }

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
      final existingIngredient = _existingIngredient;
      final ingredientId = existingIngredient == null
          ? await widget.repository.addIngredient(
              name: _ingredientNameController.text,
              base: _purchaseUnit.base,
            )
          : existingIngredient.id;

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

  void _onIngredientNameChanged(String _) {
    setState(() {
      if (!_availableUnits.contains(_purchaseUnit)) {
        _purchaseUnit = _availableUnits.first;
      }
    });
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
              TextFormField(
                controller: _ingredientNameController,
                textCapitalization: TextCapitalization.words,
                onChanged: _onIngredientNameChanged,
                decoration: const InputDecoration(
                  labelText: 'Nome do ingrediente',
                  hintText: 'Ex.: Açúcar',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Informe o nome do ingrediente.'
                    : null,
              ),
              if (_existingIngredient != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Este ingrediente já foi registrado neste ciclo. A nova compra será adicionada a ele.',
                        ),
                      ),
                    ],
                  ),
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
                    width: 132,
                    child: DropdownButtonFormField<PurchaseUnit>(
                      key: ValueKey(_base),
                      initialValue: _purchaseUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unidade da compra',
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
              const SizedBox(height: 8),
              Text(
                _existingIngredient == null
                    ? 'A unidade escolhida definirá como este ingrediente será usado nas receitas.'
                    : 'Este ingrediente é usado em ${_base.label} nas receitas.',
                style: Theme.of(context).textTheme.bodySmall,
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
