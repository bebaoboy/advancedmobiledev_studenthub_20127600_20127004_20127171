import 'package:boilerplate/domain/entity/user/user.dart';

class Account {
  final User user;
  final List<Account> children;
  bool isExpanded = true;
  bool isLoggedIn;

  Account(this.user, {this.children = const <Account>[], this.isLoggedIn = false});
}
