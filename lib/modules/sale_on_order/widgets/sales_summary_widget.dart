import 'package:bala_baiana/modules/sale_on_order/controller/sale_on_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SalesSummaryWidget extends StatelessWidget {
  final TabController tabController;

  const SalesSummaryWidget({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SaleOnOrderController>();
    final selectedDate =
        DateTime.now().subtract(Duration(days: 7 - tabController.index));

    return Obx(() {
      final summary = controller.calculateSalesSummary(selectedDate);

      if (summary.isEmpty) {
        return const SizedBox.shrink();
      }

      final total = summary.values.reduce((a, b) => a + b);
      final dateFormatter = DateFormat('dd/MM/yyyy');
      String title = 'PEDIDOS PARA O DIA ${dateFormatter.format(selectedDate)}';

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                for (var entry in summary.entries)
                  Text('${entry.value} balas de ${entry.key}'),
                const Divider(height: 20, thickness: 1),
                Text(
                  'Total: $total balas',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
