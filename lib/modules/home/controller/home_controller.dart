import 'package:bala_baiana/core/routes.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  void goToBulletPage() {
    Get.toNamed(AppRoutes.listBullet);
  }

  void goToSheduleWeek() {
    Get.toNamed(AppRoutes.scheduleWeek);
  }
}
