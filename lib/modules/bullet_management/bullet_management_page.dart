import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class BulletManagementPage extends StatefulWidget {
  const BulletManagementPage({super.key});

  @override
  _BulletManagementPageState createState() => _BulletManagementPageState();
}

class _BulletManagementPageState extends State<BulletManagementPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<Map<String, dynamic>> _ingredients = [];
  double _totalCost = 0.0;
  double _salePrice = 0.0;

  void _addIngredient(String name, double cost) {
    setState(() {
      _ingredients.add({'name': name, 'cost': cost});
      _totalCost =
          _ingredients.fold(0, (sum, ingredient) => sum + ingredient['cost']);
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
      _totalCost =
          _ingredients.fold(0, (sum, ingredient) => sum + ingredient['cost']);
    });
  }

  double _calculateProfit() {
    return _salePrice - _totalCost;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bala Baiana'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilderTextField(
                name: 'candyName',
                decoration: const InputDecoration(
                  labelText: 'Nome da bala',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'salePrice',
                decoration: const InputDecoration(
                  labelText: 'Preço da bala',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    _salePrice = double.tryParse(value ?? '') ?? 0.0;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Ingredientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _ingredients.isEmpty
                  ? const Text('Sem ingredientes ainda.')
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _ingredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = _ingredients[index];
                          return Slidable(
                            key: ValueKey(ingredient['name']),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) =>
                                      _removeIngredient(index),
                                  backgroundColor: Colors.red,
                                  icon: Icons.delete,
                                  label: 'Remove',
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(ingredient['name']),
                              subtitle: Text(
                                'Custo: R\$ ${ingredient['cost'].toStringAsFixed(2)}',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final nameController = TextEditingController();
                  final costController = TextEditingController();
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Adicionar Ingrediente'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                                labelText: 'Nome do Ingrediente'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: costController,
                            decoration: const InputDecoration(
                                labelText: 'Custo', prefixText: 'R\$ '),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            final name = nameController.text;
                            final cost =
                                double.tryParse(costController.text) ?? 0.0;
                            if (name.isNotEmpty && cost > 0) {
                              _addIngredient(name, cost);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Adicionar Ingrediente'),
              ),
              const SizedBox(height: 16),
              Text(
                  'Total de custo do ingrediente: R\$ ${_totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Lucro: R\$ ${_calculateProfit().toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    final candyName = _formKey.currentState?.value['candyName'];
                    final salePrice = _salePrice;
                    final profit = _calculateProfit();
                    // You can handle the data here or navigate to a new page with this info.
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Resumo $candyName'),
                        content: Text(
                          'Preço de venda: R\$ ${salePrice.toStringAsFixed(2)}\n'
                          'Custo total dos ingredientes: R\$ ${_totalCost.toStringAsFixed(2)}\n'
                          'Lucro: R\$ ${profit.toStringAsFixed(2)}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('Salvar Bala'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
