import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/update_user_usecase.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/upload_image_usecase.dart';
import 'package:not_a_writing_app/features/profile/presentation/state/profile_state.dart';

final profileViewmodelProvider =
    NotifierProvider<ProfileViewmodel, ProfileState>(() => ProfileViewmodel());

class ProfileViewmodel extends Notifier<ProfileState> {
  late final UpdateProfileUsecase _updateProfileUsecase;
  late final GetProfileUsecase _getProfileUsecase;
  // late final UploadImageUsecase _uploadImageUsecase;

  @override
  ProfileState build() {
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    _getProfileUsecase = ref.read(getProfileUsecaseProvider);
    // _uploadImageUsecase = ref.read(uploadImageUsecaseProvider);
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

  Future<void> updateProfile(UpdateProfileParams params) async {
  state = state.copyWith(status: ProfileStatus.loading);

  final result = await _updateProfileUsecase(params);

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

Future<void> pickProfileImage() async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    state = state.copyWith(pickedImage: image);
  }
}
}