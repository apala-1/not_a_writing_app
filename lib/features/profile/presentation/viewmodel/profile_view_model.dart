import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/get_whole_comments_usecase.dart';
import 'package:not_a_writing_app/features/profile/domain/entities/profile_entity.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/get_profile_by_id_usecase.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/update_user_usecase.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/upload_image_usecase.dart';
import 'package:not_a_writing_app/features/profile/presentation/state/profile_state.dart';

final profileViewmodelProvider =
    NotifierProvider<ProfileViewmodel, ProfileState>(() => ProfileViewmodel());

class ProfileViewmodel extends Notifier<ProfileState> {
  late final UpdateProfileUsecase _updateProfileUsecase;
  late final GetProfileUsecase _getProfileUsecase;
  late final GetProfileByIdUsecase _getProfileByIdUsecase;
  late final GetWholeCommentUsecase _getWholeCommentUsecase;
  late final UploadImageUsecase _uploadImageUsecase;

  @override
  ProfileState build() {
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    _getProfileUsecase = ref.read(getProfileUsecaseProvider);
    _getProfileByIdUsecase = ref.read(getProfileByIdUsecaseProvider);
    _uploadImageUsecase = ref.read(uploadImageUsecaseProvider);
    _getWholeCommentUsecase = ref.read(getWholeCommentUsecaseProvider);
    return const ProfileState();
  }

   Future<void> fetchProfile() async {
    state = state.copyWith(status: ProfileStatus.loading);

    final result = await _getProfileUsecase(''); // pass userId if needed

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (profile) {
        state = state.copyWith(
          status: ProfileStatus.loaded,
          profileEntity: profile,
        );
      },
    );
  }

  Future<void> fetchProfileById(String userId) async {
  state = state.copyWith(status: ProfileStatus.loading);

  final result = await _getProfileByIdUsecase(userId);

  result.fold(
    (failure) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      );
    },
    (profile) {
      state = state.copyWith(
        status: ProfileStatus.loaded,
        profileEntity: profile,
      );
    },
  );
}

Future<void> fetchProfileAndComments(String userId) async {
  state = state.copyWith(status: ProfileStatus.loading);

  try {
    final results = await Future.wait([
      _getProfileByIdUsecase(userId),
      _getWholeCommentUsecase(userId),
    ]);

    final profileResult = results[0] as ProfileEntity;
final commentResult = results[1] as List<CommentEntity>;

    state = state.copyWith(
      status: ProfileStatus.loaded,
      profileEntity: profileResult,
      comments: commentResult,
    );
  } catch (e) {
    state = state.copyWith(
      status: ProfileStatus.error,
      errorMessage: e.toString(),
    );
  }
}


 Future<void> updateProfile(UpdateProfileParams params) async {
  state = state.copyWith(status: ProfileStatus.loading);

  final finalParams = params.copyWith(
    profilePicture: state.pickedImage?.path,
    pickedNewImage: state.pickedImage != null,
  );

  final result = await _updateProfileUsecase(finalParams);

  result.fold(
    (failure) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      );
    },
    (profile) async {
      state = state.copyWith(
        profileEntity: profile,
        pickedImage: null, 
        status: ProfileStatus.loaded,
      );

      // optional but recommended
      await fetchProfile();
    },
  );
}

Future<void> fetchFullProfile(String userId) async {
  state = state.copyWith(status: ProfileStatus.loading);

  try {
    final profileResult = await _getProfileByIdUsecase(userId);

    profileResult.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (profile) {
        state = state.copyWith(
          status: ProfileStatus.loaded,
          profileEntity: profile,
        );
        print('Profile Posts Count: ${profile.postsCount}');
      },
    );
  } catch (e) {
    state = state.copyWith(
      status: ProfileStatus.error,
      errorMessage: e.toString(),
    );
  }
}

Future<void> pickProfileImage() async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    state = state.copyWith(pickedImage: image);
  }
}


}