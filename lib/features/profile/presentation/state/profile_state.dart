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

const _unset = Object();

class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileEntity? profileEntity;
  final String? errorMessage;
  final XFile? pickedImage;
  final List<CommentEntity>? comments;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profileEntity,
    this.errorMessage,
    this.pickedImage,
    this.comments,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    Object? profileEntity = _unset,
    Object? errorMessage = _unset,
    Object? pickedImage = _unset,
    Object? comments = _unset,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profileEntity: identical(profileEntity, _unset) ? this.profileEntity : profileEntity as ProfileEntity?,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      pickedImage: identical(pickedImage, _unset) ? this.pickedImage : pickedImage as XFile?,
      comments: identical(comments, _unset) ? this.comments : comments as List<CommentEntity>?,
    );
  }

  @override
  List<Object?> get props => [status, profileEntity, errorMessage, pickedImage, comments];
}