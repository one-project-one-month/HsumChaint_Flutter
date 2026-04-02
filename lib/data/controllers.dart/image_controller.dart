import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;
  final selectedImageFile = Rx<File?>(null);

  Future<void> openImagePicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Use Camera'),
              onTap: () async {
                Navigator.pop(context);
                await openCamera(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('Use Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await openGallery(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openGallery(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final permission = androidInfo.version.sdkInt <= 32
            ? Permission.storage
            : Permission.photos;

        final status = await permission.request();
        if (!status.isGranted) {
          _showDeniedError(
            context,
            'Please enable gallery permission in settings.',
          );
          return;
        }
      }

      final picture = await _picker.pickImage(source: ImageSource.gallery);
      if (picture == null) return;

      await _handlePickedFile(picture.path);
    } catch (e) {
      _showError(context, 'Error opening gallery: $e');
    }
  }

  Future<void> openCamera(BuildContext context) async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _showDeniedError(
          context,
          'Please enable camera permission in settings.',
        );
        return;
      }

      final picture = await _picker.pickImage(source: ImageSource.camera);
      if (picture == null) return;

      await _handlePickedFile(picture.path);
    } catch (e) {
      _showError(context, 'Error opening camera: $e');
    }
  }

  Future<void> _handlePickedFile(String path) async {
    isLoading.value = true;

    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: path,
        uiSettings: [
          AndroidUiSettings(
            hideBottomControls: true,
            toolbarTitle: 'Crop Image',
            initAspectRatio: CropAspectRatioPreset.square,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(aspectRatioPresets: [CropAspectRatioPreset.square]),
        ],
      );

      if (cropped == null) return;

      File file = File(cropped.path);

      final fileSize = await file.length();
      if (fileSize > 2 * 1024 * 1024) {
        file = await _compressFile(file);
      }

      selectedImageFile.value = file;
    } finally {
      isLoading.value = false;
    }
  }

  Future<File> _compressFile(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return file;

    final resized = img.copyResize(decoded, width: 800);
    final compressedBytes = img.encodeJpg(resized, quality: 50);

    return file..writeAsBytesSync(compressedBytes);
  }

  void _showDeniedError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Alert'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
