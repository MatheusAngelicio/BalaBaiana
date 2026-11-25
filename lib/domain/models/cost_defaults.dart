class CostDefaults {
  const CostDefaults({this.packagingAndLabelCents = 0});

  final int packagingAndLabelCents;

  Map<String, int> toMap() => {
        'packagingAndLabel': packagingAndLabelCents,
      };

  factory CostDefaults.fromMap(Map<String, dynamic>? map) {
    return CostDefaults(
      packagingAndLabelCents: (map?['packagingAndLabel'] as num?)?.toInt() ??
          ((map?['packaging'] as num?)?.toInt() ?? 0) +
              ((map?['label'] as num?)?.toInt() ?? 0),
    );
  }
}
