import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';

sealed class BookEditorArgs {
  const BookEditorArgs();

  factory BookEditorArgs.create({
    required List<BookChapterEntity> initialChapters,
  }) = CreateBookArgs;

  factory BookEditorArgs.edit({
    required String existingBookId,
  }) = EditBookArgs;
}

class CreateBookArgs extends BookEditorArgs {
  final List<BookChapterEntity> initialChapters;
  const CreateBookArgs({required this.initialChapters});
}

class EditBookArgs extends BookEditorArgs {
  final String existingBookId;
  const EditBookArgs({required this.existingBookId});
}