import 'dart:async';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/core/widgets/chip_input_widget.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/classes.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
              const SizedBox(
                width: 20,
              ),
              Text(
                item.name,
                textAlign: TextAlign.start,
              ),
              const Spacer(),
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

const mockSkillsets = <Skill>[
  Skill('JavaScript', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
  Skill('iOS Development', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_colourbox4057996.jpg'),
  Skill('C', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_colourbox4057996.jpg'),
  Skill('Java', "Fake description",
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  Skill('C++', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_colourbox4057996.jpg'),
  Skill('Kubernetes', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
  Skill('PostgreSQL', "Fake description",
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  Skill('Redis', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_colourbox4057996.jpg'),
  Skill('Android', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
  Skill('Node.js', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_colourbox4057996.jpg'),
  Skill('Objective-C', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_colourbox4057996.jpg'),
  Skill('React Native', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_colourbox4057996.jpg'),
  Skill('Video', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
  Skill('Microservices', "Fake description",
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  Skill('Socket', "Fake description",
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  Skill('AWS', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
  Skill('React', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
  Skill('Git', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
  Skill('SQL', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
  Skill('WebScrape', "Fake description",
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
];

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
  List<Language> _languages = List.empty(growable: true);
  List<Education> _educations = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    _languages.add(Language("English", "Native or Bilingual"));
    _languages.add(Language("Spanish", "Beginner"));
    _languages.add(Language("Cupkkake", "Intermediate"));
    _languages.add(Language("VN", "Null"));
    _languages.add(Language("Monkeyish", "Beginner"));
    _languages.add(Language("Floptropican", "Intermediate"));
    _languages.add(Language("Spanish 2.0", "Native"));
    _languages.add(Language("AHHH", "Beginner"));
    _languages.add(Language("Papi", "Native"));
    _languages.add(Language("Egyptian", "Beginner"));
    _languages.add(Language("Indian", "Native"));
    _languages.add(Language("Nadir", "Beginner"));
    _educations.add(Education("Le Hong Phong Highschool", "2007 - 2010"));
    _educations
        .add(Education("Ho Chi Minh University of Science", "2010 - 2014"));
    _educations
        .add(Education("Ho Chi Minh University of Science", "2014 - 2018"));
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
                    child: const LoadingScreen()),
              );
            },
          )
        ],
      ),
    );
  }

  void _onChipTapped(Skill profile) {
    print('$profile');
  }

  void _onChanged(List<Skill> data) {
    print('onChanged $data');
  }

  Future<List<Skill>> _findSuggestions(String query) async {
    if (query.length != 0) {
      return mockSkillsets.where((profile) {
        return profile.name.contains(query) ||
            profile.description.contains(query);
      }).toList(growable: true);
    } else {
      return mockSkillsets;
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
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          EmptyAppBar(),
          Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                children: [
                  AutoSizeText(
                    AppLocalizations.of(context)
                        .translate('profile_welcome_text'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                    minFontSize: 10,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AutoSizeText(
                    AppLocalizations.of(context)
                        .translate('profile_welcome_text2'),
                    style: const TextStyle(fontSize: 13),
                    minFontSize: 10,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Image.asset(
                  //   'assets/images/img_login.png',
                  //   scale: 1.2,
                  // ),
                  const SizedBox(height: 34.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                      AppLocalizations.of(context)
                          .translate('profile_techstack'),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      minFontSize: 10,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 14.0),
                  const SearchDropdown(),
                  // _buildUserIdField(),
                  // _buildPasswordField(),
                  // _buildForgotPasswordButton(),
                  const SizedBox(
                    height: 24,
                  ),
                  SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                            AppLocalizations.of(context)
                                .translate('profile_skillset'),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                            minFontSize: 10,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                              margin: EdgeInsets.only(
                                right: 5,
                              ),
                              padding: EdgeInsets.zero,
                              child: IconButton(
                                onPressed: () => {
                                  FocusManager.instance.primaryFocus?.unfocus()
                                },
                                icon: Icon(Icons.check_circle_outline),
                              )),
                        ),
                      ],
                    ),
                  ),

                  ChipsInput<Skill>(
                    initialChips: [],
                    onChipTapped: _onChipTapped,
                    decoration: InputDecoration(
                        prefixIconConstraints: BoxConstraints(),
                        // prefixIcon: Container(
                        //     margin: EdgeInsets.only(top: 13),
                        //     child: Icon(
                        //       Icons.search,
                        //     )),
                        hintText: AppLocalizations.of(context)
                            .translate('profile_choose_skillset'),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        )),
                    findSuggestions: _findSuggestions,
                    onChanged: _onChanged,
                    chipBuilder: (BuildContext context,
                        ChipsInputState<Skill> state, Skill profile) {
                      return InputChip(
                        elevation: 8,
                        pressElevation: 9,
                        key: ObjectKey(profile),
                        label: Text(profile.name),
                        labelStyle: const TextStyle(fontSize: 10),
                        visualDensity: VisualDensity.compact,
                        avatar: CircleAvatar(
                          backgroundImage: NetworkImage(profile.imageUrl),
                        ),
                        onDeleted: () => state.deleteChip(profile),
                        onSelected: (_) => _onChipTapped(profile),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    },
                    suggestionBuilder: (BuildContext context,
                        ChipsInputState<Skill> state, Skill profile) {
                      return ListTile(
                        key: ObjectKey(profile),
                        // leading: CircleAvatar(
                        //   backgroundImage: NetworkImage(profile.imageUrl),
                        // ),
                        leading: Icon(Icons.developer_mode),
                        title: Text(profile.name),
                        subtitle: Text(profile.description),
                        onTap: () => state.selectSuggestion(profile),
                      );
                    },
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                            "${AppLocalizations.of(context).translate('profile_languages')}: ${_languages.length}",
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                            minFontSize: 10,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Container(
                            margin: EdgeInsets.only(right: 5),
                            child: IconButton(
                              onPressed: () => {
                                setState(() {
                                  _languages.insert(0,
                                      Language("Name", "...", readOnly: false));
                                })
                              },
                              icon: Icon(Icons.add_circle_outline),
                            )),
                        // Container(
                        //     padding: EdgeInsets.zero,
                        //     child: IconButton(
                        //       onPressed: () => {},
                        //       icon: Icon(Icons.mode_edit_outline),
                        //     )),
                      ],
                    ),
                  ),
                  Container(
                    child: _buildLanguageField(),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(Radius.circular(13))),
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                            "${AppLocalizations.of(context).translate('profile_education')}: ${_educations.length}",
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                            minFontSize: 10,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Container(
                            margin: EdgeInsets.only(right: 5),
                            child: IconButton(
                              onPressed: () => {
                                setState(() {
                                  _educations.insert(
                                      0,
                                      Education("School Name", "2002-2002",
                                          readOnly: false));
                                })
                              },
                              icon: Icon(Icons.add_circle_outline),
                            )),
                        // Container(
                        //     padding: EdgeInsets.zero,
                        //     child: IconButton(
                        //       onPressed: () => {},
                        //       icon: Icon(Icons.mode_edit_outline),
                        //     )),
                      ],
                    ),
                  ),
                  Container(
                    child: _buildEducationField(),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(Radius.circular(13))),
                  ),
                  // _buildUserIdField(),
                  const SizedBox(height: 34.0),
                  _buildSignInButton(),
                ],
              ),
            ),
          ),
          //_buildFooterText(),
          const SizedBox(
            height: 14,
          ),
          //_buildSignUpButton(),
        ],
      ),
    );
  }

  Widget _buildLanguageField() {
    return Observer(
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Scrollbar(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: _languages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: _languages[index].enabled ? null : Colors.grey,
                    child: Row(
                      key: ValueKey(_languages[index]),
                      children: [
                        Wrap(
                          direction: Axis.vertical,
                          spacing: 1,
                          children: [
                            GestureDetector(
                              onDoubleTap: () {
                                if (_languages[index].readOnly &&
                                    _languages[index].enabled)
                                  setState(() {
                                    _languages[index].readOnly = false;
                                  });
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: TextFieldWidget(
                                  inputDecoration: InputDecoration(
                                              border: _languages[index].readOnly
                                                  ? InputBorder.none
                                                  : null),
                                  label: _languages[index].readOnly
                                      ? null
                                      : Text(
                                          AppLocalizations.of(context)
                                              .translate('profile_language'),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                  enabled: _languages[index].enabled,
                                  enableInteractiveSelection:
                                      !_languages[index].readOnly,
                                  canRequestFocus: !_languages[index].readOnly,
                                  iconMargin: EdgeInsets.only(top: 30),
                                  initialValue: _languages[index].name,
                                  readOnly: _languages[index].readOnly,
                                  hint: AppLocalizations.of(context)
                                      .translate('login_et_user_email'),
                                  inputType: TextInputType.emailAddress,
                                  icon: Icons.language,
                                  iconColor: _themeStore.darkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                  textController: null,
                                  inputAction: TextInputAction.next,
                                  autoFocus: false,
                                  onChanged: (value) {
                                    _languages[index].name = value;

                                    // _formStore
                                    //     .setUserId(_userEmailController.text);
                                  },
                                  onFieldSubmitted: (value) {
                                    // FocusScope.of(context)
                                    //     .requestFocus(_passwordFocusNode);
                                  },
                                  errorText: null,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onDoubleTap: () {
                                if (_languages[index].readOnly &&
                                    _languages[index].enabled)
                                  setState(() {
                                    _languages[index].readOnly = false;
                                  });
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: _languages[index].readOnly ? 12 : null,
                                child: TextFieldWidget(
                                  inputDecoration: InputDecoration(
                                              border: _languages[index].readOnly
                                                  ? InputBorder.none
                                                  : null),
                                    label: _languages[index].readOnly
                                        ? null
                                        : Text(
                                            AppLocalizations.of(context).translate(
                                                'profile_language_proficiency'),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                          ),
                                    enabled: _languages[index].enabled,
                                    enableInteractiveSelection:
                                        !_languages[index].readOnly,
                                    canRequestFocus:
                                        !_languages[index].readOnly,
                                    readOnly: _languages[index].readOnly,
                                    initialValue: _languages[index].proficiency,
                                    fontSize:
                                        _languages[index].readOnly ? 10 : 15,
                                    hint: AppLocalizations.of(context)
                                        .translate('login_et_user_email'),
                                    inputType: TextInputType.emailAddress,
                                    icon: null,
                                    textController: null,
                                    inputAction: TextInputAction.next,
                                    autoFocus: false,
                                    onChanged: (value) {
                                      _languages[index].proficiency = value;

                                      // _formStore
                                      //     .setUserId(_userEmailController.text);
                                    },
                                    onFieldSubmitted: (value) {
                                      // FocusScope.of(context)
                                      //     .requestFocus(_passwordFocusNode);
                                    },
                                    errorText: null
                                    // _formStore
                                    //             .formErrorStore.userEmail ==
                                    //         null
                                    //     ? null
                                    //     : AppLocalizations.of(context).translate(
                                    //         _formStore.formErrorStore.userEmail),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Container(
                            width: 20,
                            margin: EdgeInsets.only(right: 10),
                            child: IconButton(
                              padding: EdgeInsets.only(right: 10),
                              onPressed: () {
                                if (_languages[index].enabled) {
                                  setState(() {
                                    _languages[index].readOnly = true;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.done,
                                size: (_languages[index].enabled &&
                                        !_languages[index].readOnly)
                                    ? null
                                    : 0,
                              ),
                            )),
                        Container(
                            width: 20,
                            margin: EdgeInsets.only(right: 20),
                            child: IconButton(
                              padding: EdgeInsets.only(right: 10),
                              onPressed: () {
                                try {
                                  if (_languages[index].enabled) {
                                    setState(() {
                                      _languages[index].enabled = false;
                                    });
                                  } else {
                                    setState(() {
                                      _languages[index].enabled = true;
                                    });
                                  }
                                } catch (E) {
                                  setState(() {});
                                }
                              },
                              icon: _languages[index].enabled
                                  ? Icon(_languages[index].readOnly == false
                                      ? null
                                      : Icons.remove_circle_outline)
                                  : Icon(_languages[index].readOnly == false
                                      ? null
                                      : Icons.restore_rounded),
                            )),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEducationField() {
    return Observer(
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Scrollbar(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: _educations.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: _educations[index].enabled ? null : Colors.grey,
                    child: Row(
                      key: ValueKey(_educations[index]),
                      children: [
                        Wrap(
                          direction: Axis.vertical,
                          spacing: 1,
                          children: [
                            GestureDetector(
                              onDoubleTap: () {
                                if (_educations[index].enabled)
                                  setState(() {
                                    _educations[index].readOnly = false;
                                  });
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: TextFieldWidget(
                                  inputDecoration: InputDecoration(
                                              border: _educations[index].readOnly
                                                  ? InputBorder.none
                                                  : null),
                                  label: _educations[index].readOnly
                                      ? null
                                      : Text(
                                          AppLocalizations.of(context)
                                              .translate('profile_education'),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                  enabled: _educations[index].enabled,
                                  enableInteractiveSelection:
                                      !_educations[index].readOnly,
                                  canRequestFocus: !_educations[index].readOnly,
                                  iconMargin: EdgeInsets.only(top: 30),
                                  initialValue: _educations[index].name,
                                  readOnly: _educations[index].readOnly,
                                  hint: AppLocalizations.of(context)
                                      .translate('login_et_user_email'),
                                  inputType: TextInputType.emailAddress,
                                  icon: Icons.language,
                                  iconColor: _themeStore.darkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                  textController: null,
                                  inputAction: TextInputAction.next,
                                  autoFocus: false,
                                  onChanged: (value) {
                                    _educations[index].name = value;

                                    // _formStore
                                    //     .setUserId(_userEmailController.text);
                                  },
                                  onFieldSubmitted: (value) {
                                    // FocusScope.of(context)
                                    //     .requestFocus(_passwordFocusNode);
                                  },
                                  errorText: null,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: _educations[index].readOnly ? 12 : null,
                              child: TextFieldWidget(
                                inputDecoration: InputDecoration(
                                              border: _educations[index].readOnly
                                                  ? InputBorder.none
                                                  : null),
                                label: _educations[index].readOnly
                                    ? null
                                    : Text(
                                        AppLocalizations.of(context)
                                            .translate('profile_year'),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                enabled: _educations[index].enabled,
                                enableInteractiveSelection:
                                    !_educations[index].readOnly,
                                canRequestFocus: !_educations[index].readOnly,
                                readOnly: _educations[index].readOnly,
                                initialValue: _educations[index].year,
                                fontSize: _educations[index].readOnly ? 10 : 15,
                                hint: AppLocalizations.of(context)
                                    .translate('login_et_user_email'),
                                inputType: TextInputType.emailAddress,
                                icon: null,
                                textController: null,
                                inputAction: TextInputAction.next,
                                autoFocus: false,
                                onChanged: (value) {
                                  _educations[index].year = value;
                                  // _formStore
                                  //     .setUserId(_userEmailController.text);
                                },
                                onFieldSubmitted: (value) {
                                  // FocusScope.of(context)
                                  //     .requestFocus(_passwordFocusNode);
                                },
                                errorText: null,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Container(
                            width: 20,
                            margin: EdgeInsets.only(right: 10),
                            child: IconButton(
                              padding: EdgeInsets.only(right: 10),
                              onPressed: () {
                                if (_educations[index].enabled) {
                                  setState(() {
                                    _educations[index].readOnly = true;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.done,
                                size: (_educations[index].enabled &&
                                        !_educations[index].readOnly)
                                    ? null
                                    : 0,
                              ),
                            )),
                        Container(
                            width: 20,
                            margin: EdgeInsets.only(right: 20),
                            child: IconButton(
                              padding: EdgeInsets.only(right: 10),
                              onPressed: () {
                                try {
                                  if (_educations[index].enabled) {
                                    setState(() {
                                      _educations[index].enabled = false;
                                    });
                                  } else {
                                    setState(() {
                                      _educations[index].enabled = true;
                                    });
                                  }
                                } catch (E) {
                                  setState(() {});
                                }
                              },
                              icon: _educations[index].enabled
                                  ? Icon(_educations[index].readOnly == false
                                      ? null
                                      : Icons.remove_circle_outline)
                                  : Icon(_educations[index].readOnly == false
                                      ? null
                                      : Icons.restore_rounded),
                            )),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
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
          padding: const EdgeInsets.only(top: 16.0),
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
        padding: const EdgeInsets.all(0.0),
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
        width: 200,
        child: RoundedButtonWidget(
          buttonText: AppLocalizations.of(context).translate('profile_next'),
          buttonColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          onPressed: () async {
            Navigator.of(context)
              ..push(MaterialPageRoute2(routeName: Routes.profileStudentStep2));
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
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: <Widget>[
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(left: 10.0, right: 20.0),
              child: const Divider(
                color: Colors.black,
                height: 36,
              )),
        ),
        Text(
          AppLocalizations.of(context).translate('login_btn_sign_up_prompt'),
          style: const TextStyle(fontSize: 12),
        ),
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(left: 20.0, right: 10.0),
              child: const Divider(
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
        margin: const EdgeInsets.fromLTRB(50, 0, 50, 20),
        child: RoundedButtonWidget(
          buttonText:
              AppLocalizations.of(context).translate('login_btn_sign_up'),
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

  Widget navigate(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });

    Future.delayed(const Duration(milliseconds: 0), () {
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
      Future.delayed(const Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: AppLocalizations.of(context).translate('home_tv_error'),
            duration: const Duration(seconds: 3),
          )..show(context);
        }
      });
    }

    return const SizedBox.shrink();
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
