import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/auth/presentation/pages/signup_screen.dart';
import 'package:not_a_writing_app/features/auth/presentation/state/auth_state.dart';
import 'package:not_a_writing_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:state_notifier/state_notifier.dart';

class FakeAuthViewModel extends StateNotifier<AuthState> implements AuthViewmodel {
  FakeAuthViewModel() : super(AuthState(status: AuthStatus.initial));

  bool registerCalled = false;
  String? receivedName;
  String? receivedEmail;
  String? receivedPassword;

  @override
  Future<void> register({
    String? authId,
    required String name,
    required String email,
    required String password,
  }) async {
    registerCalled = true;
    receivedName = name;
    receivedEmail = email;
    receivedPassword = password;
  }

  @override
  Future<void> login({required String email, required String password}) async {}
  @override
  Future<void> logout() async {}
  @override
  void runBuild() {}
  @override
  AuthState build() => state;
  @override
  RemoveListener listenSelf(void Function(AuthState? previous, AuthState next) listener, {void Function(Object error, StackTrace stackTrace)? onError}) => throw UnimplementedError();
  @override
  Ref get ref => throw UnimplementedError();
  @override
  AuthState? get stateOrNull => state;
}

Widget createTestApp(FakeAuthViewModel fakeVm) {
  return ProviderScope(
  overrides: [
    authViewmodelProvider.overrideWith(() => FakeAuthViewModel()),
  ],
  child: MaterialApp(
    home: const SignUpPage(),
    routes: {
      '/login': (_) => const Scaffold(body: Text('Login Page')),
    },
  ),
);
}

void main() {
  testWidgets('shows validation errors when fields are empty', (tester) async {
    final fakeVm = FakeAuthViewModel();
    await tester.pumpWidget(createTestApp(fakeVm));
    await tester.pumpAndSettle();
    final buttonFinder = find.byType(ElevatedButton);
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pump();
    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Confirm your password'), findsOneWidget);
  });

  testWidgets('shows error when email is invalid', (tester) async {
    final fakeVm = FakeAuthViewModel();
    await tester.pumpWidget(createTestApp(fakeVm));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
    await tester.enterText(find.byType(TextFormField).at(1), 'notanemail');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');
    await tester.enterText(find.byType(TextFormField).at(3), '123456');
    final buttonFinder = find.byType(ElevatedButton);
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pump();
    expect(find.text('Enter a valid email'), findsOneWidget);
  });

  testWidgets('shows error when passwords do not match', (tester) async {
    final fakeVm = FakeAuthViewModel();
    await tester.pumpWidget(createTestApp(fakeVm));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
    await tester.enterText(find.byType(TextFormField).at(1), 'test@test.com');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');
    await tester.enterText(find.byType(TextFormField).at(3), 'abcdef');
    final buttonFinder = find.byType(ElevatedButton);
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  // testWidgets('calls register when form is valid', 
  // (tester) async {
  //   final fakeVm = FakeAuthViewModel();
  //   await tester.pumpWidget(createTestApp(fakeVm));
  //   await tester.pumpAndSettle();
  //   await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
  //   await tester.enterText(find.byType(TextFormField).at(1), 'test@test.com');
  //   await tester.enterText(find.byType(TextFormField).at(2), '123456');
  //   await tester.enterText(find.byType(TextFormField).at(3), '123456');
  //   final buttonFinder = find.byType(ElevatedButton);
  //   await tester.ensureVisible(buttonFinder);
  //   await tester.tap(buttonFinder);
  //   await tester.pump();
  //   expect(fakeVm.registerCalled, isTrue);
  //   expect(fakeVm.receivedName, 'Test User');
  //   expect(fakeVm.receivedEmail, 'test@test.com');
  //   expect(fakeVm.receivedPassword, '123456');
  // });

  testWidgets('navigates to login page on "Already have an account?" tap', (tester) async {
    final fakeVm = FakeAuthViewModel();
    await tester.pumpWidget(createTestApp(fakeVm));
    await tester.pumpAndSettle();
    final loginTextFinder = find.text("Already have an account? Log In");
    await tester.ensureVisible(loginTextFinder);
    await tester.tap(loginTextFinder);
    await tester.pumpAndSettle();
    expect(find.text('Login Page'), findsOneWidget);
  });
}
