import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير اليومية والدورية للمبيعات والمخازن'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.barChart3,
              size: 72,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16),
            Text(
              'التقارير والإحصائيات العامة',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'هنا يمكنك توليد وعرض تقارير الأرباح والمبيعات ومستويات الأدوية وتصديرها كملفات PDF.',
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
