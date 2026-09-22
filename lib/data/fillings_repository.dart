import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/filling.dart';
import '../domain/models/ingredient.dart';
import '../domain/models/recipe_base.dart';

class FillingsRepository {
  FillingsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _fillings =>
      _firestore.collection('fillings');

  Stream<List<Filling>> watchFillings() {
    return _fillings.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs.map((document) {
            final data = document.data();
            final ingredientMaps = (data['ingredients'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
            return Filling(
              id: document.id,
              name: data['name'] as String,
              yieldQuantity: (data['yieldQuantity'] as num).toDouble(),
              yieldUnit: MeasurementBase.fromStorage(
                data['yieldUnit'] as String,
              ),
              ingredients:
                  ingredientMaps.map(RecipeIngredientUsage.fromMap).toList(),
            );
          }).toList(),
        );
  }

  Future<void> saveFilling(Filling filling) {
    final data = {
      'name': filling.name.trim(),
      'yieldQuantity': filling.yieldQuantity,
      'yieldUnit': filling.yieldUnit.name,
      'ingredients': filling.ingredients.map((item) => item.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (filling.id.isEmpty) {
      return _fillings
          .add({...data, 'createdAt': FieldValue.serverTimestamp()});
    }
    return _fillings.doc(filling.id).set(data, SetOptions(merge: true));
  }
}
