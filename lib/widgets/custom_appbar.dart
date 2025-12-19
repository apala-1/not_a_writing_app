import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Dashboard'),
      centerTitle: true,
      backgroundColor: Colors.pink.shade300,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // handle notifications
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
