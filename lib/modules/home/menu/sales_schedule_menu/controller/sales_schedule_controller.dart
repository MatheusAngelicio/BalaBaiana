import 'package:bala_baiana/core/routes.dart';
import 'package:get/get.dart';

class SalesScheduleController extends GetxController {
  void goToSalesOnOrder() {
    Get.toNamed(AppRoutes.saleOnOrder);
  }

  void goToDailySales() {
    Get.toNamed(AppRoutes.dailySales);
  }
}
