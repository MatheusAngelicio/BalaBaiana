import 'package:bala_baiana/domain/models/cost_defaults.dart';
import 'package:bala_baiana/domain/services/production_pricing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates fixed cost, labor and profit from the recipe', () {
    final breakdown = ProductionCostBreakdown(recipeCostCents: 10000);
    expect(breakdown.fixedCostCents, 2000);
    expect(breakdown.laborCostCents, 12000);
    expect(breakdown.targetProfitCents, 12000);
    expect(breakdown.totalCostCents, 24000);

    final pricing = ProductionPricing.calculate(
      recipeCostCents: 10000,
      yieldUnits: 100,
      packagingAndLabelPerUnitCents: 50,
    );
    expect(pricing.totalCostCents, 29000);
    expect(pricing.costPerUnitCents, 290);
    expect(pricing.suggestedPriceCents, 410);
    expect(pricing.profitPerUnitCents, 120);
    expect(pricing.estimatedRevenueCents, 41000);
    expect(pricing.estimatedProfitCents, 12000);
  });

  test('packaging changes costs and price without increasing target profit',
      () {
    final pricing = ProductionPricing.calculate(
      recipeCostCents: 10000,
      yieldUnits: 100,
      packagingAndLabelPerUnitCents: 0,
    );
    expect(pricing.totalCostCents, 24000);
    expect(pricing.suggestedPriceCents, 360);
    expect(pricing.estimatedProfitCents, 12000);
  });

  test('rounds cents and keeps estimated revenue and profit consistent', () {
    final breakdown = ProductionCostBreakdown(recipeCostCents: 1001);
    expect(breakdown.fixedCostCents, 200);
    expect(breakdown.laborCostCents, 1201);
    final pricing = ProductionPricing.calculate(
      recipeCostCents: 1001,
      yieldUnits: 7,
      packagingAndLabelPerUnitCents: 13,
    );
    expect(pricing.totalCostCents, 2493);
    expect(pricing.suggestedPriceCents, 528);
    expect(pricing.estimatedRevenueCents, 3696);
    expect(pricing.estimatedProfitCents, 1203);
  });

  test('rejects zero and negative yield', () {
    for (final yieldUnits in [0, -1]) {
      expect(
          () => ProductionPricing.calculate(
                recipeCostCents: 1000,
                yieldUnits: yieldUnits,
                packagingAndLabelPerUnitCents: 0,
              ),
          throwsArgumentError);
    }
  });

  test('combines legacy packaging and label defaults and ignores manual rates',
      () {
    final defaults = CostDefaults.fromMap({
      'packaging': 20,
      'label': 10,
      'fixed': 900,
      'labor': 800,
    });
    expect(defaults.packagingAndLabelCents, 30);
    expect(defaults.toMap(), {'packagingAndLabel': 30});
    expect(
        CostDefaults.fromMap({
          ...defaults.toMap(),
          'packagingAndLabel': 0,
          'packaging': 20,
          'label': 10,
        }).packagingAndLabelCents,
        0);
    expect(CostDefaults.fromMap(null).packagingAndLabelCents, 0);
  });
}
