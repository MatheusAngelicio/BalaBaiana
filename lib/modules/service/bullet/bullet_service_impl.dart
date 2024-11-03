import 'package:bala_baiana/entities/bullet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bullet_service.dart';

class BulletServiceImpl extends BulletService {
  final CollectionReference _bulletCollection =
      FirebaseFirestore.instance.collection('bullet');

  @override
  Future<void> saveBullet(Bullet bullet) async {
    final bulletData = {
      'candyName': bullet.candyName,
      'salePrice': bullet.salePrice,
      'totalCost': bullet.totalCost,
      'profit': bullet.profit,
      'ingredients': bullet.ingredients.map((e) => e.toMap()).toList(),
    };
    await _bulletCollection.add(bulletData);
  }

  @override
  Future<List<Bullet>> getBullets() async {
    final querySnapshot = await _bulletCollection.get();
    return querySnapshot.docs.map((doc) {
      return Bullet.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }
}
