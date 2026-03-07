import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/settings_providers.dart';
import 'package:not_a_writing_app/features/profile/presentation/viewmodel/profile_view_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _emailCtrl = TextEditingController();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  bool _prefilled = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = ref.read(authViewmodelProvider.notifier);

    // Prefill from profile state once
    ref.listen(profileViewmodelProvider, (prev, next) {
      final email = next.profileEntity?.email;
      if (!_prefilled && email != null && email.isNotEmpty) {
        _prefilled = true;
        _emailCtrl.text = email;
      }
    });

    // Also watch it so this screen rebuilds if needed
    final profileState = ref.watch(profileViewmodelProvider);
    final currentEmail = profileState.profileEntity?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Account', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (currentEmail.isNotEmpty)
            Text('Current: $currentEmail', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),

          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),
         FilledButton(
  onPressed: () async {
    final email = _emailCtrl.text.trim();
    final emailOk = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
    if (!emailOk) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid email')));
      return;
    }

    try {
      await ref.read(settingsRemoteProvider).updateMe(email: email);

      // refresh profile/me so UI shows new email
      final vm = ref.read(profileViewmodelProvider.notifier);
      final userId = ref.read(profileViewmodelProvider).profileEntity?.id;
      if (userId != null) await vm.fetchFullProfile(userId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email updated')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  },
  child: const Text('Update Email'),
),

          const SizedBox(height: 24),
          const Text('Password', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          TextField(
            controller: _currentPassCtrl,
            decoration: const InputDecoration(labelText: 'Current password'),
            obscureText: true,
          ),
          TextField(
            controller: _newPassCtrl,
            decoration: const InputDecoration(labelText: 'New password'),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          FilledButton(
  onPressed: () async {
    final newPass = _newPassCtrl.text;
    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters')));
      return;
    }

    try {
      await ref.read(settingsRemoteProvider).updateMe(password: newPass);
      _currentPassCtrl.clear();
      _newPassCtrl.clear();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  },
  child: const Text('Update Password'),
),

          const SizedBox(height: 24),
          const Text('Danger zone', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
          const SizedBox(height: 12),

          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete account?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    OutlinedButton(
  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
  onPressed: () async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref.read(settingsRemoteProvider).deleteMe();
      await ref.read(authViewmodelProvider.notifier).logout();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  },
  child: const Text('Delete Account'),
),
                  ],
                ),
              );
              if (ok != true) return;

              // TODO: call backend delete endpoint, then logout
              await authVm.logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}