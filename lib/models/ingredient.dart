class Ingredient {
  final String name;
  final double cost;

  Ingredient({required this.name, required this.cost});

  // Método para converter Ingredient em um Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cost': cost,
    };
  }
}
