class CommentUserEntity {
  final String id;
  final String name;
  final String? profilePicture; // filename or url

  const CommentUserEntity({
    required this.id,
    required this.name,
    required this.profilePicture,
  });
}