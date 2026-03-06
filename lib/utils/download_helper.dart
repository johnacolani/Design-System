import 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart' as impl;

/// Triggers a file download. On web, uses the browser download.
/// On other platforms, throws UnsupportedError.
void downloadFile(String content, String filename) {
  impl.downloadFile(content, filename);
}
