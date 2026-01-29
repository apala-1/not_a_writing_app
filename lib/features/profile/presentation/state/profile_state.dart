import 'package:equatable/equatable.dart';
import 'package:not_a_writing_app/features/profile/domain/entities/profile_entity.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  updated,
  pictureUploaded,
  error,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileEntity? profileEntity;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profileEntity,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profileEntity,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profileEntity: profileEntity ?? this.profileEntity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [status, profileEntity, errorMessage];
}