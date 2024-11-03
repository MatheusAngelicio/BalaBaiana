import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  String flavor;
  int quantity;
  DateTime deliveryDate;
  bool delivered;
  String customerName;

  Sale({
    required this.flavor,
    required this.quantity,
    required this.deliveryDate,
    this.delivered = false,
    required this.customerName,
  });

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      flavor: map['flavor'] as String,
      quantity: map['quantity'] as int,
      deliveryDate: (map['deliveryDate'] as Timestamp).toDate(),
      delivered: map['delivered'] as bool? ?? false,
      customerName: map['customerName'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'flavor': flavor,
      'quantity': quantity,
      'deliveryDate': deliveryDate,
      'delivered': delivered,
      'customerName': customerName,
    };
  }
}
