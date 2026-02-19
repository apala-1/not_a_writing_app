import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:not_a_writing_app/features/auth/presentation/widgets/profile_action_tile.dart';
import 'package:not_a_writing_app/features/auth/presentation/widgets/profile_stat_card.dart';
import 'package:not_a_writing_app/features/profile/presentation/state/profile_state.dart';
import 'package:not_a_writing_app/features/profile/presentation/viewmodel/profile_view_model.dart';
import 'package:not_a_writing_app/theme/colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
          final userSession = ref.read(userSessionServiceProvider);
          final userId = userSession.getUserId();
      ref.read(profileViewmodelProvider.notifier).fetchFullProfile(userId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewmodelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileState.status == ProfileStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : profileState.status == ProfileStatus.error
              ? Center(
                  child: Text(
                    profileState.errorMessage ?? 'Something went wrong',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : _buildProfileContent(context, profileState),
    );
  }

  Widget _buildProfileContent(
      BuildContext context, ProfileState profileState) {
    final profile = profileState.profileEntity;

    
  debugPrint("Profile Posts Count: ${profile?.postsCount}");
  debugPrint("Profile name: ${profile?.name}");

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),

          /// PROFILE HEADER
          Column(
            children: [
              CircleAvatar(
  radius: 48,
  backgroundColor: AppColors.cardBackground,
  backgroundImage: (profile?.profilePicture != null &&
          profile!.profilePicture.isNotEmpty &&
          profile.profilePicture != 'default-picture.png')
      ? NetworkImage('${ApiEndpoints.mediaServerUrl}/uploads/${profile.profilePicture}')
      : AssetImage('assets/images/google.png') as ImageProvider,
  child: (profile?.profilePicture == null ||
          profile!.profilePicture.isEmpty ||
          profile.profilePicture == 'onb_1.jpg')
      ? const Icon(Icons.person, size: 48)
      : null,
),

              const SizedBox(height: 12),

              Text(
                profile?.name ?? 'No name',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                profile?.occupation ?? '',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),

              if (profile?.bio != null && profile!.bio.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  profile.bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          /// STATS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProfileStatCard(label: 'Posts', value: profile?.postsCount.toString()),
              ProfileStatCard(label: 'Streak', value: '4 🔥'),
              ProfileStatCard(label: 'Reads', value: '9'),
            ],
          ),

          const SizedBox(height: 32),

          /// ACTIONS
          ProfileActionTile(
            icon: Icons.edit,
            title: 'Edit Profile',
            backgroundColor: AppColors.cardBackground,
            iconColor: AppColors.primaryOrange,
            onTap: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
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
            onTap: () async {
              await ref.read(authViewmodelProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }
}