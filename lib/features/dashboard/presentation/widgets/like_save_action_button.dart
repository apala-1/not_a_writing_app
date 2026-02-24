import 'package:flutter/material.dart';
import 'package:not_a_writing_app/theme/colors.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color; // new

  const ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textSecondary, // default if not provided
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}