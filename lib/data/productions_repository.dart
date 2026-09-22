import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/production_draft.dart';
import '../domain/models/finalized_production.dart';
import '../domain/services/production_pricing.dart';

class ProductionsRepository {
  ProductionsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _productions =>
      _firestore.collection('productions');

  Stream<List<ProductionDraft>> watchDrafts() {
    return _productions.orderBy('updatedAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .where((document) => document.data()['status'] == 'draft')
              .map((document) {
            final data = document.data();
            return ProductionDraft(
              id: document.id,
              name: data['name'] as String,
              syrup: ProductionPartSelection.fromMap(
                Map<String, dynamic>.from(data['syrup'] as Map),
              ),
              base: ProductionPartSelection.fromMap(
                Map<String, dynamic>.from(data['base'] as Map),
              ),
              filling: ProductionPartSelection.fromMap(
                Map<String, dynamic>.from(data['filling'] as Map),
              ),
              extraCostsCents: Map<String, int>.from(
                (data['extraCostsCents'] as Map).map(
                  (key, value) => MapEntry(key as String, value as int),
                ),
              ),
            );
          }).toList(),
        );
  }

  Stream<List<FinalizedProduction>> watchFinalizedProductions() {
    return _productions
        .orderBy('finalizedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where((document) => document.data()['status'] == 'finalized')
              .map((document) {
            final data = document.data();
            return FinalizedProduction(
              id: document.id,
              name: data['name'] as String,
              yieldUnits: data['yieldUnits'] as int,
              profitPercentage: (data['profitPercentage'] as num).toDouble(),
              totalCostCents: data['pricing']['totalCostCents'] as int,
              costPerUnitCents: data['pricing']['costPerUnitCents'] as int,
              suggestedPriceCents:
                  data['pricing']['suggestedPriceCents'] as int,
              profitPerUnitCents: data['pricing']['profitPerUnitCents'] as int,
              estimatedRevenueCents:
                  data['pricing']['estimatedRevenueCents'] as int,
              estimatedProfitCents:
                  data['pricing']['estimatedProfitCents'] as int,
              finalizedAt: (data['finalizedAt'] as Timestamp).toDate(),
            );
          }).toList(),
        );
  }

  Future<void> saveDraft(ProductionDraft draft) {
    final data = {
      'name': draft.name.trim(),
      'status': 'draft',
      'syrup': draft.syrup.toMap(),
      'base': draft.base.toMap(),
      'filling': draft.filling.toMap(),
      'extraCostsCents': draft.extraCostsCents,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (draft.id.isEmpty) {
      return _productions
          .add({...data, 'createdAt': FieldValue.serverTimestamp()});
    }
    return _productions.doc(draft.id).set(data, SetOptions(merge: true));
  }

  Future<void> finalizeDraft({
    required ProductionDraft draft,
    required int yieldUnits,
    required double profitPercentage,
    required ProductionPricing pricing,
    required Map<String, dynamic> costSnapshot,
  }) {
    return _productions.doc(draft.id).set({
      'status': 'finalized',
      'yieldUnits': yieldUnits,
      'profitPercentage': profitPercentage,
      'pricing': {
        'totalCostCents': pricing.totalCostCents,
        'costPerUnitCents': pricing.costPerUnitCents,
        'suggestedPriceCents': pricing.suggestedPriceCents,
        'profitPerUnitCents': pricing.profitPerUnitCents,
        'estimatedRevenueCents': pricing.estimatedRevenueCents,
        'estimatedProfitCents': pricing.estimatedProfitCents,
      },
      'costSnapshot': costSnapshot,
      'finalizedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
