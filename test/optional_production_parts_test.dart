import 'package:bala_baiana/data/productions_repository.dart';
import 'package:bala_baiana/data/settings_repository.dart';
import 'package:bala_baiana/domain/models/cost_defaults.dart';
import 'package:bala_baiana/domain/models/filling.dart';
import 'package:bala_baiana/domain/models/ingredient.dart';
import 'package:bala_baiana/domain/models/production_draft.dart';
import 'package:bala_baiana/domain/models/purchase.dart';
import 'package:bala_baiana/domain/models/recipe_base.dart';
import 'package:bala_baiana/domain/services/production_pricing.dart';
import 'package:bala_baiana/presentation/production_finalize_page.dart';
import 'package:bala_baiana/presentation/production_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const usage = RecipeIngredientUsage(
  ingredientId: 'ingredient',
  purchaseId: 'purchase',
  quantityBase: 100,
);
const dough = RecipeBase(
  id: 'dough',
  name: 'Massa de coco',
  type: RecipeBaseType.base,
  yieldQuantity: 100,
  yieldUnit: MeasurementBase.gram,
  ingredients: [usage],
);
const syrup = RecipeBase(
  id: 'syrup',
  name: 'Calda tradicional',
  type: RecipeBaseType.syrup,
  yieldQuantity: 100,
  yieldUnit: MeasurementBase.gram,
  ingredients: [usage],
);
const filling = Filling(
  id: 'filling',
  name: 'Morango',
  yieldQuantity: 100,
  yieldUnit: MeasurementBase.gram,
  ingredients: [usage],
);
final purchase = Purchase(
  id: 'purchase',
  ingredientId: 'ingredient',
  priceCents: 1000,
  quantity: 100,
  unit: PurchaseUnit.gram,
  quantityBase: 100,
  purchasedAt: DateTime(2026),
);

ProductionDraft makeDraft(bool withSyrup, bool withFilling) => ProductionDraft(
      id: 'draft',
      name: 'Produção',
      base: const ProductionPartSelection(recipeId: 'dough', quantityUsed: 100),
      syrup: withSyrup
          ? const ProductionPartSelection(recipeId: 'syrup', quantityUsed: 100)
          : null,
      filling: withFilling
          ? const ProductionPartSelection(
              recipeId: 'filling', quantityUsed: 100)
          : null,
      extraCostsCents: const {
        'packaging': 200,
        'label': 0,
        'labor': 0,
        'fixed': 0
      },
    );

class RecordingProductions extends Fake implements ProductionsRepository {
  ProductionDraft? saved;
  ProductionPricing? pricing;
  Map<String, dynamic>? snapshot;

  @override
  Future<void> saveDraft(ProductionDraft draft) async {
    saved = draft;
  }

  @override
  Future<void> finalizeDraft({
    required ProductionDraft draft,
    required int yieldUnits,
    required double profitPercentage,
    required ProductionPricing pricing,
    required Map<String, dynamic> costSnapshot,
  }) async {
    this.pricing = pricing;
    snapshot = costSnapshot;
  }
}

class TestSettings extends Fake implements SettingsRepository {
  @override
  Future<CostDefaults> getCostDefaults() async =>
      const CostDefaults(packagingCents: 10);
}

Future<void> showPage(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(1000, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: page));
  await tester.pumpAndSettle();
}

Future<void> choose(WidgetTester tester, String label, String option) async {
  await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

void main() {
  for (final withSyrup in [false, true]) {
    for (final withFilling in [false, true]) {
      final description = 'calda=$withSyrup, recheio=$withFilling';
      final draft = makeDraft(withSyrup, withFilling);
      test('persists and reloads $description', () {
        final restored = ProductionDraft.fromMap(draft.id, draft.toMap());
        expect(restored.base.recipeId, 'dough');
        expect(restored.syrup?.recipeId, withSyrup ? 'syrup' : null);
        expect(restored.filling?.recipeId, withFilling ? 'filling' : null);
        expect(restored.toMap(), draft.toMap());
      });

      testWidgets('edits and saves $description', (tester) async {
        final repository = RecordingProductions();
        await showPage(
            tester,
            ProductionFormPage(
              syrups: withSyrup ? [syrup] : [],
              bases: const [dough],
              fillings: withFilling ? [filling] : [],
              purchases: [purchase],
              productionsRepository: repository,
              draft: draft,
            ));
        expect(find.textContaining('Custo atual da produção:'), findsOneWidget);
        await tester.tap(find.text('Salvar montagem'));
        await tester.pumpAndSettle();
        expect(repository.saved?.toMap(), draft.toMap());
        expect(tester.takeException(), isNull);
      });

      testWidgets('finalizes with correct pricing and snapshot: $description',
          (tester) async {
        final repository = RecordingProductions();
        await showPage(
            tester,
            ProductionFinalizePage(
              draft: draft,
              syrup: withSyrup ? syrup : null,
              base: dough,
              filling: withFilling ? filling : null,
              purchases: [purchase],
              productionsRepository: repository,
              settingsRepository: TestSettings(),
            ));
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Quantas balas renderam?'),
            '10');
        await tester.pumpAndSettle();
        await tester
            .tap(find.widgetWithText(FilledButton, 'Finalizar produção'));
        await tester.pumpAndSettle();
        expect(repository.pricing?.totalCostCents,
            1300 + (withSyrup ? 1000 : 0) + (withFilling ? 1000 : 0));
        expect(repository.snapshot?['syrup'], withSyrup ? isNotNull : isNull);
        expect(
            repository.snapshot?['filling'], withFilling ? isNotNull : isNull);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('does not ignore a selected recipe that is unavailable',
      (tester) async {
    final repository = RecordingProductions();
    await showPage(
        tester,
        ProductionFinalizePage(
          draft: makeDraft(true, false),
          syrup: null,
          base: dough,
          filling: null,
          purchases: [purchase],
          productionsRepository: repository,
          settingsRepository: TestSettings(),
        ));
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Quantas balas renderam?'), '10');
    await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Finalizar produção'));
    expect(button.onPressed, isNull);
    expect(repository.pricing, isNull);
  });

  test('reads absent optional fields in storage', () {
    final data = makeDraft(false, false).toMap()
      ..remove('syrup')
      ..remove('filling');
    final restored = ProductionDraft.fromMap('draft', data);
    expect(restored.syrup, isNull);
    expect(restored.filling, isNull);
  });

  testWidgets('removes previously selected parts when editing', (tester) async {
    final repository = RecordingProductions();
    await showPage(
        tester,
        ProductionFormPage(
          syrups: const [syrup],
          bases: const [dough],
          fillings: const [filling],
          purchases: [purchase],
          productionsRepository: repository,
          draft: makeDraft(true, true),
        ));
    await choose(tester, 'Calda (opcional)', 'Sem calda');
    await choose(tester, 'Recheio ou sabor (opcional)', 'Sem recheio');
    expect(
        find.widgetWithText(TextFormField, 'Quantidade usada'), findsOneWidget);
    await tester.tap(find.text('Salvar montagem'));
    await tester.pumpAndSettle();
    expect(repository.saved, isNotNull);
    expect(repository.saved!.toMap()['syrup'], isNull);
    expect(repository.saved!.toMap()['filling'], isNull);
  });

  testWidgets('requires dough and positive quantities only for selected parts',
      (tester) async {
    final repository = RecordingProductions();
    await showPage(
        tester,
        ProductionFormPage(
          syrups: const [syrup],
          bases: const [dough],
          fillings: const [filling],
          purchases: [purchase],
          productionsRepository: repository,
        ));
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome da produção'), 'Bala');
    await tester.tap(find.text('Salvar montagem'));
    await tester.pumpAndSettle();
    expect(find.text('Selecione uma opção.'), findsOneWidget);
    expect(repository.saved, isNull);
    await choose(tester, 'Massa da bala', 'Massa de coco');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Quantidade usada'), '100');
    await choose(tester, 'Calda (opcional)', 'Calda tradicional');
    await tester.tap(find.text('Salvar montagem'));
    await tester.pumpAndSettle();
    expect(find.text('Informe a quantidade usada.'), findsOneWidget);
    expect(repository.saved, isNull);
    await choose(tester, 'Calda (opcional)', 'Sem calda');
    await tester.tap(find.text('Salvar montagem'));
    await tester.pumpAndSettle();
    expect(repository.saved?.base.recipeId, 'dough');
    expect(repository.saved?.syrup, isNull);
    expect(repository.saved?.filling, isNull);
  });
}
