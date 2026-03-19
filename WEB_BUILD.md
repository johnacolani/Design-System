# Web build

Build for web with:

```bash
flutter build web --no-tree-shake-icons
```

Or on Windows: `.\build_web.ps1`

**Why `--no-tree-shake-icons`?** The app shows user-defined project icons by code point (`IconData(e.codePoint, ...)`). Those are not compile-time constants, so Flutter's icon tree shaker cannot run. Using this flag includes the full icon font and allows the build to succeed.
