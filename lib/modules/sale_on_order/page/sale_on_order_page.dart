import 'package:bala_baiana/modules/sale_on_order/controller/sale_on_order_controller.dart';
import 'package:bala_baiana/modules/sale_on_order/widgets/add_sale_dialog.dart';
import 'package:bala_baiana/modules/sale_on_order/widgets/sales_list_view.dart';
import 'package:bala_baiana/modules/sale_on_order/widgets/sales_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SaleOnOrderPage extends StatefulWidget {
  SaleOnOrderPage({Key? key}) : super(key: key);

  @override
  _SaleOnOrderPageState createState() => _SaleOnOrderPageState();
}

class _SaleOnOrderPageState extends State<SaleOnOrderPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final SaleOnOrderController controller = Get.put(SaleOnOrderController());

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
        body: Obx(() {
          if (controller.loading.value) {
            return Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: List.generate(14, (index) {
                    final date =
                        DateTime.now().subtract(Duration(days: 7 - index));
                    return SalesListView(date: date);
                  }),
                ),
              ),
              SalesSummaryWidget(tabController: tabController),
            ],
          );
        }),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final tabIndex = tabController.index;
    final selectedDate = DateTime.now().subtract(Duration(days: 7 - tabIndex));

    if (!selectedDate
        .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return FloatingActionButton(
        onPressed: () {
          _showAddSaleDialog(selectedDate);
        },
        child: const Icon(Icons.add),
      );
    }
    return const SizedBox.shrink();
  }

  void _showAddSaleDialog(DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (context) => AddSaleDialog(
        selectedDate: selectedDate,
        controller: controller,
      ),
    );
  }
}
