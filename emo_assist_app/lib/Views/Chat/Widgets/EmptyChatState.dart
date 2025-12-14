// Views/Chat/Widgets/EmptyChatState.dart
import 'package:emo_assist_app/ViewModels/Chat/ChatViewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';

class EmptyChatState extends StatelessWidget {
  final double maxHeight;
  final ChatViewModel viewModel;

  const EmptyChatState({
    super.key,
    required this.maxHeight,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: maxHeight - 120, // Reserve space for input area
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome illustration
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Constants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(75),
                ),
                child: Icon(
                  Icons.psychology,
                  size: 80,
                  color: Constants.primaryColor,
                ),
              ),
              const SizedBox(height: 30),

              // Welcome text
              const Text(
                'Welcome to MindSpace',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Constants.textColor,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              const Text(
                'Your emotional support companion.\nShare your thoughts, feelings, or just chat.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Constants.textColor),
              ),
              const SizedBox(height: 30),

              // Quick suggestions
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildQuickSuggestion('How are you feeling today?'),
                  _buildQuickSuggestion('I need someone to talk to'),
                  _buildQuickSuggestion('Share my thoughts'),
                  _buildQuickSuggestion('Get emotional support'),
                ],
              ),
              const SizedBox(height: 30),

              // Multi-modal feature showcase
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Constants.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Constants.dividerColor.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Multi-modal Features',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Constants.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeatureItem(Icons.text_fields, 'Text Sentiment'),
                        _buildFeatureItem(Icons.mic, 'Voice Tone'),
                        _buildFeatureItem(Icons.face, 'Facial Expression'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSuggestion(String text) {
    return GestureDetector(
      onTap: () {
        viewModel.sendMessage(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Constants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Constants.primaryColor.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 12, color: Constants.primaryColor),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Constants.primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Constants.textColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}