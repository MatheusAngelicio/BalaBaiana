import 'package:bala_baiana/modules/schedule_week/controller/schedule_week_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesSummaryWidget extends StatelessWidget {
  final TabController tabController;

  const SalesSummaryWidget({Key? key, required this.tabController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScheduleWeekController>();
    final selectedDate =
        DateTime.now().subtract(Duration(days: 7 - tabController.index));

    return Obx(() {
      final summary = controller.calculateSalesSummary(selectedDate);

      if (summary.isEmpty) {
        return const SizedBox.shrink();
      }

      final total = summary.values.reduce((a, b) => a + b);

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
                const Text(
                  'PEDIDOS PARA HOJE',
                  style: TextStyle(
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
