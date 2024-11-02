import 'package:bala_baiana/bindings/app_bindings.dart';
import 'package:bala_baiana/services/bullet_service.dart';
import 'package:bala_baiana/services/bullet_service_impl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'views/bullet_management_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Get.put<BulletService>(BulletServiceImpl());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Flutter App',
      initialBinding: AppBindings(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BulletManagementPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
