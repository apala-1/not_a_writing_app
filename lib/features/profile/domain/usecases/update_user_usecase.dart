import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/features/profile/data/repositories/profile_repository.dart';
import 'package:not_a_writing_app/features/profile/domain/entities/profile_entity.dart';
import 'package:not_a_writing_app/features/profile/domain/repositories/profile_repository.dart';

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return UpdateProfileUsecase(repository);
});

class UpdateProfileParams {
  final String userId;
  final String? name;
  final String? email;
  final String? password;
  final String? occupation;
  final String? bio;
  final String? profilePicture;
  final String? token;

  const UpdateProfileParams({
    required this.userId,
    this.name,
    this.email,
    this.password,
    this.occupation,
    this.bio,
    this.profilePicture, this.token,
  });

  /// Convenience method to convert to JSON if needed
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'password': password,
      'occupation': occupation,
      'bio': bio,
      'profilePicture': profilePicture,
      'token': token,
    };
  }

  /// CopyWith for immutability
  UpdateProfileParams copyWith({
    String? userId,
    String? name,
    String? email,
    String? password,
    String? occupation,
    String? bio,
    String? profilePicture,
    String? token,
  }) {
    return UpdateProfileParams(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      occupation: occupation ?? this.occupation,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      token: token ?? this.token,
    );
  }
}

class UpdateProfileUsecase {
  final IProfileRepository repository;

  UpdateProfileUsecase(this.repository);

  Future<Either<Failure, ProfileEntity>> call(UpdateProfileParams params) async {
    return repository.updateUser(params);
  }
}
