import 'package:bala_baiana/core/routes.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  void goToCandyPage() {
    Get.toNamed(AppRoutes.candyMenu);
  }

  void goToSheduleWeek() {
    Get.toNamed(AppRoutes.salesSchedule);
  }

  void goToSalesChart() {
    Get.toNamed(AppRoutes.salesChart);
  }
}
