import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  Future<void> _exportAsPdf() async {
    if (!mounted) return;
    
    try {
      final provider = Provider.of<DesignSystemProvider>(context, listen: false);
      final designSystem = provider.designSystem;

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Generating PDF...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final pdf = await _generatePdf(designSystem);
      
      if (!mounted) return;

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // Desktop platforms - use file picker to save
        final fileName = 'design_system_${designSystem.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final path = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Design System PDF',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        
        if (path != null && mounted) {
          final file = File(path);
          await file.writeAsBytes(await pdf.save());
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF exported to: $path'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        // Mobile/Web - use printing package to share/preview
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<pw.Document> _generatePdf(models.DesignSystem ds) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header
            _buildPdfHeader(ds),
            pw.SizedBox(height: 20),
            
            // Colors Section
            pw.Header(level: 1, text: 'Colors'),
            pw.SizedBox(height: 10),
            _buildPdfColors(ds),
            pw.SizedBox(height: 20),
            
            // Typography Section
            pw.Header(level: 1, text: 'Typography'),
            pw.SizedBox(height: 10),
            _buildPdfTypography(ds),
            pw.SizedBox(height: 20),
            
            // Spacing Section
            pw.Header(level: 1, text: 'Spacing'),
            pw.SizedBox(height: 10),
            _buildPdfSpacing(ds),
            pw.SizedBox(height: 20),
            
            // Border Radius Section
            pw.Header(level: 1, text: 'Border Radius'),
            pw.SizedBox(height: 10),
            _buildPdfBorderRadius(ds),
            pw.SizedBox(height: 20),
            
            // Shadows Section
            pw.Header(level: 1, text: 'Shadows'),
            pw.SizedBox(height: 10),
            _buildPdfShadows(ds),
            pw.SizedBox(height: 20),
            
            // Effects Section
            pw.Header(level: 1, text: 'Effects'),
            pw.SizedBox(height: 10),
            _buildPdfEffects(ds),
            pw.SizedBox(height: 20),
            
            // Components Section
            pw.Header(level: 1, text: 'Components'),
            pw.SizedBox(height: 10),
            _buildPdfComponents(ds),
            pw.SizedBox(height: 20),
            
            // Grid Section
            pw.Header(level: 1, text: 'Grid'),
            pw.SizedBox(height: 10),
            _buildPdfGrid(ds),
            pw.SizedBox(height: 20),
            
            // Icons Section
            pw.Header(level: 1, text: 'Icons'),
            pw.SizedBox(height: 10),
            _buildPdfIcons(ds),
            pw.SizedBox(height: 20),
            
            // Gradients Section
            pw.Header(level: 1, text: 'Gradients'),
            pw.SizedBox(height: 10),
            _buildPdfGradients(ds),
            pw.SizedBox(height: 20),
            
            // Roles Section
            pw.Header(level: 1, text: 'Roles'),
            pw.SizedBox(height: 10),
            _buildPdfRoles(ds),
          ];
        },
      ),
    );
    
    return pdf;
  }

  pw.Widget _buildPdfHeader(models.DesignSystem ds) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          ds.name,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        if (ds.description.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Text(
            ds.description,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
        ],
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            pw.Text('Version: ${ds.version}', style: pw.TextStyle(fontSize: 10)),
            pw.SizedBox(width: 20),
            pw.Text('Created: ${ds.created}', style: pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPdfColors(models.DesignSystem ds) {
    final colors = <String, dynamic>{};
    colors.addAll(ds.colors.primary);
    colors.addAll(ds.colors.semantic);
    if (ds.colors.blue != null) colors.addAll(ds.colors.blue!);
    if (ds.colors.green != null) colors.addAll(ds.colors.green!);
    if (ds.colors.orange != null) colors.addAll(ds.colors.orange!);
    if (ds.colors.purple != null) colors.addAll(ds.colors.purple!);
    if (ds.colors.red != null) colors.addAll(ds.colors.red!);
    if (ds.colors.grey != null) colors.addAll(ds.colors.grey!);

    if (colors.isEmpty) {
      return pw.Text('No colors defined', style: pw.TextStyle(color: PdfColors.grey));
    }

    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.entries.map((entry) {
        final colorValue = entry.value is Map
            ? (entry.value as Map)['value']?.toString() ?? '#000000'
            : entry.value.toString();
        final color = _parsePdfColor(colorValue);
        return pw.Container(
          width: 50,
          height: 50,
          decoration: pw.BoxDecoration(
            color: color,
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          margin: const pw.EdgeInsets.only(right: 8, bottom: 8),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Container(
                color: PdfColors.white,
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(
                  entry.key,
                  style: pw.TextStyle(fontSize: 8),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildPdfTypography(models.DesignSystem ds) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Font Family: ${ds.typography.fontFamily.primary}'),
        pw.SizedBox(height: 10),
        pw.Text('Font Weights:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        ...ds.typography.fontWeights.entries.map((e) => 
          pw.Text('  ${e.key}: ${e.value}', style: pw.TextStyle(fontSize: 10))
        ),
        pw.SizedBox(height: 10),
        pw.Text('Font Sizes:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        ...ds.typography.fontSizes.entries.map((e) => 
          pw.Text('  ${e.key}: ${e.value.value} (line-height: ${e.value.lineHeight})', style: pw.TextStyle(fontSize: 10))
        ),
      ],
    );
  }

  pw.Widget _buildPdfSpacing(models.DesignSystem ds) {
    if (ds.spacing.values.isEmpty) {
      return pw.Text('No spacing defined', style: pw.TextStyle(color: PdfColors.grey));
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: ds.spacing.values.entries.map((e) => 
        pw.Text('${e.key}: ${e.value}', style: pw.TextStyle(fontSize: 10))
      ).toList(),
    );
  }

  pw.Widget _buildPdfBorderRadius(models.DesignSystem ds) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('None: ${ds.borderRadius.none}'),
        pw.Text('Small: ${ds.borderRadius.sm}'),
        pw.Text('Base: ${ds.borderRadius.base}'),
        pw.Text('Medium: ${ds.borderRadius.md}'),
        pw.Text('Large: ${ds.borderRadius.lg}'),
        pw.Text('XL: ${ds.borderRadius.xl}'),
        pw.Text('Full: ${ds.borderRadius.full}'),
      ],
    );
  }

  pw.Widget _buildPdfShadows(models.DesignSystem ds) {
    if (ds.shadows.values.isEmpty) {
      return pw.Text('No shadows defined', style: pw.TextStyle(color: PdfColors.grey));
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: ds.shadows.values.entries.map((e) => 
        pw.Text('${e.key}: ${e.value.value}${e.value.description != null ? " (${e.value.description})" : ""}', style: pw.TextStyle(fontSize: 10))
      ).toList(),
    );
  }

  pw.Widget _buildPdfEffects(models.DesignSystem ds) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Glass Morphism: ${ds.effects.glassMorphism}'),
        pw.Text('Dark Overlay: ${ds.effects.darkOverlay}'),
      ],
    );
  }

  pw.Widget _buildPdfComponents(models.DesignSystem ds) {
    final components = <String>[];
    components.addAll(ds.components.buttons.keys);
    components.addAll(ds.components.inputs.keys);
    components.addAll(ds.components.cards.keys);
    components.addAll(ds.components.navigation.keys);
    components.addAll(ds.components.avatars.keys);
    
    if (components.isEmpty) {
      return pw.Text('No components defined', style: pw.TextStyle(color: PdfColors.grey));
    }
    
    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: components.map((name) => 
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Text(name, style: pw.TextStyle(fontSize: 10)),
        )
      ).toList(),
    );
  }

  pw.Widget _buildPdfGrid(models.DesignSystem ds) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Columns: ${ds.grid.columns}'),
        pw.Text('Gutter: ${ds.grid.gutter}'),
        pw.Text('Margin: ${ds.grid.margin}'),
      ],
    );
  }

  pw.Widget _buildPdfIcons(models.DesignSystem ds) {
    if (ds.icons.sizes.isEmpty) {
      return pw.Text('No icons defined', style: pw.TextStyle(color: PdfColors.grey));
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: ds.icons.sizes.entries.map((e) => 
        pw.Text('${e.key}: ${e.value}', style: pw.TextStyle(fontSize: 10))
      ).toList(),
    );
  }

  pw.Widget _buildPdfGradients(models.DesignSystem ds) {
    if (ds.gradients.values.isEmpty) {
      return pw.Text('No gradients defined', style: pw.TextStyle(color: PdfColors.grey));
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: ds.gradients.values.entries.map((e) => 
        pw.Text('${e.key}: ${e.value.type} ${e.value.direction} - ${e.value.colors.join(", ")}', style: pw.TextStyle(fontSize: 10))
      ).toList(),
    );
  }

  pw.Widget _buildPdfRoles(models.DesignSystem ds) {
    if (ds.roles.values.isEmpty) {
      return pw.Text('No roles defined', style: pw.TextStyle(color: PdfColors.grey));
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: ds.roles.values.entries.map((e) => 
        pw.Text('${e.key}: Primary=${e.value.primaryColor}, Accent=${e.value.accentColor}, Background=${e.value.background}', style: pw.TextStyle(fontSize: 10))
      ).toList(),
    );
  }

  PdfColor _parsePdfColor(String colorHex) {
    try {
      String hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha if missing
      }
      final value = int.parse(hex, radix: 16);
      return PdfColor.fromInt(value);
    } catch (e) {
      return PdfColors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final designSystem = provider.designSystem;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export as PDF',
            onPressed: _exportAsPdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, designSystem),
              const SizedBox(height: 32),
              
              // Colors
              _buildSectionTitle(context, 'Colors'),
              const SizedBox(height: 16),
              _buildColorPreview(context, designSystem),
              const SizedBox(height: 32),
              
              // Typography
              _buildSectionTitle(context, 'Typography'),
              const SizedBox(height: 16),
              _buildTypographyPreview(context, designSystem),
              const SizedBox(height: 32),
              
              // Components
              _buildSectionTitle(context, 'Components'),
              const SizedBox(height: 16),
              _buildComponentsPreview(context, designSystem),
              const SizedBox(height: 32),
              
              // Spacing
              _buildSectionTitle(context, 'Spacing'),
              const SizedBox(height: 16),
              _buildSpacingPreview(context, designSystem),
              const SizedBox(height: 32),
              
              // Border Radius
              _buildSectionTitle(context, 'Border Radius'),
              const SizedBox(height: 16),
              _buildBorderRadiusPreview(context, designSystem),
              const SizedBox(height: 32),
              
              // Shadows
              if (designSystem.shadows.values.isNotEmpty) ...[
                _buildSectionTitle(context, 'Shadows'),
                const SizedBox(height: 16),
                _buildShadowsPreview(context, designSystem),
                const SizedBox(height: 32),
              ],
              
              // Effects
              if (designSystem.effects.glassMorphism != null || designSystem.effects.darkOverlay != null) ...[
                _buildSectionTitle(context, 'Effects'),
                const SizedBox(height: 16),
                _buildEffectsPreview(context, designSystem),
                const SizedBox(height: 32),
              ],
              
              // Grid
              _buildSectionTitle(context, 'Grid'),
              const SizedBox(height: 16),
              _buildGridPreview(context, designSystem),
              const SizedBox(height: 32),
              
              // Icons
              if (designSystem.icons.sizes.isNotEmpty) ...[
                _buildSectionTitle(context, 'Icons'),
                const SizedBox(height: 16),
                _buildIconsPreview(context, designSystem),
                const SizedBox(height: 32),
              ],
              
              // Gradients
              if (designSystem.gradients.values.isNotEmpty) ...[
                _buildSectionTitle(context, 'Gradients'),
                const SizedBox(height: 16),
                _buildGradientsPreview(context, designSystem),
                const SizedBox(height: 32),
              ],
              
              // Roles
              if (designSystem.roles.values.isNotEmpty) ...[
                _buildSectionTitle(context, 'Roles'),
                const SizedBox(height: 16),
                _buildRolesPreview(context, designSystem),
              ],
            ],
          ),
        ),

    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildHeader(BuildContext context, models.DesignSystem ds) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ds.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (ds.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                ds.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildInfoChip('Version', ds.version),
                _buildInfoChip('Created', ds.created),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildColorPreview(BuildContext context, models.DesignSystem ds) {
    final colors = <String, dynamic>{};
    colors.addAll(ds.colors.primary);
    colors.addAll(ds.colors.semantic);
    if (ds.colors.blue != null) colors.addAll(ds.colors.blue!);
    if (ds.colors.green != null) colors.addAll(ds.colors.green!);
    if (ds.colors.orange != null) colors.addAll(ds.colors.orange!);
    if (ds.colors.purple != null) colors.addAll(ds.colors.purple!);
    if (ds.colors.red != null) colors.addAll(ds.colors.red!);
    if (ds.colors.grey != null) colors.addAll(ds.colors.grey!);

    if (colors.isEmpty) {
      return const Text('No colors defined', style: TextStyle(color: Colors.grey));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.entries.map((entry) {
        final colorValue = entry.value is Map
            ? (entry.value as Map)['value']?.toString() ?? '#000000'
            : entry.value.toString();
        return _buildColorSwatch(colorValue, entry.key);
      }).toList(),
    );
  }

  Widget _buildColorSwatch(String colorHex, String name) {
    Color? color = _parseColor(colorHex);
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color ?? Colors.grey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTypographyPreview(BuildContext context, models.DesignSystem ds) {
    if (ds.typography.textStyles.isEmpty && ds.typography.fontSizes.isEmpty) {
      return const Text('No typography defined', style: TextStyle(color: Colors.grey));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ds.typography.textStyles.isNotEmpty)
          ...ds.typography.textStyles.entries.map((entry) {
            final style = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontFamily: style.fontFamily,
                      fontSize: _parseSize(style.fontSize),
                      fontWeight: FontWeight.values.firstWhere(
                        (w) => w.value == style.fontWeight,
                        orElse: () => FontWeight.normal,
                      ),
                      color: _parseColor(style.color ?? '#000000') ?? Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${style.fontFamily} • ${style.fontSize} • Weight ${style.fontWeight}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          })
        else
          Text(
            'The quick brown fox jumps over the lazy dog',
            style: TextStyle(
              fontFamily: ds.typography.fontFamily.primary,
              fontSize: 16,
            ),
          ),
      ],
    );
  }

  Widget _buildComponentsPreview(BuildContext context, models.DesignSystem ds) {
    final hasComponents = ds.components.buttons.isNotEmpty ||
        ds.components.cards.isNotEmpty ||
        ds.components.inputs.isNotEmpty ||
        ds.components.navigation.isNotEmpty ||
        ds.components.avatars.isNotEmpty;

    if (!hasComponents) {
      return const Text('No components defined', style: TextStyle(color: Colors.grey));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ds.components.buttons.isNotEmpty) ...[
          const Text('Buttons', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ds.components.buttons.entries.map((entry) {
              return ElevatedButton(
                onPressed: () {},
                child: Text(entry.key),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (ds.components.cards.isNotEmpty) ...[
          const Text('Cards', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          ...ds.components.cards.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('${entry.key} Card'),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
        if (ds.components.inputs.isNotEmpty) ...[
          const Text('Inputs', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          ...ds.components.inputs.entries.take(3).map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                decoration: InputDecoration(
                  labelText: '${entry.key} Input',
                  border: const OutlineInputBorder(),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
        if (ds.components.navigation.isNotEmpty) ...[
          const Text('Navigation', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ds.components.navigation.entries.take(4).map((entry) {
              return Chip(label: Text(entry.key));
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (ds.components.avatars.isNotEmpty) ...[
          const Text('Avatars', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ds.components.avatars.entries.take(4).map((entry) {
              return CircleAvatar(
                child: Text(entry.key.substring(0, 1).toUpperCase()),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSpacingPreview(BuildContext context, models.DesignSystem ds) {
    if (ds.spacing.values.isEmpty) {
      return const Text('No spacing values defined', style: TextStyle(color: Colors.grey));
    }

    final spacingEntries = ds.spacing.values.entries.toList()
      ..sort((a, b) => _parseSize(a.value).compareTo(_parseSize(b.value)));

    return Column(
      children: spacingEntries.map((entry) {
        final size = _parseSize(entry.value);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: size,
                height: 20,
                color: Colors.blue.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 12),
              Text(
                '${entry.key}: ${entry.value}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBorderRadiusPreview(BuildContext context, models.DesignSystem ds) {
    final borderRadius = ds.borderRadius;
    final radiusValues = [
      {'name': 'None', 'value': borderRadius.none},
      {'name': 'Small', 'value': borderRadius.sm},
      {'name': 'Base', 'value': borderRadius.base},
      {'name': 'Medium', 'value': borderRadius.md},
      {'name': 'Large', 'value': borderRadius.lg},
      {'name': 'XL', 'value': borderRadius.xl},
      {'name': 'Full', 'value': borderRadius.full},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: radiusValues.map((entry) {
        final radius = _parseSize(entry['value'] as String);
        return Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${entry['name']}\n${entry['value']}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildShadowsPreview(BuildContext context, models.DesignSystem ds) {
    if (ds.shadows.values.isEmpty) {
      return const Text('No shadows defined', style: TextStyle(color: Colors.grey));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ds.shadows.values.entries.map((entry) {
        // Parse shadow value string (format: "offsetX offsetY blur color")
        final shadowValue = entry.value.value;
        final parts = shadowValue.split(' ');
        double offsetX = 0;
        double offsetY = 0;
        double blur = 0;
        Color shadowColor = Colors.black;

        if (parts.length >= 3) {
          offsetX = double.tryParse(parts[0]) ?? 0;
          offsetY = double.tryParse(parts[1]) ?? 0;
          blur = double.tryParse(parts[2]) ?? 0;
          if (parts.length >= 4) {
            shadowColor = _parseColor(parts[3]) ?? Colors.black;
          }
        }

        return Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(offsetX, offsetY),
                    blurRadius: blur,
                    color: shadowColor.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.key,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEffectsPreview(BuildContext context, models.DesignSystem ds) {
    final effects = <String>[];
    if (ds.effects.glassMorphism != null) {
      effects.add('Glass Morphism');
    }
    if (ds.effects.darkOverlay != null) {
      effects.add('Dark Overlay');
    }

    if (effects.isEmpty) {
      return const Text('No effects defined', style: TextStyle(color: Colors.grey));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: effects.map((effect) {
        return Chip(
          label: Text(effect),
          backgroundColor: Colors.grey[100],
        );
      }).toList(),
    );
  }

  Widget _buildGridPreview(BuildContext context, models.DesignSystem ds) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Columns: ${ds.grid.columns}'),
            const SizedBox(height: 8),
            Text('Gutter: ${ds.grid.gutter}'),
            const SizedBox(height: 8),
            Text('Margin: ${ds.grid.margin}'),
            if (ds.grid.breakpoints.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Breakpoints:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...ds.grid.breakpoints.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${entry.key}: ${entry.value}'),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconsPreview(BuildContext context, models.DesignSystem ds) {
    if (ds.icons.sizes.isEmpty) {
      return const Text('No icon sizes defined', style: TextStyle(color: Colors.grey));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ds.icons.sizes.entries.map((entry) {
        final size = _parseSize(entry.value);
        return Column(
          children: [
            Icon(Icons.star, size: size),
            const SizedBox(height: 4),
            Text(
              '${entry.key}\n${entry.value}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildGradientsPreview(BuildContext context, models.DesignSystem ds) {
    if (ds.gradients.values.isEmpty) {
      return const Text('No gradients defined', style: TextStyle(color: Colors.grey));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ds.gradients.values.entries.map((entry) {
        final gradient = entry.value;
        List<Color> colors = [];
        
        // Parse colors from GradientValue
        if (gradient.colors.isNotEmpty) {
          colors = gradient.colors.map((c) => _parseColor(c) ?? Colors.blue).toList();
        }
        
        if (colors.isEmpty) {
          colors = [Colors.blue, Colors.purple];
        }

        // Determine gradient direction
        AlignmentGeometry begin = Alignment.topLeft;
        AlignmentGeometry end = Alignment.bottomRight;
        if (gradient.direction.contains('vertical') || gradient.direction.contains('top')) {
          begin = Alignment.topCenter;
          end = Alignment.bottomCenter;
        } else if (gradient.direction.contains('horizontal') || gradient.direction.contains('left')) {
          begin = Alignment.centerLeft;
          end = Alignment.centerRight;
        }

        return Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: begin,
                  end: end,
                  colors: colors,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.key,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRolesPreview(BuildContext context, models.DesignSystem ds) {
    if (ds.roles.values.isEmpty) {
      return const Text('No roles defined', style: TextStyle(color: Colors.grey));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ds.roles.values.entries.map((entry) {
        return Chip(
          label: Text(entry.key),
          backgroundColor: Colors.grey[100],
        );
      }).toList(),
    );
  }

  Color? _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      } else if (colorString.startsWith('rgb')) {
        // Simple RGB parsing
        return Colors.blue;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  double _parseSize(String size) {
    try {
      return double.parse(size.replaceAll('px', ''));
    } catch (e) {
      return 16.0;
    }
  }
}
