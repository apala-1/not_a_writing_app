// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_attachment_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostAttachmentHiveAdapter extends TypeAdapter<PostAttachmentHive> {
  @override
  final int typeId = 31;

  @override
  PostAttachmentHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostAttachmentHive(
      id: fields[0] as String?,
      url: fields[1] as String,
      type: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PostAttachmentHive obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostAttachmentHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
