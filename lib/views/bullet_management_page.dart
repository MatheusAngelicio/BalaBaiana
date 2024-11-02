import 'package:bala_baiana/controllers/bullet_controller.dart';
import 'package:bala_baiana/widgets/add_ingredient_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class BulletManagementPage extends StatelessWidget {
  BulletManagementPage({super.key});

  final BulletManagementController controller =
      Get.put(BulletManagementController());

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
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo para nome da bala
              FormBuilderTextField(
                name: 'candyName',
                controller: controller.candyNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da bala',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Campo para preço de venda
              FormBuilderTextField(
                name: 'salePrice',
                controller: controller.salePriceController,
                decoration: const InputDecoration(
                  labelText: 'Preço da bala',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  controller.salePrice.value =
                      double.tryParse(value ?? '') ?? 0.0;
                },
              ),

              const SizedBox(height: 16),
              const Text('Ingredientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Lista de ingredientes
              Obx(
                () => controller.ingredients.isEmpty
                    ? const Text('Sem ingredientes ainda.')
                    : Expanded(
                        child: Scrollbar(
                          trackVisibility: true,
                          thumbVisibility: true,
                          child: ListView.builder(
                            itemCount: controller.ingredients.length,
                            itemBuilder: (context, index) {
                              final ingredient = controller.ingredients[index];
                              return Slidable(
                                key: ValueKey(ingredient.name),
                                endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) =>
                                          controller.removeIngredient(index),
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                      label: 'Remover',
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(ingredient.name),
                                  subtitle: Text(
                                    'Custo: R\$ ${ingredient.cost.toStringAsFixed(2)}',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddIngredientDialog(
                      onAddIngredient: (ingredient) {
                        controller.addIngredient(ingredient);
                      },
                    ),
                  );
                },
                child: const Text('Adicionar Ingrediente'),
              ),

              const SizedBox(height: 16),
              Obx(
                () => Text(
                  'Total de custo do ingrediente: R\$ ${controller.totalCost.value.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  'Lucro: R\$ ${controller.calculateProfit().toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (controller.formKey.currentState?.saveAndValidate() ??
                      false) {
                    final candyName = controller.candyNameController.text;
                    final salePrice = controller.salePrice.value;
                    final profit = controller.calculateProfit();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Resumo $candyName'),
                        content: Text(
                          'Preço de venda: R\$ ${salePrice.toStringAsFixed(2)}\n'
                          'Custo total dos ingredientes: R\$ ${controller.totalCost.value.toStringAsFixed(2)}\n'
                          'Lucro: R\$ ${profit.toStringAsFixed(2)}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Fechar'),
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
