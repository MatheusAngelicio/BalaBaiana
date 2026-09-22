import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionCycleSummary {
  const ProductionCycleSummary({
    required this.ingredients,
    required this.purchases,
    required this.recipeBases,
    required this.fillings,
    required this.drafts,
  });

  final int ingredients;
  final int purchases;
  final int recipeBases;
  final int fillings;
  final int drafts;

  int get totalItems =>
      ingredients + purchases + recipeBases + fillings + drafts;
}

class ProductionCycleRepository {
  ProductionCycleRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<ProductionCycleSummary> getSummary() async {
    final results = await Future.wait([
      _firestore.collection('ingredients').get(),
      _firestore.collection('purchases').get(),
      _firestore.collection('recipe_bases').get(),
      _firestore.collection('fillings').get(),
      _firestore
          .collection('productions')
          .where('status', isEqualTo: 'draft')
          .get(),
    ]);

    return ProductionCycleSummary(
      ingredients: results[0].size,
      purchases: results[1].size,
      recipeBases: results[2].size,
      fillings: results[3].size,
      drafts: results[4].size,
    );
  }

  Future<void> endCycle() async {
    await _deleteDocuments(
      _firestore.collection('productions').where('status', isEqualTo: 'draft'),
    );
    await _deleteDocuments(_firestore.collection('recipe_bases'));
    await _deleteDocuments(_firestore.collection('fillings'));
    await _deleteDocuments(_firestore.collection('purchases'));
    await _deleteDocuments(_firestore.collection('ingredients'));
  }

  Future<void> _deleteDocuments(Query<Map<String, dynamic>> query) async {
    while (true) {
      final snapshot = await query.limit(400).get();
      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
    }
  }
}
