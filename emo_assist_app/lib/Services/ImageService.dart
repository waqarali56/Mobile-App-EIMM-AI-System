// lib/Services/ImageService.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  /// Pick image from gallery
  Future<File?> pickImageFromGallery({
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: quality,
      );

      if (pickedFile == null) {
        Get.snackbar(
          'Cancelled',
          'No image selected',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return null;
      }
      
      return File(pickedFile.path);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  /// Take photo with camera
  Future<File?> takePhotoWithCamera({
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: quality,
      );

      if (pickedFile == null) {
        Get.snackbar(
          'Cancelled',
          'No photo taken',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return null;
      }
      
      return File(pickedFile.path);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  /// Pick multiple images
  Future<List<File>> pickMultipleImages({
    int maxImages = 5,
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
  }) async {
    try {
      final List<XFile>? pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (pickedFiles == null || pickedFiles.isEmpty) {
        Get.snackbar(
          'Cancelled',
          'No images selected',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return [];
      }

      // Convert to Files and limit to maxImages
      final List<File> imageFiles = pickedFiles
          .take(maxImages)
          .map((xFile) => File(xFile.path))
          .toList();

      Get.snackbar(
        'Success',
        'Selected ${imageFiles.length} image(s)',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return imageFiles;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick images: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return [];
    }
  }

  /// Get image file size
  String getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }

  /// Get image file name
  String getFileName(File file) {
    try {
      final path = file.path;
      return path.split('/').last;
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Check if file is an image
  bool isImageFile(File file) {
    try {
      final path = file.path.toLowerCase();
      return path.endsWith('.jpg') ||
             path.endsWith('.jpeg') ||
             path.endsWith('.png') ||
             path.endsWith('.gif') ||
             path.endsWith('.bmp') ||
             path.endsWith('.webp');
    } catch (e) {
      return false;
    }
  }
}