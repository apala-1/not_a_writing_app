import 'package:flutter/material.dart';
import 'package:not_a_writing_app/theme/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  // Modern Orange Rose Palette
  static const Color primaryOrange = Color(0xFFFF7F00);
  static const Color roseAccent = Color(0xFFF25C78);
  static const Color textDark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Styled Logo Container
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/pencil.png',
                  height: 28,
                  width: 28,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              // Gradient-ish Text or Bold Typography
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NOT A',
                    style: TextStyle(
                      color: roseAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'Writing App',
                    style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          // Styled Action Buttons
          _buildActionButton(
            icon: Icons.search_rounded,
            onPressed: () {
              // Search action
            },
          ),
          _buildActionButton(
            icon: Icons.notifications_none_rounded,
            onPressed: () {
              // Notification action
            },
            hasBadge: true,
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool hasBadge = false,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: textDark, size: 26),
          splashRadius: 24,
        ),
        if (hasBadge)
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: roseAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}