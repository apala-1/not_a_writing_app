import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/update_user_usecase.dart';
import 'package:not_a_writing_app/features/profile/presentation/viewmodel/profile_view_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController bioCtrl;
  late TextEditingController occupationCtrl;
  late TextEditingController passwordCtrl;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileViewmodelProvider).profileEntity;

    nameCtrl = TextEditingController(text: profile?.name ?? '');
    emailCtrl = TextEditingController(text: profile?.email ?? '');
    bioCtrl = TextEditingController(text: profile?.bio ?? '');
    occupationCtrl = TextEditingController(text: profile?.occupation ?? '');
    passwordCtrl = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewmodelProvider);
    final vm = ref.read(profileViewmodelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: state.pickedImage != null
                      ? FileImage(File(state.pickedImage!.path))
                      : NetworkImage(
                           '${ApiEndpoints.mediaServerUrl}/uploads/${state.profileEntity!.profilePicture}',
                        ) as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: vm.pickProfileImage,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: occupationCtrl, decoration: const InputDecoration(labelText: 'Occupation')),
            TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: 'Bio')),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                vm.updateProfile(
                  UpdateProfileParams(
                    userId: state.profileEntity!.id,
                    name: nameCtrl.text,
                    email: emailCtrl.text,
                    bio: bioCtrl.text,
                    occupation: occupationCtrl.text,
                    password: passwordCtrl.text.isEmpty ? null : passwordCtrl.text,
                    profilePicture: state.pickedImage?.path,
                    pickedNewImage: true,
                    token: state.profileEntity!.token,
                  ),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
