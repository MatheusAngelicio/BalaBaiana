import 'package:bala_baiana/core/inject_service.dart';
import 'package:bala_baiana/modules/list_bullet/page/list_bullet_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  InjectService.init();

  runApp(Phoenix(
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gestao de bala',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListBulletPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
