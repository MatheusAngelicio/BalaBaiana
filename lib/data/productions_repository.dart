import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/production_draft.dart';

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
}
