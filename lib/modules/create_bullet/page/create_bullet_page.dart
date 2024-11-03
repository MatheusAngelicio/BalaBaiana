import 'package:bala_baiana/modules/create_bullet/controller/bullet_controller.dart';
import 'package:bala_baiana/modules/create_bullet/widgets/add_ingredient_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CreateBulletPage extends StatelessWidget {
  CreateBulletPage({super.key});

  final BulletManagementController controller =
      Get.put(BulletManagementController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text('Bala Baiana', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilderTextField(
                name: 'candyName',
                controller: controller.candyNameController,
                decoration: InputDecoration(
                  labelText: 'Nome da bala',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(FontAwesomeIcons.candyCane,
                      color: Colors.pinkAccent),
                ),
              ),
              const SizedBox(height: 16),
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
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent)),
              const SizedBox(height: 8),
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
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent),
                child: const Text(
                  'Adicionar Ingrediente',
                  style: TextStyle(color: Colors.white),
                ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.saveBulletToFirestore(),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Salvar Bala',
                        style: TextStyle(color: Colors.white),
                      ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
