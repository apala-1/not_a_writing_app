import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
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
  final List<CommentEntity>? comments;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profileEntity,
    this.errorMessage, this.pickedImage, this.comments,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profileEntity,
    String? errorMessage,
    XFile? pickedImage,
    List<CommentEntity>? comments,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profileEntity: profileEntity ?? this.profileEntity,
      errorMessage: errorMessage ?? this.errorMessage,
      pickedImage: pickedImage ?? this.pickedImage,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<Object?> get props => [status, profileEntity, errorMessage, pickedImage, comments];
}