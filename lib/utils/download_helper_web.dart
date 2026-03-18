// Web implementation using dart:html to trigger browser download
import 'dart:convert' show utf8;
import 'dart:html' as html;
import 'dart:typed_data';

void downloadFile(String content, String filename) {
  final bytes = utf8.encode(content);
  downloadBytes(Uint8List.fromList(bytes), filename);
}

/// Binary download (e.g. zip package).
void downloadBytes(List<int> bytes, String filename) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement()
    ..href = url
    ..style.display = 'none'
    ..download = filename;
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
