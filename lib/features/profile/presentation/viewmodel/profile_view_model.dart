import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
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
  // late final UploadImageUsecase _uploadImageUsecase;

  @override
  ProfileState build() {
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    _getProfileUsecase = ref.read(getProfileUsecaseProvider);
    _getProfileByIdUsecase = ref.read(getProfileByIdUsecaseProvider);
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
    // 1. Get the actual user info
    final meResult = await _getProfileUsecase(''); // /auth/me
    final profileByIdResult = await _getProfileByIdUsecase(userId); // /profile/:id

    ProfileEntity? me;
    ProfileEntity? profileById;

    meResult.fold(
      (_) => me = null,
      (profile) => me = profile,
    );

    profileByIdResult.fold(
      (_) => profileById = null,
      (profile) => profileById = profile,
    );

    if (me == null && profileById == null) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Failed to fetch profile',
      );
      return;
    }

    // 2. Merge
    final mergedProfile = ProfileEntity(
  id: profileById?.id ?? me!.id,
  name: me?.name ?? profileById?.name ?? '',
  email: me?.email ?? profileById?.email ?? '',
  profilePicture: me?.profilePicture ?? profileById?.profilePicture ?? 'default-picture.png',
  occupation: me?.occupation ?? profileById?.occupation ?? '',
  bio: me?.bio ?? profileById?.bio ?? '',
  token: me?.token,
  postsCount: profileById?.postsCount ?? 0,
);


    state = state.copyWith(
      status: ProfileStatus.loaded,
      profileEntity: mergedProfile,
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