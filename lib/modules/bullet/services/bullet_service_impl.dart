import 'package:cloud_firestore/cloud_firestore.dart';
import 'bullet_service.dart';

class BulletServiceImpl extends BulletService {
  final CollectionReference _bulletCollection =
      FirebaseFirestore.instance.collection('bullet');

  @override
  Future<void> saveBullet(Map<String, dynamic> data) async {
    await _bulletCollection.add(data);
  }
}
