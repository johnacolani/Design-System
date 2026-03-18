import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// Desktop / mobile: native save dialog + write file.
Future<bool> saveExportText(
  String content,
  String dialogTitle,
  String fileName,
  String ext,
) async {
  try {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: [ext],
    );
    if (path == null) return false;
    var p = path;
    if (!p.toLowerCase().endsWith('.$ext')) {
      p = '$p.$ext';
    }
    await File(p).writeAsString(content);
    return true;
  } catch (e) {
    throw Exception('Could not save file: $e');
  }
}

Future<bool> saveExportBytes(
  List<int> bytes,
  String dialogTitle,
  String fileName,
  String ext,
) async {
  try {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: [ext],
    );
    if (path == null) return false;
    var p = path;
    if (!p.toLowerCase().endsWith('.$ext')) {
      p = '$p.$ext';
    }
    await File(p).writeAsBytes(bytes);
    return true;
  } catch (e) {
    throw Exception('Could not save package: $e');
  }
}
