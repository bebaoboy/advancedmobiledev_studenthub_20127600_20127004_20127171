import 'dart:async';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../di/service_locator.dart';

class Job with CustomDropdownListFilter {
  final String name;
  final IconData icon;
  const Job(this.name, this.icon);

  @override
  String toString() {
    return name;
  }

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}

const List<Job> _list = [
  Job('Developer', Icons.developer_mode),
  Job('Designer', Icons.design_services),
  Job('Consultant', Icons.account_balance),
  Job('Student', Icons.school),
];

class SearchDropdown extends StatelessWidget {
  const SearchDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<Job>.multiSelectSearch(
      noResultFoundText: "No job found!",
      maxlines: 3,
      hintText: 'Select job role',
      items: _list,
      listItemBuilder: (context, item, isSelected, onItemSelect) {
        return SizedBox(
          height: 30,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(item.icon),
              SizedBox(
                width: 20,
              ),
              Text(
                item.name,
                textAlign: TextAlign.start,
              ),
              Spacer(),
              Checkbox(
                value: isSelected,
                onChanged: (value) => value = isSelected,
              )
            ],
          ),
        );
      },
      onListChanged: (value) {
        print('changing value to: $value');
      },
      validateOnChange: true,
      listValidator: (p0) {
        return p0.isEmpty ? "Must not be null" : null;
      },
    );
  }
}

const mockResults = <AppProfile>[
  AppProfile('ManyMi', 'stock@man.com',
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
  AppProfile('Pension', 'paul@google.com',
      'https://d2gg9evh47fn9z.cloudfront.net/800px_colourbox4057996.jpg'),
  AppProfile('Cancelation', 'fred@google.com',
      'https://d2gg9evh47fn9z.cloudfront.net/800px_colourbox4057996.jpg'),
  AppProfile('Diantier', 'bera@flutter.io',
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  AppProfile('MMMMM', 'john@flutter.io',
      'https://d2gg9evh47fn9z.cloudfront.net/800px_colourbox4057996.jpg'),
  AppProfile('Tim', 'thomas@flutter.io',
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
  AppProfile('Quan', 'norbert@flutter.io',
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  AppProfile('Long', 'marina@flutter.io',
      'https://d2gg9evh47fn9z.cloudfront.net/800px_colourbox4057996.jpg'),
  AppProfile('Stock Man', 'stock@man.com',
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
  AppProfile('Paul', 'paul@google.com',
      'https://d2gg9evh47fn9z.cloudfront.net/800px_colourbox4057996.jpg'),
  AppProfile('Fred', 'fred@google.com',
      'https://d2gg9evh47fn9z.cloudfront.net/800px_colourbox4057996.jpg'),
  AppProfile('Bera', 'bera@flutter.io',
      'https://d2gg9evh47fn9z.cloudfront.net/800px_colourbox4057996.jpg'),
  AppProfile('John', 'john@flutter.io',
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
  AppProfile('Thomas', 'thomas@flutter.io',
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  AppProfile('Norbert', 'norbert@flutter.io',
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  AppProfile('Marina', 'marina@flutter.io',
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
];

class AppProfile {
  final String name;
  final String email;
  final String imageUrl;

  const AppProfile(this.name, this.email, this.imageUrl);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppProfile &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'Profile{$name}';
  }
}

// -------------------------------------------------

typedef ChipsInputSuggestions<T> = Future<List<T>> Function(String query);
typedef ChipSelected<T> = void Function(T data, bool selected);
typedef ChipsBuilder<T> = Widget Function(
    BuildContext context, ChipsInputState<T> state, T data);

class ChipsInput<T> extends StatefulWidget {
  const ChipsInput({
    Key? key,
    this.decoration = const InputDecoration(),
    required this.chipBuilder,
    required this.suggestionBuilder,
    required this.findSuggestions,
    required this.onChanged,
    required this.onChipTapped,
  }) : super(key: key);

  final InputDecoration decoration;
  final ChipsInputSuggestions<T> findSuggestions;
  final ValueChanged<List<T>> onChanged;
  final ValueChanged<T> onChipTapped;
  final ChipsBuilder<T> chipBuilder;
  final ChipsBuilder<T> suggestionBuilder;

  @override
  ChipsInputState<T> createState() => ChipsInputState<T>();
}

class ChipsInputState<T> extends State<ChipsInput<T>>
    implements TextInputClient {
  static const kObjectReplacementChar = 0xFFFC;

  Set<T> _chips = Set<T>();
  List<T> _suggestions = List.empty(growable: true);
  int _searchId = 0;

  FocusNode _focusNode = FocusNode();
  TextEditingValue _value = TextEditingValue();
  TextInputConnection? _connection;
  ScrollController _scrollController = ScrollController();

  String get text => String.fromCharCodes(
        _value.text.codeUnits.where((ch) => ch != kObjectReplacementChar),
      );

  bool get _hasInputConnection => _connection != null && _connection!.attached;

  void requestKeyboard() {
    if (_focusNode.hasFocus) {
      _openInputConnection();
    } else {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void selectSuggestion(T data) {
    setState(() {
      _chips.add(data);
      _updateTextInputState();
      _suggestions.remove(data);
      // _scrollController.animateTo(
      //   _scrollController.position.maxScrollExtent,
      //   duration: Duration(milliseconds: 10),
      //   curve: Curves.ease,
      // );
    });
    widget.onChanged(_chips.toList(growable: false));
  }

  void deleteChip(T data) {
    setState(() {
      _chips.remove(data);
      _updateTextInputState();
    });
    widget.onChanged(_chips.toList(growable: false));
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _openInputConnection();
    } else {
      _closeInputConnectionIfNeeded();
    }
    setState(() {
      // rebuild so that _TextCursor is hidden.
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _closeInputConnectionIfNeeded();
    super.dispose();
  }

  void _openInputConnection() {
    if (!_hasInputConnection) {
      _connection = TextInput.attach(this, TextInputConfiguration());
      _connection!.setEditingState(_value);
    }
    _connection!.show();
    _onSearchChanged("");
  }

  void _closeInputConnectionIfNeeded() {
    if (_hasInputConnection) {
      _connection!.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    var chipsChildren = _chips
        .map<Widget>(
          (data) => widget.chipBuilder(context, this, data),
        )
        .toList();

    final theme = Theme.of(context);

    chipsChildren.add(
      Container(
        height: 32.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              text,
              style: theme.textTheme.subtitle1?.copyWith(
                height: 1.5,
              ),
            ),
            _TextCaret(
              resumed: _focusNode.hasFocus,
            ),
          ],
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: SizedBox(
        height: _focusNode.hasFocus
            ? 500
            : _chips.length == 0
                ? 65
                : 102,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            //mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: requestKeyboard,
                child: InputDecorator(
                  decoration: widget.decoration,
                  isFocused: _focusNode.hasFocus,
                  isEmpty: _value.text.length == 0,
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 70),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      reverse: true,
                      child: Wrap(
                        children: chipsChildren,
                        spacing: 2.0,
                        runSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return widget.suggestionBuilder(
                        context, this, _suggestions[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    final oldCount = _countReplacements(_value);
    final newCount = _countReplacements(value);
    setState(() {
      if (newCount < oldCount) {
        _chips = Set.from(_chips.take(newCount));
      }
      _value = value;
    });
    _onSearchChanged(text);
  }

  int _countReplacements(TextEditingValue value) {
    return value.text.codeUnits
        .where((ch) => ch == kObjectReplacementChar)
        .length;
  }

  @override
  void performAction(TextInputAction action) {
    _focusNode.unfocus();
  }

  void _updateTextInputState() {
    final text =
        String.fromCharCodes(_chips.map((_) => kObjectReplacementChar));
    _value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange(start: 0, end: text.length),
    );
    _connection!.setEditingState(_value);
  }

  void _onSearchChanged(String value) async {
    final localId = ++_searchId;
    await widget.findSuggestions(value).then((value) {
      if (_searchId == localId && mounted) {
        setState(() {
          _suggestions = value
              .where((profile) => !_chips.contains(profile))
              .toList(growable: true);
        });
      }
    });
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TextCaret extends StatefulWidget {
  const _TextCaret({
    Key? key,
    this.duration = const Duration(milliseconds: 500),
    this.resumed = false,
  }) : super(key: key);

  final Duration duration;
  final bool resumed;

  @override
  _TextCursorState createState() => _TextCursorState();
}

class _TextCursorState extends State<_TextCaret>
    with SingleTickerProviderStateMixin {
  bool _displayed = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.duration, _onTimer);
  }

  void _onTimer(Timer timer) {
    setState(() => _displayed = !_displayed);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Opacity(
        opacity: _displayed && widget.resumed ? 1.0 : 0.0,
        child: Container(
          width: 2.0,
          color: theme.primaryColor,
        ),
      ),
    );
  }
}

class ProfileStudentScreen extends StatefulWidget {
  @override
  _ProfileStudentScreenState createState() => _ProfileStudentScreenState();
}

class _ProfileStudentScreenState extends State<ProfileStudentScreen> {
  //text controllers:-----------------------------------------------------------
  TextEditingController _userEmailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final FormStore _formStore = getIt<FormStore>();
  final UserStore _userStore = getIt<UserStore>();

  //focus node:-----------------------------------------------------------------
  late FocusNode _passwordFocusNode;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Material(
      child: Stack(
        children: <Widget>[
          MediaQuery.of(context).orientation == Orientation.landscape
              ? Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: _buildLeftSide(),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildRightSide(),
                    ),
                  ],
                )
              : Container(child: _buildRightSide()),
          Observer(
            builder: (context) {
              return _userStore.success
                  ? navigate(context)
                  : _showErrorMessage(_formStore.errorStore.errorMessage);
            },
          ),
          Observer(
            builder: (context) {
              return Visibility(
                visible: _userStore.isLoading || loading,
                // child: CustomProgressIndicatorWidget(),
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        loading = false;
                      });
                    },
                    child: LoadingScreen()),
              );
            },
          )
        ],
      ),
    );
  }

  void _onChipTapped(AppProfile profile) {
    print('$profile');
  }

  void _onChanged(List<AppProfile> data) {
    print('onChanged $data');
  }

  Future<List<AppProfile>> _findSuggestions(String query) async {
    if (query.length != 0) {
      return mockResults.where((profile) {
        return profile.name.contains(query) || profile.email.contains(query);
      }).toList(growable: true);
    } else {
      return mockResults;
    }
  }

  Widget _buildLeftSide() {
    return SizedBox.expand(
      child: Image.asset(
        Assets.carBackground,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildRightSide() {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          EmptyAppBar(),
          Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                children: [
                  AutoSizeText(
                    AppLocalizations.of(context)
                        .translate('profile_welcome_text'),
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    minFontSize: 10,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AutoSizeText(
                    AppLocalizations.of(context)
                        .translate('profile_welcome_text2'),
                    style: TextStyle(fontSize: 13),
                    minFontSize: 10,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Image.asset(
                  //   'assets/images/img_login.png',
                  //   scale: 1.2,
                  // ),
                  SizedBox(height: 34.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                      AppLocalizations.of(context)
                          .translate('profile_techstack'),
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      minFontSize: 10,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 14.0),
                  SearchDropdown(),
                  // _buildUserIdField(),
                  // _buildPasswordField(),
                  // _buildForgotPasswordButton(),
                  SizedBox(
                    height: 24,
                  ),
                  SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AutoSizeText(
                          AppLocalizations.of(context)
                              .translate('profile_skillset'),
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                          minFontSize: 10,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: Container(
                                padding: EdgeInsets.zero,
                                child: Icon(
                                  Icons.check_circle_outline,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
      
                  SizedBox(height: 14.0),
                  ChipsInput<AppProfile>(
                    onChipTapped: _onChipTapped,
                    decoration: InputDecoration(
                        prefixIconConstraints: BoxConstraints(),
                        // prefixIcon: Container(
                        //     margin: EdgeInsets.only(top: 13),
                        //     child: Icon(
                        //       Icons.search,
                        //     )),
                        hintText: 'Profile search',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        )),
                    findSuggestions: _findSuggestions,
                    onChanged: _onChanged,
                    chipBuilder: (BuildContext context,
                        ChipsInputState<AppProfile> state,
                        AppProfile profile) {
                      return InputChip(
                        elevation: 8,
                        pressElevation: 9,
                        key: ObjectKey(profile),
                        label: Text(profile.name),
                        labelStyle: TextStyle(fontSize: 10),
                        visualDensity: VisualDensity.compact,
                        avatar: CircleAvatar(
                          backgroundImage: NetworkImage(profile.imageUrl),
                        ),
                        onDeleted: () => state.deleteChip(profile),
                        onSelected: (_) => _onChipTapped(profile),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      );
                    },
                    suggestionBuilder: (BuildContext context,
                        ChipsInputState<AppProfile> state,
                        AppProfile profile) {
                      return ListTile(
                        key: ObjectKey(profile),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(profile.imageUrl),
                        ),
                        title: Text(profile.name),
                        subtitle: Text(profile.email),
                        onTap: () => state.selectSuggestion(profile),
                      );
                    },
                  ),
                  SizedBox(height: 24.0),
                  SizedBox(
                    height: 30,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AutoSizeText(
                          AppLocalizations.of(context)
                              .translate('profile_languages'),
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                          minFontSize: 10,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Container(
                              padding: EdgeInsets.zero,
                              child: Icon(
                                Icons.add_circle_outline,
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Container(
                              padding: EdgeInsets.zero,
                              child: Icon(
                                Icons.mode_edit_outline,
                              )),
                        ),
                      ],
                    ),
                  ),
                  _buildUserIdField(),
                  SizedBox(height: 24.0),
      SizedBox(
                    height: 30,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AutoSizeText(
                          AppLocalizations.of(context)
                              .translate('profile_education'),
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                          minFontSize: 10,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Container(
                              padding: EdgeInsets.zero,
                              child: Icon(
                                Icons.add_circle_outline,
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Container(
                              padding: EdgeInsets.zero,
                              child: Icon(
                                Icons.mode_edit_outline,
                              )),
                        ),
                      ],
                    ),
                  ),
                  _buildUserIdField(),
                  _buildUserIdField(),
                  SizedBox(height: 34.0),
                  _buildSignInButton(),
                ],
              ),
            ),
          ),
          //_buildFooterText(),
          SizedBox(
            height: 14,
          ),
          //_buildSignUpButton(),
        ],
      ),
    );
  }

  Widget _buildUserIdField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: AppLocalizations.of(context).translate('login_et_user_email'),
          inputType: TextInputType.emailAddress,
          icon: Icons.person,
          iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
          textController: _userEmailController,
          inputAction: TextInputAction.next,
          autoFocus: false,
          onChanged: (value) {
            _formStore.setUserId(_userEmailController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          errorText: _formStore.formErrorStore.userEmail == null
              ? null
              : AppLocalizations.of(context)
                  .translate(_formStore.formErrorStore.userEmail),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint:
              AppLocalizations.of(context).translate('login_et_user_password'),
          isObscure: true,
          padding: EdgeInsets.only(top: 16.0),
          icon: Icons.lock,
          iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
          textController: _passwordController,
          focusNode: _passwordFocusNode,
          errorText: _formStore.formErrorStore.password == null
              ? null
              : AppLocalizations.of(context)
                  .translate(_formStore.formErrorStore.password),
          onChanged: (value) {
            _formStore.setPassword(_passwordController.text);
          },
        );
      },
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: FractionalOffset.centerRight,
      child: MaterialButton(
        padding: EdgeInsets.all(0.0),
        child: Text(
          AppLocalizations.of(context).translate('login_btn_forgot_password'),
          style: Theme.of(context)
              .textTheme
              .caption
              ?.copyWith(color: Colors.orangeAccent),
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _buildSignInButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
width: 200,        child: RoundedButtonWidget(
          buttonText: AppLocalizations.of(context).translate('profile_next'),
          buttonColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          onPressed: () async {
            // if (_formStore.canProfileStudent) {
            //   DeviceUtils.hideKeyboard(context);
            //   _userStore.login(
            //       _userEmailController.text, _passwordController.text);
            // } else {
            //   _showErrorMessage(AppLocalizations.of(context)
            //       .translate('login_error_missing_fields'));
            // }
          },
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: <Widget>[
        Expanded(
          child: new Container(
              margin: const EdgeInsets.only(left: 10.0, right: 20.0),
              child: Divider(
                color: Colors.black,
                height: 36,
              )),
        ),
        Text(
          AppLocalizations.of(context).translate('login_btn_sign_up_prompt'),
          style: TextStyle(fontSize: 12),
        ),
        Expanded(
          child: new Container(
              margin: const EdgeInsets.only(left: 20.0, right: 10.0),
              child: Divider(
                color: Colors.black,
                height: 36,
              )),
        ),
      ]),
    );
  }

  Widget _buildSignUpButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        margin: EdgeInsets.fromLTRB(50, 0, 50, 20),
        child: RoundedButtonWidget(
          buttonText:
              AppLocalizations.of(context).translate('login_btn_sign_up'),
          buttonColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          onPressed: () async {
            Navigator.of(context)
              ..push(MaterialPageRoute2(routeName: Routes.signUp));
            // if (_formStore.canProfileStudent) {
            //   DeviceUtils.hideKeyboard(context);
            //   _userStore.login(
            //       _userEmailController.text, _passwordController.text);
            // } else {
            //   _showErrorMessage(AppLocalizations.of(context)
            //       .translate('login_error_missing_fields'));
            // }
          },
        ),
      ),
    );
  }

  Widget navigate(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });

    Future.delayed(Duration(milliseconds: 0), () {
      print("LOADING = $loading");
      Navigator.of(context)
        ..pushAndRemoveUntil(MaterialPageRoute2(routeName: Routes.home),
            (Route<dynamic> route) => false);
    });

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: AppLocalizations.of(context).translate('home_tv_error'),
            duration: Duration(seconds: 3),
          )..show(context);
        }
      });
    }

    return SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _userEmailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
