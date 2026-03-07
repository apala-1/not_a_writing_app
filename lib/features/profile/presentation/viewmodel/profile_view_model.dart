import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/profile/data/cache/profile_cache.dart';
import 'package:not_a_writing_app/features/profile/data/cache/profile_hive_mapper.dart';
import 'package:not_a_writing_app/features/profile/domain/entities/profile_entity.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/get_profile_by_id_usecase.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/update_user_usecase.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/upload_image_usecase.dart';
import 'package:not_a_writing_app/features/profile/presentation/providers/profile_cache_providers.dart';
import 'package:not_a_writing_app/features/profile/presentation/state/profile_state.dart';

final profileViewmodelProvider =
    NotifierProvider<ProfileViewmodel, ProfileState>(() => ProfileViewmodel());

class ProfileViewmodel extends Notifier<ProfileState> {
  late final UpdateProfileUsecase _updateProfileUsecase;
  late final GetProfileUsecase _getProfileUsecase;
  late final GetProfileByIdUsecase _getProfileByIdUsecase;
  late final UploadImageUsecase _uploadImageUsecase;

  @override
  ProfileState build() {
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    _getProfileUsecase = ref.read(getProfileUsecaseProvider);
    _getProfileByIdUsecase = ref.read(getProfileByIdUsecaseProvider);
    _uploadImageUsecase = ref.read(uploadImageUsecaseProvider);
    return const ProfileState();
  }

  void reset() {
  state = const ProfileState();
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

void clearPickedImage() {
  state = state.copyWith(pickedImage: null);
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

      await fetchFullProfile(params.userId);
    },
  );
}

Future<void> fetchFullProfile(String userId) async {
  final ProfileCache cache = ref.read(profileCacheProvider);

  // 1) Load cache first (if any)
  final cached = await cache.readByUserId(userId);
  if (cached != null) {
    state = state.copyWith(
      status: ProfileStatus.loaded,
      profileEntity: profileFromHive(cached),
      errorMessage: null,
    );
  } else {
    state = state.copyWith(status: ProfileStatus.loading, errorMessage: null);
  }

  // 2) Network
  final result = await _getProfileByIdUsecase(userId);

  result.fold(
    (failure) {
      // If we already have cached data, keep showing it
      if (state.profileEntity != null) {
        state = state.copyWith(
          status: ProfileStatus.loaded,
          errorMessage: 'Offline. Showing cached profile.',
        );
      } else {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      }
    },
    (profile) async {
      state = state.copyWith(
        status: ProfileStatus.loaded,
        profileEntity: profile,
        errorMessage: null,
      );

      await cache.write(profileToHive(profile));
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