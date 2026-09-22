import 'package:flutter/material.dart';

import '../data/fillings_repository.dart';
import '../domain/models/filling.dart';
import '../domain/models/ingredient.dart';
import '../domain/models/purchase.dart';
import '../domain/models/recipe_base.dart';
import 'formatters.dart';
import 'recipe_base_form_page.dart';

class FillingFormPage extends StatefulWidget {
  const FillingFormPage({
    required this.ingredients,
    required this.purchases,
    required this.fillingsRepository,
    super.key,
    this.filling,
  });

  final List<Ingredient> ingredients;
  final List<Purchase> purchases;
  final FillingsRepository fillingsRepository;
  final Filling? filling;

  @override
  State<FillingFormPage> createState() => _FillingFormPageState();
}

class _FillingFormPageState extends State<FillingFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _yieldController;
  late MeasurementBase _yieldUnit;
  late List<RecipeIngredientUsage> _ingredientsUsed;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final filling = widget.filling;
    _nameController = TextEditingController(text: filling?.name ?? '');
    _yieldController = TextEditingController(
      text: filling == null ? '' : formatQuantity(filling.yieldQuantity),
    );
    _yieldUnit = filling?.yieldUnit ?? MeasurementBase.gram;
    _ingredientsUsed = List.of(filling?.ingredients ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yieldController.dispose();
    super.dispose();
  }

  Future<void> _showIngredientSheet({int? index}) async {
    if (widget.ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Registre uma compra de ingrediente antes de criar o recheio.'),
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
        initialUsage: index == null ? null : _ingredientsUsed[index],
      ),
    );
    if (usage == null) return;
    setState(() {
      if (index == null) {
        _ingredientsUsed.add(usage);
      } else {
        _ingredientsUsed[index] = usage;
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_ingredientsUsed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um ingrediente.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.fillingsRepository.saveFilling(
        Filling(
          id: widget.filling?.id ?? '',
          name: _nameController.text,
          yieldQuantity: parsePositiveNumber(_yieldController.text)!,
          yieldUnit: _yieldUnit,
          ingredients: _ingredientsUsed,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.filling == null
              ? 'Recheio criado.'
              : 'Recheio atualizado.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o recheio.')),
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
    final totalCost = _ingredientsUsed.fold(0.0, (total, usage) {
      final purchase = purchasesById[usage.purchaseId];
      return total + (purchase?.costPerBaseUnit ?? 0) * usage.quantityBase;
    });
    final yieldQuantity = parsePositiveNumber(_yieldController.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filling == null ? 'Novo recheio' : 'Editar recheio'),
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
                  labelText: 'Sabor ou recheio',
                  hintText: 'Ex.: Coco',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Informe o sabor ou recheio.'
                    : null,
              ),
              const SizedBox(height: 8),
              const Text('Exemplos: tradicional, coco, chocolate ou morango.'),
              const SizedBox(height: 28),
              Text('Ingredientes',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_ingredientsUsed.isEmpty)
                const Text('Adicione os ingredientes usados neste recheio.')
              else
                ..._ingredientsUsed.asMap().entries.map((entry) {
                  final index = entry.key;
                  final usage = entry.value;
                  final ingredient = ingredientsById[usage.ingredientId];
                  final purchase = purchasesById[usage.purchaseId];
                  final subtotal = purchase == null
                      ? 'Compra não encontrada'
                      : formatCurrency(
                          (purchase.costPerBaseUnit * usage.quantityBase * 100)
                              .round(),
                        );
                  return Card(
                    child: ListTile(
                      title: Text(
                          ingredient?.name ?? 'Ingrediente não encontrado'),
                      subtitle: Text(
                        '${formatQuantity(usage.quantityBase)} ${ingredient?.base.symbol ?? ''} • $subtotal',
                      ),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Editar ingrediente',
                            onPressed: () => _showIngredientSheet(index: index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Remover ingrediente',
                            onPressed: () => setState(
                              () => _ingredientsUsed.removeAt(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _showIngredientSheet,
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
                        hintText: 'Ex.: 500',
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
              if (_ingredientsUsed.isNotEmpty && yieldQuantity != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Custo total: ${formatCurrency((totalCost * 100).round())}\n'
                    'Custo proporcional: ${formatUnitCost(totalCost / yieldQuantity)} por ${_yieldUnit.symbol}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
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
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar recheio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
