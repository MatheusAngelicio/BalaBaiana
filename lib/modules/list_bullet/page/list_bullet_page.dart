import 'package:bala_baiana/modules/list_bullet/controller/list_bullet_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ListBulletPage extends StatelessWidget {
  ListBulletPage({super.key});

  final ListBulletController controller = Get.put(ListBulletController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title:
            const Text('Lista de Balas', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              controller.navigateToCreateBulletPage();
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.bullets.isEmpty) {
          return const Center(
              child: Text('Nenhuma bala encontrada.',
                  style: TextStyle(color: Colors.pinkAccent)));
        } else {
          return ListView.builder(
            itemCount: controller.bullets.length,
            itemBuilder: (context, index) {
              final bullet = controller.bullets[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                color: Colors.pink[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(FontAwesomeIcons.candyCane,
                                color: Colors.pinkAccent),
                            const SizedBox(width: 8),
                            Text(
                              bullet.candyName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.pink[800]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Custo Total',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'R\$${bullet.totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preço de Venda',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$${bullet.salePrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lucro',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$${bullet.profit.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: bullet.profitColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}
