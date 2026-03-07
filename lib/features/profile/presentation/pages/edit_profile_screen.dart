import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      ref.read(profileViewmodelProvider.notifier).clearPickedImage();
    bioCtrl.dispose();
    occupationCtrl.dispose();
    super.dispose();
  }

  ImageProvider? _currentProfileImage(ProfileState state) {
    final picked = state.pickedImage;
    if (picked != null) return FileImage(File(picked.path));

    final pic = state.profileEntity?.profilePicture;
    if (pic == null || pic.isEmpty || pic == 'default-picture.png') return null;

    // ✅ you said it's in uploads/profiles
    return NetworkImage('${ApiEndpoints.mediaServerUrl}/uploads/profiles/$pic');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewmodelProvider);
    final vm = ref.read(profileViewmodelProvider.notifier);

    final profile = state.profileEntity;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// Profile Picture (current OR picked)
              Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _currentProfileImage(state),
                    child: _currentProfileImage(state) == null
                        ? const Icon(Icons.person, size: 52)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: vm.pickProfileImage,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.edit, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Name is required';
                  if (t.length < 2) return 'Name must be at least 2 characters';
                  if (t.length > 40) return 'Name is too long';
                  return null;
                },
              ),

              TextFormField(
                controller: occupationCtrl,
                decoration: const InputDecoration(labelText: 'Occupation'),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Occupation is required';
                  if (t.length < 2) return 'Occupation must be at least 2 characters';
                  if (t.length > 40) return 'Occupation is too long';
                  return null;
                },
              ),

              TextFormField(
                controller: bioCtrl,
                decoration: const InputDecoration(labelText: 'Bio'),
                minLines: 2,
                maxLines: 5,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.length > 160) return 'Bio must be under 160 characters';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              FilledButton(
                onPressed: state.status == ProfileStatus.loading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        if (profile == null) return;

                        try {
                          await vm.updateProfile(
                            UpdateProfileParams(
                              userId: profile.id,
                              name: nameCtrl.text.trim(),
                              bio: bioCtrl.text.trim(),
                              occupation: occupationCtrl.text.trim(),
                              // removed: email, password
                              profilePicture: state.pickedImage?.path,
                              pickedNewImage: state.pickedImage != null,
                              token: profile.token,
                            ),
                          );

                          // refresh latest profile
                          await vm.fetchFullProfile(profile.id);

                          if (context.mounted) {
                            Navigator.pop(context); // go back to ProfileScreen
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}