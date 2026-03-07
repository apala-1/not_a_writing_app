// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_author_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostAuthorHiveAdapter extends TypeAdapter<PostAuthorHive> {
  @override
  final int typeId = 30;

  @override
  PostAuthorHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostAuthorHive(
      id: fields[0] as String,
      name: fields[1] as String,
      profilePictureUrl: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PostAuthorHive obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.profilePictureUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostAuthorHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
