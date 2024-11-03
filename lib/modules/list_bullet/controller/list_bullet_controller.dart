import 'package:bala_baiana/core/routes.dart';
import 'package:bala_baiana/entities/bullet.dart';
import 'package:bala_baiana/modules/service/bullet/bullet_service.dart';
import 'package:get/get.dart';

class ListBulletController extends GetxController {
  final BulletService _bulletService = Get.find<BulletService>();
  var bullets = <Bullet>[].obs;
  var loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBullets();
  }

  Future<void> fetchBullets() async {
    loading.value = true;

    final result = await _bulletService.getBullets();

    result.fold(
      (error) {
        print('Erro ao buscar bullets: $error');
      },
      (bulletList) {
        bullets.assignAll(bulletList);
      },
    );

    loading.value = false; // Define loading como false após a operação
  }

  void navigateToCreateBulletPage() async {
    print('Navegando para criar bala...');
    final result = await Get.toNamed(AppRoutes.createBullet);
    print('Resultado da criação: $result');
    if (result == true) {
      fetchBullets();
    }
  }
}
