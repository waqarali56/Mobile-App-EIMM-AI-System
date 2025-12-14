// Views/Chat/Widgets/MultiModalOptionsPanel.dart
import 'package:emo_assist_app/ViewModels/Chat/ChatViewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';

class MultiModalOptionsPanel extends StatelessWidget {
  final ChatViewModel viewModel;

  const MultiModalOptionsPanel({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!viewModel.showMultiModalOptions.value)
        return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Constants.cardColor,
          border: Border(
            bottom: BorderSide(color: Constants.dividerColor, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Multi-modal Emotion Detection',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Constants.textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: Constants.textColor.withOpacity(0.6),
                  ),
                  onPressed: () => viewModel.toggleMultiModalOptions(false),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildModalOption(
                  icon: Icons.text_fields,
                  label: 'Text Analysis',
                  isActive: true,
                  percentage: viewModel.textSentimentPercentage,
                ),
                _buildModalOption(
                  icon: Icons.mic,
                  label: 'Tone Analysis',
                  isActive: viewModel.isPremiumUser.value,
                  percentage: viewModel.voiceTonePercentage,
                ),
                _buildModalOption(
                  icon: Icons.face,
                  label: 'Expression',
                  isActive: viewModel.isPremiumUser.value,
                  percentage: viewModel.facialExpressionPercentage,
                ),
              ],
            ),
            const SizedBox(height: 8),

            //   // Fused emotion result
            //   Container(
            //     padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
            //     decoration: BoxDecoration(
            //       color: Constants.primaryColor.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: Row(
            //       children: [
            //         const Icon(
            //           Icons.insights,
            //           size: 18,
            //           color: Constants.primaryColor,
            //         ),
            //         const SizedBox(width: 12),
            //         Expanded(
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               const Text(
            //                 'Fused Emotion:',
            //                 style: TextStyle(
            //                   fontSize: 12,
            //                   color: Constants.textColor,
            //                 ),
            //               ),
            //               Obx(() {
            //                 return Text(
            //                   viewModel.currentEmotion.value,
            //                   style: const TextStyle(
            //                     fontSize: 12,
            //                     fontWeight: FontWeight.w600,
            //                     color: Constants.textColor,
            //                   ),
            //                 );
            //               }),
            //             ],
            //           ),
            //         ),
            //         const Icon(
            //           Icons.info_outline,
            //           size: 16,
            //           color: Constants.textColor,
            //         ),
            //       ],
            //     ),
            //   ),
          ],
        ),
      );
    });
  }

  Widget _buildModalOption({
    required IconData icon,
    required String label,
    required bool isActive,
    required String percentage,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? Constants.primaryColor.withOpacity(0.1)
                : Constants.inputBackground,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isActive ? Constants.primaryColor : Constants.dividerColor,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 24,
              color: isActive
                  ? Constants.primaryColor
                  : Constants.textColor.withOpacity(0.4),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive
                ? Constants.textColor
                : Constants.textColor.withOpacity(0.4),
          ),
        ),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive
                ? Constants.primaryColor
                : Constants.textColor.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
