import 'package:bala_baiana/domain/models/purchase.dart';
import 'package:bala_baiana/presentation/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PurchaseUnit', () {
    test('converts kilograms to grams', () {
      expect(PurchaseUnit.kilogram.toBaseQuantity(5), 5000);
    });

    test('converts liters to milliliters', () {
      expect(PurchaseUnit.liter.toBaseQuantity(1.5), 1500);
    });
  });

  test('calculates proportional cost from the purchase base quantity', () {
    final purchase = Purchase(
      id: 'purchase-1',
      ingredientId: 'sugar',
      priceCents: 1800,
      quantity: 5,
      unit: PurchaseUnit.kilogram,
      quantityBase: 5000,
      purchasedAt: DateTime(2026, 9, 21),
    );

    expect(purchase.costPerBaseUnit * 520, closeTo(1.872, 0.0001));
  });

  test('accepts Brazilian decimal and thousand separators', () {
    expect(parseCurrencyToCents('1.250,50'), 125050);
    expect(parsePositiveNumber('1.000'), 1000);
    expect(parsePositiveNumber('1.5'), 1.5);
  });
}
