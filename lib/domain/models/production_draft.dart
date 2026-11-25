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
    this.syrup,
    required this.base,
    this.filling,
  });

  final String id;
  final String name;
  final ProductionPartSelection? syrup;
  final ProductionPartSelection base;
  final ProductionPartSelection? filling;

  factory ProductionDraft.fromMap(String id, Map<String, dynamic> map) {
    return ProductionDraft(
      id: id,
      name: map['name'] as String,
      syrup: map['syrup'] == null
          ? null
          : ProductionPartSelection.fromMap(
              Map<String, dynamic>.from(map['syrup'] as Map)),
      base: ProductionPartSelection.fromMap(
          Map<String, dynamic>.from(map['base'] as Map)),
      filling: map['filling'] == null
          ? null
          : ProductionPartSelection.fromMap(
              Map<String, dynamic>.from(map['filling'] as Map)),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name.trim(),
        // Keep storage keys compatible with existing productions.
        'base': base.toMap(),
        'syrup': syrup?.toMap(),
        'filling': filling?.toMap(),
      };
}
