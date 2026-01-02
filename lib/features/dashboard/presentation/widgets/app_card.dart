import 'package:flutter/material.dart';
import 'package:not_a_writing_app/theme/colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: AppColors.cardBackground,
      elevation: 1.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    return onTap != null
        ? InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: card,
          )
        : card;
  }
}
