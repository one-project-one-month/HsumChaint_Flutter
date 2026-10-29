# App branding

The original logo is `assets/icons/app_logo.png`. All launcher icons and launch
screens use this artwork. The files here are generated canvases with padding
for platform masks, not alternative logo designs.

To regenerate from the original logo, run from the Flutter repository:

```powershell
dart run tool/generate_brand_assets.dart
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

The generator configurations live at the repository root. Keep the web title,
favicon version, and accessible viewport settings in `web/index.html` when
regenerating splash HTML. Native icon changes require rebuilding and
reinstalling the app. iOS and macOS builds require a Mac with Xcode.
