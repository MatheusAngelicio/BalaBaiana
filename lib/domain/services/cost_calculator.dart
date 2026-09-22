import '../models/filling.dart';
import '../models/purchase.dart';
import '../models/recipe_base.dart';

class CostCalculator {
  const CostCalculator._();

  static double? recipeBaseTotalCost(
    RecipeBase recipe,
    Map<String, Purchase> purchasesById,
  ) {
    return _ingredientsCost(recipe.ingredients, purchasesById);
  }

  static double? fillingTotalCost(
    Filling filling,
    Map<String, Purchase> purchasesById,
  ) {
    return _ingredientsCost(filling.ingredients, purchasesById);
  }

  static double? recipeBaseProportionalCost({
    required RecipeBase recipe,
    required double quantityUsed,
    required Map<String, Purchase> purchasesById,
  }) {
    final total = recipeBaseTotalCost(recipe, purchasesById);
    return total == null ? null : total / recipe.yieldQuantity * quantityUsed;
  }

  static double? fillingProportionalCost({
    required Filling filling,
    required double quantityUsed,
    required Map<String, Purchase> purchasesById,
  }) {
    final total = fillingTotalCost(filling, purchasesById);
    return total == null ? null : total / filling.yieldQuantity * quantityUsed;
  }

  static double? _ingredientsCost(
    List<RecipeIngredientUsage> ingredients,
    Map<String, Purchase> purchasesById,
  ) {
    var total = 0.0;
    for (final ingredient in ingredients) {
      final purchase = purchasesById[ingredient.purchaseId];
      if (purchase == null) return null;
      total += purchase.costPerBaseUnit * ingredient.quantityBase;
    }
    return total;
  }
}
