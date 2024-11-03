import 'package:bala_baiana/entities/sale.dart';
import 'package:bala_baiana/modules/service/sale/sale_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaleServiceImpl extends SaleService {
  final CollectionReference _saleCollection =
      FirebaseFirestore.instance.collection('sales');

  @override
  Future<void> saveSale({required Sale sale}) async {
    final saleData = {
      'flavor': sale.flavor,
      'quantity': sale.quantity,
      'deliveryDate': sale.deliveryDate,
      'customerName': sale.customerName,
      'delivered': sale.delivered,
      'profitFromSale': sale.profitFromSale,
    };
    await _saleCollection.add(saleData);
  }

  @override
  Future<List<Sale>> getSales() async {
    final querySnapshot = await _saleCollection.get();
    return querySnapshot.docs.map((doc) {
      return Sale.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }
}
