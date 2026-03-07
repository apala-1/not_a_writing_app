import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:not_a_writing_app/features/auth/presentation/pages/login_screen.dart';

import 'package:not_a_writing_app/features/auth/presentation/state/auth_state.dart';
import 'package:not_a_writing_app/features/auth/presentation/view_model/auth_viewmodel.dart';

void main() {
  Widget _app({required AuthViewmodel vm}) {
    return ProviderScope(
      overrides: [
        authViewmodelProvider.overrideWith(() => vm),
      ],
      child: MaterialApp(
        routes: {
          '/bottom_navigation': (_) => const Scaffold(body: Text('BottomNav')),
          '/forgot_password': (_) => const Scaffold(body: Text('ForgotPassword')),
          '/signup': (_) => const Scaffold(body: Text('Signup')),
        },
        home: const LoginPage(),
      ),
    );
  }

  testWidgets('renders login form', (tester) async {
    final vm = TestAuthViewmodel();

    await tester.pumpWidget(_app(vm: vm));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('invalid email shows validation error and does not call login', (tester) async {
    final vm = TestAuthViewmodel();

    await tester.pumpWidget(_app(vm: vm));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(vm.loginCalls, isEmpty);
  });

  testWidgets('valid inputs call login with trimmed values', (tester) async {
    final vm = TestAuthViewmodel();

    await tester.pumpWidget(_app(vm: vm));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), ' hello@example.com ');
    await tester.enterText(find.byType(TextFormField).at(1), ' 123456 ');

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(vm.loginCalls.length, 1);
    expect(vm.loginCalls.single.email, 'hello@example.com');
    expect(vm.loginCalls.single.password, '123456');
  });

  testWidgets('authenticated state triggers navigation to bottom nav', (tester) async {
    final vm = TestAuthViewmodel();

    await tester.pumpWidget(_app(vm: vm));
    await tester.pumpAndSettle();

    vm.setState(const AuthState(status: AuthStatus.authenticated));
    await tester.pumpAndSettle();

    expect(find.text('BottomNav'), findsOneWidget);
  });

  testWidgets('error state shows snackbar text', (tester) async {
    final vm = TestAuthViewmodel();

    await tester.pumpWidget(_app(vm: vm));
    await tester.pump(); // first build

    vm.setState(const AuthState(
      status: AuthStatus.error,
      errorMessage: 'Wrong password',
    ));

    // allow listener to run + snackbar animation
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Wrong password'), findsOneWidget);
  });
}

/// A real Notifier subclass, so Riverpod can mount it (no _element crash),
/// but controlled by the test.
///
/// We keep super.build() contract by returning the current state.
class TestAuthViewmodel extends AuthViewmodel {
  AuthState _current = const AuthState();

  final List<LoginCall> loginCalls = <LoginCall>[];
  final List<String> googleLoginCalls = <String>[];

  @override
  AuthState build() => _current;

  void setState(AuthState next) {
    _current = next;
    state = next;
  }

  @override
  Future<void> login({required String email, required String password}) async {
    loginCalls.add(LoginCall(email: email, password: password));
  }

  @override
  Future<void> loginWithGoogle(String idToken) async {
    googleLoginCalls.add(idToken);
  }
}

class LoginCall {
  final String email;
  final String password;
  LoginCall({required this.email, required this.password});
}