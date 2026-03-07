import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

class PostsToChaptersMapper {
  static List<BookChapterEntity> map(List<PostEntity> posts) {
    return List.generate(posts.length, (i) {
      final p = posts[i];
      final title = (p.title != null && p.title!.trim().isNotEmpty)
          ? p.title!.trim()
          : 'Chapter ${i + 1}';

      final items = <BookContentItemEntity>[];

      final text = (p.content ?? '').trim();
      if (text.isNotEmpty) {
        items.add(BookContentItemEntity(type: 'text', value: text));
      }

      // optional: include post attachments as images
      for (final att in p.attachments) {
        if (att.type == 'image' || att.type == 'gif') {
          items.add(BookContentItemEntity(type: 'image', value: att.url));
        }
      }

      if (items.isEmpty) {
        items.add(const BookContentItemEntity(type: 'text', value: ''));
      }

      return BookChapterEntity(title: title, content: items);
    });
  }
}