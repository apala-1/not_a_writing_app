import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';

class BookApiModel extends BookEntity {
  BookApiModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
  });

  factory BookApiModel.fromJson(Map<String, dynamic> json) {
    return BookApiModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  BookEntity toEntity() {
    return BookEntity(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
    );
  }
}