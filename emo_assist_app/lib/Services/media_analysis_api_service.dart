// lib/Services/MediaAnalysisService.dart
import '../Models/MediaEmotionData.dart';
import '../Resources/api_client.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'AudioConverterService.dart';

class MediaAnalysisService {
  final ApiClient _apiClient = ApiClient();
  final AudioConverterService _audioConverter = AudioConverterService();

  /// Analyze voice/audio for emotion detection
  Future<ApiResponse<VoiceEmotionData>> analyzeVoice(File audioFile) async {
    print('🎤 [MediaAnalysisService] Starting voice analysis...');
    print('🎤 [MediaAnalysisService] Audio path: ${audioFile.path}');
    print('🎤 [MediaAnalysisService] File extension: ${audioFile.path.split('.').last}');
    
    try {
      // Convert to WAV format if needed
      File? processedAudioFile = audioFile;
      
      if (!audioFile.path.toLowerCase().endsWith('.wav')) {
        print('🔄 [MediaAnalysisService] Converting audio to WAV format...');
        processedAudioFile = await _audioConverter.convertToWav(audioFile);
        
        if (processedAudioFile == null) {
          return ApiResponse.error('Failed to convert audio to WAV format');
        }
        
        print('✅ [MediaAnalysisService] Audio converted to WAV: ${processedAudioFile.path}');
      } else {
        print('✅ [MediaAnalysisService] Audio is already in WAV format');
      }

      // Validate WAV file
      final isValidWav = await _audioConverter.validateWavFile(processedAudioFile!);
      if (!isValidWav) {
        print('⚠️ [MediaAnalysisService] WAV file validation failed, but proceeding anyway');
      } else {
        print('✅ [MediaAnalysisService] WAV file validation passed');
      }

      // Check file size
      final fileSize = await processedAudioFile.length();
      print('🎤 [MediaAnalysisService] WAV file size: $fileSize bytes');
      
      if (fileSize < 1024) { // Less than 1KB
        return ApiResponse.error('Audio file is too small for analysis');
      }

      // Prepare multipart file
      final multipartFile = await _apiClient.createMultipartFile(
        processedAudioFile,
        fieldName: 'file',
        mimeType: 'audio/wav', // Force WAV MIME type
      );
      
      print('🎤 [MediaAnalysisService] Multipart file created successfully');
      print('🎤 [MediaAnalysisService] Sending POST request to /predict/voice');

      // Send to API
      final response = await _apiClient.multipartPost(
        '/predict/voice',
        files: [multipartFile],
        fromJson: (json) => VoiceEmotionData.fromJson(json),
      );

      // Clean up converted file if it's different from original
      if (processedAudioFile.path != audioFile.path) {
        try {
          await processedAudioFile.delete();
          print('🗑️ [MediaAnalysisService] Temporary WAV file deleted');
        } catch (e) {
          print('⚠️ [MediaAnalysisService] Failed to delete temp file: $e');
        }
      }

      if (response.success) {
        print('✅ [MediaAnalysisService] Voice analysis successful');
        print('✅ [MediaAnalysisService] Response data: ${response.data}');
        return ApiResponse.success(response.data!);
      } else {
        print('❌ [MediaAnalysisService] Voice analysis failed: ${response.message}');
        return ApiResponse.error(response.message ?? 'Voice analysis failed');
      }
    } catch (e) {
      print('💥 [MediaAnalysisService] Exception in analyzeVoice: ${e.toString()}');
      print('💥 [MediaAnalysisService] Stack trace: ${StackTrace.current}');
      return ApiResponse.error('Failed to analyze voice: ${e.toString()}');
    }
  }

  

  /// Analyze image for emotion detection
  Future<ApiResponse<ImageEmotionData>> analyzeImage(File imageFile) async {
    print('📸 [MediaAnalysisService] Starting image analysis...');
    print('📸 [MediaAnalysisService] Image path: ${imageFile.path}');
    
    try {
      final mimeType = lookupMimeType(imageFile.path);
      print('📸 [MediaAnalysisService] Detected MIME type: $mimeType');
      
      final multipartFile = await _apiClient.createMultipartFile(
        imageFile,
        fieldName: 'file',
        mimeType: mimeType,
      );
      print('📸 [MediaAnalysisService] Multipart file created successfully');
      
      print('📸 [MediaAnalysisService] Sending POST request to /predict/image');
      final response = await _apiClient.multipartPost(
        '/predict/image',
        files: [multipartFile],
        fromJson: (json) => ImageEmotionData.fromJson(json),
      );
      
      if (response.success) {
        print('✅ [MediaAnalysisService] Image analysis successful');
        print('✅ [MediaAnalysisService] Response data: ${response.data}');
        return ApiResponse.success(response.data!);
      } else {
        print('❌ [MediaAnalysisService] Image analysis failed: ${response.message}');
        return ApiResponse.error(response.message ?? 'Image analysis failed');
      }
    } catch (e) {
      print('💥 [MediaAnalysisService] Exception in analyzeImage: ${e.toString()}');
      print('💥 [MediaAnalysisService] Stack trace: ${StackTrace.current}');
      return ApiResponse.error('Failed to analyze image: ${e.toString()}');
    }
  }

  /// Analyze video for emotion detection
  Future<ApiResponse<VideoEmotionData>> analyzeVideo(File videoFile) async {
    print('🎥 [MediaAnalysisService] Starting video analysis...');
    print('🎥 [MediaAnalysisService] Video path: ${videoFile.path}');
    
    try {
      final mimeType = lookupMimeType(videoFile.path);
      print('🎥 [MediaAnalysisService] Detected MIME type: $mimeType');
      
      final multipartFile = await _apiClient.createMultipartFile(
        videoFile,
        fieldName: 'file',
        mimeType: mimeType,
      );
      print('🎥 [MediaAnalysisService] Multipart file created successfully');
      
      print('🎥 [MediaAnalysisService] Sending POST request to /predict/video');
      final response = await _apiClient.multipartPost(
        '/predict/video',
        files: [multipartFile],
        fromJson: (json) => VideoEmotionData.fromJson(json),
      );
      
      if (response.success) {
        print('✅ [MediaAnalysisService] Video analysis successful');
        print('✅ [MediaAnalysisService] Response data: ${response.data}');
        return ApiResponse.success(response.data!);
      } else {
        print('❌ [MediaAnalysisService] Video analysis failed: ${response.message}');
        return ApiResponse.error(response.message ?? 'Video analysis failed');
      }
    } catch (e) {
      print('💥 [MediaAnalysisService] Exception in analyzeVideo: ${e.toString()}');
      print('💥 [MediaAnalysisService] Stack trace: ${StackTrace.current}');
      return ApiResponse.error('Failed to analyze video: ${e.toString()}');
    }
  }

 

  /// Analyze image from bytes
  Future<ApiResponse<ImageEmotionData>> analyzeImageBytes(
    List<int> imageBytes, {
    String fileName = 'image.jpg',
    String mimeType = 'image/jpeg',
  }) async {
    print('📷 [MediaAnalysisService] Starting image analysis from bytes...');
    print('📷 [MediaAnalysisService] File name: $fileName');
    print('📷 [MediaAnalysisService] MIME type: $mimeType');
    print('📷 [MediaAnalysisService] Bytes length: ${imageBytes.length}');
    
    try {
      final multipartFile = await _apiClient.createMultipartFileFromBytes(
        imageBytes,
        fileName: fileName,
        mimeType: mimeType,
        fieldName: 'file',
      );
      print('📷 [MediaAnalysisService] Multipart file created from bytes successfully');
      
      print('📷 [MediaAnalysisService] Sending POST request to /predict/image');
      final response = await _apiClient.multipartPost(
        '/predict/image',
        files: [multipartFile],
        fromJson: (json) => ImageEmotionData.fromJson(json),
      );
      
      if (response.success) {
        print('✅ [MediaAnalysisService] Image bytes analysis successful');
        print('✅ [MediaAnalysisService] Response data: ${response.data}');
        return ApiResponse.success(response.data!);
      } else {
        print('❌ [MediaAnalysisService] Image bytes analysis failed: ${response.message}');
        return ApiResponse.error(response.message ?? 'Image analysis failed');
      }
    } catch (e) {
      print('💥 [MediaAnalysisService] Exception in analyzeImageBytes: ${e.toString()}');
      print('💥 [MediaAnalysisService] Stack trace: ${StackTrace.current}');
      return ApiResponse.error('Failed to analyze image: ${e.toString()}');
    }
  }
}