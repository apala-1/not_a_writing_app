import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:not_a_writing_app/core/utils/snackbar_utils.dart';
import 'package:not_a_writing_app/features/auth/presentation/state/auth_state.dart';
import 'package:not_a_writing_app/features/auth/presentation/view_model/auth_viewmodel.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  // Note: authId controller kept as per original logic, though typically handled by backend
  final _authIdController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _rememberMe = false;

  Future<void> _handleGoogleLogin() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: "458852825785-d4r3gpp7b9v6kmldqug9b42de7cqf8a0.apps.googleusercontent.com",
      );

      final userData = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email'],
      );

      final idToken = userData.authentication.idToken;
      if (idToken == null) throw Exception('No ID token');

      if (!mounted) return;
      await ref.read(authViewmodelProvider.notifier).loginWithGoogle(idToken);
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Google login failed: $e');
    }
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _authIdController.dispose();
    super.dispose();
  }

  // Theme Colors
  final Color primaryOrange = const Color(0xFFFF7F00);
  final Color roseColor = const Color(0xFFE91E63);
  final Color softRose = const Color(0xFFFFE4E1);

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewmodelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(context, next.errorMessage ?? 'Registration failed');
      } else if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(context, 'Registration successful! Please log in.');
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    final authState = ref.watch(authViewmodelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryOrange, size: 20),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo/Illustration Area
              Hero(
                tag: 'app_logo',
                child: Image.asset(
                  'assets/images/pencil.png',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => 
                      Icon(Icons.edit_note, size: 100, color: primaryOrange),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Create Account",
                style: TextStyle(
                  color: primaryOrange,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "Start your writing journey today",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 35),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _fullnameController,
                      label: "Full Name",
                      icon: Icons.person_outline,
                      validator: (value) => (value == null || value.isEmpty) ? "Full name is required" : null,
                    ),
                    const SizedBox(height: 18),
                    _buildTextField(
                      controller: _emailController,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Email is required";
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Enter a valid email";
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildTextField(
                      controller: _passwordController,
                      label: "Password",
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: roseColor),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Password is required";
                        if (value.length < 6) return "Min 6 characters";
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildTextField(
                      controller: _confirmController,
                      label: "Confirm Password",
                      icon: Icons.shield_outlined,
                      obscureText: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: roseColor),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Please confirm password";
                        if (value != _passwordController.text) return "Passwords do not match";
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: primaryOrange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (v) => setState(() => _rememberMe = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text("I agree to the Terms & Conditions", style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Primary Sign Up Button
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [primaryOrange, roseColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: roseColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: isLoading ? null : () {
                          if (_formKey.currentState!.validate()) {
                            ref.read(authViewmodelProvider.notifier).register(
                              authId: _authIdController.text.trim(),
                              name: _fullnameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );
                          }
                        },
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "SIGN UP",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ", style: TextStyle(color: Colors.grey[600])),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: Text(
                            "Log In",
                            style: TextStyle(color: roseColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Social Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300]!)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text("Or sign up with", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300]!)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton('assets/images/google.png', () {
                          _handleGoogleLogin();
                        }),
                        const SizedBox(width: 25),
                        _buildSocialButton('assets/images/facebook.png', () {}),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Icon(icon, color: primaryOrange, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSocialButton(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, spreadRadius: 1),
          ],
        ),
        child: Image.asset(assetPath, height: 28, errorBuilder: (c, e, s) => const Icon(Icons.link)),
      ),
    );
  }
}