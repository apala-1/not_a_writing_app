import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/book_repository.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

final createBookUsecaseProvider = Provider<CreateBookUseCase>((ref) {
  final repo = ref.read(bookRepositoryProvider);
  return CreateBookUseCase(repo);
});

class CreateBookUseCase {
  final BookRepository repository;

  CreateBookUseCase(this.repository);

  Future<BookEntity> call(List<PostEntity> posts, {required String title, required String description, required XFile coverPhoto}) {
    final chapters = posts.map((post) {
      return {
        "title": post.title,   // Post title → Chapter title
        "content": [
          {
            "type": "text",
            "value": post.content,
          },

          // Attachments → Images inside chapter
          ...post.attachments
              .where((att) => att.type == "image")
              .map((att) => {
                    "type": "image",
                    "value": att.url,
                  }),
        ]
      };
    }).toList();

    final body = {
      "title": title,
      "description": description,
      "coverPhoto": coverPhoto,
      "chapters": chapters,
    };

    return repository.createBookMultipart(
      title: title,
      description: description,
      chapters: chapters,
      coverPhoto: coverPhoto,
    );
  }
}