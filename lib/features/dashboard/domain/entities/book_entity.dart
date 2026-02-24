class BookEntity {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  BookEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });
}