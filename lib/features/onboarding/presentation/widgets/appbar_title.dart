import 'package:flutter/material.dart';
import 'package:not_a_writing_app/theme/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 1.5,
      shadowColor: Colors.black12,
      titleSpacing: 0,
      title: Row(
        children: [
          // Menu icon
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () {
              // Open drawer or menu action
            },
          ),

          // Logo
          SizedBox(
            height: 40,
            width: 40,
            child: Image.asset(
              'assets/images/pencil.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 8),

          // App name
          const Text(
            'Not A Writing App',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),

      // Right-side actions
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
          onPressed: () {
            // Notification action
          },
        ),
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {
            // Search action
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
