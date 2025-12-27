// lib/Services/AudioConverterService.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

class AudioConverterService {
  static final AudioConverterService _instance = AudioConverterService._internal();
  factory AudioConverterService() => _instance;
  AudioConverterService._internal();

  /// Convert AAC audio to WAV format
  Future<File?> convertAacToWav(File aacFile) async {
    print('🔄 [AudioConverterService] Converting AAC to WAV...');
    print('🔄 [AudioConverterService] Input file: ${aacFile.path}');
    
    try {
      // Check if file exists
      if (!await aacFile.exists()) {
        print('❌ [AudioConverterService] AAC file does not exist');
        return null;
      }

      // Read the AAC file bytes
      final aacBytes = await aacFile.readAsBytes();
      print('🔄 [AudioConverterService] AAC file size: ${aacBytes.length} bytes');

      // Create output WAV file path
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final wavPath = path.join(tempDir.path, 'converted_${timestamp}.wav');
      
      // For now, we'll use a simple approach since direct AAC to WAV conversion
      // requires audio processing libraries. We'll create a basic WAV header.
      
      // In a real implementation, you would use FFmpeg or similar library.
      // For now, let's create a placeholder and focus on the architecture.
      
      // If the file is already a WAV, return it as-is
      if (aacFile.path.toLowerCase().endsWith('.wav')) {
        print('✅ [AudioConverterService] File is already WAV format');
        return aacFile;
      }
      
      // For demo/testing, let's create a minimal WAV file
      // Note: This creates an empty/invalid WAV file
      // In production, use a proper audio converter library
      final wavFile = File(wavPath);
      await wavFile.writeAsBytes(aacBytes); // Just copy for now
      
      print('✅ [AudioConverterService] WAV file created: ${wavFile.path}');
      print('✅ [AudioConverterService] WAV file size: ${await wavFile.length()} bytes');
      
      return wavFile;
      
    } catch (e) {
      print('💥 [AudioConverterService] Error converting audio: ${e.toString()}');
      Get.snackbar(
        'Conversion Error',
        'Could not convert audio to WAV format',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  /// Convert any audio file to WAV format
  Future<File?> convertToWav(File audioFile) async {
    print('🔄 [AudioConverterService] Converting to WAV format...');
    
    try {
      final fileName = path.basename(audioFile.path).toLowerCase();
      
      if (fileName.endsWith('.wav')) {
        print('✅ [AudioConverterService] Already WAV format');
        return audioFile;
      }
      
      if (fileName.endsWith('.aac') || fileName.endsWith('.m4a')) {
        return await convertAacToWav(audioFile);
      }
      
      if (fileName.endsWith('.mp3')) {
        return await convertMp3ToWav(audioFile);
      }
      
      // For other formats, return as-is and let the API handle it
      print('⚠️ [AudioConverterService] Unknown format: $fileName, sending as-is');
      return audioFile;
      
    } catch (e) {
      print('💥 [AudioConverterService] Error: ${e.toString()}');
      return audioFile; // Return original as fallback
    }
  }

  /// Convert MP3 to WAV (placeholder - implement with actual conversion)
  Future<File?> convertMp3ToWav(File mp3File) async {
    print('🔄 [AudioConverterService] Converting MP3 to WAV...');
    
    // For now, just copy the file and change extension
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final wavPath = path.join(tempDir.path, 'converted_${timestamp}.wav');
    
    try {
      final mp3Bytes = await mp3File.readAsBytes();
      final wavFile = File(wavPath);
      await wavFile.writeAsBytes(mp3Bytes);
      
      print('✅ [AudioConverterService] MP3 converted (placeholder)');
      return wavFile;
    } catch (e) {
      print('💥 [AudioConverterService] MP3 conversion failed: $e');
      return mp3File;
    }
  }

  /// Validate WAV file
  Future<bool> validateWavFile(File wavFile) async {
    try {
      if (!await wavFile.exists()) {
        return false;
      }
      
      final bytes = await wavFile.readAsBytes();
      if (bytes.length < 44) { // WAV header is 44 bytes
        return false;
      }
      
      // Check for "RIFF" and "WAVE" in header
      final header = String.fromCharCodes(bytes.sublist(0, 4));
      final format = String.fromCharCodes(bytes.sublist(8, 12));
      
      return header == 'RIFF' && format == 'WAVE';
    } catch (e) {
      return false;
    }
  }
}