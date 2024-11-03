import 'package:bala_baiana/entities/bullet.dart';
import 'package:bala_baiana/entities/sale.dart';
import 'package:bala_baiana/modules/service/bullet/bullet_service.dart';
import 'package:bala_baiana/modules/service/sale/sale_service.dart';
import 'package:get/get.dart';

class ScheduleWeekController extends GetxController {
  final BulletService _bulletService = Get.find<BulletService>();
  final SaleService _saleService = Get.find<SaleService>();

  var sales = <Sale>[].obs;
  var bullets = <Bullet>[].obs;
  var loading = true.obs;
  var selectedBullet = Rx<Bullet?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchBullets();
    fetchSales();
  }

  Future<void> fetchBullets() async {
    loading.value = true;
    final result = await _bulletService.getBullets();

    result.fold(
      (error) {
        print('Erro ao buscar bullets: $error');
      },
      (bulletList) {
        bullets.assignAll(bulletList);
      },
    );

    loading.value = false;
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
      },
    );

    loading.value = false;
  }

  Future<void> addSale(Bullet bullet, int quantity, DateTime deliveryDate,
      String customerName) async {
    final profitFromSale = bullet.profit * quantity;

    final sale = Sale(
      flavor: bullet.candyName,
      quantity: quantity,
      deliveryDate: deliveryDate,
      customerName: customerName,
      profitFromSale: profitFromSale,
    );

    final result = await _saleService.saveSale(sale: sale);

    result.fold(
      (failure) {
        print('Erro ao adicionar venda: ${failure.message}');
      },
      (_) {
        sales.add(sale);
        print('Venda adicionada com sucesso: ${sale.flavor}');
      },
    );
  }

  void markAsDelivered(int index) {
    if (index >= 0 && index < sales.length) {
      sales[index].delivered = true;
      sales.refresh();
    }
  }

  List<Sale> getSalesForDate(DateTime date) {
    return sales.where((sale) => isSameDay(sale.deliveryDate, date)).toList();
  }

  Map<String, int> calculateSalesSummary(DateTime date) {
    final dailySales =
        sales.where((sale) => isSameDay(sale.deliveryDate, date));
    final summary = <String, int>{};

    for (var sale in dailySales) {
      summary[sale.flavor] = (summary[sale.flavor] ?? 0) + sale.quantity;
    }

    return summary;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
