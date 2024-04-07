import 'dart:async';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/core/widgets/chip_input_widget.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/presentation/profile/store/form/profile_info_store.dart';
import 'package:boilerplate/presentation/profile/store/form/profile_student_form_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../di/service_locator.dart';

// class Job with CustomDropdownListFilter {
//   final String name;
//   final IconData icon;
//   const Job(this.name, this.icon);

//   @override
//   String toString() {
//     return name;
//   }

//   @override
//   bool filter(String query) {
//     return name.toLowerCase().contains(query.toLowerCase());
//   }
// }

// const List<Job> _list = [
//   Job('Developer', Icons.developer_mode),
//   Job('Designer', Icons.design_services),
//   Job('Consultant', Icons.account_balance),
//   Job('Student', Icons.school),
// ];

class SearchDropdown extends StatefulWidget {
  const SearchDropdown({super.key, required this.onListChangedCallback});
  final Function(TechStack) onListChangedCallback;

  @override
  State<SearchDropdown> createState() => _SearchDropdownState();
}

class _SearchDropdownState extends State<SearchDropdown> {
  final userStore = getIt<UserStore>();

  final ProfileStudentStore _infoStore = getIt<ProfileStudentStore>();

  List<TechStack> _list = [
    TechStack("Designer", id: "5"),
    TechStack("Developer", id: "1"),
    TechStack("Consultant", id: "2"),
    TechStack("Student", id: "3"),
    TechStack("Backend Developer", id: "4"),
  ];

  @override
  void initState() {
    super.initState();
    if (_infoStore.techStack.isNotEmpty) {
      _list = _infoStore.techStack;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<TechStack>.searchRequest(
      initialItem: userStore.user != null &&
              userStore.user!.studentProfile != null &&
              userStore.user!.studentProfile!.techStack != null
          ? userStore.user!.studentProfile!.techStack!
          : _list[0],
      futureRequest: (p0) {
        return Future.microtask(
          () {
            return _list;
          },
        );
      },
      futureRequestDelay: const Duration(seconds: 1),
      onChanged: (p0) {
        widget.onListChangedCallback(p0);
      },
      noResultFoundText: Lang.get("nothing_here"),
      maxlines: 3,
      hintText: Lang.get('profile_choose_techstack'),
      items: _list,
      listItemBuilder: (context, item, isSelected, onItemSelect) {
        return SizedBox(
          height: 30,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon(item.icon),
              // const SizedBox(
              //   width: 20,
              // ),
              Text(
                item.name,
                textAlign: TextAlign.start,
              ),
              // const Spacer(),
              // Checkbox(
              //   value: isSelected,
              //   onChanged: (value) => value = isSelected,
              // )
            ],
          ),
        );
      },
      // onListChanged: (value) {
      //   //print('changing value to: $value');
      //   onListChangedCallback(value);
      // },
      // validateOnChange: true,
      // validator: (p0) {
      //   return p0.isEmpty ? "Must not be null" : null;
      // },
    );
  }
}

var mockSkillsets = <Skill>[
  Skill('JavaScript', "Fake description", '', id: "1"),
  Skill('iOS Development', "Fake description", '', id: "2"),
  Skill('C', "Fake description", '', id: "3"),
  Skill('Java', "Fake description",
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
      id: "4"),
  Skill('C++', "Fake description", '', id: "5"),
  Skill('Kubernetes', "Fake description", '', id: "6"),
  Skill('PostgreSQL', "Fake description",
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
      id: "7"),
  Skill('Redis', "Fake description", '', id: "8"),
  Skill('Android', "Fake description", '', id: "9"),
  Skill('Node.js', "Fake description", '', id: "10"),
  Skill('Objective-C', "Fake description", '', id: "11"),
  Skill('React Native', "Fake description", '', id: "12"),
  Skill('Video', "Fake description", '', id: "13"),
  Skill('Microservices', "Fake description",
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
      id: "14"),
  Skill('Socket', "Fake description",
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
      id: "15"),
  Skill('AWS', "Fake description", '', id: "16"),
  Skill('React', "Fake description", '', id: "17"),
  Skill('Git', "Fake description", '', id: "18"),
  // Skill('SQL', "Fake description", ''),
  // Skill('WebScrape', "Fake description", ''),
];

class ProfileStudentScreen extends StatefulWidget {
  const ProfileStudentScreen({super.key, this.fullName = ""});
  final String fullName;

  @override
  _ProfileStudentScreenState createState() => _ProfileStudentScreenState();
}

class _ProfileStudentScreenState extends State<ProfileStudentScreen> {
  //text controllers:-----------------------------------------------------------

  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final FormStore _formStore = getIt<FormStore>();
  final UserStore _userStore = getIt<UserStore>();
  final ProfileStudentFormStore _profileStudentFormStore =
      getIt<ProfileStudentFormStore>();
  final ProfileStudentStore _infoStore = getIt<ProfileStudentStore>();

  //focus node:-----------------------------------------------------------------

  bool loading = false;
  final List<Language> _languages = List.empty(growable: true);
  final List<Education> _educations = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
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
    _educations.add(Education("Le Hong Phong Highschool",
        startYear: DateTime(2007), endYear: DateTime(2010)));
    _educations.add(Education("Ho Chi Minh University of Science",
        startYear: DateTime(2010), endYear: DateTime(2014)));
    _educations.add(Education("Ho Chi Minh University of Science",
        startYear: DateTime(2014), endYear: DateTime(2018)));
    mockSkillsets = _infoStore.skillSet;
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
    //print('$profile');
  }

  void _onChanged(List<Skill> data) {
    _profileStudentFormStore.setSkillSet(data);
    print('onChanged $data');
  }

  Future<List<Skill>> _findSuggestions(String query) async {
    if (query.isNotEmpty) {
      return mockSkillsets.where((profile) {
        return profile.name.contains(query) ||
            profile.description.contains(query);
      }).toList(growable: true);
    } else {
      return mockSkillsets;
    }
  }

  Widget _buildRightSide() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const EmptyAppBar(),
          Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                children: [
                  AutoSizeText(
                    Lang.get('profile_welcome_text'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                    minFontSize: 10,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AutoSizeText(
                    Lang.get('profile_welcome_text2'),
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
                      Lang.get('profile_techstack'),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      minFontSize: 10,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 14.0),
                  SearchDropdown(
                    onListChangedCallback: (p0) {
                      _profileStudentFormStore.setTechStack(p0);
                    },
                  ),
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
                            Lang.get('profile_skillset'),
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
                              margin: const EdgeInsets.only(
                                right: 5,
                              ),
                              padding: EdgeInsets.zero,
                              child: IconButton(
                                onPressed: () => {
                                  FocusManager.instance.primaryFocus?.unfocus()
                                },
                                icon: const Icon(Icons.check_circle_outline),
                              )),
                        ),
                      ],
                    ),
                  ),

                  // Skillset
                  ChipsInput<Skill>(
                    initialChips: const [],
                    onChipTapped: _onChipTapped,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 13),
                        prefixIconConstraints: const BoxConstraints(),
                        // prefixIcon: Container(
                        //     margin: EdgeInsets.only(top: 13),
                        //     child: Icon(
                        //       Icons.search,
                        //     )),
                        hintText: Lang.get('profile_choose_skillset'),
                        hintStyle: const TextStyle(
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
                          backgroundImage: profile.imageUrl.isNotEmpty
                              ? NetworkImage(profile.imageUrl)
                              : null,
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
                        leading: const Icon(Icons.developer_mode),
                        title: Text(profile.name),
                        subtitle: Text(
                          "id: ${profile.description}",
                          style: const TextStyle(fontSize: 11),
                        ),
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
                            "${Lang.get('profile_languages')}: ${_languages.length}",
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                            minFontSize: 10,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Container(
                            margin: const EdgeInsets.only(right: 5),
                            child: IconButton(
                              onPressed: () => {
                                setState(() {
                                  _languages.insert(0,
                                      Language("Name", "...", readOnly: false));
                                  setLanguage();
                                })
                              },
                              icon: const Icon(Icons.add_circle_outline),
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
                    decoration: const BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(Radius.circular(13))),
                    child: _buildLanguageField(),
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
                            "${Lang.get('profile_education')}: ${_educations.length}",
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                            minFontSize: 10,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Container(
                            margin: const EdgeInsets.only(right: 5),
                            child: IconButton(
                              onPressed: () => {
                                setState(() {
                                  _educations.insert(
                                      0,
                                      Education("School Name",
                                          readOnly: false,
                                          startYear: DateTime(2002),
                                          endYear: DateTime(2002)));
                                  setEducation();
                                })
                              },
                              icon: const Icon(Icons.add_circle_outline),
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
                    decoration: const BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(Radius.circular(13))),
                    child: _buildEducationField(),
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

  openHintBar() {
    FlushbarHelper.createInformation(
      message: Lang.get("double_click_to_edit"),
    ).show(context);
  }

  setLanguage() {
    _profileStudentFormStore.setLanguages(_languages
        .where(
          (e) => e.enabled,
        )
        .toList());
  }

  Widget _buildLanguageField() {
    return SizedBox(
      height: 200,
      child: Scrollbar(
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
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
                                _languages[index].enabled) {
                              setState(() {
                                _languages[index].readOnly = false;
                              });
                            }
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: TextFieldWidget(
                              onTap: () {
                                if (_languages[index].readOnly) {
                                  openHintBar();
                                }
                              },
                              inputDecoration: InputDecoration(
                                  border: _languages[index].readOnly
                                      ? InputBorder.none
                                      : null),
                              label: _languages[index].readOnly
                                  ? null
                                  : Text(
                                      Lang.get('profile_language'),
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
                              iconMargin: const EdgeInsets.only(top: 30),
                              initialValue: _languages[index].languageName,
                              readOnly: _languages[index].readOnly,
                              hint: Lang.get('login_et_user_email'),
                              inputType: TextInputType.emailAddress,
                              icon: Icons.language,
                              iconColor: _themeStore.darkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              textController: null,
                              inputAction: TextInputAction.next,
                              autoFocus: false,
                              onChanged: (value) {
                                _languages[index].languageName = value;

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
                                _languages[index].enabled) {
                              setState(() {
                                _languages[index].readOnly = false;
                              });
                            }
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: _languages[index].readOnly ? 12 : null,
                            child: TextFieldWidget(
                                onTap: () {
                                  if (_languages[index].readOnly) {
                                    openHintBar();
                                  }
                                },
                                inputDecoration: InputDecoration(
                                    border: _languages[index].readOnly
                                        ? InputBorder.none
                                        : null),
                                label: _languages[index].readOnly
                                    ? null
                                    : Text(
                                        Lang.get(
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
                                canRequestFocus: !_languages[index].readOnly,
                                readOnly: _languages[index].readOnly,
                                initialValue: _languages[index].level,
                                fontSize: _languages[index].readOnly ? 10 : 15,
                                hint: Lang.get('login_et_user_email'),
                                inputType: TextInputType.emailAddress,
                                icon: null,
                                textController: null,
                                inputAction: TextInputAction.next,
                                autoFocus: false,
                                onChanged: (value) {
                                  _languages[index].level = value;

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
                                //     : AppLocalizations.of(context).get(
                                //         _formStore.formErrorStore.userEmail),
                                ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                        width: 20,
                        margin: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          padding: const EdgeInsets.only(right: 10),
                          onPressed: () {
                            if (_languages[index].enabled) {
                              setState(() {
                                _languages[index].readOnly = true;
                              });
                              setLanguage();
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
                        margin: const EdgeInsets.only(right: 20),
                        child: IconButton(
                          padding: const EdgeInsets.only(right: 10),
                          onPressed: () {
                            try {
                              if (_languages[index].readOnly == false) return;

                              if (_languages[index].enabled) {
                                setState(() {
                                  _languages[index].enabled = false;
                                });
                              } else {
                                setState(() {
                                  _languages[index].enabled = true;
                                });
                              }
                              setLanguage();
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
  }

  setEducation() {
    _profileStudentFormStore.setEducations(_educations
        .where(
          (e) => e.enabled,
        )
        .toList());
  }

  Widget _buildEducationField() {
    return SizedBox(
      height: 200,
      child: Scrollbar(
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
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
                            if (_educations[index].enabled) {
                              setState(() {
                                _educations[index].readOnly = false;
                              });
                            }
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: TextFieldWidget(
                              onTap: () {
                                if (_educations[index].readOnly) {
                                  openHintBar();
                                }
                              },
                              inputDecoration: InputDecoration(
                                  border: _educations[index].readOnly
                                      ? InputBorder.none
                                      : null),
                              label: _educations[index].readOnly
                                  ? null
                                  : Text(
                                      Lang.get('profile_education'),
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
                              iconMargin: const EdgeInsets.only(top: 30),
                              initialValue: _educations[index].schoolName,
                              readOnly: _educations[index].readOnly,
                              hint: Lang.get('login_et_user_email'),
                              inputType: TextInputType.emailAddress,
                              icon: Icons.language,
                              iconColor: _themeStore.darkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              textController: null,
                              inputAction: TextInputAction.next,
                              autoFocus: false,
                              onChanged: (value) {
                                _educations[index].schoolName = value;

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
                          child: _educations[index].readOnly
                              ? TextFieldWidget(
                                  inputDecoration: InputDecoration(
                                      border: _educations[index].readOnly
                                          ? InputBorder.none
                                          : null),
                                  label: _educations[index].readOnly
                                      ? null
                                      : Text(
                                          Lang.get('year'),
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
                                  initialValue: _educations[index].year(),
                                  fontSize:
                                      _educations[index].readOnly ? 10 : 15,
                                  hint: Lang.get('login_et_user_email'),
                                  inputType: TextInputType.emailAddress,
                                  icon: null,
                                  textController: null,
                                  inputAction: TextInputAction.next,
                                  autoFocus: false,
                                  onChanged: (value) {
                                    // _educations[index].year() = value;
                                    // _formStore
                                    //     .setUserId(_userEmailController.text);
                                  },
                                  onFieldSubmitted: (value) {
                                    // FocusScope.of(context)
                                    //     .requestFocus(_passwordFocusNode);
                                  },
                                  errorText: null,
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(Lang.get(
                                                    "profile_project_start")),
                                                content: SizedBox(
                                                  // Need to use container to add size constraint.
                                                  width: 300,
                                                  height: 300,
                                                  child: YearPicker(
                                                    firstDate: DateTime(
                                                        DateTime.now().year -
                                                            50,
                                                        1),
                                                    lastDate: DateTime(
                                                        DateTime.now().year +
                                                            50,
                                                        1),
                                                    // save the selected date to _selectedDate DateTime variable.
                                                    // It's used to set the previous selected date when
                                                    // re-showing the dialog.
                                                    selectedDate:
                                                        _educations[index]
                                                            .startYear,
                                                    onChanged:
                                                        (DateTime dateTime) {
                                                      setState(() {
                                                        _educations[index]
                                                                .startYear =
                                                            dateTime;
                                                      });
                                                      // close the dialog when year is selected.
                                                      Navigator.pop(context);

                                                      // Do something with the dateTime selected.
                                                      // Remember that you need to use dateTime.year to get the year
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              Lang.get('profile_project_start'),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontSize: 11),
                                            ),
                                            Text(
                                              _educations[index]
                                                  .startYear
                                                  .year
                                                  .toString(),
                                              style: const TextStyle(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(Lang.get(
                                                    "profile_project_end")),
                                                content: SizedBox(
                                                  // Need to use container to add size constraint.
                                                  width: 300,
                                                  height: 300,
                                                  child: YearPicker(
                                                    firstDate: DateTime(
                                                        DateTime.now().year -
                                                            50,
                                                        1),
                                                    lastDate: DateTime(
                                                        DateTime.now().year +
                                                            50,
                                                        1),
                                                    // save the selected date to _selectedDate DateTime variable.
                                                    // It's used to set the previous selected date when
                                                    // re-showing the dialog.
                                                    selectedDate:
                                                        _educations[index]
                                                            .endYear,
                                                    onChanged:
                                                        (DateTime dateTime) {
                                                      setState(() {
                                                        _educations[index]
                                                            .endYear = dateTime;
                                                      });
                                                      // close the dialog when year is selected.
                                                      Navigator.pop(context);

                                                      // Do something with the dateTime selected.
                                                      // Remember that you need to use dateTime.year to get the year
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              Lang.get('profile_project_end'),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontSize: 11),
                                            ),
                                            Text(
                                              _educations[index]
                                                  .endYear
                                                  .year
                                                  .toString(),
                                              style: const TextStyle(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                        width: 20,
                        margin: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          padding: const EdgeInsets.only(right: 10),
                          onPressed: () {
                            if (_educations[index].enabled) {
                              setState(() {
                                _educations[index].readOnly = true;
                              });
                              setEducation();
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
                        margin: const EdgeInsets.only(right: 20),
                        child: IconButton(
                          padding: const EdgeInsets.only(right: 10),
                          onPressed: () {
                            try {
                              if (_educations[index].readOnly == false) return;

                              if (_educations[index].enabled) {
                                setState(() {
                                  _educations[index].enabled = false;
                                });
                              } else {
                                setState(() {
                                  _educations[index].enabled = true;
                                });
                              }
                              setEducation();
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
  }

  Widget _buildSignInButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 200,
        child: RoundedButtonWidget(
          buttonText: Lang.get('next'),
          buttonColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          onPressed: () async {
            setLanguage();
            setEducation();
            _profileStudentFormStore.setFullName(widget.fullName);
            // if (_profileStudentFormStore.techStack == null ||
            //     (_profileStudentFormStore.techStack != null &&
            //         _profileStudentFormStore.techStack!.isEmpty)) {
            //   _profileStudentFormStore.setTechStack([_list[0]]);
            // }
            Navigator.of(context).push(
                MaterialPageRoute2(routeName: Routes.profileStudentStep2));
            // if (_formStore.canProfileStudent) {
            //   DeviceUtils.hideKeyboard(context);
            //   _userStore.login(
            //       _userEmailController.text, _passwordController.text);
            // } else {
            //   _showErrorMessage(AppLocalizations.of(context)
            //       .get('login_error_missing_fields'));
            // }
          },
        ),
      ),
    );
  }

  Widget navigate(BuildContext context) {
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setBool(Preferences.is_logged_in, true);
    // });

    // Future.delayed(const Duration(milliseconds: 0), () {
    //   //print("LOADING = $loading");
    //   Navigator.of(context).pushAndRemoveUntil(
    //       MaterialPageRoute2(routeName: Routes.home),
    //       (Route<dynamic> route) => false);
    // });

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: Lang.get('error'),
            duration: const Duration(seconds: 3),
          ).show(context);
        }
      });
    }

    return const SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    super.dispose();
  }
}
