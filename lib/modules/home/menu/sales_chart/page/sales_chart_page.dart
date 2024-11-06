import 'package:bala_baiana/modules/home/menu/sales_chart/controller/sales_chart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesChartPage extends StatelessWidget {
  SalesChartPage({super.key});

  final SalesChartController controller = Get.put(SalesChartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gráfico de vendas")),
      body: contentPage(),
    );
  }

  Widget contentPage() {
    return SafeArea(
      child: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            const SizedBox(height: 20),
            filterOptions(),
            const SizedBox(height: 20),
            Expanded(child: salesBarChart()),
            const SizedBox(height: 20),
            salesSummary(), // Widget de resumo de vendas
          ],
        );
      }),
    );
  }

  Widget filterOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        filterButton("Esta Semana", "week"),
        const SizedBox(width: 10),
        filterButton("Este Mês", "month"),
      ],
    );
  }

  Widget filterButton(String text, String filter) {
    return Obx(() => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.selectedFilter.value == filter
                ? Colors.blue
                : Colors.grey,
          ),
          onPressed: () {
            controller.updateFilter(filter);
          },
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ));
  }

  Widget salesBarChart() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            legendIndicator(Colors.blue, 'Quantidade de Vendas'),
            const SizedBox(width: 10),
            legendIndicator(Colors.green, 'Lucro das Vendas'),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: BarChart(
            swapAnimationDuration: const Duration(seconds: 3),
            swapAnimationCurve: Curves.linear,
            BarChartData(
              barGroups: controller.getBarChartData(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < controller.salesData.keys.length) {
                        DateTime date =
                            controller.salesData.keys.toList()[value.toInt()];
                        return Text('${date.month}/${date.day}');
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget legendIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }

  Widget salesSummary() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo das Vendas (${controller.selectedFilter.value == 'week' ? "Semana" : "Mês"})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
              'Lucro total: R\$ ${controller.totalProfit.value.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          Text('Vendas por sabor:'),
          const SizedBox(height: 5),
          ...controller.flavorSummary.entries.map((entry) => Text(
                '${entry.key}: ${entry.value} unidades',
                style: const TextStyle(fontSize: 14),
              )),
          const SizedBox(height: 10),
          Text('Pedidos entregues: ${controller.deliveredCount.value}'),
          Text('Pedidos pendentes: ${controller.pendingCount.value}'),
        ],
      ),
    );
  }
}
