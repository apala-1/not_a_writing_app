import 'package:flutter/material.dart';
import 'package:not_a_writing_app/theme/colors.dart';
import 'package:not_a_writing_app/widgets/profile_action_tile.dart';
import 'package:not_a_writing_app/widgets/profile_header.dart';
import 'package:not_a_writing_app/widgets/profile_stat_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 40),
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
              backgroundColor: AppColors.cardBackground,
              iconColor: AppColors.primaryOrange,
              onTap: () {},
            ),
            ProfileActionTile(
              icon: Icons.bookmark,
              title: 'Saved Posts',
              backgroundColor: AppColors.cardBackground,
              iconColor: AppColors.textSecondary,
              onTap: () {},
            ),
            ProfileActionTile(
              icon: Icons.settings,
              title: 'Settings',
              backgroundColor: AppColors.cardBackground,
              iconColor: AppColors.textSecondary,
              onTap: () {},
            ),
            ProfileActionTile(
              icon: Icons.logout,
              title: 'Log Out',
              backgroundColor: AppColors.cardBackground,
              iconColor: Colors.red,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
