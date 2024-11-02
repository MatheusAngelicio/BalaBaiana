import 'package:bala_baiana/models/ingredient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';

class BulletManagementController extends GetxController {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  void onClose() {
    candyNameController.dispose();
    salePriceController.dispose();
    super.onClose();
  }

  // Controllers para os campos de formulário
  final candyNameController = TextEditingController();
  final salePriceController = TextEditingController();

  // Lista de ingredientes
  final ingredients = <Ingredient>[].obs;
  final totalCost = 0.0.obs;
  final salePrice = 0.0.obs;

  // Adiciona um ingrediente
  void addIngredient(String name, double cost) {
    ingredients.add(Ingredient(name: name, cost: cost));
    updateTotalCost();
  }

  // Remove um ingrediente
  void removeIngredient(int index) {
    ingredients.removeAt(index);
    updateTotalCost();
  }

  // Atualiza o custo total
  void updateTotalCost() {
    totalCost.value =
        ingredients.fold(0.0, (sum, ingredient) => sum + ingredient.cost);
  }

  // Calcula o lucro
  double calculateProfit() {
    salePrice.value = double.tryParse(salePriceController.text) ?? 0.0;
    return salePrice.value - totalCost.value;
  }
}
