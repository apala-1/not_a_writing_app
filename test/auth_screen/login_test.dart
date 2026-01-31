import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:not_a_writing_app/features/auth/presentation/pages/login_screen.dart';
import 'package:not_a_writing_app/features/auth/presentation/state/auth_state.dart';
import 'package:not_a_writing_app/features/auth/presentation/view_model/auth_viewmodel.dart';

late FakeAuthViewModel fakeVm;

class FakeAuthViewModel extends AuthViewmodel {
  bool loginCalled = false;
  String? receivedEmail;
  String? receivedPassword;

  @override
  AuthState build() {
    return AuthState(
      status: AuthStatus.initial,
      errorMessage: null,
    );
  }

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    loginCalled = true;
    receivedEmail = email;
    receivedPassword = password;
  }

  @override
  Future<void> logout() async {}
}

Widget createTestApp(Widget child) {
  return ProviderScope(
    overrides: [
      authViewmodelProvider.overrideWith(() {
        fakeVm = FakeAuthViewModel();
        return fakeVm;
      }),
    ],
    child: MaterialApp(
      routes: {
        '/bottom_navigation': (_) =>
            const Scaffold(body: Text('Home Page')),
        '/forgot_password': (_) =>
            const Scaffold(body: Text('Forgot Password')),
        '/signup': (_) => const Scaffold(body: Text('Signup')),
      },
      home: child,
    ),
  );
}

void main() {
  testWidgets(
    'shows validation errors when fields are empty',
    (tester) async {
      await tester.pumpWidget(createTestApp(const LoginPage()));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    },
  );

  testWidgets(
    'shows error when email is invalid',
    (tester) async {
      await tester.pumpWidget(createTestApp(const LoginPage()));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'notanemail',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123456',
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    },
  );

  testWidgets(
    'calls login when form is valid',
    (tester) async {
      await tester.pumpWidget(createTestApp(const LoginPage()));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@test.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123456',
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(fakeVm.loginCalled, true);
      expect(fakeVm.receivedEmail, 'test@test.com');
      expect(fakeVm.receivedPassword, '123456');
    },
  );

  testWidgets(
    'toggles password visibility',
    (tester) async {
      await tester.pumpWidget(createTestApp(const LoginPage()));

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    },
  );

testWidgets('navigates to signup page', (tester) async {
  await tester.pumpWidget(createTestApp(const LoginPage()));
  await tester.pumpAndSettle();

  // Tap "Sign Up" link and check navigation
  final signUpFinder = find.text("Don't have an account yet? Sign Up");
  expect(signUpFinder, findsOneWidget);
  await tester.tap(signUpFinder);
  await tester.pumpAndSettle();
  expect(find.text('Signup'), findsOneWidget);
});
}
