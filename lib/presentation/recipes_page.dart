import 'package:flutter/material.dart';

import '../data/fillings_repository.dart';
import '../data/purchases_repository.dart';
import '../data/recipe_bases_repository.dart';
import '../domain/models/filling.dart';
import '../domain/models/ingredient.dart';
import '../domain/models/purchase.dart';
import '../domain/models/recipe_base.dart';
import 'design_system.dart';
import 'formatters.dart';
import 'filling_form_page.dart';
import 'recipe_base_form_page.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({
    super.key,
    this.purchasesRepository,
    this.recipeBasesRepository,
    this.fillingsRepository,
  });

  final PurchasesRepository? purchasesRepository;
  final RecipeBasesRepository? recipeBasesRepository;
  final FillingsRepository? fillingsRepository;

  @override
  Widget build(BuildContext context) {
    final purchases = purchasesRepository ?? PurchasesRepository();
    final recipes = recipeBasesRepository ?? RecipeBasesRepository();
    final fillings = fillingsRepository ?? FillingsRepository();

    return StreamBuilder<List<Ingredient>>(
      stream: purchases.watchIngredients(),
      builder: (context, ingredientsSnapshot) {
        if (ingredientsSnapshot.hasError) return const _RecipeLoadError();
        if (!ingredientsSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return StreamBuilder<List<Purchase>>(
          stream: purchases.watchPurchases(),
          builder: (context, purchasesSnapshot) {
            if (purchasesSnapshot.hasError) return const _RecipeLoadError();
            if (!purchasesSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return StreamBuilder<List<RecipeBase>>(
              stream: recipes.watchRecipeBases(),
              builder: (context, recipesSnapshot) {
                if (recipesSnapshot.hasError) return const _RecipeLoadError();
                if (!recipesSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return StreamBuilder<List<Filling>>(
                  stream: fillings.watchFillings(),
                  builder: (context, fillingsSnapshot) {
                    if (fillingsSnapshot.hasError) {
                      return const _RecipeLoadError();
                    }
                    if (!fillingsSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _RecipesContent(
                      ingredients: ingredientsSnapshot.data!,
                      purchases: purchasesSnapshot.data!,
                      recipes: recipesSnapshot.data!,
                      fillings: fillingsSnapshot.data!,
                      recipeBasesRepository: recipes,
                      fillingsRepository: fillings,
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

class _RecipesContent extends StatelessWidget {
  const _RecipesContent({
    required this.ingredients,
    required this.purchases,
    required this.recipes,
    required this.fillings,
    required this.recipeBasesRepository,
    required this.fillingsRepository,
  });

  final List<Ingredient> ingredients;
  final List<Purchase> purchases;
  final List<RecipeBase> recipes;
  final List<Filling> fillings;
  final RecipeBasesRepository recipeBasesRepository;
  final FillingsRepository fillingsRepository;

  void _openRecipeForm(
    BuildContext context, {
    required RecipeBaseType type,
    RecipeBase? recipe,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeBaseFormPage(
          ingredients: ingredients,
          purchases: purchases,
          recipeBasesRepository: recipeBasesRepository,
          type: type,
          recipe: recipe,
        ),
      ),
    );
  }

  void _openFillingForm(BuildContext context, {Filling? filling}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FillingFormPage(
          ingredients: ingredients,
          purchases: purchases,
          fillingsRepository: fillingsRepository,
          filling: filling,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syrups =
        recipes.where((recipe) => recipe.type == RecipeBaseType.syrup).toList();
    final bases =
        recipes.where((recipe) => recipe.type == RecipeBaseType.base).toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            children: [
              const SectionHero(
                palette: SectionColors.recipes,
                title: 'Receitas e sabores',
                subtitle: 'Deixe caldas, bases e recheios prontos para usar.',
              ),
              const SizedBox(height: 24),
              _RecipeSection(
                title: 'Caldas',
                color: const Color(0xFFC78021),
                icon: Icons.water_drop_outlined,
                recipes: syrups,
                purchases: purchases,
                onTap: (recipe) => _openRecipeForm(
                  context,
                  type: RecipeBaseType.syrup,
                  recipe: recipe,
                ),
                onAdd: () => _openRecipeForm(
                  context,
                  type: RecipeBaseType.syrup,
                ),
              ),
              const SizedBox(height: 24),
              _FillingSection(
                fillings: fillings,
                purchases: purchases,
                onTap: (filling) => _openFillingForm(context, filling: filling),
                onAdd: () => _openFillingForm(context),
              ),
              const SizedBox(height: 24),
              _RecipeSection(
                title: 'Bases',
                color: const Color(0xFF8B5C9D),
                icon: Icons.layers_outlined,
                recipes: bases,
                purchases: purchases,
                onTap: (recipe) => _openRecipeForm(
                  context,
                  type: RecipeBaseType.base,
                  recipe: recipe,
                ),
                onAdd: () => _openRecipeForm(
                  context,
                  type: RecipeBaseType.base,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecipeSection extends StatelessWidget {
  const _RecipeSection({
    required this.title,
    required this.color,
    required this.icon,
    required this.recipes,
    required this.purchases,
    required this.onTap,
    required this.onAdd,
  });

  final String title;
  final Color color;
  final IconData icon;
  final List<RecipeBase> recipes;
  final List<Purchase> purchases;
  final ValueChanged<RecipeBase> onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          label: title,
          color: color,
          icon: icon,
          onAdd: onAdd,
          addTooltip: 'Cadastrar $title',
        ),
        const SizedBox(height: 10),
        if (recipes.isEmpty)
          Text('Nenhuma $title cadastrada ainda.')
        else
          ...recipes.map(
            (recipe) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RecipeCard(
                recipe: recipe,
                color: color,
                purchases: purchases,
                onTap: () => onTap(recipe),
              ),
            ),
          ),
      ],
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.color,
    required this.purchases,
    required this.onTap,
  });

  final RecipeBase recipe;
  final Color color;
  final List<Purchase> purchases;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final purchasesById = {
      for (final purchase in purchases) purchase.id: purchase
    };
    var totalCost = 0.0;
    var hasMissingPurchase = false;
    for (final item in recipe.ingredients) {
      final purchase = purchasesById[item.purchaseId];
      if (purchase == null) {
        hasMissingPurchase = true;
      } else {
        totalCost += purchase.costPerBaseUnit * item.quantityBase;
      }
    }

    final totalCents = (totalCost * 100).round();
    final costPerYield = totalCost / recipe.yieldQuantity;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          foregroundColor: color,
          child: Icon(recipe.type == RecipeBaseType.syrup
              ? Icons.water_drop_outlined
              : Icons.layers_outlined),
        ),
        title: Text(recipe.name),
        subtitle: Text(
          hasMissingPurchase
              ? 'Uma compra usada nesta receita não está mais disponível.'
              : '${recipe.ingredients.length} ingrediente(s) • Rendimento: ${formatQuantity(recipe.yieldQuantity)} ${recipe.yieldUnit.symbol}\n'
                  '${formatCurrency(totalCents)} no total • ${formatUnitCost(costPerYield)} por ${recipe.yieldUnit.symbol}',
        ),
        isThreeLine: !hasMissingPurchase,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _FillingSection extends StatelessWidget {
  const _FillingSection({
    required this.fillings,
    required this.purchases,
    required this.onTap,
    required this.onAdd,
  });

  final List<Filling> fillings;
  final List<Purchase> purchases;
  final ValueChanged<Filling> onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          label: 'Recheios e sabores',
          color: const Color(0xFFC65C7A),
          icon: Icons.favorite_outline,
          onAdd: onAdd,
          addTooltip: 'Cadastrar recheio ou sabor',
        ),
        const SizedBox(height: 10),
        if (fillings.isEmpty)
          const Text('Nenhum recheio cadastrado ainda.')
        else
          ...fillings.map(
            (filling) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FillingCard(
                filling: filling,
                purchases: purchases,
                onTap: () => onTap(filling),
              ),
            ),
          ),
      ],
    );
  }
}

class _FillingCard extends StatelessWidget {
  const _FillingCard({
    required this.filling,
    required this.purchases,
    required this.onTap,
  });

  final Filling filling;
  final List<Purchase> purchases;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final purchasesById = {
      for (final purchase in purchases) purchase.id: purchase
    };
    var totalCost = 0.0;
    var hasMissingPurchase = false;
    for (final item in filling.ingredients) {
      final purchase = purchasesById[item.purchaseId];
      if (purchase == null) {
        hasMissingPurchase = true;
      } else {
        totalCost += purchase.costPerBaseUnit * item.quantityBase;
      }
    }

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFE0E9),
          foregroundColor: Color(0xFFC65C7A),
          child: Icon(Icons.favorite_outline),
        ),
        title: Text(filling.name),
        subtitle: Text(
          hasMissingPurchase
              ? 'Uma compra usada neste recheio não está mais disponível.'
              : '${filling.ingredients.length} ingrediente(s) • Rendimento: ${formatQuantity(filling.yieldQuantity)} ${filling.yieldUnit.symbol}\n'
                  '${formatCurrency((totalCost * 100).round())} no total • ${formatUnitCost(totalCost / filling.yieldQuantity)} por ${filling.yieldUnit.symbol}',
        ),
        isThreeLine: !hasMissingPurchase,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _RecipeLoadError extends StatelessWidget {
  const _RecipeLoadError();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('Não foi possível carregar as receitas.'),
      ),
    );
  }
}
