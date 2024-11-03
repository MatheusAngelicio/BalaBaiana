import 'package:bala_baiana/entities/bullet.dart';
import 'package:bala_baiana/modules/schedule_week/controller/schedule_week_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ScheduleWeekPage extends StatefulWidget {
  ScheduleWeekPage({Key? key}) : super(key: key);

  @override
  _ScheduleWeekPageState createState() => _ScheduleWeekPageState();
}

class _ScheduleWeekPageState extends State<ScheduleWeekPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final ScheduleWeekController controller = Get.put(ScheduleWeekController());

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 14,
      vsync: this,
      initialIndex: 7,
    );

    tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 14,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Organizar Vendas de Balas'),
          bottom: TabBar(
            controller: tabController,
            isScrollable: true,
            tabs: List.generate(14, (index) {
              final date = DateTime.now().subtract(Duration(days: 7 - index));
              return Tab(
                text: DateFormat('dd \'de\' MMMM\nEEEE', 'pt_BR').format(date),
              );
            }),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: List.generate(14, (index) {
                  final date =
                      DateTime.now().subtract(Duration(days: 7 - index));
                  return _buildSalesListForDate(date);
                }),
              ),
            ),
            // Adicionando o widget de resumo
            Obx(() {
              final selectedDate = DateTime.now()
                  .subtract(Duration(days: 7 - tabController.index));
              return _buildSalesSummary(selectedDate);
            }),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabIndex = tabController.index;
            final selectedDate =
                DateTime.now().subtract(Duration(days: 7 - tabIndex));

            if (!selectedDate
                .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
              return FloatingActionButton(
                onPressed: () {
                  _showAddSaleDialog(context, selectedDate);
                },
                child: const Icon(Icons.add),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSalesListForDate(DateTime date) {
    return Obx(() {
      final filteredSales = controller.sales.where((sale) {
        return isSameDay(sale.deliveryDate, date);
      }).toList();

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
                    onPressed: () => controller
                        .markAsDelivered(controller.sales.indexOf(sale)),
                  ),
                );
              },
            );
    });
  }

  void _showAddSaleDialog(BuildContext context, DateTime selectedDate) {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController customerNameController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Venda'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                return DropdownButton<Bullet>(
                  hint: const Text('Escolha uma bala'),
                  value: controller.selectedBullet.value,
                  onChanged: (Bullet? newValue) {
                    controller.selectedBullet.value = newValue;
                  },
                  items: controller.bullets.map((Bullet bullet) {
                    return DropdownMenuItem<Bullet>(
                      value: bullet,
                      child: Text(bullet.candyName),
                    );
                  }).toList(),
                );
              }),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: customerNameController,
                decoration: const InputDecoration(labelText: 'Nome do Cliente'),
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (controller.selectedBullet.value != null &&
                    quantityController.text.isNotEmpty &&
                    customerNameController.text.isNotEmpty) {
                  controller.addSale(
                    controller.selectedBullet.value!,
                    int.parse(quantityController.text),
                    selectedDate,
                    customerNameController.text,
                  );
                  Navigator.of(context).pop();
                } else {
                  Get.snackbar("Erro",
                      "Por favor, selecione uma bala, informe a quantidade e o nome do cliente.");
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSalesSummary(DateTime date) {
    final summary = calculateSalesSummary(date);

    if (summary.isEmpty) {
      return const Center(child: Text('Nenhum pedido para hoje.'));
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
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Map<String, int> calculateSalesSummary(DateTime date) {
    final summary = <String, int>{};

    final filteredSales = controller.sales.where((sale) {
      return isSameDay(sale.deliveryDate, date);
    }).toList();

    for (var sale in filteredSales) {
      summary[sale.flavor] = (summary[sale.flavor] ?? 0) + sale.quantity;
    }

    return summary;
  }
}
