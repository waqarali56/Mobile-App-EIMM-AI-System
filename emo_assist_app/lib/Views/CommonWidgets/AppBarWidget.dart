// Views/Chat/Widgets/AppBar.dart (Alternative version)
import 'package:emo_assist_app/ViewModels/Chat/ChatViewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final RxBool showMultiModalOptions = false.obs;

  AppBarWidget({super.key, required this.scaffoldKey});

  // Helper method to check if current route is chat screen
  bool get _isChatScreen {
    final currentRoute = Get.currentRoute;
    return currentRoute.contains('/chat') || 
           currentRoute == '/' || // Assuming home is chat
           currentRoute.contains('ChatScreen');
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Constants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
        tooltip: 'Menu',
      ),
      title: _buildAppBarTitle(),
      actions: _buildAppBarActions(),
    );
  }

  Widget _buildAppBarTitle() {
    final ChatViewModel viewModel = Get.find<ChatViewModel>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.psychology,
                size: 14,
                color: Colors.white,
              ),
            ),
            const Text(
              'MindSpace',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Obx(() {
          return Text(
            viewModel.isGuestMode.value ? 'Guest Mode' : '',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
            ),
          );
        }),
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    final ChatViewModel viewModel = Get.find<ChatViewModel>();
    
    List<Widget> actions = [];

    // Multi-modal toggle button - only show on chat screen
    if (_isChatScreen) {
      actions.add(
        Obx(() {
          return IconButton(
            icon: Icon(
              showMultiModalOptions.value
                  ? Icons.settings_input_component
                  : Icons.sensors,
              color: Colors.white,
            ),
            onPressed: () {
              showMultiModalOptions.value = !showMultiModalOptions.value;
              viewModel.toggleMultiModalOptions(showMultiModalOptions.value);
            },
            tooltip: 'Multi-modal Options',
          );
        }),
      );
    }

    // Profile button - always show (use NavigationService so profile opens correctly)
    actions.add(
      Container(
        margin: EdgeInsets.only(right: _isChatScreen ? 8 : 12),
        child: InkWell(
          onTap: () {
            scaffoldKey.currentState?.closeDrawer();
            NavigationService.goToProfile();
          },
          borderRadius: BorderRadius.circular(20),
          child: Obx(() {
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: viewModel.isGuestMode.value ? 20 : 22,
              ),
            );
          }),
        ),
      ),
    );

    return actions;
  }
}