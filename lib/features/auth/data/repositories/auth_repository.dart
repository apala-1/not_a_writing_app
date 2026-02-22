import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/core/services/connectivity/network_info.dart';
import 'package:not_a_writing_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:not_a_writing_app/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:not_a_writing_app/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:not_a_writing_app/features/auth/data/models/auth_api_model.dart';
import 'package:not_a_writing_app/features/auth/data/models/auth_hive_model.dart';
import 'package:not_a_writing_app/features/auth/domain/entities/auth_entity.dart';
import 'package:not_a_writing_app/features/auth/domain/repositories/auth_repository.dart';

// Create provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authDatasource: authDatasource,
    authRemoteDataSource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authDataSource;
  final IAuthRemoteDatasource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDatasource authDatasource,
    required IAuthRemoteDatasource authRemoteDataSource,
    required NetworkInfo networkInfo,
  }) : _authDataSource = authDatasource,
       _authRemoteDataSource = authRemoteDataSource,
       _networkInfo = networkInfo;

@override
Future<Either<Failure, AuthEntity>> register(AuthEntity user) async {
  if (await _networkInfo.isConnected) {
    try {
      final apiModel = AuthApiModel.fromEntity(user);

      final responseModel =
          await _authRemoteDataSource.register(apiModel);

  print('REGISTER RESPONSE MODEL: $responseModel');
      // ✅ THIS is the only correct success path
      final entity = responseModel.toEntity();

      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data?['message'] ??
              'Registration failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      // 🔥 THIS was missing — parsing errors were swallowed
      return Left(
        ApiFailure(message: 'Parsing error: ${e.toString()}'),
      );
    }
  } else {
    try {
      final existingUser =
          await _authDataSource.getUserByEmail(user.email);

      if (existingUser != null) {
        return const Left(
          LocalDatabaseFailure(message: "Email already registered"),
        );
      }

      final authModel = AuthHiveModel(
        authId: user.authId,
        name: user.name,
        email: user.email,
        password: user.password,
      );

      await _authDataSource.register(authModel);

      // ✅ Return canonical entity
      return Right(authModel.toEntity());
    } catch (e) {
      return Left(
        LocalDatabaseFailure(message: e.toString()),
      );
    }
  }
}


  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: "Invalid credentials"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _authDataSource.login(email, password);
        if (model != null) {
          final entity = model.toEntity();
          return Right(entity);
        }
        return const Left(
          LocalDatabaseFailure(message: "Invalid email or password"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authDataSource.getCurrentUser();
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return const Left(LocalDatabaseFailure(message: "No user logged in"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDataSource.logout();
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to logout"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, bool>> forgotPassword(String email) async {
    if (await _networkInfo.isConnected) {
    try {
      await _authRemoteDataSource.forgotPassword(email);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to send reset link',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
  return const Left(ApiFailure(message: "No internet connection"));
  }
  
  @override
  Future<Either<Failure, bool>> resetPassword(String token, String password) async {
    if (await _networkInfo.isConnected) {
    try {
      await _authRemoteDataSource.resetPassword(token, password);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Reset failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
  return const Left(ApiFailure(message: "No internet connection"));
  }

  @override
  Future<Either<Failure, AuthEntity>> loginWithGoogle(String idToken) async {
    try {
      final model = await _authRemoteDataSource.loginWithGoogle(idToken);
      if (model != null) return Right(model.toEntity());
      return const Left(ApiFailure(message: "Google login failed"));
    } on DioException catch (e) {
      return Left(ApiFailure(
        message: e.response?.data['message'] ?? "Google login failed",
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}