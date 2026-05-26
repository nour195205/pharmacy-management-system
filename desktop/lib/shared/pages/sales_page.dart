import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('نقطة بيع الفواتير (POS Cash Register)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.shoppingCart,
              size: 72,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16),
            Text(
              'شاشة نقطة البيع (POS)',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تسمح هذه الواجهة للصيدلي بإجراء معاملات المبيعات الفورية وطباعة الإيصالات وخصم الكميات من المخزن أوفلاين.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
