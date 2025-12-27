// lib/Services/AudioVideoService.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class AudioVideoService {
  static final AudioVideoService _instance = AudioVideoService._internal();
  factory AudioVideoService() => _instance;
  AudioVideoService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  
  // Flutter Sound recorder
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  String? _currentRecordingPath;
  Timer? _recordingTimer;
  int _recordingDurationSeconds = 0;

  /// Initialize the audio recorder
  Future<void> _initializeRecorder() async {
    if (_isRecorderInitialized) return;
    
    try {
      await _audioRecorder.openRecorder();
      _isRecorderInitialized = true;
      print('✅ [AudioVideoService] Audio recorder initialized');
    } catch (e) {
      print('💥 [AudioVideoService] Error initializing recorder: $e');
      _isRecorderInitialized = false;
    }
  }

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

  /// Start audio recording in WAV format
  Future<bool> startAudioRecording() async {
    print('🎤 [AudioVideoService] Starting audio recording...');
    try {
      // Check if already recording
      if (_isRecording) {
        print('⚠️ [AudioVideoService] Already recording');
        return false;
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

      // Initialize recorder if needed
      await _initializeRecorder();
      if (!_isRecorderInitialized) {
        print('❌ [AudioVideoService] Recorder not initialized');
        return false;
      }

      // Create WAV file for recording
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = path.join(tempDir.path, 'recording_$timestamp.wav');
      print('🎤 [AudioVideoService] Recording WAV file: $_currentRecordingPath');

      // Start recording in WAV format
      await _audioRecorder.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.pcm16WAV, // Use WAV format
        sampleRate: 16000,     // 16kHz for speech recognition
      );
      
      _isRecording = true;
      _recordingDurationSeconds = 0;
      
      // Start timer for duration tracking
      _startRecordingTimer();
      
      print('✅ [AudioVideoService] WAV recording started successfully');
      print('🎤 [AudioVideoService] Recording configuration:');
      print('🎤 [AudioVideoService]   - Format: WAV (PCM16)');
      print('🎤 [AudioVideoService]   - Sample Rate: 16kHz');
      
      Get.snackbar(
        '🎤 Recording Started',
        'Recording audio in WAV format...\nSpeak clearly for best results',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
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

  /// Start recording timer
  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording) {
        _recordingDurationSeconds++;
        print('🎤 [AudioVideoService] Recording duration: ${_recordingDurationSeconds}s');
      } else {
        timer.cancel();
      }
    });
  }

  /// Stop audio recording and get WAV file
  Future<File?> stopAudioRecording() async {
    print('🎤 [AudioVideoService] Stopping recording...');
    try {
      if (!_isRecording || _currentRecordingPath == null) {
        print('⚠️ [AudioVideoService] Not currently recording');
        return null;
      }

      // Stop recording
      await _audioRecorder.stopRecorder();
      _isRecording = false;
      
      // Stop timer
      _recordingTimer?.cancel();
      _recordingTimer = null;
      
      print('🎤 [AudioVideoService] Recording stopped');
      print('🎤 [AudioVideoService] Total recording duration: ${_recordingDurationSeconds} seconds');

      // Small delay to ensure file is written
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if file exists
      final file = File(_currentRecordingPath!);
      
      if (!await file.exists()) {
        print('❌ [AudioVideoService] WAV file does not exist');
        Get.snackbar(
          'Recording Failed',
          'No audio file was created',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return null;
      }

      // Check file size
      final fileSize = await file.length();
      print('🎤 [AudioVideoService] WAV file size: $fileSize bytes');
      
      if (fileSize < 1024) { // Less than 1KB
        print('⚠️ [AudioVideoService] WAV file is too small');
        Get.snackbar(
          'Recording Too Short',
          'Please record for at least 2 seconds',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return null;
      }

      // Validate WAV format
      final isValidWav = await _validateWavFile(file);
      if (!isValidWav) {
        print('⚠️ [AudioVideoService] WAV file validation failed');
        // Continue anyway - the API might still accept it
      } else {
        print('✅ [AudioVideoService] Valid WAV file format');
      }

      // Check minimum duration (at least 2 seconds)
      if (_recordingDurationSeconds < 2) {
        print('⚠️ [AudioVideoService] Recording too short for analysis');
        Get.snackbar(
          'Recording Too Short',
          'Please record for at least 2 seconds for accurate analysis',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return null;
      }

      print('✅ [AudioVideoService] WAV recording saved successfully');
      print('✅ [AudioVideoService] File path: ${file.path}');
      
      Get.snackbar(
        '✅ Recording Saved',
        '${_recordingDurationSeconds}s WAV audio ready for analysis',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      return file;
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
      _resetRecordingState();
    }
  }

  /// Validate WAV file format
  Future<bool> _validateWavFile(File wavFile) async {
    try {
      final bytes = await wavFile.readAsBytes();
      
      if (bytes.length < 44) {
        return false; // WAV header is at least 44 bytes
      }
      
      // Check RIFF header
      final riffHeader = String.fromCharCodes(bytes.sublist(0, 4));
      if (riffHeader != 'RIFF') {
        return false;
      }
      
      // Check WAVE format
      final waveFormat = String.fromCharCodes(bytes.sublist(8, 12));
      if (waveFormat != 'WAVE') {
        return false;
      }
      
      return true;
    } catch (e) {
      print('⚠️ [AudioVideoService] Error validating WAV: $e');
      return false;
    }
  }

  /// Reset recording state
  void _resetRecordingState() {
    _isRecording = false;
    _currentRecordingPath = null;
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _recordingDurationSeconds = 0;
  }

  /// Cancel current recording
  Future<void> cancelRecording() async {
    if (!_isRecording) return;
    
    print('🎤 [AudioVideoService] Cancelling recording...');
    
    try {
      await _audioRecorder.stopRecorder();
    } catch (e) {
      print('⚠️ [AudioVideoService] Error cancelling recording: $e');
    } finally {
      _resetRecordingState();
      print('✅ [AudioVideoService] Recording cancelled');
      
      Get.snackbar(
        'Recording Cancelled',
        'Audio recording was cancelled',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  /// Check if currently recording
  bool get isRecording => _isRecording;

  /// Get current recording duration in seconds
  int get recordingDuration => _recordingDurationSeconds;

  /// Get formatted recording duration
  String get formattedRecordingDuration {
    final minutes = (_recordingDurationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordingDurationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Pick audio file from storage (any format)
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
        // Supported audio extensions
        allowedExtensions: ['wav', 'mp3', 'm4a', 'aac', 'flac', 'ogg', 'wma'],
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

      // Check file size (max 10MB for audio)
      final fileSize = await file.length();
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (fileSize > maxSize) {
        print('❌ [AudioVideoService] File too large: ${fileSize} bytes');
        Get.snackbar(
          'File Too Large',
          'Audio file exceeds 10MB limit',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      print('✅ [AudioVideoService] Audio file ready for analysis');
      print('🎵 [AudioVideoService] File format: ${path.extension(filePath).toLowerCase()}');
      
      Get.snackbar(
        '✅ Audio Selected',
        '${path.basename(filePath)} ready for emotion analysis',
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

  /// Get file information with enhanced details
  Map<String, dynamic> getFileInfo(File file) {
    print('📄 [AudioVideoService] Getting file info for: ${file.path}');
    try {
      final filePath = file.path;
      final fileName = path.basename(filePath);
      final fileSize = file.lengthSync();
      final mimeType = lookupMimeType(filePath);
      final extension = path.extension(filePath).toLowerCase();
      
      // Detect audio format
      String format = 'Unknown';
      if (extension == '.wav') {
        format = 'WAV Audio';
      } else if (extension == '.mp3') {
        format = 'MP3 Audio';
      } else if (extension == '.m4a' || extension == '.aac') {
        format = 'AAC Audio';
      } else if (extension == '.flac') {
        format = 'FLAC Audio';
      } else if (mimeType?.startsWith('audio/') == true) {
        format = 'Audio File';
      } else if (mimeType?.startsWith('video/') == true) {
        format = 'Video File';
      } else if (mimeType?.startsWith('image/') == true) {
        format = 'Image File';
      }
      
      print('📄 [AudioVideoService] File: $fileName');
      print('📄 [AudioVideoService] Size: ${_formatFileSize(fileSize)}');
      print('📄 [AudioVideoService] Type: $format ($mimeType)');
      
      return {
        'fileName': fileName,
        'filePath': filePath,
        'fileSize': fileSize,
        'fileSizeFormatted': _formatFileSize(fileSize),
        'mimeType': mimeType ?? 'unknown',
        'format': format,
        'extension': extension,
        'canAnalyze': mimeType?.startsWith('audio/') == true || 
                      mimeType?.startsWith('video/') == true ||
                      mimeType?.startsWith('image/') == true,
      };
    } catch (e) {
      print('💥 [AudioVideoService] Error getting file info: ${e.toString()}');
      return {
        'fileName': 'Unknown',
        'filePath': '',
        'fileSize': 0,
        'fileSizeFormatted': '0 B',
        'mimeType': 'unknown',
        'format': 'Unknown',
        'extension': '',
        'canAnalyze': false,
      };
    }
  }

  /// Format file size for display
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

  /// Check device recording capabilities
  Future<Map<String, dynamic>> checkRecordingCapabilities() async {
    print('🔍 [AudioVideoService] Checking recording capabilities...');
    try {
      final hasPermission = await Permission.microphone.isGranted;
      
      // Check if recorder can be initialized
      await _initializeRecorder();
      final canRecord = _isRecorderInitialized && hasPermission;
      
      print('🔍 [AudioVideoService] Has permission: $hasPermission');
      print('🔍 [AudioVideoService] Recorder initialized: $_isRecorderInitialized');
      
      return {
        'hasPermission': hasPermission,
        'recorderInitialized': _isRecorderInitialized,
        'canRecord': canRecord,
        'message': hasPermission 
            ? (_isRecorderInitialized ? 'Ready to record' : 'Recorder initialization failed')
            : 'Microphone permission required',
      };
    } catch (e) {
      print('⚠️ [AudioVideoService] Error checking capabilities: $e');
      return {
        'hasPermission': false,
        'recorderInitialized': false,
        'canRecord': false,
        'message': 'Unable to check recording capabilities',
      };
    }
  }

  /// Get audio recording tips
  List<String> getRecordingTips() {
    return [
      '🎤 Speak clearly and at a normal volume',
      '🎤 Record in a quiet environment',
      '🎤 Hold the device close to your mouth',
      '🎤 Record for at least 3 seconds for best results',
      '🎤 Try to express genuine emotions in your voice',
      '🎤 Avoid background music or noise',
    ];
  }

  /// Clean up resources
  void dispose() {
    print('🧹 [AudioVideoService] Cleaning up resources...');
    
    if (_isRecording) {
      cancelRecording();
    }
    
    if (_isRecorderInitialized) {
      _audioRecorder.closeRecorder();
      _isRecorderInitialized = false;
    }
    
    _resetRecordingState();
    
    print('✅ [AudioVideoService] Resources cleaned up');
  }

  @override
  String toString() {
    return 'AudioVideoService{isRecording: $_isRecording, duration: ${_recordingDurationSeconds}s}';
  }
}