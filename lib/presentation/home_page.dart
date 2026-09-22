import 'package:flutter/material.dart';

import 'design_system.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.onNavigate, super.key});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          const SectionHero(
            palette: SectionColors.home,
            title: 'Olá! Vamos precificar?',
            subtitle: 'Organize custos e defina o valor das suas balas.',
          ),
          const SizedBox(height: 20),
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
          const SectionLabel(
            label: 'Acessos rápidos',
            color: Color(0xFFB8572C),
            icon: Icons.bolt_outlined,
          ),
          const SizedBox(height: 12),
          _ShortcutCard(
            icon: Icons.add_shopping_cart_outlined,
            color: SectionColors.purchases.start,
            title: 'Registrar compra',
            description: 'Anote o preço e a quantidade dos ingredientes.',
            onTap: () => onNavigate(1),
          ),
          const SizedBox(height: 12),
          _ShortcutCard(
            icon: Icons.menu_book_outlined,
            color: SectionColors.recipes.start,
            title: 'Ver receitas',
            description: 'Consulte caldas, bases e recheios.',
            onTap: () => onNavigate(2),
          ),
          const SizedBox(height: 12),
          _ShortcutCard(
            icon: Icons.calculate_outlined,
            color: SectionColors.productions.start,
            title: 'Ir para produções',
            description: 'Monte uma produção ou consulte o histórico.',
            onTap: () => onNavigate(3),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE7D8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFF9A4A1B)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Os valores de embalagem, etiqueta e mão de obra podem ser ajustados nas configurações.',
                  ),
                ),
              ],
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
    required this.color,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
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
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
