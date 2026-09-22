import 'package:bala_baiana/domain/models/ingredient.dart';
import 'package:bala_baiana/domain/models/purchase.dart';
import 'package:bala_baiana/domain/models/recipe_base.dart';
import 'package:bala_baiana/domain/services/cost_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates the proportional cost of a recipe base', () {
    final purchase = Purchase(
      id: 'sugar-purchase',
      ingredientId: 'sugar',
      priceCents: 1800,
      quantity: 5,
      unit: PurchaseUnit.kilogram,
      quantityBase: 5000,
      purchasedAt: DateTime(2026, 9, 21),
    );
    const syrup = RecipeBase(
      id: 'syrup',
      name: 'Calda',
      type: RecipeBaseType.syrup,
      yieldQuantity: 1000,
      yieldUnit: MeasurementBase.gram,
      ingredients: [
        RecipeIngredientUsage(
          ingredientId: 'sugar',
          purchaseId: 'sugar-purchase',
          quantityBase: 520,
        ),
      ],
    );

    final cost = CostCalculator.recipeBaseProportionalCost(
      recipe: syrup,
      quantityUsed: 300,
      purchasesById: {purchase.id: purchase},
    );

    expect(cost, closeTo(0.5616, 0.0001));
  });
}
