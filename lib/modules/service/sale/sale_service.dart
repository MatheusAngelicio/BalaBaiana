import 'package:bala_baiana/entities/sale.dart';

abstract class SaleService {
  Future<void> saveSale({required Sale sale});
  Future<List<Sale>> getSales();
}
