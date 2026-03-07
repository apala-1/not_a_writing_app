// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';

// class WriteViewModel extends ChangeNotifier {
//   final IPostRepository repository;

//   WriteViewModel(this.repository);

//   final titleController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final contentController = TextEditingController();

//   final ImagePicker _picker = ImagePicker();
//   List<File> selectedImages = [];

//   bool isDraft = false;
//   bool isLoading = false;

//   Future<void> pickImage() async {
//     final image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       selectedImages.add(File(image.path));
//       notifyListeners();
//     }
//   }

//   Future<void> submitPost({String? postId}) async {
//     if (isLoading) return;
//     isLoading = true;
//     notifyListeners();

//     try {
//       if (postId == null) {
//         await repository.createPost(
//           title: titleController.text,
//           description: descriptionController.text,
//           content: contentController.text,
//           isDraft: isDraft,
//           attachments: selectedImages,
//         );
//       } else {
//         await repository.updatePost(
//           postId: postId,
//           title: titleController.text,
//           description: descriptionController.text,
//           content: contentController.text,
//           isDraft: isDraft,
//           attachments: selectedImages,
//         );
//       }
//     } catch (e) {
//       rethrow;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   void toggleDraft(bool value) {
//     isDraft = value;
//     notifyListeners();
//   }
// }
