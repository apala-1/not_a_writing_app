import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
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
  final XFile? pickedImage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profileEntity,
    this.errorMessage, this.pickedImage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profileEntity,
    String? errorMessage,
    XFile? pickedImage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profileEntity: profileEntity ?? this.profileEntity,
      errorMessage: errorMessage ?? this.errorMessage,
      pickedImage: pickedImage ?? this.pickedImage,
    );
  }

  @override
  List<Object?> get props => [status, profileEntity, errorMessage, pickedImage];
}