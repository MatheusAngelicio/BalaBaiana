import 'package:bala_baiana/entities/bullet.dart';
import 'package:bala_baiana/entities/ingredient.dart';
import 'package:bala_baiana/modules/common/service/bullet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';

class BulletManagementController extends GetxController {
  final BulletService _bulletService = Get.find<BulletService>();

  final formKey = GlobalKey<FormBuilderState>();
  final candyNameController = TextEditingController();
  final salePriceController = TextEditingController();

  final isLoading = false.obs;

  final ingredients = <Ingredient>[].obs;
  final totalCost = 0.0.obs;
  final salePrice = 0.0.obs;

  @override
  void dispose() {
    candyNameController.dispose();
    salePriceController.dispose();
    super.dispose();
  }

  // Calcula o lucro
  double calculateProfit() {
    salePrice.value = double.tryParse(salePriceController.text) ?? 0.0;
    return salePrice.value - totalCost.value;
  }

  void addIngredient(Ingredient ingredient) {
    ingredients.add(ingredient);
    updateTotalCost();
  }

  // Atualiza o custo total
  void updateTotalCost() {
    totalCost.value =
        ingredients.fold(0.0, (sum, ingredient) => sum + ingredient.cost);
  }

  // Remove um ingrediente
  void removeIngredient(int index) {
    ingredients.removeAt(index);
    updateTotalCost();
  }

  Future<void> saveBulletToFirestore() async {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      isLoading.value = true;
      final candyName = candyNameController.text;
      final salePrice = this.salePrice.value;
      final profit = calculateProfit();

      final bulletData = Bullet(
        candyName: candyName,
        ingredients: ingredients,
        profit: profit,
        salePrice: salePrice,
        totalCost: totalCost.value,
      );

      try {
        await _bulletService.saveBullet(bulletData);
        Get.snackbar('Sucesso', 'Bala salva com sucesso!');
      } catch (e) {
        print(e);
        Get.snackbar('Erro', 'Erro ao salvar a bala: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }
}
