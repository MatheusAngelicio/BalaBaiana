import 'package:bala_baiana/core/inject_service.dart';
import 'package:bala_baiana/core/routes.dart';
import 'package:bala_baiana/modules/create_bullet/page/create_bullet_page.dart';
import 'package:bala_baiana/modules/home/page/home_page.dart';
import 'package:bala_baiana/modules/list_bullet/page/list_bullet_page.dart';
import 'package:bala_baiana/modules/schedule_week/page/schedule_week_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Garanta que o binding do Flutter esteja inicializado
  //WidgetsFlutterBinding.ensureInitialized();

  InjectService.init();

  // Inicializa o locale
  await initializeDateFormatting('pt_BR', null);

  runApp(Phoenix(
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestao de bala',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.home,
      getPages: [
        GetPage(name: AppRoutes.listBullet, page: () => ListBulletPage()),
        GetPage(name: AppRoutes.createBullet, page: () => CreateBulletPage()),
        GetPage(name: AppRoutes.home, page: () => HomePage()),
        GetPage(name: AppRoutes.scheduleWeek, page: () => ScheduleWeekPage()),
      ],
    );
  }
}
