// Stub for platforms that don't support programmatic download (e.g. io)
void downloadFile(String content, String filename) {
  throw UnsupportedError('Download to file is not available on this platform.');
}

void downloadBytes(List<int> bytes, String filename) {
  throw UnsupportedError('downloadBytes is only used on web.');
}
