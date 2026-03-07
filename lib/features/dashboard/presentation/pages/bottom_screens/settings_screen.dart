import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

  // Theme Colors
  static const Color orangePrimary = Color(0xFFF97316);
  static const Color rosePrimary = Color(0xFFF43F5E);
  static const Color bgColor = Color(0xFFFFF7ED);
  static const Color inputBg = Color(0xFFF9FAFB);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Prefill logic
    ref.listen(profileViewmodelProvider, (prev, next) {
      final email = next.profileEntity?.email;
      if (!_prefilled && email != null && email.isNotEmpty) {
        _prefilled = true;
        _emailCtrl.text = email;
      }
    });

    final profileState = ref.watch(profileViewmodelProvider);
    final currentEmail = profileState.profileEntity?.email ?? '';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(top: -50, left: -50, child: _buildBlob(200, orangePrimary.withOpacity(0.1))),
          Positioned(bottom: -50, right: -50, child: _buildBlob(250, rosePrimary.withOpacity(0.1))),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                /// 1. Account Section
                _buildSectionHeader("Account Security", LucideIcons.shieldCheck),
                _buildSettingsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (currentEmail.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Current Email: $currentEmail',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      _buildTextField(
                        controller: _emailCtrl,
                        hint: "New Email Address",
                        icon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        text: "Update Email",
                        onPressed: _handleUpdateEmail,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// 2. Password Section
                _buildSectionHeader("Change Password", LucideIcons.lock),
                _buildSettingsCard(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _currentPassCtrl,
                        hint: "Current Password",
                        icon: LucideIcons.key,
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _newPassCtrl,
                        hint: "New Password",
                        icon: LucideIcons.lock,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        text: "Update Password",
                        onPressed: _handleUpdatePassword,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// 3. Danger Zone
                _buildSectionHeader("Danger Zone", LucideIcons.triangleAlert400, color: Colors.redAccent),
                _buildSettingsCard(
                  borderColor: Colors.redAccent.withOpacity(0.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Delete Account",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Once you delete your account, there is no going back. Please be certain.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => _showDeleteDialog(context),
                          child: const Text("Delete My Account", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Logic Handlers ---

  Future<void> _handleUpdateEmail() async {
    final email = _emailCtrl.text.trim();
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      _showSnack('Enter a valid email address');
      return;
    }
    try {
      await ref.read(settingsRemoteProvider).updateMe(email: email);
      final userId = ref.read(profileViewmodelProvider).profileEntity?.id;
      if (userId != null) await ref.read(profileViewmodelProvider.notifier).fetchFullProfile(userId);
      _showSnack('Email updated successfully');
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  Future<void> _handleUpdatePassword() async {
    if (_newPassCtrl.text.length < 6) {
      _showSnack('Password must be at least 6 characters');
      return;
    }
    try {
      await ref.read(settingsRemoteProvider).updateMe(password: _newPassCtrl.text);
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _showSnack('Password updated successfully');
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // --- Styled Components ---

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40), child: Container(color: Colors.transparent)),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color color = Colors.black54}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(title.toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: color)),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child, Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool obscureText = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: orangePrimary.withOpacity(0.6)),
        filled: true,
        fillColor: inputBg,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: orangePrimary, width: 2)),
      ),
    );
  }

  Widget _buildActionButton({required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [orangePrimary, rosePrimary]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: rosePrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 14)),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) async {
    final ok = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text("Delete Account?", style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text("This action is permanent and cannot be undone. All your data will be removed."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true) {
      try {
        await ref.read(settingsRemoteProvider).deleteMe();
        await ref.read(authViewmodelProvider.notifier).logout();
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      } catch (e) { _showSnack(e.toString()); }
    }
  }
}