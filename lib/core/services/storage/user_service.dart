// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:not_a_writing_app/core/providers/dio_provider.dart';
// import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';

// final userServiceProvider = Provider<UserService>((ref) {
//   final dio = ref.read(dioProvider);
//   final session = ref.read(userSessionServiceProvider);

//   return UserService(
//     dio: dio,
//     session: session,
//   );
// });

// class UserService {
//   final Dio dio;
//   final UserSessionService session;

//   UserService({
//     required this.dio,
//     required this.session,
//   });

//   Future<String> uploadProfileImage(XFile image) async {
//   final userId = session.getUserId();
//   final token = session.getAuthToken();

//   if (userId == null || token == null) {
//     throw Exception('User not authenticated');
//   }

//   final formData = FormData.fromMap({
//     'image': await MultipartFile.fromFile(image.path),
//   });

//   final response = await dio.put(
//     '/users/$userId/image',
//     data: formData,
//     options: Options(
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     ),
//   );

//   return response.data['imageUrl'] as String;
// }
// }
