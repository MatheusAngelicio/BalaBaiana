import 'package:bala_baiana/entities/bullet.dart';
import 'package:bala_baiana/entities/sale.dart';
import 'package:bala_baiana/modules/service/bullet/bullet_service.dart';
import 'package:get/get.dart';

class ScheduleWeekController extends GetxController {
  final BulletService _bulletService = Get.find<BulletService>();

  var sales = <Sale>[].obs;
  var bullets = <Bullet>[].obs;
  var loading = true.obs;
  var selectedBullet = Rx<Bullet?>(null);

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

  void addSale(
      Bullet bullet, int quantity, DateTime deliveryDate, String customerName) {
    sales.add(Sale(
      flavor: bullet.candyName,
      quantity: quantity,
      deliveryDate: deliveryDate,
      customerName: customerName,
    ));
  }

  void markAsDelivered(int index) {
    if (index >= 0 && index < sales.length) {
      sales[index].delivered = true;
      sales.refresh();
    }
  }
}
