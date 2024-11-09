import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Sale {
  final String id;
  String flavor;
  int quantity;
  DateTime deliveryDate;
  bool delivered;
  String customerName;
  double profitFromSale;

  Sale({
    String? id,
    required this.flavor,
    required this.quantity,
    required this.deliveryDate,
    this.delivered = false,
    required this.customerName,
    required this.profitFromSale,
  }) : id = id ?? const Uuid().v4();

  factory Sale.fromMap(Map<String, dynamic> data) {
    return Sale(
      id: data['idVenda'],
      flavor: data['sabor'],
      quantity: data['quantidade'],
      deliveryDate: (data['dataPedido'] as Timestamp).toDate(),
      delivered: data['entregue'] as bool? ?? false,
      customerName: data['nomeCliente'],
      profitFromSale: data['lucroDaVenda'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idVenda': id,
      'sabor': flavor,
      'quantidade': quantity,
      'dataPedido': deliveryDate,
      'entregue': delivered,
      'nomeCliente': customerName,
      'lucroDaVenda': profitFromSale,
    };
  }
}
