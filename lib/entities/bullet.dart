import 'dart:ui';

import 'package:bala_baiana/entities/ingredient.dart';
import 'package:flutter/material.dart';

class Bullet {
  final String candyName;
  final List<Ingredient> ingredients;
  double profit;
  double salePrice;
  double totalCost;

  Bullet({
    required this.candyName,
    required this.ingredients,
    required this.profit,
    required this.salePrice,
    required this.totalCost,
  });

  Color get profitColor => profit <= 0 ? Colors.red : Colors.green;

  factory Bullet.fromMap(Map<String, dynamic> data) {
    return Bullet(
      candyName: data['candyName'],
      salePrice: data['salePrice'],
      totalCost: data['totalCost'],
      profit: data['profit'],
      ingredients: (data['ingredients'] as List<dynamic>)
          .map((item) => Ingredient.fromMap(item))
          .toList(),
    );
  }
}
