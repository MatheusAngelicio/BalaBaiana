import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'views/bullet_management_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BulletManagementPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
