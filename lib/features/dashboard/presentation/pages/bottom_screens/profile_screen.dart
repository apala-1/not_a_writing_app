import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:not_a_writing_app/features/profile/presentation/state/profile_state.dart';
import 'package:not_a_writing_app/features/profile/presentation/viewmodel/profile_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Theme Palette
  static const Color primaryOrange = Color(0xFFFF7F00);
  static const Color roseAccent = Color(0xFFF25C78);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGray = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userSession = ref.read(userSessionServiceProvider);
      final userId = userSession.getUserId();
      if (userId != null) {
        ref.read(profileViewmodelProvider.notifier).fetchFullProfile(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewmodelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: profileState.status == ProfileStatus.loading
          ? const Center(child: CircularProgressIndicator(color: primaryOrange))
          : profileState.status == ProfileStatus.error
              ? _buildErrorState(profileState.errorMessage)
              : _buildProfileContent(context, profileState),
    );
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: roseAccent, size: 60),
          const SizedBox(height: 16),
          Text(message ?? 'Something went wrong', style: const TextStyle(color: textGray)),
          TextButton(
            onPressed: () => setState(() {}),
            child: const Text('Retry', style: TextStyle(color: primaryOrange)),
          )
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileState profileState) {
    final profile = profileState.profileEntity;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with Gradient Backdrop
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryOrange, roseAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
              Positioned(
                top: 130,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFF1F5F9),
                    backgroundImage: (profile?.profilePicture != null &&
                            profile!.profilePicture.isNotEmpty &&
                            profile.profilePicture != 'default-picture.png')
                        ? NetworkImage('${ApiEndpoints.mediaServerUrl}/uploads/profiles/${profile.profilePicture}')
                        : null,
                    child: (profile?.profilePicture == null || profile!.profilePicture.isEmpty)
                        ? const Icon(Icons.person, size: 60, color: textGray)
                        : null,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 70),

          // Identity Info
          Text(
            profile?.name ?? 'Loading name...',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            profile?.occupation ?? 'Storyteller',
            style: const TextStyle(fontSize: 16, color: roseAccent, fontWeight: FontWeight.w600),
          ),
          if (profile?.bio != null && profile!.bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              child: Text(
                profile.bio,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textGray, height: 1.4),
              ),
            ),

          const SizedBox(height: 24),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildModernStatCard('Posts', profile?.postsCount.toString() ?? '0', Icons.article_rounded),
                const SizedBox(width: 12),
                _buildModernStatCard('Streak', '4 🔥', Icons.local_fire_department_rounded),
                const SizedBox(width: 12),
                _buildModernStatCard('Reads', '12', Icons.auto_stories_rounded),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Actions Menu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Account Settings', style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 16)),
                const SizedBox(height: 12),
                _buildActionTile(
                  icon: Icons.edit_rounded,
                  title: 'Edit Profile',
                  color: primaryOrange,
                  onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                ),
                _buildActionTile(
                  icon: Icons.bookmark_rounded,
                  title: 'Saved Collections',
                  color: Colors.blueAccent,
                  onTap: () {},
                ),
                _buildActionTile(
                  icon: Icons.settings_rounded,
                  title: 'Preferences',
                  color: textGray,
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
                const SizedBox(height: 20),
                const Text('Security', style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 16)),
                const SizedBox(height: 12),
                _buildActionTile(
                  icon: Icons.logout_rounded,
                  title: 'Log Out',
                  color: roseAccent,
                  onTap: () async {
                    await ref.read(authViewmodelProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryOrange.withOpacity(0.7), size: 22),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark)),
            Text(label, style: const TextStyle(fontSize: 12, color: textGray, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: textDark)),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: textGray, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}