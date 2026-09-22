import 'package:flutter/material.dart';

import '../data/purchases_repository.dart';
import '../domain/models/ingredient.dart';
import '../domain/models/purchase.dart';
import 'formatters.dart';

class PurchaseHistoryPage extends StatelessWidget {
  // O repositório é injetado em tempo de execução, por isso este construtor não é const.
  // ignore: prefer_const_constructors_in_immutables
  PurchaseHistoryPage({
    required this.ingredient,
    required this.repository,
    super.key,
  });

  final Ingredient ingredient;
  final PurchasesRepository repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ingredient.name)),
      body: StreamBuilder<List<Purchase>>(
        stream: repository.watchPurchases(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final purchases = snapshot.data!
              .where((purchase) => purchase.ingredientId == ingredient.id)
              .toList();

          if (purchases.isEmpty) {
            return const Center(child: Text('Nenhuma compra encontrada.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: purchases.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final purchase = purchases[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  title: Text(
                    '${formatCurrency(purchase.priceCents)} • ${formatDate(purchase.purchasedAt)}',
                  ),
                  subtitle: Text(
                    '${formatQuantity(purchase.quantity)} ${purchase.unit.label}\n'
                    '${formatUnitCost(purchase.costPerBaseUnit)} por ${ingredient.base.symbol}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
