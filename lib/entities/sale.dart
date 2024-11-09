import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  String flavor;
  int quantity;
  DateTime deliveryDate;
  bool delivered;
  String customerName;
  double profitFromSale;

  Sale({
    required this.flavor,
    required this.quantity,
    required this.deliveryDate,
    this.delivered = false,
    required this.customerName,
    required this.profitFromSale,
  });

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      flavor: map['sabor'] as String,
      quantity: map['quantidade'] as int,
      deliveryDate: (map['dataPedido'] as Timestamp).toDate(),
      delivered: map['entregue'] as bool? ?? false,
      customerName: map['nomeCliente'] as String,
      profitFromSale: map['lucroDaVenda'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sabor': flavor,
      'quantidade': quantity,
      'dataPedido': deliveryDate,
      'entregue': delivered,
      'nomeCliente': customerName,
      'lucroDaVenda': profitFromSale,
    };
  }
}
