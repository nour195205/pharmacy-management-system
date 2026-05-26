import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:desktop/core/theme/app_colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم والإحصائيات العامة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text(
              'أهلاً بك مجدداً في نظام إدارة الصيدلية 👋',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'إليك نظرة سريعة على أداء العمليات اليوم ومزامنة قاعدة البيانات أوفلاين.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
            const SizedBox(height: 24),

            // Top Aggregate Stat Cards
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'إجمالي المبيعات اليوم',
                  value: '14,250 ج.م',
                  description: '+12% مقارنة بأمس',
                  icon: LucideIcons.trendingUp,
                  color: Colors.teal,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  title: 'الفواتير المعلقة',
                  value: '3 فواتير',
                  description: 'قيد انتظار الاستلام والمزامنة',
                  icon: LucideIcons.clock,
                  color: Colors.amber,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  title: 'الأدوية منخفضة المخزون',
                  value: '5 أصناف',
                  description: 'تجاوزت الحد الأدنى للطلب',
                  icon: LucideIcons.alertTriangle,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Secondary Info Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Sync status summary
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حالة المزامنة والربط مع السيرفر',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSyncDetailRow(context, 'حالة الاتصال بالإنترنت', 'متصل (Online)', Colors.green, LucideIcons.wifi),
                        _buildSyncDetailRow(context, 'العمليات في قائمة الانتظار (Queue)', '0 عملية معلقة', Colors.teal, LucideIcons.listTodo),
                        _buildSyncDetailRow(context, 'آخر مزامنة لقاعدة البيانات', 'منذ دقيقة واحدة', Colors.blue, LucideIcons.checkCheck),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                
                // Active alerts / logs placeholder
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التنبيهات السريعة والملاحظات',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAlertItem(context, 'صلاحية الأدوية', 'صنف "كونجستال أقراص" يوشك على الانتهاء خلال شهرين.', Colors.amber),
                        _buildAlertItem(context, 'حسابات العملاء', 'العميل "أحمد محمد" تجاوز حد الائتمان المسموح به.', Colors.red),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? AppColors.slate400 : AppColors.slate600,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.slate400 : AppColors.slate600,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncDetailRow(BuildContext context, String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.slate600),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(BuildContext context, String label, String details, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(details, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
