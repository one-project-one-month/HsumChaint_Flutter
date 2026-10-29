import 'dart:io';
import 'package:image/image.dart' as img;

// Resize the existing artwork without changing its design. Keep launcher
// backgrounds opaque and foregrounds inside the platform's masking safe area.
void main() {
  final source = img.decodePng(
    File('assets/icons/app_logo.png').readAsBytesSync(),
  )!;
  void write(String path, int size, int logoSize, {bool opaque = false}) {
    final canvas = img.Image(width: size, height: size, numChannels: 4);
    img.fill(
      canvas,
      color: opaque
          ? img.ColorRgba8(251, 249, 245, 255)
          : img.ColorRgba8(0, 0, 0, 0),
    );
    final logo = img.copyResize(
      source,
      width: logoSize,
      height: logoSize,
      interpolation: img.Interpolation.cubic,
    );
    img.compositeImage(
      canvas,
      logo,
      dstX: (size - logoSize) ~/ 2,
      dstY: (size - logoSize) ~/ 2,
    );
    File(path).writeAsBytesSync(img.encodePng(canvas));
  }

  Directory('assets/branding').createSync(recursive: true);
  write('assets/branding/launcher_icon.png', 1024, 736, opaque: true);
  write('assets/branding/splash_logo.png', 768, 640);
  write('assets/branding/splash_android12.png', 1152, 512);
}
