import 'ingredient.dart';

enum PurchaseUnit {
  kilogram,
  gram,
  liter,
  milliliter,
  unit;

  String get label => switch (this) {
        PurchaseUnit.kilogram => 'kg',
        PurchaseUnit.gram => 'g',
        PurchaseUnit.liter => 'L',
        PurchaseUnit.milliliter => 'ml',
        PurchaseUnit.unit => 'unidade',
      };

  MeasurementBase get base => switch (this) {
        PurchaseUnit.kilogram || PurchaseUnit.gram => MeasurementBase.gram,
        PurchaseUnit.liter ||
        PurchaseUnit.milliliter =>
          MeasurementBase.milliliter,
        PurchaseUnit.unit => MeasurementBase.unit,
      };

  double toBaseQuantity(double quantity) => switch (this) {
        PurchaseUnit.kilogram || PurchaseUnit.liter => quantity * 1000,
        PurchaseUnit.gram ||
        PurchaseUnit.milliliter ||
        PurchaseUnit.unit =>
          quantity,
      };

  static PurchaseUnit fromStorage(String value) => switch (value) {
        'kilogram' => PurchaseUnit.kilogram,
        'gram' => PurchaseUnit.gram,
        'liter' => PurchaseUnit.liter,
        'milliliter' => PurchaseUnit.milliliter,
        'unit' => PurchaseUnit.unit,
        _ => throw ArgumentError('Unidade de compra inválida: $value'),
      };
}

class Purchase {
  const Purchase({
    required this.id,
    required this.ingredientId,
    required this.priceCents,
    required this.quantity,
    required this.unit,
    required this.quantityBase,
    required this.purchasedAt,
  });

  final String id;
  final String ingredientId;
  final int priceCents;
  final double quantity;
  final PurchaseUnit unit;
  final double quantityBase;
  final DateTime purchasedAt;

  double get costPerBaseUnit => priceCents / quantityBase / 100;
}
