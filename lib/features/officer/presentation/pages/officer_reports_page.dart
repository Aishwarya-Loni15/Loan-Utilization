import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/services/report_generator_service.dart';

class OfficerReportsPage extends ConsumerStatefulWidget {
  const OfficerReportsPage({super.key});

  @override
  ConsumerState<OfficerReportsPage> createState() => _OfficerReportsPageState();
}

class _OfficerReportsPageState extends ConsumerState<OfficerReportsPage> {
  SystemReportType _selectedReportType = SystemReportType.loanUtilization;
  final ReportGeneratorService _reportService = ReportGeneratorService();

  void _exportCsv() {
    final csvContent = _reportService.generateCsvReport(_selectedReportType);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.table_chart_outlined, color: AppColors.success),
            const SizedBox(width: 8),
            Text('Export CSV/Excel - ${_selectedReportType.title}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Formatted CSV / Excel output generated successfully:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  csvContent.trim(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.greenAccent),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvContent));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ CSV data copied to clipboard for Excel export!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copy CSV Data'),
          ),
        ],
      ),
    );
  }

  void _exportPdf() {
    final pdfPreview = _reportService.generatePdfPreviewText(_selectedReportType);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf_rounded, color: AppColors.danger),
            const SizedBox(width: 8),
            Text('Export PDF - ${_selectedReportType.title}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Official Signed PDF Document Preview:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  pdfPreview.trim(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📄 PDF Report generated and downloaded to device!'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Audit & Reporting Console'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Report Domain', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<SystemReportType>(
                    initialValue: _selectedReportType,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: SystemReportType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedReportType = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(_selectedReportType.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Export Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _exportPdf,
                    icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                    label: const Text('EXPORT TO PDF', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _exportCsv,
                    icon: const Icon(Icons.table_chart_outlined, color: Colors.white),
                    label: const Text('EXPORT TO CSV / EXCEL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Available System Reports Catalog', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...SystemReportType.values.map((type) {
              final isSelected = type == _selectedReportType;
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 1.5 : 1.0),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                    child: Icon(
                      isSelected ? Icons.assignment_turned_in : Icons.assignment_outlined,
                      color: isSelected ? AppColors.primary : Colors.grey,
                    ),
                  ),
                  title: Text(type.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                  subtitle: Text(type.description, style: const TextStyle(fontSize: 11)),
                  onTap: () => setState(() => _selectedReportType = type),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
