import 'package:flutter/material.dart';

class AddIngredientDialog extends StatelessWidget {
  const AddIngredientDialog({super.key, required this.onAddIngredient});

  final void Function(String name, double cost) onAddIngredient;

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final costController = TextEditingController();

    return AlertDialog(
      title: const Text('Adicionar Ingrediente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nome do Ingrediente'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: costController,
            decoration:
                const InputDecoration(labelText: 'Custo', prefixText: 'R\$ '),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final name = nameController.text;
            final cost = double.tryParse(costController.text) ?? 0.0;
            if (name.isNotEmpty && cost > 0) {
              onAddIngredient(name, cost);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Por favor, insira um nome e um custo válidos.')),
              );
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
