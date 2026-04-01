# Web build

Build for web with:

```bash
flutter build web --release
```

Or on Windows: `.\build_web.ps1`

**Icon tree shaking:** Static `Icons.*` use Flutter’s subsetted `MaterialIcons` font. Project icons stored by code point render via [`DynamicMaterialIcon`](lib/widgets/dynamic_material_icon.dart) and a second full font family (`MaterialIconsDynamic` in `pubspec.yaml`), so the build does not need `--no-tree-shake-icons`.
