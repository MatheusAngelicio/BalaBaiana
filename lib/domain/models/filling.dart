import 'ingredient.dart';
import 'recipe_base.dart';

class Filling {
  const Filling({
    required this.id,
    required this.name,
    required this.yieldQuantity,
    required this.yieldUnit,
    required this.ingredients,
  });

  final String id;
  final String name;
  final double yieldQuantity;
  final MeasurementBase yieldUnit;
  final List<RecipeIngredientUsage> ingredients;
}
