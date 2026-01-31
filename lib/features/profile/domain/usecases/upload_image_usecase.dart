// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:not_a_writing_app/core/services/storage/user_service.dart';

// final uploadImageUsecaseProvider = Provider<UploadImageUsecase>((ref) {
//   final userService = ref.read(userServiceProvider);
//   return UploadImageUsecase(userService);
// });

// class UploadImageUsecase {
//   final UserService userService;

//   UploadImageUsecase(this.userService);

//   Future<String> call({
//     required XFile image,
//   }) async {
//     final imageUrl = await userService.uploadProfileImage(image);
//     return imageUrl;
//   }
// }
