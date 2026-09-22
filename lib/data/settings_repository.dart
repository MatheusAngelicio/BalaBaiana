import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/cost_defaults.dart';

class SettingsRepository {
  SettingsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _document =>
      _firestore.collection('settings').doc('app');

  Future<CostDefaults> getCostDefaults() async {
    final snapshot = await _document.get();
    return CostDefaults.fromMap(
        snapshot.data()?['costDefaults'] as Map<String, dynamic>?);
  }

  Future<void> saveCostDefaults(CostDefaults defaults) {
    return _document.set({
      'costDefaults': defaults.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
