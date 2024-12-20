import 'package:bala_baiana/entities/bullet.dart';
import 'package:bala_baiana/entities/ingredient.dart';
import 'package:bala_baiana/modules/service/bullet/bullet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class CreateBulletController extends GetxController {
  final BulletService _bulletService = Get.find<BulletService>();

  final formKey = GlobalKey<FormBuilderState>();
  final candyNameController = TextEditingController();

  final salePriceController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );

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

  // Ajuste para cálculo correto do lucro
  double calculateProfit() {
    return salePrice.value - totalCost.value;
  }

  void addIngredient(Ingredient ingredient) {
    ingredients.add(ingredient);
    updateTotalCost();
  }

  void updateTotalCost() {
    totalCost.value =
        ingredients.fold(0.0, (sum, ingredient) => sum + ingredient.cost);
  }

  void removeIngredient(int index) {
    ingredients.removeAt(index);
    updateTotalCost();
  }

  Future<void> saveBulletToFirestore() async {
    print('Tentando salvar a bala...');

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

      final result = await _bulletService.saveBullet(bulletData);

      result.fold(
        (error) {
          print('Erro ao salvar a bala: $error');
          Get.snackbar('Erro', 'Erro ao salvar a bala: $error');
        },
        (_) async {
          Get.back(result: true);
          Get.snackbar('Sucesso', '${bulletData.candyName} salva com sucesso!');
        },
      );

      isLoading.value = false;
    }
  }
}
