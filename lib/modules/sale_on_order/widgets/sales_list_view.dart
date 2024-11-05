import 'package:bala_baiana/modules/sale_on_order/controller/sale_on_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesListView extends StatelessWidget {
  final DateTime date;

  const SalesListView({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SaleOnOrderController>();

    return Obx(() {
      final filteredSales = controller.getSalesForDate(date);

      return filteredSales.isEmpty
          ? const Center(child: Text('Nenhuma venda para este dia.'))
          : ListView.builder(
              itemCount: filteredSales.length,
              itemBuilder: (context, index) {
                final sale = filteredSales[index];
                return ListTile(
                  title: Text('${sale.quantity} balas de ${sale.flavor}'),
                  subtitle: Text('Cliente: ${sale.customerName}'),
                  trailing: IconButton(
                    icon: Icon(
                        sale.delivered ? Icons.check_circle : Icons.circle),
                    onPressed: () => controller.markAsDelivered(index),
                  ),
                );
              },
            );
    });
  }
}
