import 'package:bala_baiana/entities/bullet.dart';

abstract class BulletService {
  Future<void> saveBullet(Bullet bullet);
  Future<List<Bullet>> getBullets();
}
