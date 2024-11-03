import 'package:bala_baiana/core/failure.dart';
import 'package:bala_baiana/entities/bullet.dart';
import 'package:dartz/dartz.dart';

abstract class BulletService {
  Future<Either<Failure, void>> saveBullet(Bullet bullet);
  Future<Either<Failure, List<Bullet>>> getBullets();
}
