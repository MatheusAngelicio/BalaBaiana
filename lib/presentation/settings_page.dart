import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
            'Os custos padrão por bala serão configurados aqui nas próximas etapas.'),
      ),
    );
  }
}
