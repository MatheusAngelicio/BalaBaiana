import 'package:bala_baiana/core/failure.dart';
import 'package:bala_baiana/entities/bullet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bullet_service.dart';
import 'package:dartz/dartz.dart';

class BulletServiceImpl extends BulletService {
  final CollectionReference _bulletCollection =
      FirebaseFirestore.instance.collection('bullet');

  @override
  Future<Either<Failure, void>> saveBullet(Bullet bullet) async {
    final bulletData = {
      'nomeBala': bullet.candyName,
      'precoBala': bullet.salePrice,
      'custoBala': bullet.totalCost,
      'lucroBala': bullet.profit,
      'ingredientes': bullet.ingredients.map((e) => e.toMap()).toList(),
    };

    try {
      await _bulletCollection.add(bulletData);
      return const Right(null);
    } catch (e) {
      return Left(Failure('Erro ao salvar a bala: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Bullet>>> getBullets() async {
    try {
      final querySnapshot = await _bulletCollection.get();
      final bullets = querySnapshot.docs.map((doc) {
        return Bullet.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return Right(bullets);
    } catch (e) {
      return Left(Failure('Erro ao buscar as balas: ${e.toString()}'));
    }
  }
}
