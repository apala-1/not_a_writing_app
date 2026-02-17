import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/auth/presentation/state/auth_state.dart';
import 'package:not_a_writing_app/features/auth/presentation/view_model/auth_viewmodel.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.token,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewmodelProvider, (previous, next) {
      if (previous?.status == AuthStatus.loading &&
          next.status != AuthStatus.loading) {
        
        if (next.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage ?? "Error")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password reset successful")),
          );

          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    });
    final state = ref.watch(authViewmodelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
              ),
            ),
            const SizedBox(height: 20),
            state.status == AuthStatus.loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      final password =
                          _passwordController.text.trim();

                      if (password.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Password must be at least 6 characters")),
                        );
                        return;
                      }
                      print("TOKEN BEING SENT: $widget.token");

                      ref
                          .read(authViewmodelProvider.notifier)
                          .resetPassword(
                            token: widget.token,
                            password: password,
                          );
                          
                    },
                    child: const Text("Reset Password"),
                  ),
          ],
        ),
      ),
    );
  }
}
