class CostDefaults {
  const CostDefaults({
    this.packagingCents = 0,
    this.labelCents = 0,
    this.laborCents = 0,
    this.fixedCents = 0,
  });

  final int packagingCents;
  final int labelCents;
  final int laborCents;
  final int fixedCents;

  Map<String, int> toMap() => {
        'packaging': packagingCents,
        'label': labelCents,
        'labor': laborCents,
        'fixed': fixedCents,
      };

  factory CostDefaults.fromMap(Map<String, dynamic>? map) {
    return CostDefaults(
      packagingCents: (map?['packaging'] as num?)?.toInt() ?? 0,
      labelCents: (map?['label'] as num?)?.toInt() ?? 0,
      laborCents: (map?['labor'] as num?)?.toInt() ?? 0,
      fixedCents: (map?['fixed'] as num?)?.toInt() ?? 0,
    );
  }
}
