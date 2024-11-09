import 'package:bala_baiana/entities/ingredient.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Bullet {
  final String id;
  final String candyName;
  final List<Ingredient> ingredients;
  double profit;
  double salePrice;
  double totalCost;

  Bullet({
    String? id,
    required this.candyName,
    required this.ingredients,
    required this.profit,
    required this.salePrice,
    required this.totalCost,
  }) : id = id ?? const Uuid().v4();

  Color get profitColor => profit <= 0 ? Colors.red : Colors.green;

  factory Bullet.fromMap(Map<String, dynamic> data) {
    return Bullet(
      id: data['idBala'],
      candyName: data['nomeBala'],
      salePrice: data['precoBala'],
      totalCost: data['custoBala'],
      profit: data['lucroBala'],
      ingredients: (data['ingredientes'] as List<dynamic>)
          .map((item) => Ingredient.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idBala': id,
      'nomeBala': candyName,
      'precoBala': salePrice,
      'custoBala': totalCost,
      'lucroBala': profit,
      'ingredientes': ingredients.map((e) => e.toMap()).toList(),
    };
  }
}
