import 'package:hive/hive.dart';
import 'package:not_a_writing_app/core/constants/hive_table_constant.dart';
import 'package:not_a_writing_app/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {

  @HiveField(0)
  final String? authId;
  @HiveField(1)
  final String fullname;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String? password;

  AuthHiveModel({
    String? authId,
    required this.fullname,
    required this.email,
    this.password
  }) : authId = authId ?? Uuid().v4();

  // From Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullname: entity.fullname,
      email: entity.email,
      password: entity.password,
    );
  }

  // To Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullname: fullname,
      email: email,
      password: password,
    );
  }

  // To Entity List
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}