import 'package:flutter/material.dart';

class SectionColors {
  const SectionColors._();

  static const home = SectionPalette(
    start: Color(0xFFC76B36),
    end: Color(0xFF8D3C1D),
    soft: Color(0xFFFFE3D2),
    icon: Icons.cake_outlined,
  );
  static const purchases = SectionPalette(
    start: Color(0xFF529476),
    end: Color(0xFF286650),
    soft: Color(0xFFDCEFE3),
    icon: Icons.shopping_bag_outlined,
  );
  static const recipes = SectionPalette(
    start: Color(0xFFC65C7A),
    end: Color(0xFF913A59),
    soft: Color(0xFFFFE0E9),
    icon: Icons.menu_book_outlined,
  );
  static const productions = SectionPalette(
    start: Color(0xFF8060B7),
    end: Color(0xFF513B88),
    soft: Color(0xFFE9E0F7),
    icon: Icons.calculate_outlined,
  );
}

class SectionPalette {
  const SectionPalette({
    required this.start,
    required this.end,
    required this.soft,
    required this.icon,
  });

  final Color start;
  final Color end;
  final Color soft;
  final IconData icon;
}

class SectionHero extends StatelessWidget {
  const SectionHero({
    required this.palette,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final SectionPalette palette;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [palette.start, palette.end],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.end.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(palette.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
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

class SectionLabel extends StatelessWidget {
  const SectionLabel({
    required this.label,
    required this.color,
    required this.icon,
    super.key,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
