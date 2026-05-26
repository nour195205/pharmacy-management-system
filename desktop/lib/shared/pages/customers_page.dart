import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة حسابات ومستحقات العملاء'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.users,
              size: 72,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16),
            Text(
              'صفحة إدارة العملاء',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'القسم مخصص لإضافة العملاء وتعديل بياناتهم وإدارة حد الائتمان ومستحقاتهم المالية الآجلة.',
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
