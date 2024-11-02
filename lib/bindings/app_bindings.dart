import 'package:bala_baiana/services/bullet_service.dart';
import 'package:bala_baiana/services/bullet_service_impl.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<BulletService>(BulletServiceImpl());
  }
}
