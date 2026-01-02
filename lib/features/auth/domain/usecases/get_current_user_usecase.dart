import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<AuthEntity?> call() {
    return repository.getCurrentUser();
  }
}
