import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/features/admin/providers/admin_provider.dart';

class SystemConfigPage extends ConsumerStatefulWidget {
  const SystemConfigPage({super.key});

  @override
  ConsumerState<SystemConfigPage> createState() => _SystemConfigPageState();
}

class _SystemConfigPageState extends ConsumerState<SystemConfigPage> {
  late double _confidenceThreshold;
  late bool _autoApprovalEnabled;
  late double _geotagRadius;
  late int _maxImageSize;
  late int _maxPhotos;
  late bool _maintenanceMode;
  late bool _require2FA;
  late String _auditLogLevel;

  @override
  void initState() {
    super.initState();
    final config = ref.read(systemConfigProvider);
    _confidenceThreshold = config.aiConfidenceThreshold;
    _autoApprovalEnabled = config.autoApprovalEnabled;
    _geotagRadius = config.geotagRadiusMeters;
    _maxImageSize = config.maxImageSizeBytes;
    _maxPhotos = config.maxPhotosPerSubmission;
    _maintenanceMode = config.maintenanceMode;
    _require2FA = config.require2FA;
    _auditLogLevel = config.auditLogLevel;
  }

  void _saveConfig() {
    final updated = SystemConfig(
      aiConfidenceThreshold: _confidenceThreshold,
      autoApprovalEnabled: _autoApprovalEnabled,
      geotagRadiusMeters: _geotagRadius,
      maxImageSizeBytes: _maxImageSize,
      maxPhotosPerSubmission: _maxPhotos,
      maintenanceMode: _maintenanceMode,
      require2FA: _require2FA,
      auditLogLevel: _auditLogLevel,
    );

    ref.read(systemConfigProvider.notifier).updateConfig(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('System configuration updated successfully'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage System Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Save System Settings',
            onPressed: _saveConfig,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Global Engine & Security Rules',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure verification parameters, geofencing, and system controls',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // AI Rules Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.smart_toy_outlined, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'AI Verification Engine Settings',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      title: const Text('Enable AI Auto-Approval'),
                      subtitle: const Text('Automatically approve evidence submissions meeting confidence criteria'),
                      value: _autoApprovalEnabled,
                      onChanged: (val) => setState(() => _autoApprovalEnabled = val),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'AI Minimum Confidence Threshold: ${_confidenceThreshold.toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Slider(
                      value: _confidenceThreshold,
                      min: 50,
                      max: 98,
                      divisions: 48,
                      label: '${_confidenceThreshold.toStringAsFixed(0)}%',
                      onChanged: (val) => setState(() => _confidenceThreshold = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Geofencing & Photo Settings
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'Geofencing & Media Constraints',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'Geotag Verification Radius: ${_geotagRadius.toStringAsFixed(0)} meters',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Slider(
                      value: _geotagRadius,
                      min: 10,
                      max: 500,
                      divisions: 49,
                      label: '${_geotagRadius.toStringAsFixed(0)}m',
                      onChanged: (val) => setState(() => _geotagRadius = val),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Max Photos Per Submission:', style: TextStyle(fontWeight: FontWeight.w600)),
                        DropdownButton<int>(
                          value: _maxPhotos,
                          items: [1, 2, 3, 5, 10]
                              .map((n) => DropdownMenuItem(value: n, child: Text('$n Photos')))
                              .toList(),
                          onChanged: (val) => setState(() => _maxPhotos = val ?? 5),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Max Image Size Limit:', style: TextStyle(fontWeight: FontWeight.w600)),
                        DropdownButton<int>(
                          value: _maxImageSize,
                          items: [2, 5, 10, 20]
                              .map((n) => DropdownMenuItem(value: n, child: Text('$n MB')))
                              .toList(),
                          onChanged: (val) => setState(() => _maxImageSize = val ?? 5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Security & System Controls
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.danger),
                        SizedBox(width: 8),
                        Text(
                          'System Maintenance & Security',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      title: const Text('System Maintenance Mode'),
                      subtitle: const Text('Temporarily restrict non-admin access for scheduled updates'),
                      value: _maintenanceMode,
                      activeTrackColor: Colors.orange,
                      onChanged: (val) => setState(() => _maintenanceMode = val),
                    ),
                    SwitchListTile(
                      title: const Text('Require 2FA for Officers & Managers'),
                      subtitle: const Text('Enforce multi-factor verification on high-privilege logins'),
                      value: _require2FA,
                      onChanged: (val) => setState(() => _require2FA = val),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Audit Trail Detail Level:', style: TextStyle(fontWeight: FontWeight.w600)),
                        DropdownButton<String>(
                          value: _auditLogLevel,
                          items: ['Minimal', 'Standard', 'Verbose']
                              .map((lvl) => DropdownMenuItem(value: lvl, child: Text(lvl)))
                              .toList(),
                          onChanged: (val) => setState(() => _auditLogLevel = val ?? 'Standard'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveConfig,
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Save & Apply System Configuration', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
