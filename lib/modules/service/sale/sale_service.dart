import 'package:bala_baiana/core/failure.dart';
import 'package:bala_baiana/entities/sale.dart';
import 'package:dartz/dartz.dart';

abstract class SaleService {
  Future<Either<Failure, void>> saveSale({required Sale sale});
  Future<Either<Failure, List<Sale>>> getSales();
}
