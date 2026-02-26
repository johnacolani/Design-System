import 'package:flutter/material.dart' show IconData, Icons;
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

/// Returns the platform-appropriate back arrow icon.
/// iOS and macOS: Cupertino style. Windows, web, Android, Linux: Material style.
IconData get platformBackIcon {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return CupertinoIcons.back;
    default:
      return Icons.arrow_back;
  }
}
