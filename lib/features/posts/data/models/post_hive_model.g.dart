// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostHiveAdapter extends TypeAdapter<PostHive> {
  @override
  final int typeId = 32;

  @override
  PostHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostHive(
      id: fields[0] as String,
      author: fields[1] as PostAuthorHive?,
      title: fields[2] as String?,
      description: fields[3] as String?,
      content: fields[4] as String?,
      attachments: (fields[5] as List).cast<PostAttachmentHive>(),
      status: fields[6] as String,
      visibility: fields[7] as String,
      viewsCount: fields[8] as int,
      likesCount: fields[9] as int,
      savesCount: fields[10] as int,
      sharesCount: fields[11] as int,
      commentsCount: fields[12] as int,
      isLiked: fields[13] as bool,
      isSaved: fields[14] as bool,
      createdAtMillis: fields[15] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PostHive obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.author)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.attachments)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.visibility)
      ..writeByte(8)
      ..write(obj.viewsCount)
      ..writeByte(9)
      ..write(obj.likesCount)
      ..writeByte(10)
      ..write(obj.savesCount)
      ..writeByte(11)
      ..write(obj.sharesCount)
      ..writeByte(12)
      ..write(obj.commentsCount)
      ..writeByte(13)
      ..write(obj.isLiked)
      ..writeByte(14)
      ..write(obj.isSaved)
      ..writeByte(15)
      ..write(obj.createdAtMillis);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
