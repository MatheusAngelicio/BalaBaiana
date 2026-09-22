import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.onNavigate, super.key});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Olá!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Vamos organizar os custos das suas balas?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () => onNavigate(3),
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Calcular nova produção'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(60),
              textStyle: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 28),
          Text('Acessos rápidos',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _ShortcutCard(
            icon: Icons.add_shopping_cart_outlined,
            title: 'Registrar compra',
            description: 'Anote o preço e a quantidade dos ingredientes.',
            onTap: () => onNavigate(1),
          ),
          const SizedBox(height: 12),
          _ShortcutCard(
            icon: Icons.menu_book_outlined,
            title: 'Ver receitas',
            description: 'Consulte caldas, bases e recheios.',
            onTap: () => onNavigate(2),
          ),
          const SizedBox(height: 12),
          _ShortcutCard(
            icon: Icons.history_outlined,
            title: 'Ver histórico',
            description: 'Confira as produções já calculadas.',
            onTap: () => onNavigate(3),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Os valores de embalagem, etiqueta e mão de obra poderão ser ajustados nas configurações.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(icon, size: 28),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
