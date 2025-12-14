// lib/Services/AudioVideoService.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import 'package:file_picker/file_picker.dart';

class AudioVideoService {
  static final AudioVideoService _instance = AudioVideoService._internal();
  factory AudioVideoService() => _instance;
  AudioVideoService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isRecorderInitialized = false;
  String? _currentRecordingPath;

  /// Pick video from gallery
  Future<File?> pickVideoFromGallery({
    int? maxDuration,
    int? maxFileSize,
  }) async {
    print('🎥 [AudioVideoService] Starting video selection from gallery...');
    try {
      // Request permissions
      final permissionStatus = await Permission.storage.request();
      print('🎥 [AudioVideoService] Storage permission status: ${permissionStatus.isGranted}');
      
      if (!permissionStatus.isGranted) {
        print('❌ [AudioVideoService] Storage permission denied');
        Get.snackbar(
          'Permission Required',
          'Storage permission is needed to select videos',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(seconds: maxDuration ?? 60),
      );

      if (pickedFile == null) {
        print('ℹ️ [AudioVideoService] No video selected');
        Get.snackbar(
          'Cancelled',
          'No video selected',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return null;
      }

      print('🎥 [AudioVideoService] Video selected: ${pickedFile.path}');
      final file = File(pickedFile.path);
      
      // Check file size if specified
      if (maxFileSize != null) {
        final fileSize = await file.length();
        print('🎥 [AudioVideoService] File size: $fileSize bytes (limit: $maxFileSize)');
        if (fileSize > maxFileSize) {
          print('❌ [AudioVideoService] File exceeds size limit');
          Get.snackbar(
            'File Too Large',
            'Video exceeds maximum size limit',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return null;
        }
      }

      print('✅ [AudioVideoService] Video ready for analysis');
      Get.snackbar(
        'Video Selected',
        'Ready for emotion analysis',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      return file;
    } catch (e) {
      print('💥 [AudioVideoService] Error picking video: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to pick video: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  /// Record video with camera
  Future<File?> recordVideoWithCamera({
    int maxDuration = 60,
  }) async {
    print('📹 [AudioVideoService] Starting video recording...');
    try {
      // Request camera and microphone permissions
      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();
      print('📹 [AudioVideoService] Camera: ${cameraStatus.isGranted}, Mic: ${micStatus.isGranted}');
      
      if (!cameraStatus.isGranted || !micStatus.isGranted) {
        print('❌ [AudioVideoService] Required permissions denied');
        Get.snackbar(
          'Permissions Required',
          'Camera and microphone permissions are needed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      final XFile? recordedFile = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(seconds: maxDuration),
      );

      if (recordedFile == null) {
        print('ℹ️ [AudioVideoService] Video recording cancelled');
        Get.snackbar(
          'Cancelled',
          'Video recording cancelled',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return null;
      }

      print('✅ [AudioVideoService] Video recorded: ${recordedFile.path}');
      Get.snackbar(
        'Video Recorded',
        'Ready for emotion analysis',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      return File(recordedFile.path);
    } catch (e) {
      print('💥 [AudioVideoService] Error recording video: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to record video: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  /// Start audio recording
  Future<bool> startAudioRecording() async {
    print('🎤 [AudioVideoService] Starting audio recording...');
    try {
      // Initialize recorder if needed
      if (!_isRecorderInitialized) {
        await _audioRecorder.openRecorder();
        _isRecorderInitialized = true;
        print('🎤 [AudioVideoService] Recorder initialized');
      }

      // Request microphone permission
      final micStatus = await Permission.microphone.request();
      print('🎤 [AudioVideoService] Microphone permission: ${micStatus.isGranted}');
      
      if (!micStatus.isGranted) {
        print('❌ [AudioVideoService] Microphone permission denied');
        Get.snackbar(
          'Microphone Permission',
          'Microphone access is needed for voice recording',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Create temp file for recording
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/recording_$timestamp.aac';
      print('🎤 [AudioVideoService] Recording path: $_currentRecordingPath');

      // Start recording
      await _audioRecorder.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacADTS,
      );
      
      _isRecording = true;
      print('✅ [AudioVideoService] Recording started');
      
      Get.snackbar(
        'Recording Started',
        'Recording audio... Tap stop when done',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      return true;
    } catch (e) {
      print('💥 [AudioVideoService] Error starting recording: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to start recording: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Stop audio recording and get file
  Future<File?> stopAudioRecording() async {
    print('🎤 [AudioVideoService] Stopping audio recording...');
    try {
      if (!_isRecording || _currentRecordingPath == null) {
        print('⚠️ [AudioVideoService] Not currently recording');
        return null;
      }

      // Stop recording
      await _audioRecorder.stopRecorder();
      _isRecording = false;
      print('🎤 [AudioVideoService] Recording stopped');

      // Check if file exists and has content
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        final fileSize = await file.length();
        print('🎤 [AudioVideoService] Recording file size: $fileSize bytes');
        
        if (fileSize > 0) {
          print('✅ [AudioVideoService] Recording saved successfully');
          Get.snackbar(
            'Recording Saved',
            'Audio file ready for analysis',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return file;
        }
      }

      print('⚠️ [AudioVideoService] No audio recorded');
      Get.snackbar(
        'Recording Failed',
        'No audio recorded',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return null;
    } catch (e) {
      print('💥 [AudioVideoService] Error stopping recording: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to stop recording: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      _currentRecordingPath = null;
    }
  }

  /// Check if currently recording
  bool get isRecording => _isRecording;

  /// Pick audio file from storage
  Future<File?> pickAudioFile() async {
    print('🎵 [AudioVideoService] Starting audio file selection...');
    try {
      // Request storage permission
      final permissionStatus = await Permission.storage.request();
      print('🎵 [AudioVideoService] Storage permission: ${permissionStatus.isGranted}');
      
      if (!permissionStatus.isGranted) {
        print('❌ [AudioVideoService] Storage permission denied');
        Get.snackbar(
          'Permission Required',
          'Storage permission is needed to select audio files',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      // Use file_picker for audio files
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        print('ℹ️ [AudioVideoService] No audio file selected');
        Get.snackbar(
          'Cancelled',
          'No audio file selected',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return null;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        print('❌ [AudioVideoService] Invalid file path');
        return null;
      }

      final file = File(filePath);
      print('🎵 [AudioVideoService] Audio file selected: $filePath');
      
      // Check if it's an audio file
      final mimeType = lookupMimeType(file.path);
      print('🎵 [AudioVideoService] MIME type: $mimeType');
      
      if (mimeType?.startsWith('audio/') != true) {
        print('❌ [AudioVideoService] Invalid audio file');
        Get.snackbar(
          'Invalid File',
          'Selected file is not an audio file',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      print('✅ [AudioVideoService] Audio file ready for analysis');
      Get.snackbar(
        'Audio Selected',
        'Ready for emotion analysis',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      return file;
    } catch (e) {
      print('💥 [AudioVideoService] Error picking audio: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to pick audio: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  /// Get file information
  Map<String, dynamic> getFileInfo(File file) {
    print('📄 [AudioVideoService] Getting file info for: ${file.path}');
    try {
      final path = file.path;
      final fileName = path.split('/').last;
      final fileSize = file.lengthSync();
      final mimeType = lookupMimeType(path);
      
      print('📄 [AudioVideoService] File: $fileName, Size: $fileSize, Type: $mimeType');
      
      return {
        'fileName': fileName,
        'fileSize': fileSize,
        'fileSizeFormatted': _formatFileSize(fileSize),
        'mimeType': mimeType,
        'path': path,
      };
    } catch (e) {
      print('💥 [AudioVideoService] Error getting file info: ${e.toString()}');
      return {
        'fileName': 'Unknown',
        'fileSize': 0,
        'fileSizeFormatted': '0 B',
        'mimeType': 'unknown',
        'path': '',
      };
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Clean up resources
  void dispose() {
    print('🧹 [AudioVideoService] Cleaning up resources...');
    if (_isRecording) {
      _audioRecorder.stopRecorder();
      _isRecording = false;
    }
    if (_isRecorderInitialized) {
      _audioRecorder.closeRecorder();
      _isRecorderInitialized = false;
    }
    print('✅ [AudioVideoService] Resources cleaned up');
  }
}