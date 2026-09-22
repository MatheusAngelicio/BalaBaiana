import 'package:bala_baiana/domain/services/production_pricing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds the desired profit percentage to the unit cost', () {
    final pricing = ProductionPricing.calculate(
      totalCostCents: 1000,
      yieldUnits: 10,
      profitPercentage: 100,
    );

    expect(pricing.costPerUnitCents, 100);
    expect(pricing.suggestedPriceCents, 200);
    expect(pricing.profitPerUnitCents, 100);
    expect(pricing.estimatedRevenueCents, 2000);
    expect(pricing.estimatedProfitCents, 1000);
  });
}
