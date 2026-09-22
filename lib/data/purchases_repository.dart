import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/ingredient.dart';
import '../domain/models/purchase.dart';

class PurchasesRepository {
  PurchasesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ingredients =>
      _firestore.collection('ingredients');
  CollectionReference<Map<String, dynamic>> get _purchases =>
      _firestore.collection('purchases');

  Stream<List<Ingredient>> watchIngredients() {
    return _ingredients.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (document) => Ingredient(
                  id: document.id,
                  name: document.data()['name'] as String,
                  base: MeasurementBase.fromStorage(
                    document.data()['baseUnit'] as String,
                  ),
                ),
              )
              .toList(),
        );
  }

  Stream<List<Purchase>> watchPurchases() {
    return _purchases.orderBy('purchasedAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((document) {
            final data = document.data();
            return Purchase(
              id: document.id,
              ingredientId: data['ingredientId'] as String,
              priceCents: data['priceCents'] as int,
              quantity: (data['quantity'] as num).toDouble(),
              unit: PurchaseUnit.fromStorage(data['unit'] as String),
              quantityBase: (data['quantityBase'] as num).toDouble(),
              purchasedAt: (data['purchasedAt'] as Timestamp).toDate(),
            );
          }).toList(),
        );
  }

  Future<void> addPurchase({
    required String ingredientId,
    required int priceCents,
    required double quantity,
    required PurchaseUnit unit,
    required DateTime purchasedAt,
  }) {
    return _purchases.add({
      'ingredientId': ingredientId,
      'priceCents': priceCents,
      'quantity': quantity,
      'unit': unit.name,
      'quantityBase': unit.toBaseQuantity(quantity),
      'purchasedAt': Timestamp.fromDate(purchasedAt),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> addIngredient({
    required String name,
    required MeasurementBase base,
  }) async {
    final document = await _ingredients.add({
      'name': name.trim(),
      'nameNormalized': name.trim().toLowerCase(),
      'baseUnit': base.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return document.id;
  }
}
