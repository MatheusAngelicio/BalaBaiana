enum MeasurementBase {
  gram,
  milliliter,
  unit;

  String get label => switch (this) {
        MeasurementBase.gram => 'gramas',
        MeasurementBase.milliliter => 'ml',
        MeasurementBase.unit => 'unidades',
      };

  String get symbol => switch (this) {
        MeasurementBase.gram => 'g',
        MeasurementBase.milliliter => 'ml',
        MeasurementBase.unit => 'un',
      };

  static MeasurementBase fromStorage(String value) => switch (value) {
        'gram' => MeasurementBase.gram,
        'milliliter' => MeasurementBase.milliliter,
        'unit' => MeasurementBase.unit,
        _ => throw ArgumentError('Unidade-base inválida: $value'),
      };
}

class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.base,
  });

  final String id;
  final String name;
  final MeasurementBase base;
}
