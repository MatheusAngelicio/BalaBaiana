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
    required int totalCostCents,
    required int yieldUnits,
    required double profitPercentage,
  }) {
    final costPerUnit = (totalCostCents / yieldUnits).round();
    final suggestedPrice = (costPerUnit * (1 + profitPercentage / 100)).round();
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
