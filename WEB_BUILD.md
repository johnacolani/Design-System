# Web build

## Local / CI (recommended for Firebase deploy)

Use the same flags as `deploy_web.bat` and `build_web.ps1` so production matches what you test:

```bash
flutter build web --release --no-tree-shake-icons
```

Or on Windows: `.\build_web.ps1`

**Why `--no-tree-shake-icons` for hosted web?** Release builds normally subset icon fonts by compile-time `IconData`. Subset fonts are served at **stable URLs** (e.g. `assets/fonts/MaterialIcons-Regular.otf`). Browsers can keep an **old** subset in cache while your app loads **new** HTML/JS, which produces **missing glyphs** (placeholder / “broken font” icons) after deploy. Shipping the **full** icon fonts avoids that class of failure. Font file size is larger, but icons stay correct across updates.

## Stricter bundle size (optional)

If you need the smallest release build and accept the cache risk above:

```bash
flutter build web --release
```

**Project icons** by code point still use [`DynamicMaterialIcon`](lib/widgets/dynamic_material_icon.dart) and `MaterialIconsDynamic` so the build does not fail on non-const `IconData`; tree shaking only affects the default `MaterialIcons` / Font Awesome / Cupertino subsets.

## Firebase Hosting

[`firebase.json`](firebase.json) sets **long immutable cache** only for `js|css|wasm`. Font files (`woff|woff2|ttf|otf`) use **shorter** cache (`max-age=3600`) so updates are less likely to pair new code with stale font binaries.

After changing fonts or icon usage, do a **hard refresh** or clear site data if you still see stale icons.
