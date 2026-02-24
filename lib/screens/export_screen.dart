import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import '../services/project_service.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Design System'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                const Text('Export Format: '),
                const SizedBox(width: 16),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'json', label: Text('JSON')),
                      ButtonSegment(value: 'flutter', label: Text('Flutter')),
                      ButtonSegment(value: 'kotlin', label: Text('Kotlin')),
                      ButtonSegment(value: 'swift', label: Text('Swift')),
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
                TextButton.icon(
                  onPressed: () {
                    _copyToClipboard(context);
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _saveToFile(context);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _generateExport() {
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final designSystem = provider.designSystem;

    setState(() {
      switch (_selectedFormat) {
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
        'icons': designSystem.icons.sizes,
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
    final buffer = StringBuffer();
    buffer.writeln('// Swift/iOS Theme Export');
    buffer.writeln('// Generated from Design System Builder');
    buffer.writeln('//');
    buffer.writeln('import UIKit');
    buffer.writeln('');
    buffer.writeln('struct DesignSystemColors {');
    buffer.writeln('  // Primary Colors');
    designSystem.colors.primary.forEach((key, value) {
      buffer.writeln('  static let primary$key = ${_parseColorToSwift(value)}');
    });
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
      // Note: Clipboard functionality requires additional setup
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copy functionality: Select text and copy manually'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _saveToFile(BuildContext context) async {
    if (_exportedCode.isEmpty) {
      _generateExport();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    try {
      final provider = Provider.of<DesignSystemProvider>(context, listen: false);
      final designSystem = provider.designSystem;

      String? outputFile;
      String defaultFileName = _sanitizeFileName(designSystem.name);

      if (_selectedFormat == 'json') {
        // Save as project file
        outputFile = await ProjectService.saveProject(designSystem);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // For code exports, use file picker
        String? path = await FilePicker.platform.saveFile(
          dialogTitle: 'Save ${_selectedFormat.toUpperCase()} Export',
          fileName: '${defaultFileName}_theme.${_getFileExtension()}',
          type: FileType.custom,
          allowedExtensions: [_getFileExtension()],
        );

        if (path != null) {
          final file = File(path);
          await file.writeAsString(_exportedCode);
          outputFile = path;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
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

  String _getFileExtension() {
    switch (_selectedFormat) {
      case 'flutter':
        return 'dart';
      case 'kotlin':
        return 'kt';
      case 'swift':
        return 'swift';
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
}
