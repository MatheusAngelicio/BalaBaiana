import 'package:bala_baiana/presentation/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final formatter = CurrencyInputFormatter();

  test('formats typed digits as Brazilian reais', () {
    final result = formatter.formatEditUpdate(
      const TextEditingValue(),
      const TextEditingValue(text: '1599'),
    );

    expect(result.text, '15,99');
    expect(result.selection.baseOffset, 5);
  });

  test('accepts a pasted value with Brazilian separators', () {
    final result = formatter.formatEditUpdate(
      const TextEditingValue(),
      const TextEditingValue(text: '1.250,50'),
    );

    expect(result.text, '1.250,50');
    expect(parseCurrencyToCents(result.text), 125050);
  });
}
