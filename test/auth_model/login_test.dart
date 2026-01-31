import 'package:flutter_test/flutter_test.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:not_a_writing_app/features/auth/presentation/state/auth_state.dart';

class FakeAuthViewModel extends StateNotifier<AuthState> {
  FakeAuthViewModel() : super(AuthState(status: AuthStatus.initial));

  bool loginCalled = false;
  String? receivedEmail;
  String? receivedPassword;

  Future<void> login({required String email, required String password}) async {
    loginCalled = true;
    receivedEmail = email;
    receivedPassword = password;

    if (email.isEmpty || password.isEmpty) {
      state = AuthState(status: AuthStatus.error, errorMessage: 'Fields cannot be empty');
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      state = AuthState(status: AuthStatus.error, errorMessage: 'Invalid email');
    } else if (password.length < 6) {
      state = AuthState(status: AuthStatus.error, errorMessage: 'Password too short');
    } else {
      state = AuthState(status: AuthStatus.authenticated);
    }
  }
}

void main() {
  late FakeAuthViewModel vm;

  setUp(() {
    vm = FakeAuthViewModel();
  });

  test('initial state is initial', () {
    expect(vm.state.status, AuthStatus.initial);
  });

  test('login succeeds with valid credentials', () async {
    await vm.login(email: 'test@test.com', password: '123456');

    expect(vm.loginCalled, true);
    expect(vm.receivedEmail, 'test@test.com');
    expect(vm.receivedPassword, '123456');
    expect(vm.state.status, AuthStatus.authenticated);
  });

  test('login fails with empty fields', () async {
    await vm.login(email: '', password: '');

    expect(vm.state.status, AuthStatus.error);
    expect(vm.state.errorMessage, 'Fields cannot be empty');
  });

  test('login fails with invalid email', () async {
    await vm.login(email: 'invalidemail', password: '123456');

    expect(vm.state.status, AuthStatus.error);
    expect(vm.state.errorMessage, 'Invalid email');
  });

  test('login fails with short password', () async {
    await vm.login(email: 'test@test.com', password: '123');

    expect(vm.state.status, AuthStatus.error);
    expect(vm.state.errorMessage, 'Password too short');
  });
}
