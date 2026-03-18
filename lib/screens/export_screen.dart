import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../providers/design_system_provider.dart';
import '../providers/billing_provider.dart';
import '../services/feature_gate_service.dart';
import '../models/design_system.dart' as models;
import '../services/project_service.dart';
import '../services/token_engine.dart';
import '../services/figma_tokens_export.dart';
import '../services/package_generator_service.dart';
import '../utils/download_helper.dart';
import '../utils/export_file_platform.dart';
import '../utils/screen_body_padding.dart';
import '../widgets/billing/locked_badge.dart';
import '../widgets/billing/upgrade_modal.dart';
import 'upgrade_screen.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String _selectedFormat = 'json';
  String _exportedCode = '';

  @override
  Widget build(BuildContext context) {
    final billingProvider = Provider.of<BillingProvider>(context);
    final gate = const FeatureGateService();
    final canExport = gate.canExport(billingProvider.plan);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Design System'),
        actions: [
          if (!canExport)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: LockedBadge(
                requiredPlan: 'Pro',
                onTap: () => _showUpgradeModal(context),
              ),
            ),
        ],
      ),
      body: canExport
          ? ScreenBodyPadding(
        verticalPadding: 0,
        child: Column(
          children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                const Text('Export Format: '),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'tokens', label: Text('Tokens')),
                        ButtonSegment(value: 'json', label: Text('JSON')),
                        ButtonSegment(value: 'figma', label: Text('Figma')),
                        ButtonSegment(value: 'flutter', label: Text('Flutter')),
                        ButtonSegment(value: 'kotlin', label: Text('Kotlin')),
                        ButtonSegment(value: 'swift', label: Text('Swift')),
                        ButtonSegment(value: 'react', label: Text('React')),
                        ButtonSegment(value: 'css', label: Text('CSS')),
                      ],
                      selected: {_selectedFormat},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _selectedFormat = newSelection.first;
                          _generateExport();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _exportedCode.isEmpty
                ? Center(
                    child: ElevatedButton.icon(
                      onPressed: _generateExport,
                      icon: const Icon(Icons.code),
                      label: const Text('Generate Export'),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _exportedCode,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _downloadPackage(context),
                  icon: const Icon(Icons.folder_zip),
                  label: const Text('Download package'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _saveToFile(context),
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
          ),
          if (_selectedFormat == 'figma') _buildFigmaSyncHelp(context),
        ],
        ),
      )
          : _buildGatedExportBody(context),
    );
  }

  void _showUpgradeModal(BuildContext context) {
    UpgradeModal.show(
      context,
      featureName: 'Export code',
      requiredPlan: 'Pro',
      description: 'Export to Flutter, React, Swift, Kotlin, and CSS is available on the Pro plan.',
      onUpgrade: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UpgradeScreen(selectedPlan: 'pro')),
        );
      },
    );
  }

  Widget _buildGatedExportBody(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'Export is a Pro feature',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upgrade to Pro to export your design system to Flutter, React, Swift, Kotlin, and CSS.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showUpgradeModal(context),
              icon: const Icon(Icons.arrow_upward),
              label: const Text('Upgrade to Pro'),
            ),
          ],
        ),
      ),
    );
  }

  void _generateExport() {
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final designSystem = provider.designSystem;

    setState(() {
      switch (_selectedFormat) {
        case 'tokens':
          _exportedCode = TokenEngine.exportTokensAsJson(designSystem);
          break;
        case 'json':
          _exportedCode = _exportToJson(designSystem);
          break;
        case 'flutter':
          _exportedCode = _exportToFlutter(designSystem);
          break;
        case 'kotlin':
          _exportedCode = _exportToKotlin(designSystem);
          break;
        case 'swift':
          _exportedCode = _exportToSwift(designSystem);
          break;
        case 'react':
          _exportedCode = _exportToReact(designSystem);
          break;
        case 'css':
          _exportedCode = _exportToCss(designSystem);
          break;
        default:
          _exportedCode = TokenEngine.exportTokensAsJson(designSystem);
      }
    });
  }

  String _exportToJson(models.DesignSystem designSystem) {
    final Map<String, dynamic> json = {
      'designSystem': {
        'name': designSystem.name,
        'version': designSystem.version,
        'description': designSystem.description,
        'created': designSystem.created,
        'colors': _colorsToJson(designSystem.colors),
        'typography': _typographyToJson(designSystem.typography),
        'spacing': designSystem.spacing.values,
        'borderRadius': {
          'none': designSystem.borderRadius.none,
          'sm': designSystem.borderRadius.sm,
          'base': designSystem.borderRadius.base,
          'md': designSystem.borderRadius.md,
          'lg': designSystem.borderRadius.lg,
          'xl': designSystem.borderRadius.xl,
          'full': designSystem.borderRadius.full,
        },
        'shadows': designSystem.shadows.values.map((key, s) => MapEntry(key, {
              'value': s.value,
              if (s.description != null) 'description': s.description,
            })),
        'effects': {
          if (designSystem.effects.glassMorphism != null)
            'glassMorphism': designSystem.effects.glassMorphism,
          if (designSystem.effects.darkOverlay != null)
            'darkOverlay': designSystem.effects.darkOverlay,
        },
        'components': {
          'buttons': designSystem.components.buttons,
          'cards': designSystem.components.cards,
          'inputs': designSystem.components.inputs,
          'navigation': designSystem.components.navigation,
          'avatars': designSystem.components.avatars,
        },
        'grid': {
          'columns': designSystem.grid.columns,
          'gutter': designSystem.grid.gutter,
          'margin': designSystem.grid.margin,
          'breakpoints': designSystem.grid.breakpoints,
        },
        'icons': {
          'sizes': designSystem.icons.sizes,
          'projectIcons': designSystem.icons.projectIcons.map((e) => e.toJson()).toList(),
        },
        'gradients': designSystem.gradients.values.map((key, g) => MapEntry(key, {
              'type': g.type,
              'direction': g.direction,
              'colors': g.colors,
              'stops': g.stops,
            })),
        'roles': designSystem.roles.values.map((key, r) => MapEntry(key, {
              'primaryColor': r.primaryColor,
              'accentColor': r.accentColor,
              'background': r.background,
            })),
      },
    };

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  Map<String, dynamic> _colorsToJson(models.Colors colors) {
    return {
      'primary': colors.primary,
      'semantic': colors.semantic,
      if (colors.blue != null) 'blue': colors.blue,
      if (colors.green != null) 'green': colors.green,
      if (colors.orange != null) 'orange': colors.orange,
      if (colors.purple != null) 'purple': colors.purple,
      if (colors.red != null) 'red': colors.red,
      if (colors.grey != null) 'grey': colors.grey,
      if (colors.white != null) 'white': colors.white,
      if (colors.text != null) 'text': colors.text,
      if (colors.input != null) 'input': colors.input,
      if (colors.roleSpecific != null) 'roleSpecific': colors.roleSpecific,
    };
  }

  Map<String, dynamic> _typographyToJson(models.Typography typography) {
    return {
      'fontFamily': {
        'primary': typography.fontFamily.primary,
        'fallback': typography.fontFamily.fallback,
      },
      'fontWeights': typography.fontWeights,
      'fontSizes': typography.fontSizes.map((key, size) => MapEntry(key, {
            'value': size.value,
            'lineHeight': size.lineHeight,
            if (size.description != null) 'description': size.description,
          })),
      'textStyles': typography.textStyles.map((key, style) => MapEntry(key, {
            'fontFamily': style.fontFamily,
            'fontSize': style.fontSize,
            'fontWeight': style.fontWeight,
            'lineHeight': style.lineHeight,
            if (style.color != null) 'color': style.color,
            if (style.textDecoration != null) 'textDecoration': style.textDecoration,
          })),
    };
  }

  String _exportToFlutter(models.DesignSystem designSystem) {
    final buffer = StringBuffer();
    buffer.writeln('// Flutter Theme Export');
    buffer.writeln('// Generated from Design System Builder');
    buffer.writeln('//');
    buffer.writeln('import \'package:flutter/material.dart\';');
    buffer.writeln('');
    buffer.writeln('class DesignSystemTheme {');
    buffer.writeln('  static ThemeData get theme => ThemeData(');
    buffer.writeln('    useMaterial3: true,');
    buffer.writeln('    colorScheme: ColorScheme.fromSeed(');
    buffer.writeln('      seedColor: ${_parseColorToFlutter(designSystem.colors.primary['500'] ?? '#3B82F6')},');
    buffer.writeln('    ),');
    buffer.writeln('    textTheme: TextTheme(');
    buffer.writeln('      displayLarge: TextStyle(');
    buffer.writeln('        fontFamily: \'${designSystem.typography.fontFamily.primary}\',');
    if (designSystem.typography.fontSizes.isNotEmpty) {
      buffer.writeln('        fontSize: ${_parseSize(designSystem.typography.fontSizes.values.first.value)},');
    } else {
      buffer.writeln('        fontSize: 16,');
    }
    buffer.writeln('      ),');
    buffer.writeln('    ),');
    buffer.writeln('  );');
    buffer.writeln('}');
    return buffer.toString();
  }

  String _exportToKotlin(models.DesignSystem designSystem) {
    final buffer = StringBuffer();
    buffer.writeln('// Kotlin/Android Theme Export');
    buffer.writeln('// Generated from Design System Builder');
    buffer.writeln('//');
    buffer.writeln('package com.example.designsystem');
    buffer.writeln('');
    buffer.writeln('object DesignSystemColors {');
    buffer.writeln('  // Primary Colors');
    designSystem.colors.primary.forEach((key, value) {
      buffer.writeln('  val primary$key = ${_parseColorToKotlin(value)}');
    });
    buffer.writeln('}');
    return buffer.toString();
  }

  String _exportToSwift(models.DesignSystem designSystem) {
    final tokens = TokenEngine.buildTokenMap(designSystem);
    final buffer = StringBuffer();
    buffer.writeln('// Swift/SwiftUI — generated from design tokens');
    buffer.writeln('import UIKit');
    buffer.writeln('');
    buffer.writeln('enum DesignSystemTokens {');
    for (final e in tokens.entries) {
      if (e.value is! Map && e.value != null) {
        final val = e.value.toString().replaceAll("'", "\\'");
        buffer.writeln("  static let ${e.key.replaceAll('.', '_')} = \"$val\"");
      }
    }
    buffer.writeln('}');
    return buffer.toString();
  }

  String _exportToReact(models.DesignSystem designSystem) {
    final tokens = TokenEngine.buildTokenMap(designSystem);
    final buffer = StringBuffer();
    buffer.writeln('// React/JS/TS — design tokens (single source of truth)');
    buffer.writeln('export const tokens = {');
    for (final e in tokens.entries) {
      if (e.value is! Map && e.value != null) {
        final key = e.key.replaceAll('.', '_');
        final val = e.value is num ? e.value : '"${e.value.toString().replaceAll('"', '\\"')}"';
        buffer.writeln("  $key: $val,");
      }
    }
    buffer.writeln('} as const;');
    buffer.writeln('');
    buffer.writeln('export type TokenKey = keyof typeof tokens;');
    return buffer.toString();
  }

  String _exportToCss(models.DesignSystem designSystem) {
    final tokens = TokenEngine.buildTokenMap(designSystem);
    final buffer = StringBuffer();
    buffer.writeln('/* CSS variables — generated from design tokens */');
    buffer.writeln(':root {');
    for (final e in tokens.entries) {
      if (e.value is! Map && e.value != null) {
        final key = '--${e.key.replaceAll('.', '-')}';
        buffer.writeln('  $key: ${e.value};');
      }
    }
    buffer.writeln('}');
    return buffer.toString();
  }

  String _parseColorToFlutter(String color) {
    if (color.startsWith('#')) {
      return 'Color(0xFF${color.substring(1)})';
    }
    return 'Colors.blue';
  }

  String _parseColorToKotlin(String color) {
    if (color.startsWith('#')) {
      return 'Color.parseColor("$color")';
    }
    return 'Color.BLUE';
  }

  String _parseColorToSwift(String color) {
    if (color.startsWith('#')) {
      return 'UIColor(hex: "$color")';
    }
    return 'UIColor.blue';
  }

  double _parseSize(String size) {
    try {
      return double.parse(size.replaceAll('px', ''));
    } catch (e) {
      return 16.0;
    }
  }

  void _copyToClipboard(BuildContext context) async {
    if (_exportedCode.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _exportedCode));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied to clipboard'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _downloadPackage(BuildContext context) async {
    try {
      final provider = Provider.of<DesignSystemProvider>(context, listen: false);
      final ds = provider.designSystem;
      final zipBytes = PackageGeneratorService.buildPackage(ds);
      final name = _exportBaseName(ds.name);
      final fileName = '${name}_design_system.zip';
      if (kIsWeb) {
        downloadBytes(zipBytes, fileName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download started. Unzip for tokens/, theme/, components/, documentation/'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        final ok = await saveExportBytes(
          zipBytes,
          'Save design system package',
          fileName,
          'zip',
        );
        if (context.mounted && ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Package saved. Unzip to get tokens/, theme/, components/, documentation/'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create package: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildFigmaSyncHelp(BuildContext context) {
    final ds = Provider.of<DesignSystemProvider>(context, listen: false).designSystem;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hub, color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Figma token sync',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Export is compatible with Tokens Studio (and similar plugins). Your colors, spacing, radius, typography, shadows, and motion tokens are mapped to Figma token types.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35),
          ),
          const SizedBox(height: 12),
          _figmaStep(context, '1', 'Generate export above, then Copy or Save as JSON.'),
          _figmaStep(context, '2', 'In Figma: install Tokens Studio for Figma (Community plugin).'),
          _figmaStep(context, '3', 'Plugin → Load / Import → paste JSON or choose this file.'),
          _figmaStep(context, '4', 'Apply token sets to local styles or variables as the plugin guides you.'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final w3c = FigmaTokensExport.exportW3cDtcg(ds);
                  await Clipboard.setData(ClipboardData(text: w3c));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('W3C DTCG JSON copied (for other token tools)')),
                    );
                  }
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy W3C DTCG JSON'),
              ),
              TextButton.icon(
                onPressed: () async {
                  final u = Uri.parse('https://tokens.studio/');
                  if (await canLaunchUrl(u)) {
                    await launchUrl(u, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Tokens Studio'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _figmaStep(BuildContext context, String n, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(n, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }

  void _saveToFile(BuildContext context) async {
    if (_exportedCode.isEmpty) {
      _generateExport();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    try {
      final provider = Provider.of<DesignSystemProvider>(context, listen: false);
      final designSystem = provider.designSystem;

      if (_selectedFormat == 'json') {
        await ProjectService.saveProject(designSystem);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project saved successfully!'), backgroundColor: Colors.green),
          );
        }
      } else {
        final ext = _getFileExtension();
        final base = _exportBaseName(designSystem.name);
        final fileName = '${base}_${_exportFileNameSuffix()}.$ext';
        if (kIsWeb) {
          downloadFile(_exportedCode, fileName);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Download started — check your downloads folder'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          final ok = await saveExportText(
            _exportedCode,
            'Save ${_selectedFormat.toUpperCase()} Export',
            fileName,
            ext,
          );
          if (context.mounted && ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _exportFileNameSuffix() {
    switch (_selectedFormat) {
      case 'tokens':
        return 'tokens';
      case 'figma':
        return 'figma_tokens';
      default:
        return 'theme';
    }
  }

  String _getFileExtension() {
    switch (_selectedFormat) {
      case 'tokens':
        return 'json';
      case 'flutter':
        return 'dart';
      case 'kotlin':
        return 'kt';
      case 'swift':
        return 'swift';
      case 'react':
        return 'ts';
      case 'css':
        return 'css';
      case 'figma':
        return 'json';
      default:
        return 'txt';
    }
  }

  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(' ', '_')
        .toLowerCase();
  }

  String _exportBaseName(String name) {
    final s = _sanitizeFileName(name.trim());
    return s.isEmpty ? 'design_system' : s;
  }
}
