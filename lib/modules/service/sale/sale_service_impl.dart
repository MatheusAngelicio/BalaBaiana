import 'package:bala_baiana/core/failure.dart';
import 'package:bala_baiana/entities/sale.dart';
import 'package:bala_baiana/modules/service/sale/sale_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class SaleServiceImpl extends SaleService {
  final CollectionReference _saleCollection =
      FirebaseFirestore.instance.collection('sales');

  @override
  Future<Either<Failure, void>> saveSale({required Sale sale}) async {
    try {
      final saleData = {
        'flavor': sale.flavor,
        'quantity': sale.quantity,
        'deliveryDate': sale.deliveryDate,
        'customerName': sale.customerName,
        'delivered': sale.delivered,
        'profitFromSale': sale.profitFromSale,
      };
      await _saleCollection.add(saleData);
      return Right(null);
    } catch (e) {
      return Left(Failure('Erro ao salvar a venda: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getSales() async {
    try {
      final querySnapshot = await _saleCollection.get();
      final salesList = querySnapshot.docs.map((doc) {
        return Sale.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      return Right(salesList);
    } catch (e) {
      return Left(Failure('Erro ao buscar vendas: $e'));
    }
  }
}
