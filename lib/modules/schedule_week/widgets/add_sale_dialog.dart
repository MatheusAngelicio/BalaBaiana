import 'package:bala_baiana/entities/bullet.dart';
import 'package:bala_baiana/modules/schedule_week/controller/schedule_week_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddSaleDialog extends StatelessWidget {
  final DateTime selectedDate;
  final ScheduleWeekController controller;

  const AddSaleDialog({
    Key? key,
    required this.selectedDate,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController customerNameController =
        TextEditingController();

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
  }
}
