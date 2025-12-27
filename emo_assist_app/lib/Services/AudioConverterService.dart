// lib/Services/AudioConverterService.dart
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AudioConverterService {
  static final AudioConverterService _instance = AudioConverterService._internal();
  factory AudioConverterService() => _instance;
  AudioConverterService._internal();

  /// Convert any audio file to WAV format (placeholder)
  /// Note: In a real app, you'd use FFmpeg or another audio processing library
  Future<File?> convertToWav(File audioFile) async {
    print('🔄 [AudioConverterService] Converting to WAV format...');
    
    try {
      final fileName = path.basename(audioFile.path).toLowerCase();
      
      // If already WAV, return as-is
      if (fileName.endsWith('.wav')) {
        print('✅ [AudioConverterService] Already WAV format');
        return audioFile;
      }
      
      // For other formats, we'll just copy and rename
      // In production, implement actual conversion with FFmpeg
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final wavPath = path.join(tempDir.path, 'converted_${timestamp}.wav');
      
      // Read original file
      final bytes = await audioFile.readAsBytes();
      
      // Create new file with .wav extension
      final wavFile = File(wavPath);
      await wavFile.writeAsBytes(bytes);
      
      print('✅ [AudioConverterService] File copied to: ${wavFile.path}');
      print('⚠️ [AudioConverterService] Note: Actual audio conversion not implemented');
      print('⚠️ [AudioConverterService] API may not accept non-WAV files properly');
      
      return wavFile;
      
    } catch (e) {
      print('💥 [AudioConverterService] Error converting audio: $e');
      return audioFile; // Return original as fallback
    }
  }

  /// Validate WAV file (basic check)
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
      print('⚠️ [AudioConverterService] Error validating WAV: $e');
      return false;
    }
  }
}