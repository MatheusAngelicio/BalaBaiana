class Ingredient {
  final String name;
  final double cost;

  Ingredient({required this.name, required this.cost});

  Map<String, dynamic> toMap() {
    return {
      'nome': name,
      'custo': cost,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> data) {
    return Ingredient(
      name: data['nome'],
      cost: data['custo'],
    );
  }
}
