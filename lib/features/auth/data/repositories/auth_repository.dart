import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:not_a_writing_app/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:not_a_writing_app/features/auth/data/models/auth_hive_model.dart';
import 'package:not_a_writing_app/features/auth/domain/entities/auth_entity.dart';
import 'package:not_a_writing_app/features/auth/domain/repositories/auth_repository.dart';

// provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(authDataSource: ref.read(authLocalDatasourceProvider));
});

class AuthRepository implements IAuthRepository {
  final IAuthDatasource _authDataSource;

  AuthRepository({required IAuthDatasource authDataSource})
      : _authDataSource = authDataSource;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      // model ma convert gara
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDataSource.register(model);
      if (result) {
        return Right(true);
      }
        return Left(LocalDatabaseFailure(message: 'Registration failed'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final user = await _authDataSource.login(email, password);
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: 'Invalid email or password'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDataSource.getCurrentUser();
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: 'No current user found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDataSource.logout();
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Logout failed'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
