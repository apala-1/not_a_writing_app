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
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const SizedBox(width: 18), // Left padding

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

          // App name with flexible space
          Expanded(
            child: Text(
              'Not A Writing App',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis, // Shrink text with "..." if needed
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
