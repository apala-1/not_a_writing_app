import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/create_book_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

final bookViewModelProvider = Provider<BookViewmodel>((ref) {
  final createBookUseCase = ref.read(createBookUsecaseProvider);
  return BookViewmodel(createBookUseCase);
});

class BookViewmodel {
  final CreateBookUseCase _createBookUseCase;

  BookViewmodel(this._createBookUseCase);

  Future<void> createBook(List<PostEntity> selectedPosts, {required String title, required String description, required XFile coverPhoto}) async {
    try {
      final book = await _createBookUseCase(selectedPosts, title: title, description: description, coverPhoto: coverPhoto);
      print("Book created: ${book.title}");
      // You can now remove your temporary body print
    } catch (e) {
      print("Error creating book: $e");
    }
  }
}