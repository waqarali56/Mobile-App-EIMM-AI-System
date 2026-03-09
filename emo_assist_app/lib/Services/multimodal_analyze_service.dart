// lib/Services/multimodal_analyze_service.dart
import 'dart:io';
import 'package:emo_assist_app/Models/MultimodalAnalyzeResponse.dart';
import 'package:emo_assist_app/Resources/api_client.dart';
import 'package:emo_assist_app/Services/AudioConverterService.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

/// Single API for emotion detection: POST /analyze (multimodal).
/// Sends text, optional audio, image, and video in one request.
class MultimodalAnalyzeService {
  final ApiClient _apiClient = ApiClient();
  final AudioConverterService _audioConverter = AudioConverterService();

  /// Analyze multimodal input (text and/or audio, image, video). Only calls POST /analyze.
  Future<ApiResponse<MultimodalAnalyzeResponse>> analyze({
    String text = '',
    File? audio,
    File? image,
    File? video,
  }) async {
    final hasText = text.trim().isNotEmpty;
    final hasAudio = audio != null;
    final hasImage = image != null;
    final hasVideo = video != null;

    if (!hasText && !hasAudio && !hasImage && !hasVideo) {
      return ApiResponse.error('Provide at least one of: text, audio, image, or video.');
    }

    try {
      final fields = <String, String>{
        'text': hasText ? text.trim() : '',
      };

      File? processedAudio = audio;
      if (audio != null && !audio.path.toLowerCase().endsWith('.wav')) {
        processedAudio = await _audioConverter.convertToWav(audio);
        if (processedAudio == null) {
          return ApiResponse.error('Failed to convert audio to WAV');
        }
      }

      final fileList = <http.MultipartFile>[];

      if (processedAudio != null) {
        final multipartAudio = await _apiClient.createMultipartFile(
          processedAudio,
          fieldName: 'audio',
          mimeType: 'audio/wav',
        );
        fileList.add(multipartAudio);
      }
      if (image != null) {
        final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
        final multipartImage = await _apiClient.createMultipartFile(
          image,
          fieldName: 'image',
          mimeType: mimeType,
        );
        fileList.add(multipartImage);
      }
      if (video != null) {
        final mimeType = lookupMimeType(video.path) ?? 'video/mp4';
        final multipartVideo = await _apiClient.createMultipartFile(
          video,
          fieldName: 'video',
          mimeType: mimeType,
        );
        fileList.add(multipartVideo);
      }

      final response = await _apiClient.multipartPost<MultimodalAnalyzeResponse>(
        '/analyze',
        fields: fields,
        files: fileList.isEmpty ? null : fileList,
        fromJson: (json) => MultimodalAnalyzeResponse.fromJson(json),
      );

      if (processedAudio != null && processedAudio.path != audio?.path) {
        try {
          await processedAudio.delete();
        } catch (_) {}
      }

      return response;
    } catch (e) {
      return ApiResponse.error('Analyze failed: ${e.toString()}');
    }
  }
}
