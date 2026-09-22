import 'package:flutter/material.dart';

import '../data/fillings_repository.dart';
import '../data/productions_repository.dart';
import '../data/purchases_repository.dart';
import '../data/recipe_bases_repository.dart';
import '../domain/models/filling.dart';
import '../domain/models/production_draft.dart';
import '../domain/models/purchase.dart';
import '../domain/models/recipe_base.dart';
import '../domain/services/cost_calculator.dart';
import 'formatters.dart';
import 'production_form_page.dart';

class ProductionsPage extends StatelessWidget {
  const ProductionsPage({
    super.key,
    this.purchasesRepository,
    this.recipeBasesRepository,
    this.fillingsRepository,
    this.productionsRepository,
  });

  final PurchasesRepository? purchasesRepository;
  final RecipeBasesRepository? recipeBasesRepository;
  final FillingsRepository? fillingsRepository;
  final ProductionsRepository? productionsRepository;

  @override
  Widget build(BuildContext context) {
    final purchases = purchasesRepository ?? PurchasesRepository();
    final recipes = recipeBasesRepository ?? RecipeBasesRepository();
    final fillings = fillingsRepository ?? FillingsRepository();
    final productions = productionsRepository ?? ProductionsRepository();

    return StreamBuilder<List<Purchase>>(
      stream: purchases.watchPurchases(),
      builder: (context, purchasesSnapshot) {
        if (purchasesSnapshot.hasError) return const _ProductionLoadError();
        if (!purchasesSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return StreamBuilder<List<RecipeBase>>(
          stream: recipes.watchRecipeBases(),
          builder: (context, recipesSnapshot) {
            if (recipesSnapshot.hasError) return const _ProductionLoadError();
            if (!recipesSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return StreamBuilder<List<Filling>>(
              stream: fillings.watchFillings(),
              builder: (context, fillingsSnapshot) {
                if (fillingsSnapshot.hasError) {
                  return const _ProductionLoadError();
                }
                if (!fillingsSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return StreamBuilder<List<ProductionDraft>>(
                  stream: productions.watchDrafts(),
                  builder: (context, draftsSnapshot) {
                    if (draftsSnapshot.hasError) {
                      return const _ProductionLoadError();
                    }
                    if (!draftsSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _ProductionsContent(
                      purchases: purchasesSnapshot.data!,
                      recipes: recipesSnapshot.data!,
                      fillings: fillingsSnapshot.data!,
                      drafts: draftsSnapshot.data!,
                      productionsRepository: productions,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ProductionsContent extends StatelessWidget {
  const _ProductionsContent({
    required this.purchases,
    required this.recipes,
    required this.fillings,
    required this.drafts,
    required this.productionsRepository,
  });

  final List<Purchase> purchases;
  final List<RecipeBase> recipes;
  final List<Filling> fillings;
  final List<ProductionDraft> drafts;
  final ProductionsRepository productionsRepository;

  void _openForm(BuildContext context, {ProductionDraft? draft}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductionFormPage(
          syrups: recipes
              .where((recipe) => recipe.type == RecipeBaseType.syrup)
              .toList(),
          bases: recipes
              .where((recipe) => recipe.type == RecipeBaseType.base)
              .toList(),
          fillings: fillings,
          purchases: purchases,
          productionsRepository: productionsRepository,
          draft: draft,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            children: [
              Text('Montagens de produção',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              const Text(
                  'Combine calda, base e recheio para calcular o custo.'),
              const SizedBox(height: 20),
              if (drafts.isEmpty)
                const _EmptyDrafts()
              else
                ...drafts.map(
                  (draft) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DraftCard(
                      draft: draft,
                      recipes: recipes,
                      fillings: fillings,
                      purchases: purchases,
                      onTap: () => _openForm(context, draft: draft),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Montar nova produção'),
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          ),
        ),
      ],
    );
  }
}

class _EmptyDrafts extends StatelessWidget {
  const _EmptyDrafts();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.calculate_outlined,
              size: 60, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text('Nenhuma produção montada',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Crie uma montagem para combinar as partes da bala e calcular o custo.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.draft,
    required this.recipes,
    required this.fillings,
    required this.purchases,
    required this.onTap,
  });

  final ProductionDraft draft;
  final List<RecipeBase> recipes;
  final List<Filling> fillings;
  final List<Purchase> purchases;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final recipesById = {for (final recipe in recipes) recipe.id: recipe};
    final fillingsById = {for (final filling in fillings) filling.id: filling};
    final purchasesById = {
      for (final purchase in purchases) purchase.id: purchase
    };
    final syrup = recipesById[draft.syrup.recipeId];
    final base = recipesById[draft.base.recipeId];
    final filling = fillingsById[draft.filling.recipeId];
    final syrupCost = syrup == null
        ? null
        : CostCalculator.recipeBaseProportionalCost(
            recipe: syrup,
            quantityUsed: draft.syrup.quantityUsed,
            purchasesById: purchasesById,
          );
    final baseCost = base == null
        ? null
        : CostCalculator.recipeBaseProportionalCost(
            recipe: base,
            quantityUsed: draft.base.quantityUsed,
            purchasesById: purchasesById,
          );
    final fillingCost = filling == null
        ? null
        : CostCalculator.fillingProportionalCost(
            filling: filling,
            quantityUsed: draft.filling.quantityUsed,
            purchasesById: purchasesById,
          );
    final hasCurrentCost =
        syrupCost != null && baseCost != null && fillingCost != null;
    final extras =
        draft.extraCostsCents.values.fold(0, (total, value) => total + value) /
            100;
    final total =
        (syrupCost ?? 0) + (baseCost ?? 0) + (fillingCost ?? 0) + extras;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        title: Text(draft.name),
        subtitle: Text(
          hasCurrentCost
              ? 'Custo atual: ${formatCurrency((total * 100).round())}\nAguardando rendimento e preço de venda.'
              : 'Uma das receitas ou compras usadas precisa ser revisada.',
        ),
        isThreeLine: hasCurrentCost,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _ProductionLoadError extends StatelessWidget {
  const _ProductionLoadError();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('Não foi possível carregar as produções.'),
      ),
    );
  }
}
