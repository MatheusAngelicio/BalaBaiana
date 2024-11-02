import 'package:bala_baiana/entities/bullet.dart';
import 'package:bala_baiana/modules/common/service/bullet_service.dart';
import 'package:bala_baiana/modules/create_bullet/page/create_bullet_page.dart';
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
    try {
      List<Bullet> bulletList = await _bulletService.getBullets();
      bullets.assignAll(bulletList);
    } catch (e) {
      print('Erro ao buscar bullets: $e');
    } finally {
      loading.value = false;
    }
  }

  void navigateToCreateBulletPage() {
    Get.to(CreateBulletPage());
  }
}
