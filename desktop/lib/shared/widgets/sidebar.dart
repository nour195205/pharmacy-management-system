import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:desktop/core/theme/app_colors.dart';
import 'package:desktop/services/sync_service.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final SyncStatus syncStatus;
  final VoidCallback onManualSync;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.syncStatus,
    required this.onManualSync,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.slate700 : AppColors.slate200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo & Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.droplets,
                    color: theme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صيدليتي',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'نظام إدارة الصيدلية',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 10,
                          color: isDark ? AppColors.slate400 : AppColors.slate600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: [
                _SidebarItem(
                  icon: LucideIcons.layoutDashboard,
                  label: 'لوحة التحكم',
                  selected: selectedIndex == 0,
                  onTap: () => onDestinationSelected(0),
                ),
                _SidebarItem(
                  icon: LucideIcons.pill,
                  label: 'الأدوية',
                  selected: selectedIndex == 1,
                  onTap: () => onDestinationSelected(1),
                ),
                _SidebarItem(
                  icon: LucideIcons.package,
                  label: 'المخزون / التشغيلات',
                  selected: selectedIndex == 2,
                  onTap: () => onDestinationSelected(2),
                ),
                _SidebarItem(
                  icon: LucideIcons.shoppingBag,
                  label: 'المشتريات',
                  selected: selectedIndex == 3,
                  onTap: () => onDestinationSelected(3),
                ),
                _SidebarItem(
                  icon: LucideIcons.database,
                  label: 'البيانات الأساسية',
                  selected: selectedIndex == 4,
                  onTap: () => onDestinationSelected(4),
                ),
                _SidebarItem(
                  icon: LucideIcons.shoppingCart,
                  label: 'نقطة البيع (POS)',
                  selected: selectedIndex == 5,
                  onTap: () => onDestinationSelected(5),
                ),
                _SidebarItem(
                  icon: LucideIcons.barChart3,
                  label: 'التقارير والإحصائيات',
                  selected: selectedIndex == 6,
                  onTap: () => onDestinationSelected(6),
                ),
                _SidebarItem(
                  icon: LucideIcons.settings,
                  label: 'إعدادات النظام',
                  selected: selectedIndex == 7,
                  onTap: () => onDestinationSelected(7),
                ),
              ],
            ),
          ),

          // Bottom Sync Indicator panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate900 : AppColors.slate50,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.slate800 : AppColors.slate200,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSyncStatusBadge(context, syncStatus),
                    IconButton(
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      tooltip: 'تحديث ومزامنة يدوية',
                      onPressed: onManualSync,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusBadge(BuildContext context, SyncStatus status) {
    String text;
    Color color;
    IconData icon;

    switch (status) {
      case SyncStatus.offline:
        text = 'غير متصل (أوفلاين)';
        color = Colors.amber;
        icon = LucideIcons.wifiOff;
        break;
      case SyncStatus.syncing:
        text = 'جاري المزامنة...';
        color = Colors.blue;
        icon = LucideIcons.refreshCw;
        break;
      case SyncStatus.synced:
        text = 'تمت المزامنة';
        color = Colors.green;
        icon = LucideIcons.checkCircle;
        break;
      case SyncStatus.error:
        text = 'فشلت المزامنة';
        color = Colors.red;
        icon = LucideIcons.alertTriangle;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 6.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: widget.selected
                ? selectedColor.withOpacity(0.1)
                : (_isHovered
                    ? (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02))
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(8.0),
            border: widget.selected
                ? Border(left: BorderSide(color: selectedColor, width: 4))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.selected ? selectedColor : (isDark ? AppColors.slate400 : AppColors.slate600),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: widget.selected ? selectedColor : (isDark ? AppColors.slate100 : AppColors.slate600),
                  fontWeight: widget.selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
