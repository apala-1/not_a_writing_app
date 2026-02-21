import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final String url;
  final String type; // image | gif | file

  const Attachment({
    required this.url,
    required this.type,
  });

  @override
  List<Object?> get props => [url, type];
}