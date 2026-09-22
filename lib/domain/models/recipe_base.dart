import 'ingredient.dart';

enum RecipeBaseType {
  syrup,
  base;

  String get label => switch (this) {
        RecipeBaseType.syrup => 'Calda',
        RecipeBaseType.base => 'Base',
      };

  static RecipeBaseType fromStorage(String value) => switch (value) {
        'syrup' => RecipeBaseType.syrup,
        'base' => RecipeBaseType.base,
        _ => throw ArgumentError('Tipo de receita-base inválido: $value'),
      };
}

class RecipeIngredientUsage {
  const RecipeIngredientUsage({
    required this.ingredientId,
    required this.purchaseId,
    required this.quantityBase,
  });

  final String ingredientId;
  final String purchaseId;
  final double quantityBase;

  Map<String, dynamic> toMap() => {
        'ingredientId': ingredientId,
        'purchaseId': purchaseId,
        'quantityBase': quantityBase,
      };

  factory RecipeIngredientUsage.fromMap(Map<String, dynamic> map) {
    return RecipeIngredientUsage(
      ingredientId: map['ingredientId'] as String,
      purchaseId: map['purchaseId'] as String,
      quantityBase: (map['quantityBase'] as num).toDouble(),
    );
  }
}

class RecipeBase {
  const RecipeBase({
    required this.id,
    required this.name,
    required this.type,
    required this.yieldQuantity,
    required this.yieldUnit,
    required this.ingredients,
  });

  final String id;
  final String name;
  final RecipeBaseType type;
  final double yieldQuantity;
  final MeasurementBase yieldUnit;
  final List<RecipeIngredientUsage> ingredients;
}
