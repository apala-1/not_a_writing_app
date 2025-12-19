import 'package:flutter/material.dart';
import 'package:not_a_writing_app/widgets/profile_action_tile.dart';
import 'package:not_a_writing_app/widgets/profile_header.dart';
import 'package:not_a_writing_app/widgets/profile_stat_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade50,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ProfileHeader(),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ProfileStatCard(label: 'Posts', value: '12'),
                ProfileStatCard(label: 'Streak', value: '4 🔥'),
                ProfileStatCard(label: 'Reads', value: '9'),
              ],
            ),

            const SizedBox(height: 32),

            ProfileActionTile(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {},
            ),
            ProfileActionTile(
              icon: Icons.bookmark,
              title: 'Saved Posts',
              onTap: () {},
            ),
            ProfileActionTile(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {},
            ),
            ProfileActionTile(
              icon: Icons.logout,
              title: 'Log Out',
              iconColor: Colors.red,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
