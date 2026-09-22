import 'package:flutter/material.dart';

import '../data/fillings_repository.dart';
import '../data/production_cycle_repository.dart';
import '../data/productions_repository.dart';
import '../data/purchases_repository.dart';
import '../data/recipe_bases_repository.dart';
import '../domain/models/filling.dart';
import '../domain/models/finalized_production.dart';
import '../domain/models/production_draft.dart';
import '../domain/models/purchase.dart';
import '../domain/models/recipe_base.dart';
import '../domain/services/cost_calculator.dart';
import 'design_system.dart';
import 'formatters.dart';
import 'production_form_page.dart';
import 'production_finalize_page.dart';

class ProductionsPage extends StatelessWidget {
  const ProductionsPage({
    super.key,
    this.purchasesRepository,
    this.recipeBasesRepository,
    this.fillingsRepository,
    this.productionsRepository,
    this.productionCycleRepository,
  });

  final PurchasesRepository? purchasesRepository;
  final RecipeBasesRepository? recipeBasesRepository;
  final FillingsRepository? fillingsRepository;
  final ProductionsRepository? productionsRepository;
  final ProductionCycleRepository? productionCycleRepository;

  void _openSection(BuildContext context, ProductionSection section) {
    final title = switch (section) {
      ProductionSection.assembly => 'Montar produção',
      ProductionSection.history => 'Histórico de produções',
    };

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: ProductionWorkspacePage(
            section: section,
            purchasesRepository: purchasesRepository,
            recipeBasesRepository: recipeBasesRepository,
            fillingsRepository: fillingsRepository,
            productionsRepository: productionsRepository,
          ),
        ),
      ),
    );
  }

  Future<void> _showEndCycleSheet(BuildContext context) async {
    final ended = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EndCycleSheet(
        repository: productionCycleRepository ?? ProductionCycleRepository(),
      ),
    );
    if (ended == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Ciclo encerrado. Você já pode começar uma nova produção.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        const SectionHero(
          palette: SectionColors.productions,
          title: 'Produções',
          subtitle: 'Monte receitas, veja custos e acompanhe seus resultados.',
        ),
        const SizedBox(height: 24),
        const SectionLabel(
          label: 'O que você quer fazer?',
          color: Color(0xFF7253A8),
          icon: Icons.auto_awesome_outlined,
        ),
        const SizedBox(height: 12),
        _ProductionDestinationCard(
          icon: Icons.calculate_outlined,
          color: SectionColors.productions.start,
          title: 'Montar produção',
          description:
              'Combine calda, base e recheio para calcular e precificar.',
          onTap: () => _openSection(context, ProductionSection.assembly),
        ),
        const SizedBox(height: 12),
        _ProductionDestinationCard(
          icon: Icons.history_outlined,
          color: const Color(0xFF4F7F9A),
          title: 'Histórico de produções',
          description: 'Consulte os custos, preços e lucros já registrados.',
          onTap: () => _openSection(context, ProductionSection.history),
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: () => _showEndCycleSheet(context),
          icon: const Icon(Icons.restart_alt),
          label: const Text('Encerrar ciclo de produção'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            minimumSize: const Size.fromHeight(52),
          ),
        ),
      ],
    );
  }
}

enum ProductionSection { assembly, history }

class _EndCycleSheet extends StatefulWidget {
  const _EndCycleSheet({required this.repository});

  final ProductionCycleRepository repository;

  @override
  State<_EndCycleSheet> createState() => _EndCycleSheetState();
}

class _EndCycleSheetState extends State<_EndCycleSheet> {
  late final Future<ProductionCycleSummary> _summaryFuture;
  bool _isEnding = false;

  @override
  void initState() {
    super.initState();
    _summaryFuture = widget.repository.getSummary();
  }

  Future<void> _endCycle() async {
    setState(() => _isEnding = true);
    try {
      await widget.repository.endCycle();
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível encerrar o ciclo.')),
      );
      setState(() => _isEnding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: FutureBuilder<ProductionCycleSummary>(
          future: _summaryFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _EndCycleLoadError();
            }
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final summary = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Encerrar ciclo de produção',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                  'As produções finalizadas continuarão salvas no histórico. Os dados de trabalho abaixo serão removidos para iniciar um novo ciclo.',
                ),
                const SizedBox(height: 18),
                _CycleItemsSummary(summary: summary),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isEnding ? null : _endCycle,
                    icon: _isEnding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Encerrar e limpar dados atuais'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      minimumSize: const Size.fromHeight(54),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed:
                        _isEnding ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CycleItemsSummary extends StatelessWidget {
  const _CycleItemsSummary({required this.summary});

  final ProductionCycleSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = [
      '${summary.ingredients} ingrediente(s)',
      '${summary.purchases} compra(s)',
      '${summary.recipeBases} calda(s) e base(s)',
      '${summary.fillings} recheio(s) e sabor(es)',
      '${summary.drafts} montagem(ns) em aberto',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Serão removidos:',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('• $item'),
              )),
        ],
      ),
    );
  }
}

class _EndCycleLoadError extends StatelessWidget {
  const _EndCycleLoadError();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      child: Center(
        child: Text('Não foi possível conferir os dados do ciclo.'),
      ),
    );
  }
}

class ProductionWorkspacePage extends StatelessWidget {
  const ProductionWorkspacePage({
    super.key,
    required this.section,
    this.purchasesRepository,
    this.recipeBasesRepository,
    this.fillingsRepository,
    this.productionsRepository,
  });

  final ProductionSection section;
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
                    return StreamBuilder<List<FinalizedProduction>>(
                      stream: productions.watchFinalizedProductions(),
                      builder: (context, historySnapshot) {
                        if (historySnapshot.hasError) {
                          return const _ProductionLoadError();
                        }
                        if (!historySnapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return _ProductionsContent(
                          section: section,
                          purchases: purchasesSnapshot.data!,
                          recipes: recipesSnapshot.data!,
                          fillings: fillingsSnapshot.data!,
                          drafts: draftsSnapshot.data!,
                          history: historySnapshot.data!,
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
      },
    );
  }
}

class _ProductionsContent extends StatelessWidget {
  const _ProductionsContent({
    required this.section,
    required this.purchases,
    required this.recipes,
    required this.fillings,
    required this.drafts,
    required this.history,
    required this.productionsRepository,
  });

  final ProductionSection section;
  final List<Purchase> purchases;
  final List<RecipeBase> recipes;
  final List<Filling> fillings;
  final List<ProductionDraft> drafts;
  final List<FinalizedProduction> history;
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

  void _finalizeDraft(BuildContext context, ProductionDraft draft) {
    RecipeBase? findRecipe(String id) {
      for (final recipe in recipes) {
        if (recipe.id == id) return recipe;
      }
      return null;
    }

    Filling? findFilling(String id) {
      for (final filling in fillings) {
        if (filling.id == id) return filling;
      }
      return null;
    }

    final syrup = findRecipe(draft.syrup.recipeId);
    final base = findRecipe(draft.base.recipeId);
    final filling = findFilling(draft.filling.recipeId);
    if (syrup == null || base == null || filling == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Revise as receitas usadas antes de finalizar.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductionFinalizePage(
          draft: draft,
          syrup: syrup,
          base: base,
          filling: filling,
          purchases: purchases,
          productionsRepository: productionsRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAssembly = section == ProductionSection.assembly;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            children: [
              SectionHero(
                palette: SectionColors.productions,
                title: isAssembly ? 'Montar produção' : 'Histórico',
                subtitle: isAssembly
                    ? 'Combine as partes e descubra o custo da receita.'
                    : 'Consulte custos, preços e lucros já registrados.',
              ),
              const SizedBox(height: 24),
              if (isAssembly) ...[
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
                        onFinalize: () => _finalizeDraft(context, draft),
                      ),
                    ),
                  ),
              ] else if (history.isEmpty) ...[
                const _EmptyHistory(),
              ] else ...[
                ...history.map(
                  (production) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _HistoryCard(production: production),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isAssembly)
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton.icon(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Montar nova produção'),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56)),
            ),
          ),
      ],
    );
  }
}

class _ProductionDestinationCard extends StatelessWidget {
  const _ProductionDestinationCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
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

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.history_outlined,
              size: 60, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text('Nenhuma produção finalizada',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'As produções aparecerão aqui depois de informar o rendimento e finalizar.',
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
    required this.onFinalize,
  });

  final ProductionDraft draft;
  final List<RecipeBase> recipes;
  final List<Filling> fillings;
  final List<Purchase> purchases;
  final VoidCallback onTap;
  final VoidCallback onFinalize;

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
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
          if (hasCurrentCost)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onFinalize,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Informar rendimento e finalizar'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.production});

  final FinalizedProduction production;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(production.name,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
                '${production.yieldUnits} balas • ${formatDate(production.finalizedAt)}'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1),
            ),
            _HistoryMetric(
              label: 'Custo da produção',
              value: formatCurrency(production.totalCostCents),
            ),
            _HistoryMetric(
              label: 'Custo por bala',
              value: formatCurrency(production.costPerUnitCents),
            ),
            _HistoryMetric(
              label: 'Venda sugerida por bala',
              value: formatCurrency(production.suggestedPriceCents),
              highlight: true,
            ),
            _HistoryMetric(
              label: 'Lucro por bala',
              value: formatCurrency(production.profitPerUnitCents),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1),
            ),
            _HistoryMetric(
              label: 'Venda estimada',
              value: formatCurrency(production.estimatedRevenueCents),
              highlight: true,
            ),
            _HistoryMetric(
              label: 'Lucro estimado',
              value: formatCurrency(production.estimatedProfitCents),
              highlight: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryMetric extends StatelessWidget {
  const _HistoryMetric({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final textStyle = highlight
        ? Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            )
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: textStyle),
        ],
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
