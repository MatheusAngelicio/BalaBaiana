import 'package:bala_baiana/modules/list_bullet/controller/list_bullet_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListBulletPage extends StatelessWidget {
  ListBulletPage({super.key});

  final ListBulletController controller = Get.put(ListBulletController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Balas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              controller.navigateToCreateBulletPage();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.bullets.isEmpty) {
          return const Center(child: Text('Nenhum bullet encontrado.'));
        } else {
          return ListView.builder(
            itemCount: controller.bullets.length,
            itemBuilder: (context, index) {
              final bullet = controller.bullets[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custo Total',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$${bullet.totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preço de Venda',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$${bullet.salePrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
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
