# Release build for Firebase: full icon fonts (--no-tree-shake-icons) avoids
# missing glyphs after deploy when browsers cache subset fonts by stable URL.
# See WEB_BUILD.md and firebase.json Cache-Control for fonts.
flutter build web --release --no-tree-shake-icons
