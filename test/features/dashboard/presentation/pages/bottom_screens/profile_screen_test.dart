import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/auth/presentation/state/auth_state.dart';
import 'package:not_a_writing_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/profile_screen.dart';
import 'package:not_a_writing_app/features/profile/presentation/state/profile_state.dart';
import 'package:not_a_writing_app/features/profile/presentation/viewmodel/profile_view_model.dart';

void main() {
  Widget _app({
    required UserSessionService userSession,
    required ProfileViewmodel profileVm,
    required AuthViewmodel authVm,
  }) {
    return ProviderScope(
      overrides: [
        userSessionServiceProvider.overrideWithValue(userSession),
        profileViewmodelProvider.overrideWith(() => profileVm),
        authViewmodelProvider.overrideWith(() => authVm),
      ],
      child: MaterialApp(
        routes: {
          '/login': (_) => const Scaffold(body: Text('LoginPage')),
          '/settings': (_) => const Scaffold(body: Text('SettingsPage')),
          '/edit-profile': (_) => const Scaffold(body: Text('EditProfilePage')),
        },
        home: const ProfileScreen(),
      ),
    );
  }

  testWidgets('shows loading indicator when profile is loading', (tester) async {
    final userSession = _FakeUserSessionService(userId: 'u1');
    final profileVm = TestProfileViewmodel(
      initial: const ProfileState(status: ProfileStatus.loading),
    );
    final authVm = TestAuthViewmodel();

    await tester.pumpWidget(_app(
      userSession: userSession,
      profileVm: profileVm,
      authVm: authVm,
    ));
    await tester.pump(); // allow initState microtask

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error UI when profile status is error', (tester) async {
    final userSession = _FakeUserSessionService(userId: 'u1');
    final profileVm = TestProfileViewmodel(
      initial: const ProfileState(
        status: ProfileStatus.error,
        errorMessage: 'Boom',
      ),
    );
    final authVm = TestAuthViewmodel();

    await tester.pumpWidget(_app(
      userSession: userSession,
      profileVm: profileVm,
      authVm: authVm,
    ));
    await tester.pump();

    expect(find.text('Boom'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('calls fetchFullProfile in initState when userId exists', (tester) async {
    final userSession = _FakeUserSessionService(userId: 'u123');
    final profileVm = TestProfileViewmodel(
      initial: const ProfileState(status: ProfileStatus.loading),
    );
    final authVm = TestAuthViewmodel();

    await tester.pumpWidget(_app(
      userSession: userSession,
      profileVm: profileVm,
      authVm: authVm,
    ));

    // initState uses Future.microtask(...)
    await tester.pump();

    expect(profileVm.fetchCalls, ['u123']);
  });

  testWidgets('does not call fetchFullProfile when userId is null', (tester) async {
    final userSession = _FakeUserSessionService(userId: null);
    final profileVm = TestProfileViewmodel(
      initial: const ProfileState(status: ProfileStatus.loading),
    );
    final authVm = TestAuthViewmodel();

    await tester.pumpWidget(_app(
      userSession: userSession,
      profileVm: profileVm,
      authVm: authVm,
    ));
    await tester.pump();

    expect(profileVm.fetchCalls, isEmpty);
  });
}

/// Fake session service override used by ProfileScreen.initState()
class _FakeUserSessionService implements UserSessionService {
  final String? userId;
  _FakeUserSessionService({required this.userId});

  @override
  String? getUserId() => userId;

  // --- Unused in these widget tests ---
  @override
  Future<void> clearUserSession() async {}

  @override
  String? getUserEmail() => null;

  @override
  String? getUserFullname() => null;

  @override
  String? getUserToken() => null;

  @override
  bool isLoggedIn() => userId != null;

  @override
  Future<void> saveUserSession({
    required String authId,
    required String email,
    required String name,
    required String token,
  }) async {}
}

/// Test notifier for profile provider (real Notifier subclass)
class TestProfileViewmodel extends ProfileViewmodel {
  TestProfileViewmodel({ProfileState initial = const ProfileState()}) : _current = initial;

  ProfileState _current;
  final List<String> fetchCalls = <String>[];

  @override
  ProfileState build() => _current;

  void emit(ProfileState next) {
    _current = next;
    state = next;
  }

  @override
  Future<void> fetchFullProfile(String userId) async {
    fetchCalls.add(userId);
  }
}

/// Test notifier for auth provider (real Notifier subclass)
class TestAuthViewmodel extends AuthViewmodel {
  int logoutCalls = 0;

  AuthState _current = const AuthState();

  @override
  AuthState build() => _current;

  @override
  Future<void> logout() async {
    logoutCalls += 1;
  }
}

// Helpers
dynamic _fakeProfile({required String name}) {
  // We don't know your exact ProfileEntity type from the snippet.
  // Replace this with your real ProfileEntity constructor.
  //
  // Example:
  // return ProfileEntity(
  //   name: name,
  //   occupation: 'Writer',
  //   bio: '',
  //   profilePicture: 'default-picture.png',
  //   postsCount: 0,
  // );
  //
  // For now, return a minimal object with the fields ProfileScreen reads.
  return _ProfileEntityLike(
    name: name,
    occupation: 'Writer',
    bio: '',
    profilePicture: 'default-picture.png',
    postsCount: 0,
  );
}

class _ProfileEntityLike {
  final String name;
  final String occupation;
  final String bio;
  final String profilePicture;
  final int postsCount;

  _ProfileEntityLike({
    required this.name,
    required this.occupation,
    required this.bio,
    required this.profilePicture,
    required this.postsCount,
  });
}