class FinalizedProduction {
  const FinalizedProduction({
    required this.id,
    required this.name,
    required this.yieldUnits,
    required this.profitPercentage,
    required this.totalCostCents,
    required this.costPerUnitCents,
    required this.suggestedPriceCents,
    required this.profitPerUnitCents,
    required this.estimatedRevenueCents,
    required this.estimatedProfitCents,
    required this.finalizedAt,
  });

  final String id;
  final String name;
  final int yieldUnits;
  final double profitPercentage;
  final int totalCostCents;
  final int costPerUnitCents;
  final int suggestedPriceCents;
  final int profitPerUnitCents;
  final int estimatedRevenueCents;
  final int estimatedProfitCents;
  final DateTime finalizedAt;
}
