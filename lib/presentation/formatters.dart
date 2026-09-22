import 'package:flutter/services.dart';

String formatCurrency(int cents) {
  final sign = cents < 0 ? '-' : '';
  final value = cents.abs();
  final whole = (value ~/ 100).toString();
  final groups = <String>[];

  for (var end = whole.length; end > 0; end -= 3) {
    final start = end - 3 < 0 ? 0 : end - 3;
    groups.add(whole.substring(start, end));
  }

  return '${sign}R\$ ${groups.reversed.join('.')},${(value % 100).toString().padLeft(2, '0')}';
}

String formatCurrencyInput(int cents) {
  final value = cents.abs();
  final whole = (value ~/ 100).toString();
  final groups = <String>[];

  for (var end = whole.length; end > 0; end -= 3) {
    final start = end - 3 < 0 ? 0 : end - 3;
    groups.add(whole.substring(start, end));
  }

  return '${groups.reversed.join('.')},${(value % 100).toString().padLeft(2, '0')}';
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();

    final cents = int.tryParse(digits);
    if (cents == null) return oldValue;

    final text = formatCurrencyInput(cents);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

String formatQuantity(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2).replaceAll('.', ',');
}

String formatUnitCost(double value) {
  final decimals = value < 0.01 ? 4 : 2;
  return 'R\$ ${value.toStringAsFixed(decimals).replaceAll('.', ',')}';
}

String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

int? parseCurrencyToCents(String value) {
  final cleaned = value.replaceAll(RegExp(r'[^0-9,.]'), '');
  if (cleaned.isEmpty) return null;
  final normalized = _normalizeNumber(cleaned);
  final parsed = double.tryParse(normalized);
  if (parsed == null || parsed <= 0) return null;
  return (parsed * 100).round();
}

double? parsePositiveNumber(String value) {
  final normalized = _normalizeNumber(value.trim());
  final parsed = double.tryParse(normalized);
  return parsed == null || parsed <= 0 ? null : parsed;
}

String _normalizeNumber(String value) {
  if (value.contains(',')) {
    return value.replaceAll('.', '').replaceAll(',', '.');
  }

  final parts = value.split('.');
  if (parts.length > 2 || (parts.length == 2 && parts.last.length == 3)) {
    return value.replaceAll('.', '');
  }
  return value;
}
