import 'package:bala_baiana/entities/sale.dart';
import 'package:bala_baiana/modules/service/sale/sale_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesChartController extends GetxController {
  final SaleService _saleService = Get.find<SaleService>();

  var sales = <Sale>[].obs;
  var loading = true.obs;
  var salesData = <DateTime, int>{}.obs;
  var selectedFilter = 'week'.obs;

  var totalProfit = 0.0.obs;
  var flavorSummary = <String, int>{}.obs;
  var deliveredCount = 0.obs;
  var pendingCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSales();
  }

  Future<void> fetchSales() async {
    loading.value = true;

    final result = await _saleService.getSales();

    result.fold(
      (failure) {
        print('Erro ao buscar vendas: ${failure.message}');
      },
      (saleList) {
        sales.assignAll(saleList);
        filterSalesData(); // Filtra os dados das vendas
        calculateSummary(); // Gera o resumo de dados
      },
    );

    loading.value = false;
  }

  void filterSalesData() {
    DateTime now = DateTime.now();
    Map<DateTime, int> data = {};

    for (var sale in sales) {
      DateTime date = DateTime(sale.deliveryDate.year, sale.deliveryDate.month,
          sale.deliveryDate.day);

      if (selectedFilter.value == 'week') {
        DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
        DateTime weekEnd =
            now.add(Duration(days: DateTime.daysPerWeek - now.weekday));

        if (date.isAfter(weekStart.subtract(Duration(days: 1))) &&
            date.isBefore(weekEnd.add(Duration(days: 1)))) {
          data[date] = (data[date] ?? 0) + sale.quantity;
        }
      } else if (selectedFilter.value == 'month') {
        if (date.year == now.year && date.month == now.month) {
          data[date] = (data[date] ?? 0) + sale.quantity;
        }
      }
    }

    salesData.assignAll(data);
    calculateSummary(); // Atualiza o resumo após o filtro
  }

  List<BarChartGroupData> getBarChartData() {
    List<BarChartGroupData> barGroups = [];
    int index = 0;

    salesData.forEach((date, quantity) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: quantity.toDouble(),
              color: Colors.blue, // Cor da barra
              width: 16, // Largura da barra
            ),
          ],
        ),
      );
      index++;
    });

    return barGroups;
  }

  void calculateSummary() {
    double profit = 0.0;
    Map<String, int> flavorCount = {};
    int delivered = 0;
    int pending = 0;

    for (var sale in sales) {
      DateTime date = DateTime(sale.deliveryDate.year, sale.deliveryDate.month,
          sale.deliveryDate.day);
      if ((selectedFilter.value == 'week' && salesData.containsKey(date)) ||
          (selectedFilter.value == 'month' &&
              date.month == DateTime.now().month &&
              date.year == DateTime.now().year)) {
        profit += sale.profitFromSale;

        flavorCount[sale.flavor] =
            (flavorCount[sale.flavor] ?? 0) + sale.quantity;

        if (sale.delivered) {
          delivered += 1;
        } else {
          pending += 1;
        }
      }
    }

    totalProfit.value = profit;
    flavorSummary.assignAll(flavorCount);
    deliveredCount.value = delivered;
    pendingCount.value = pending;
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
    filterSalesData();
  }
}
