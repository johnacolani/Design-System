import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

import '../models/design_system_wrapper.dart';
import '../providers/design_system_provider.dart';
import '../utils/serviceflow_pdf_document.dart';
import '../widgets/serviceflow_design_document_preview.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isExportingPdf = false;

  Future<void> _exportAsPdf() async {
    if (!mounted || _isExportingPdf) return;
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final designSystem = provider.designSystem;
    setState(() => _isExportingPdf = true);

    await Future.delayed(Duration.zero);

    try {
      // Let the "Generating PDF..." overlay paint (critical on web where PDF runs on same thread).
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;

      final wrapper = DesignSystemWrapper(designSystem: designSystem);
      final Uint8List pdfBytes = kIsWeb
          ? await generateServiceflowPdfBytesFromJsonChunked(wrapper.toJson())
          : await compute(generateServiceflowPdfBytesFromJson, wrapper.toJson());
      if (!mounted) return;

      // Brief yield so UI can update before opening the print dialog.
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: '${designSystem.name.replaceAll(' ', '_')}_Design_System.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generated successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExportingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final ds = provider.designSystem;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F2EB),
          appBar: AppBar(
            title: const Text('Design System Preview'),
            actions: [
              IconButton(
                icon: _isExportingPdf
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf),
                onPressed: _isExportingPdf ? null : _exportAsPdf,
                tooltip: 'Export PDF',
              ),
            ],
          ),
          body: ServiceflowDesignDocumentPreview(designSystem: ds),
        ),
        if (_isExportingPdf)
          Material(
            color: Colors.black54,
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(48),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      Text('Generating PDF...', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
