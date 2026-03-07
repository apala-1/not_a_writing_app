import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:not_a_writing_app/features/auth/presentation/pages/signup_screen.dart';

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
          '/login': (_) => const Scaffold(body: Text('LoginPage')),
        },
        home: const SignUpPage(),
      ),
    );
  }

  testWidgets('renders sign up form', (tester) async {
    final vm = TestAuthViewmodel();

    await tester.pumpWidget(_app(vm: vm));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('SIGN UP'), findsOneWidget);

    // Full name, email, password, confirm password
    expect(find.byType(TextFormField), findsNWidgets(4));
  });

  testWidgets('invalid email shows validation error and does not call register', (tester) async {
  final vm = TestAuthViewmodel();

  await tester.pumpWidget(_app(vm: vm));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).at(0), 'My Name');
  await tester.enterText(find.byType(TextFormField).at(1), 'not-an-email');
  await tester.enterText(find.byType(TextFormField).at(2), '123456');
  await tester.enterText(find.byType(TextFormField).at(3), '123456');

  final signUpButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
  await tester.ensureVisible(signUpButton);
  await tester.pumpAndSettle();

  await tester.tap(signUpButton);
  await tester.pumpAndSettle();

  final emailError = find.text('Enter a valid email');
  await tester.ensureVisible(emailError);
  await tester.pumpAndSettle();

  expect(emailError, findsOneWidget);
  expect(vm.registerCalls, isEmpty);
});

testWidgets('password mismatch shows validation error and does not call register', (tester) async {
  final vm = TestAuthViewmodel();

  await tester.pumpWidget(_app(vm: vm));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).at(0), 'My Name');
  await tester.enterText(find.byType(TextFormField).at(1), 'hello@example.com');
  await tester.enterText(find.byType(TextFormField).at(2), '123456');
  await tester.enterText(find.byType(TextFormField).at(3), '654321');

  final signUpButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
  await tester.ensureVisible(signUpButton);
  await tester.pumpAndSettle();

  await tester.tap(signUpButton);
  await tester.pumpAndSettle();

  final mismatchError = find.text('Passwords do not match');
  await tester.ensureVisible(mismatchError);
  await tester.pumpAndSettle();

  expect(mismatchError, findsOneWidget);
  expect(vm.registerCalls, isEmpty);
});

  testWidgets('registered state navigates to /login', (tester) async {
    final vm = TestAuthViewmodel();

    await tester.pumpWidget(_app(vm: vm));
    await tester.pumpAndSettle();

    vm.emit(const AuthState(status: AuthStatus.registered));
    await tester.pumpAndSettle();

    expect(find.text('LoginPage'), findsOneWidget);
  });

  testWidgets('error state shows snackbar text', (tester) async {
    final vm = TestAuthViewmodel();

    await tester.pumpWidget(_app(vm: vm));
    await tester.pump(); // first build

    vm.emit(const AuthState(
      status: AuthStatus.error,
      errorMessage: 'Email already exists',
    ));

    // allow listener to run + snackbar animation
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Email already exists'), findsOneWidget);
  });
}

/// Real Notifier subclass so Riverpod can mount it.
/// Keeps a local copy of state for build().
class TestAuthViewmodel extends AuthViewmodel {
  TestAuthViewmodel({AuthState initial = const AuthState()}) : _current = initial;

  AuthState _current;

  final List<RegisterCall> registerCalls = <RegisterCall>[];
  final List<String> googleLoginCalls = <String>[];

  @override
  AuthState build() => _current;

  /// Safe to call only after pumpWidget (mounted).
  void emit(AuthState next) {
    _current = next;
    state = next;
  }

  @override
  Future<void> register({
    String? authId,
    required String name,
    required String email,
    required String password,
  }) async {
    registerCalls.add(RegisterCall(
      authId: authId,
      name: name,
      email: email,
      password: password,
    ));
  }

  @override
  Future<void> loginWithGoogle(String idToken) async {
    googleLoginCalls.add(idToken);
  }
}

class RegisterCall {
  final String? authId;
  final String name;
  final String email;
  final String password;

  RegisterCall({
    required this.authId,
    required this.name,
    required this.email,
    required this.password,
  });
}