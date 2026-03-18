/// Web: actual save is handled via browser download in the screen (download_helper).
Future<bool> saveExportText(
  String content,
  String dialogTitle,
  String fileName,
  String ext,
) async =>
    false;

Future<bool> saveExportBytes(
  List<int> bytes,
  String dialogTitle,
  String fileName,
  String ext,
) async =>
    false;
