class Ingredient {
  final String name;
  final double cost;

  Ingredient({required this.name, required this.cost});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cost': cost,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> data) {
    return Ingredient(
      name: data['name'],
      cost: data['cost'],
    );
  }
}
