class ProductionCostBreakdown {
  ProductionCostBreakdown({required this.recipeCostCents})
      : fixedCostCents = (recipeCostCents * 20 / 100).round() {
    if (recipeCostCents < 0) {
      throw ArgumentError.value(recipeCostCents, 'recipeCostCents');
    }
  }

  final int recipeCostCents;
  final int fixedCostCents;
  int get laborCostCents => recipeCostCents + fixedCostCents;
  int get targetProfitCents => laborCostCents;
  int get totalCostCents => recipeCostCents + fixedCostCents + laborCostCents;

  Map<String, int> toMap() => {
        'recipeCostCents': recipeCostCents,
        'fixedCostCents': fixedCostCents,
        'laborCostCents': laborCostCents,
        'targetProfitCents': targetProfitCents,
      };
}

class ProductionPricing {
  const ProductionPricing({
    required this.totalCostCents,
    required this.costPerUnitCents,
    required this.suggestedPriceCents,
    required this.profitPerUnitCents,
    required this.estimatedRevenueCents,
    required this.estimatedProfitCents,
  });

  final int totalCostCents;
  final int costPerUnitCents;
  final int suggestedPriceCents;
  final int profitPerUnitCents;
  final int estimatedRevenueCents;
  final int estimatedProfitCents;

  factory ProductionPricing.calculate({
    required int recipeCostCents,
    required int yieldUnits,
    required int packagingAndLabelPerUnitCents,
  }) {
    if (yieldUnits <= 0) {
      throw ArgumentError.value(yieldUnits, 'yieldUnits');
    }
    if (packagingAndLabelPerUnitCents < 0) {
      throw ArgumentError.value(
          packagingAndLabelPerUnitCents, 'packagingAndLabelPerUnitCents');
    }
    final breakdown = ProductionCostBreakdown(recipeCostCents: recipeCostCents);
    final totalCostCents =
        breakdown.totalCostCents + packagingAndLabelPerUnitCents * yieldUnits;
    final costPerUnit = (totalCostCents / yieldUnits).round();
    final suggestedPrice =
        ((totalCostCents + breakdown.targetProfitCents) / yieldUnits).round();
    final estimatedRevenue = suggestedPrice * yieldUnits;
    return ProductionPricing(
      totalCostCents: totalCostCents,
      costPerUnitCents: costPerUnit,
      suggestedPriceCents: suggestedPrice,
      profitPerUnitCents: suggestedPrice - costPerUnit,
      estimatedRevenueCents: estimatedRevenue,
      estimatedProfitCents: estimatedRevenue - totalCostCents,
    );
  }
}
