import 'package:boilerplate/presentation/setting/setting.dart';

class Account {
  final String name;
  final AccountType type;
  final List<Account> children;

  Account(this.type, this.name, [this.children = const <Account>[]]);
}
