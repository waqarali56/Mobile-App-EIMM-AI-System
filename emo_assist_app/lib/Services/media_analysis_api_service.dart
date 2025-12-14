// lib/Services/MediaAnalysisService.dart
import '../Models/MediaEmotionData.dart';
import '../Resources/api_client.dart';
import 'dart:io';
import 'package:mime/mime.dart';

class MediaAnalysisService {
  final ApiClient _apiClient = ApiClient();

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

  /// Analyze voice/audio for emotion detection
  Future<ApiResponse<VoiceEmotionData>> analyzeVoice(File audioFile) async {
    print('🎤 [MediaAnalysisService] Starting voice analysis...');
    print('🎤 [MediaAnalysisService] Audio path: ${audioFile.path}');
    
    try {
      final mimeType = lookupMimeType(audioFile.path);
      print('🎤 [MediaAnalysisService] Detected MIME type: $mimeType');
      
      final multipartFile = await _apiClient.createMultipartFile(
        audioFile,
        fieldName: 'file',
        mimeType: mimeType,
      );
      print('🎤 [MediaAnalysisService] Multipart file created successfully');
      
      print('🎤 [MediaAnalysisService] Sending POST request to /predict/voice');
      final response = await _apiClient.multipartPost(
        '/predict/voice',
        files: [multipartFile],
        fromJson: (json) => VoiceEmotionData.fromJson(json),
      );
      
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