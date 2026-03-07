import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/update_user_usecase.dart';
import 'package:not_a_writing_app/features/profile/presentation/state/profile_state.dart';
import 'package:not_a_writing_app/features/profile/presentation/viewmodel/profile_view_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameCtrl;
  late final TextEditingController bioCtrl;
  late final TextEditingController occupationCtrl;

  // Theme Colors
  static const Color orangePrimary = Color(0xFFF97316);
  static const Color rosePrimary = Color(0xFFF43F5E);
  static const Color bgColor = Color(0xFFFFF7ED);
  static const Color inputBg = Color(0xFFF9FAFB); // gray-50

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileViewmodelProvider.notifier).clearPickedImage();
    });
    final profile = ref.read(profileViewmodelProvider).profileEntity;

    nameCtrl = TextEditingController(text: profile?.name ?? '');
    bioCtrl = TextEditingController(text: profile?.bio ?? '');
    occupationCtrl = TextEditingController(text: profile?.occupation ?? '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    bioCtrl.dispose();
    occupationCtrl.dispose();
    super.dispose();
  }

  ImageProvider? _currentProfileImage(ProfileState state) {
    final picked = state.pickedImage;
    if (picked != null) return FileImage(File(picked.path));

    final pic = state.profileEntity?.profilePicture;
    if (pic == null || pic.isEmpty || pic == 'default-picture.png') return null;

    return NetworkImage('${ApiEndpoints.mediaServerUrl}/uploads/profiles/$pic');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewmodelProvider);
    final vm = ref.read(profileViewmodelProvider.notifier);
    final profile = state.profileEntity;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(top: -50, right: -50, child: _buildBlob(200, orangePrimary.withOpacity(0.1))),
          Positioned(bottom: 100, left: -50, child: _buildBlob(250, rosePrimary.withOpacity(0.08))),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// 1. Profile Picture with Gradient Ring
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [orangePrimary, rosePrimary]),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              backgroundImage: _currentProfileImage(state),
                              child: _currentProfileImage(state) == null
                                  ? const Icon(LucideIcons.user, size: 50, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: vm.pickProfileImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                                ),
                                child: const Icon(LucideIcons.camera, size: 20, color: orangePrimary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// 2. Form Fields inside a Card-like Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Full Name"),
                          _buildTextField(
                            controller: nameCtrl,
                            hint: "Enter your name",
                            icon: LucideIcons.user,
                            validator: (v) {
                              final t = (v ?? '').trim();
                              if (t.isEmpty) return 'Name is required';
                              if (t.length < 2) return 'Too short';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          _buildLabel("Occupation"),
                          _buildTextField(
                            controller: occupationCtrl,
                            hint: "e.g. UX Designer",
                            icon: LucideIcons.briefcase,
                            validator: (v) {
                              if ((v ?? '').trim().isEmpty) return 'Occupation is required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          _buildLabel("Bio"),
                          _buildTextField(
                            controller: bioCtrl,
                            hint: "Tell us about yourself...",
                            icon: LucideIcons.layoutList400,
                            maxLines: 4,
                            validator: (v) {
                              if ((v ?? '').trim().length > 160) return 'Bio too long';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// 3. Save Button
                    _buildSaveButton(state, vm, profile),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40), child: Container(color: Colors.transparent)),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: orangePrimary.withOpacity(0.7)),
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: orangePrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildSaveButton(ProfileState state, ProfileViewmodel vm, dynamic profile) {
    final isLoading = state.status == ProfileStatus.loading;

    return GestureDetector(
      onTap: isLoading ? null : () async {
        if (!_formKey.currentState!.validate()) return;
        if (profile == null) return;

        try {
          await vm.updateProfile(UpdateProfileParams(
            userId: profile.id,
            name: nameCtrl.text.trim(),
            bio: bioCtrl.text.trim(),
            occupation: occupationCtrl.text.trim(),
            profilePicture: state.pickedImage?.path,
            pickedNewImage: state.pickedImage != null,
            token: profile.token,
          ));
          await vm.fetchFullProfile(profile.id);
          if (mounted) Navigator.pop(context);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [orangePrimary, rosePrimary]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: rosePrimary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}