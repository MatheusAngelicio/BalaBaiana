import 'package:bala_baiana/modules/service/bullet/bullet_service.dart';
import 'package:bala_baiana/modules/service/bullet/bullet_service_impl.dart';
import 'package:get/get.dart';

class InjectService {
  static void init() {
    Get.put<BulletService>(BulletServiceImpl());
  }
}
