import 'package:bala_baiana/entities/ingredient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class AddIngredientDialog extends StatelessWidget {
  const AddIngredientDialog({super.key, required this.onAddIngredient});

  final void Function(Ingredient) onAddIngredient;

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final costController = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      decimalSeparator: ',',
      thousandSeparator: '.',
    );

    return AlertDialog(
      backgroundColor: Colors.pink[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        'Adicionar Ingrediente',
        style: TextStyle(
          color: Colors.pinkAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Nome do Ingrediente',
              labelStyle: const TextStyle(color: Colors.pinkAccent),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.pinkAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.pink[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: costController,
            decoration: InputDecoration(
              labelText: 'Custo',
              labelStyle: const TextStyle(color: Colors.pinkAccent),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.pinkAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.pink[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.pinkAccent,
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text;
            final cost = costController.numberValue;
            if (name.isNotEmpty && cost > 0) {
              onAddIngredient(Ingredient(name: name, cost: cost));
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Por favor, insira um nome e um custo válidos.',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.pinkAccent,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
