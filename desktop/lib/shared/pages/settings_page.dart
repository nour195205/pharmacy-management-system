import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'package:desktop/core/theme/app_colors.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/services/api_service.dart';
import 'package:desktop/services/sync_service.dart';
import 'package:desktop/core/utils/constants.dart';
import 'package:desktop/injection_container.dart' as di;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  
  bool _isLoading = true;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;
  int? _latencyMs;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentSettings() async {
    setState(() => _isLoading = true);
    final dbService = di.sl<DatabaseService>();
    final apiService = di.sl<ApiService>();

    // Try fetching from database, fallback to active ApiService URL, fallback to default constant
    String? dbUrl = await dbService.getSetting('api_base_url');
    _urlController.text = dbUrl ?? apiService.baseUrl;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isTesting = true;
      _testResult = null;
      _latencyMs = null;
    });

    final testUrl = _urlController.text.trim();
    final testDio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ));

    final stopwatch = Stopwatch()..start();

    try {
      // Call the API dashboard or root to test connectivity
      final response = await testDio.get('$testUrl/dashboard');
      stopwatch.stop();

      setState(() {
        _isTesting = false;
        _testSuccess = response.statusCode == 200 || response.statusCode == 201;
        _latencyMs = stopwatch.elapsedMilliseconds;
        _testResult = _testSuccess
            ? 'تم الاتصال بالخادم بنجاح! استجابة سريعة.'
            : 'استجاب الخادم بكود غير متوقع: ${response.statusCode}';
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _isTesting = false;
        _testSuccess = false;
        _testResult = 'فشل الاتصال بالخادم! يرجى التحقق من تشغيل السيرفر ومن صحة الرابط.';
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final newUrl = _urlController.text.trim();

    try {
      final dbService = di.sl<DatabaseService>();
      final apiService = di.sl<ApiService>();

      // 1. Persist to database settings
      await dbService.setSetting('api_base_url', newUrl);

      // 2. Update active ApiService base URL instantly
      apiService.baseUrl = newUrl;

      // 3. Trigger immediate background synchronization from the new server URL
      final syncService = di.sl<SyncService>();
      syncService.syncQueue();
      syncService.syncFromServer();

      setState(() => _isLoading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(LucideIcons.checkCircle, color: Colors.white),
              SizedBox(width: 8),
              Text('تم حفظ وإعدادات الاتصال وتطبيق الرابط الجديد فورياً!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل حفظ الإعدادات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetToDefault() {
    setState(() {
      _urlController.text = AppConstants.baseApiUrl;
      _testResult = null;
      _latencyMs = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الاتصال بالخادم'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'تحديث الرابط الحالي',
            onPressed: _loadCurrentSettings,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Welcome Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                          : [Colors.white, const Color(0xFFF8FAFC)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          LucideIcons.server,
                          color: theme.primaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إعدادات ربط الخادم (Server Connection)',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'تتيح لك هذه الصفحة التحكم في عنوان الخادم (API IP/URL) لضمان مزامنة البيانات والعمليات في الصيدلية بشكل مباشر وسليم.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? AppColors.slate400 : AppColors.slate600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Form settings card
                Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'عنوان السيرفر والاتصال السحابي',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),

                        TextFormField(
                          controller: _urlController,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'رابط الخادم الرئيسي (Base API URL) *',
                            hintText: 'http://127.0.0.1:8000/api/v1',
                            prefixIcon: const Icon(LucideIcons.link2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'يرجى إدخال عنوان السيرفر';
                            }
                            final val = v.trim();
                            if (!val.startsWith('http://') && !val.startsWith('https://')) {
                              return 'يجب أن يبدأ الرابط بـ http:// أو https://';
                            }
                            if (!val.endsWith('/api/v1')) {
                              return 'يجب إدخال الرابط بالصيغة الكاملة لنسخة الـ API مثل /api/v1 في النهاية';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'تلميح: إذا كان السيرفر على جهاز آخر بالشبكة المحلية، يرجى كتابة عنوان الـ IP الخاص به مثل: http://192.168.1.10:8000/api/v1',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.slate400 : AppColors.slate500,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Action Buttons for testing and resetting
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isTesting ? null : _testConnection,
                              icon: _isTesting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(LucideIcons.wifi, size: 18),
                              label: const Text('اختبار اتصال السيرفر'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                            ),
                            const SizedBox(width: 14),
                            OutlinedButton.icon(
                              onPressed: _resetToDefault,
                              icon: const Icon(LucideIcons.rotateCcw, size: 18),
                              label: const Text('إرجاع الافتراضي'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                            ),
                          ],
                        ),

                        // Test connection result view
                        if (_testResult != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _testSuccess
                                  ? Colors.green.withOpacity(0.08)
                                  : Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _testSuccess ? Colors.green : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _testSuccess ? LucideIcons.checkCircle : LucideIcons.alertTriangle,
                                  color: _testSuccess ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _testResult!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _testSuccess ? Colors.green[800] : Colors.red[800],
                                          fontSize: 13,
                                        ),
                                      ),
                                      if (_latencyMs != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'زمن الاستجابة (Latency): $_latencyMs مللي ثانية',
                                          style: TextStyle(
                                            color: _testSuccess ? Colors.green[700] : Colors.red[700],
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save button bar
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(LucideIcons.save, size: 20),
                    label: const Text('حفظ وتطبيق الإعدادات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
