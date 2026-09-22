class ProductionPartSelection {
  const ProductionPartSelection({
    required this.recipeId,
    required this.quantityUsed,
  });

  final String recipeId;
  final double quantityUsed;

  Map<String, dynamic> toMap() => {
        'recipeId': recipeId,
        'quantityUsed': quantityUsed,
      };

  factory ProductionPartSelection.fromMap(Map<String, dynamic> map) {
    return ProductionPartSelection(
      recipeId: map['recipeId'] as String,
      quantityUsed: (map['quantityUsed'] as num).toDouble(),
    );
  }
}

class ProductionDraft {
  const ProductionDraft({
    required this.id,
    required this.name,
    required this.syrup,
    required this.base,
    required this.filling,
    required this.extraCostsCents,
  });

  final String id;
  final String name;
  final ProductionPartSelection syrup;
  final ProductionPartSelection base;
  final ProductionPartSelection filling;
  final Map<String, int> extraCostsCents;
}
