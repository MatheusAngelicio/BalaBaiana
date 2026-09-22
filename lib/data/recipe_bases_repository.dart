import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/ingredient.dart';
import '../domain/models/recipe_base.dart';

class RecipeBasesRepository {
  RecipeBasesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _recipes =>
      _firestore.collection('recipe_bases');

  Stream<List<RecipeBase>> watchRecipeBases() {
    return _recipes.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs.map((document) {
            final data = document.data();
            final ingredientMaps = (data['ingredients'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
            return RecipeBase(
              id: document.id,
              name: data['name'] as String,
              type: RecipeBaseType.fromStorage(data['type'] as String),
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

  Future<void> saveRecipeBase(RecipeBase recipe) {
    final data = {
      'name': recipe.name.trim(),
      'type': recipe.type.name,
      'yieldQuantity': recipe.yieldQuantity,
      'yieldUnit': recipe.yieldUnit.name,
      'ingredients': recipe.ingredients.map((item) => item.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (recipe.id.isEmpty) {
      return _recipes.add({...data, 'createdAt': FieldValue.serverTimestamp()});
    }
    return _recipes.doc(recipe.id).set(data, SetOptions(merge: true));
  }
}
