import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';

class SaveUserDataUsecase extends UseCase<void, User?> {
  final UserRepository _userRepository;

  SaveUserDataUsecase(this._userRepository);

  @override
  Future<void> call({required User? params}) async {
    return _userRepository.changeUserData(params);
  }
}
