import 'package:boilerplate/domain/entity/user/user.dart';

class Account {
  final User user;
  final UserType type;
  final List<Account> children;
  bool isExpanded = true;
  bool isLoggedIn;

  Account(this.user,
      {required this.type,
      this.children = const <Account>[],
      this.isLoggedIn = false});
}
