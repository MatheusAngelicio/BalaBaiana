class Sale {
  String flavor;
  int quantity;
  DateTime deliveryDate;
  bool delivered;
  String customerName; // Novo parâmetro

  Sale({
    required this.flavor,
    required this.quantity,
    required this.deliveryDate,
    this.delivered = false,
    required this.customerName, // Novo parâmetro obrigatório
  });
}
