import 'package:flutter/material.dart';

import '../data/purchases_repository.dart';
import '../domain/models/ingredient.dart';
import '../domain/models/purchase.dart';
import 'design_system.dart';
import 'formatters.dart';
import 'purchase_form_page.dart';
import 'purchase_history_page.dart';

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key, this.repository});

  final PurchasesRepository? repository;

  @override
  Widget build(BuildContext context) {
    final purchasesRepository = repository ?? PurchasesRepository();

    return StreamBuilder<List<Ingredient>>(
      stream: purchasesRepository.watchIngredients(),
      builder: (context, ingredientSnapshot) {
        if (ingredientSnapshot.hasError) {
          return _LoadError(
              onRetry: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                        builder: (_) => const PurchasesPage()),
                  ));
        }

        if (!ingredientSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<List<Purchase>>(
          stream: purchasesRepository.watchPurchases(),
          builder: (context, purchaseSnapshot) {
            if (purchaseSnapshot.hasError) {
              return const _LoadError();
            }

            if (!purchaseSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return _PurchasesContent(
              ingredients: ingredientSnapshot.data!,
              purchases: purchaseSnapshot.data!,
              repository: purchasesRepository,
            );
          },
        );
      },
    );
  }
}

class _PurchasesContent extends StatelessWidget {
  const _PurchasesContent({
    required this.ingredients,
    required this.purchases,
    required this.repository,
  });

  final List<Ingredient> ingredients;
  final List<Purchase> purchases;
  final PurchasesRepository repository;

  void _openNewPurchase(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PurchaseFormPage(
          ingredients: ingredients,
          repository: repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return _EmptyPurchases(onAdd: () => _openNewPurchase(context));
    }

    final latestPurchaseByIngredient = <String, Purchase>{};
    for (final purchase in purchases) {
      latestPurchaseByIngredient.putIfAbsent(
          purchase.ingredientId, () => purchase);
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            children: [
              const SectionHero(
                palette: SectionColors.purchases,
                title: 'Compras de ingredientes',
                subtitle: 'Acompanhe preços e o histórico de cada item.',
              ),
              const SizedBox(height: 24),
              const SectionLabel(
                label: 'Ingredientes cadastrados',
                color: Color(0xFF3C8061),
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 12),
              ...ingredients.map((ingredient) {
                final purchase = latestPurchaseByIngredient[ingredient.id];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: SectionColors.purchases.soft,
                        foregroundColor: SectionColors.purchases.end,
                        child: const Icon(Icons.shopping_basket_outlined),
                      ),
                      title: Text(ingredient.name),
                      subtitle: purchase == null
                          ? const Text('Nenhuma compra registrada ainda')
                          : Text(
                              'Última: ${formatQuantity(purchase.quantity)} ${purchase.unit.label} por ${formatCurrency(purchase.priceCents)}\n'
                              '${formatUnitCost(purchase.costPerBaseUnit)} por ${ingredient.base.symbol} • ${formatDate(purchase.purchasedAt)}',
                            ),
                      isThreeLine: purchase != null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PurchaseHistoryPage(
                            ingredient: ingredient,
                            repository: repository,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed: () => _openNewPurchase(context),
            icon: const Icon(Icons.add),
            label: const Text('Registrar compra'),
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          ),
        ),
      ],
    );
  }
}

class _EmptyPurchases extends StatelessWidget {
  const _EmptyPurchases({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 60, color: SectionColors.purchases.start),
            const SizedBox(height: 18),
            Text('Nenhuma compra registrada',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Comece registrando um ingrediente comprado no mercado.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Registrar primeira compra'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 16),
            const Text('Não foi possível carregar as compras.',
                textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: onRetry, child: const Text('Tentar novamente')),
            ],
          ],
        ),
      ),
    );
  }
}
