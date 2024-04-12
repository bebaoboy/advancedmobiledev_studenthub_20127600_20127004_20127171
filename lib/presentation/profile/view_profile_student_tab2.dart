import 'dart:async';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/core/widgets/chip_input_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/presentation/profile/store/form/profile_info_store.dart';
import 'package:boilerplate/presentation/profile/store/form/profile_student_form_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

import '../../di/service_locator.dart';

class ViewProfileStudentTab2 extends StatefulWidget {
  const ViewProfileStudentTab2({super.key});

  @override
  _ViewProfileStudentTab2State createState() => _ViewProfileStudentTab2State();
}

class _ViewProfileStudentTab2State extends State<ViewProfileStudentTab2> {
  //text controllers:-----------------------------------------------------------
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //stores:---------------------------------------------------------------------
  // final ThemeStore _themeStore = getIt<ThemeStore>();
  final FormStore _formStore = getIt<FormStore>();
  final UserStore _userStore = getIt<UserStore>();
  final ProfileStudentFormStore _profileStudentFormStore =
      getIt<ProfileStudentFormStore>();
  final ProfileStudentStore _infoStore = getIt<ProfileStudentStore>();

  //focus node:-----------------------------------------------------------------
  late FocusNode _passwordFocusNode;

  bool loading = false;
  final List<ProjectExperience> _projects = List.empty(growable: true);

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
  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    _projects.addAll(_infoStore.currentProjectExperience);
    if (_infoStore.skillSet.isNotEmpty) mockSkillsets = _infoStore.skillSet;

    setPE();
    // _projects.add(ProjectExperience("Intelligent Taxi Dispatching System",
    //     description:
    //         "It is the developer of a super-app for ride-hailing, food delivery, and digital payment services on mobile devices, operated in Singapore, Malaysia,...",
    //     startDate: DateTime(2020, 9),
    //     endDate: DateTime(2020, 12),
    //     skills: [
    //       Skill("React", "", "", id: "10"),
    //       Skill("Android", "", "", id: "2")
    //     ]));
    // _projects.add(ProjectExperience("Community partners project",
    //     description:
    //         "This is a web usability class. Student teams apply their newly acquired web usability analysis skills to a community organization with a website in need of [more content to come]. In this semester long project, student teams choose from several instructor-selected community organization projects and do usability testing on their website and make recommendations to the organization in a final presentation to the entire class. This project is worth [More content to come] of their final grade. (Lee-Ann Breuch, CLA, UMTC)",
    //     startDate: DateTime(2019, 12),
    //     endDate: DateTime(2024, 2),
    //     skills: [
    //       Skill("iOS", "", "", id: "5"),
    //       Skill("Web", "", "", id: "4"),
    //       Skill("Artificial Intelligent", "", "", id: "3")
    //     ]));
    // _projects.add(ProjectExperience("bebaoboy Project Bunny",
    //     description:
    //         "food delivery, and digital payment services on mobile devices, operated in Singapore, Malaysia,...",
    //     startDate: DateTime(2021, 9),
    //     endDate: DateTime(2021, 12)));
    // _projects.add(ProjectExperience("Coca Cola Advertisement",
    //     description:
    //         "Klls to a community organization with a website in need of [more content to come]. In this semester long project, student teams choose from several instructor-selected community organization projects and do usability testing on their website and make recommendations to the organization in a final presentation to the entire class. This project is worth [More content to come] of their final grade. (Lee-Ann Breuch, CLA, UMTC)",
    //     startDate: DateTime(2023, 1),
    //     endDate: DateTime(2024, 2)));
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
                    // Expanded(
                    //   flex: 1,
                    //   child: _buildLeftSide(),
                    // ),
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
    setPE();
  }

  // void onChanged(List<Skill> data, {int? index}) {
  //   //print('onChanged $data');
  //   if (index != null) {
  //     try {
  //       setState(() {
  //         _projects[index!].skills =
  //             data.map((e) => e.name).toList(growable: true);
  //         //print("data: " + data.toString());
  //       });
  //     } catch (e) {}
  //   }
  // }

  // void _onChanged(List<Skill> data) {
  //   //print('onChanged $data');
  // }

  Future<List<Skill>> _findSuggestions(String query) async {
    if (query.isNotEmpty) {
      return mockSkillsets.where((profile) {
        return profile.name.toLowerCase().contains(query.toLowerCase()) ||
            profile.description.toLowerCase().contains(query.toLowerCase());
      }).toList(growable: true);
    } else {
      return mockSkillsets;
    }
  }

  Widget _buildRightSide() {
    return SingleChildScrollView(
      controller: ScrollController(),
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              child: Column(
                children: [
                  AutoSizeText(
                    Lang.get('profile_experiences'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                    minFontSize: 10,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AutoSizeText(
                    Lang.get('profile_welcome_text3'),
                    style: const TextStyle(fontSize: 13),
                    minFontSize: 10,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Image.asset(
                  //   'assets/images/img_login.png',
                  //   scale: 1.2,
                  // ),
                  // _buildUserIdField(),
                  // _buildPasswordField(),
                  // _buildForgotPasswordButton(),
                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(
                    height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                            "${Lang.get('profile_projects')}: ${_projects.length}",
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                            minFontSize: 10,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => {
                            setState(() {
                              _projects.insert(
                                  0,
                                  ProjectExperience("Untitled Project",
                                      description: "No description",
                                      readOnly: false,
                                      startDate: DateTime.now(),
                                      endDate: DateTime.now(),
                                      skills: []));
                              setPE();
                            })
                          },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
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

                  const SizedBox(height: 34.0),
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

  setPE() {
    _profileStudentFormStore.setProjectExperience(_projects
        .where(
          (e) => e.enabled,
        )
        .toList());
  }

  Widget _buildLanguageField() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: ListView.builder(
        controller: ScrollController(),
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: _projects.length,
        itemBuilder: (BuildContext context, int index) {
          double w = MediaQuery.of(context).orientation == Orientation.landscape
              ? MediaQuery.of(context).size.width * 0.93
              : MediaQuery.of(context).size.width * 0.84;
          return Container(
            decoration: BoxDecoration(
              border: Border.all(width: 0.1),
              borderRadius: const BorderRadius.all(Radius.circular(13)),
              color: _projects[index].enabled ? null : Colors.grey,
            ),
            child: Row(
              key: ValueKey(_projects[index]),
              children: [
                Stack(
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                            margin: const EdgeInsets.only(left: 0),
                            child: IconButton(
                              padding: const EdgeInsets.only(left: 5),
                              onPressed: () {
                                try {
                                  if (!_projects[index].readOnly) {
                                    if (_projects[index].enabled) {
                                      setState(() {
                                        _projects[index].readOnly = true;
                                      });
                                    }
                                  } else if (_projects[index].enabled) {
                                    setState(() {
                                      _projects[index].enabled = false;
                                    });
                                  } else {
                                    setState(() {
                                      _projects[index].enabled = true;
                                    });
                                  }
                                  setPE();
                                } catch (E) {
                                  setState(() {});
                                }
                              },
                              icon: _projects[index].enabled
                                  ? Icon(_projects[index].readOnly == false
                                      ? Icons.done
                                      : Icons.remove_circle_outline)
                                  : Icon(_projects[index].readOnly == false
                                      ? null
                                      : Icons.restore_rounded),
                            )),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Wrap(
                        direction: Axis.vertical,
                        spacing: 1,
                        children: [
                          SizedBox(
                            width: w,
                            child: GestureDetector(
                              onDoubleTap: () {
                                if (_projects[index].readOnly &&
                                    _projects[index].enabled) {
                                  setState(() {
                                    _projects[index].readOnly = false;
                                  });
                                }
                              },
                              child: TextFieldWidget(
                                onTap: () {
                                  if (_projects[index].readOnly) openHintBar();
                                },
                                inputDecoration: InputDecoration(
                                    border: _projects[index].readOnly
                                        ? InputBorder.none
                                        : null),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                                isIcon: false,
                                label: _projects[index].readOnly
                                    ? null
                                    : Text(
                                        Lang.get('profile_project'),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                enabled: _projects[index].enabled,
                                enableInteractiveSelection:
                                    !_projects[index].readOnly,
                                canRequestFocus: !_projects[index].readOnly,
                                iconMargin: const EdgeInsets.only(top: 30),
                                initialValue: _projects[index].name,
                                readOnly: _projects[index].readOnly,
                                hint: Lang.get('profile_choose_skillset'),
                                icon: null,
                                textController: null,
                                inputAction: TextInputAction.next,
                                autoFocus: false,
                                onChanged: (value) {
                                  _projects[index].name = value;

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
                            width: w,
                            height: _projects[index].readOnly ? 12 : null,
                            child: _projects[index].readOnly
                                ? GestureDetector(
                                    onDoubleTap: () {
                                      if (_projects[index].readOnly &&
                                          _projects[index].enabled) {
                                        setState(() {
                                          _projects[index].readOnly = false;
                                        });
                                      }
                                    },
                                    child: SizedBox(
                                      width: w / 2,
                                      child: TextFieldWidget(
                                          onTap: () {
                                            if (_projects[index].readOnly) {
                                              openHintBar();
                                            }
                                          },
                                          inputDecoration: InputDecoration(
                                              border: _projects[index].readOnly
                                                  ? InputBorder.none
                                                  : null),
                                          isIcon: false,
                                          label: _projects[index].readOnly
                                              ? null
                                              : Text(
                                                  Lang.get(
                                                      'profile_project_start'),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                                ),
                                          enabled: _projects[index].enabled,
                                          enableInteractiveSelection:
                                              !_projects[index].readOnly,
                                          canRequestFocus:
                                              !_projects[index].readOnly,
                                          readOnly: true,
                                          initialValue:
                                              "${DateFormat("yyyy/MM").format(_projects[index].startDate)} - ${DateFormat("yyyy/MM").format(_projects[index].endDate)} (${_projects[index].startDate.compareTo(_projects[index].endDate) < 0 ? (_projects[index].endDate.difference(_projects[index].startDate).inDays / 30.0).round() : 0} months)",
                                          fontSize: _projects[index].readOnly
                                              ? 10
                                              : 15,
                                          hint: Lang.get(
                                              'profile_choose_skillset'),
                                          icon: null,
                                          textController: null,
                                          inputAction: TextInputAction.next,
                                          autoFocus: false,
                                          onChanged: (value) {
                                            //_projects[index].proficiency = value;

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
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            if (!_projects[index].readOnly) {
                                              DateTime? pickedDate =
                                                  await showDatePicker(
                                                      initialDatePickerMode:
                                                          DatePickerMode.year,
                                                      context: context,
                                                      initialDate:
                                                          _projects[index]
                                                              .startDate,
                                                      firstDate: DateTime(1950),
                                                      //DateTime.now() - not to allow to choose before today.
                                                      lastDate: DateTime(2100));

                                              if (pickedDate != null) {
                                                //print(
                                                // pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                                // String formattedDate =
                                                //     DateFormat('yyyy-MM-dd')
                                                //         .format(pickedDate);
                                                // //print(
                                                //     formattedDate); //formatted date output using intl package =>  2021-03-16
                                                setState(() {
                                                  _projects[index].startDate =
                                                      pickedDate; //set output date to TextField value.
                                                });
                                              } else {}
                                            }
                                          },
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                Lang.get(
                                                    'profile_project_start'),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    fontSize: 11),
                                              ),
                                              Text(
                                                DateFormat("yyyy/MM").format(
                                                    _projects[index].startDate),
                                                style: const TextStyle(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            if (!_projects[index].readOnly) {
                                              DateTime? pickedDate =
                                                  await showDatePicker(
                                                      initialDatePickerMode:
                                                          DatePickerMode.year,
                                                      context: context,
                                                      initialDate:
                                                          _projects[index]
                                                              .endDate,
                                                      firstDate: DateTime(1950),
                                                      //DateTime.now() - not to allow to choose before today.
                                                      lastDate: DateTime(2100));

                                              if (pickedDate != null) {
                                                //print(
                                                // pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                                // String formattedDate =
                                                //     DateFormat('yyyy-MM-dd')
                                                //         .format(pickedDate);
                                                // //print(
                                                //     formattedDate); //formatted date output using intl package =>  2021-03-16
                                                setState(() {
                                                  _projects[index].endDate =
                                                      pickedDate; //set output date to TextField value.
                                                });
                                              } else {}
                                            }
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
                                                DateFormat("yyyy/MM").format(
                                                    _projects[index].endDate),
                                                style: const TextStyle(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          if (_projects[index].readOnly)
                            if (_projects[index].link.isNotEmpty)
                              SizedBox(
                                width: w,
                                height: _projects[index].readOnly ? 20 : null,
                                child: GestureDetector(
                                    // onTap: () {
                                    //   if (_projects[index].readOnly) {
                                    //     openHintBar();
                                    //   }
                                    // },
                                    onDoubleTap: () {
                                      if (_projects[index].readOnly &&
                                          _projects[index].enabled) {
                                        setState(() {
                                          _projects[index].readOnly = false;
                                        });
                                      }
                                    },
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                        text: _projects[index].link,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      )
                                    ]))),
                              ),
                          if (!_projects[index].readOnly)
                            SizedBox(
                              width: w,
                              height: _projects[index].readOnly ? 20 : null,
                              child: TextFieldWidget(
                                inputDecoration: InputDecoration(
                                    border: _projects[index].readOnly
                                        ? InputBorder.none
                                        : null),
                                isIcon: false,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                label: _projects[index].readOnly
                                    ? null
                                    : Text(
                                        Lang.get('profile_project_link'),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                enabled: _projects[index].enabled,
                                enableInteractiveSelection:
                                    !_projects[index].readOnly,
                                canRequestFocus: !_projects[index].readOnly,
                                iconMargin: const EdgeInsets.only(top: 30),
                                initialValue: _projects[index].link.isEmpty
                                    ? ""
                                    : _projects[index].link,
                                readOnly: _projects[index].readOnly,
                                hint: Lang.get("profile_enter_link"),
                                hintStyle: TextStyle(
                                    fontSize:
                                        _projects[index].readOnly ? 10 : 15),
                                inputType: TextInputType.url,
                                icon: null,
                                fontSize: _projects[index].readOnly ? 10 : 15,
                                textController: null,
                                inputAction: TextInputAction.next,
                                autoFocus: false,
                                onChanged: (value) {
                                  _projects[index].link = value;

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
                          SizedBox(
                            // transform: _projects[index].readOnly
                            //     ? Matrix4.translationValues(0.0, -25.0, 0.0)
                            //     : null,
                            width: w,
                            child: GestureDetector(
                              onTap: () {
                                if (_projects[index].readOnly) openHintBar();
                              },
                              onDoubleTap: () {
                                if (_projects[index].readOnly &&
                                    _projects[index].enabled) {
                                  setState(() {
                                    _projects[index].readOnly = false;
                                  });
                                }
                              },
                              child: _projects[index].readOnly
                                  ? LimitedBox(
                                      maxHeight: 90,
                                      child: SingleChildScrollView(
                                        controller: ScrollController(),
                                        child: Text(
                                          _projects[index].description,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    )
                                  : TextFieldWidget(
                                      onTap: () {
                                        if (_projects[index].readOnly) {
                                          openHintBar();
                                        }
                                      },
                                      textAlignVertical:
                                          const TextAlignVertical(y: -1),
                                      inputDecoration: InputDecoration(
                                          border: _projects[index].readOnly
                                              ? InputBorder.none
                                              : null),
                                      isIcon: false,
                                      textAlign: TextAlign.justify,
                                      label: _projects[index].readOnly
                                          ? null
                                          : Text(
                                              Lang.get(
                                                  'profile_project_description'),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                            ),
                                      fontSize:
                                          _projects[index].readOnly ? 10 : 13,
                                      enabled: _projects[index].enabled,
                                      enableInteractiveSelection:
                                          !_projects[index].readOnly,
                                      canRequestFocus:
                                          !_projects[index].readOnly,
                                      iconMargin:
                                          const EdgeInsets.only(top: 30),
                                      initialValue:
                                          _projects[index].description,
                                      readOnly: _projects[index].readOnly,
                                      inputType: TextInputType.multiline,
                                      icon: null,
                                      maxLines:
                                          _projects[index].readOnly ? 5 : 8,
                                      minLines: 2,
                                      textController: null,
                                      inputAction: TextInputAction.next,
                                      autoFocus: false,
                                      onChanged: (value) {
                                        _projects[index].description = value;

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
                              if (_projects[index].readOnly &&
                                  _projects[index].enabled) {
                                setState(() {
                                  _projects[index].readOnly = false;
                                });
                              }
                            },
                            child: SizedBox(
                              height: 30,
                              width: w,
                              // transform: _projects[index].readOnly
                              //     ? Matrix4.translationValues(0.0, -30.0, 0.0)
                              //     : null,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: AutoSizeText(
                                      Lang.get('profile_skillset'),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600),
                                      minFontSize: 9,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (!_projects[index].readOnly)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                          padding: EdgeInsets.zero,
                                          child: IconButton(
                                            onPressed: () {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              setPE();
                                            },
                                            icon: const Icon(
                                                Icons.check_circle_outline),
                                          )),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: !_projects[index].readOnly
                                ? const EdgeInsets.only(bottom: 60)
                                : const EdgeInsets.only(bottom: 10),
                            child: _projects[index].readOnly
                                ? SizedBox(
                                    width: w * 0.8,
                                    // transform: _projects[index].readOnly
                                    //     ? Matrix4.translationValues(
                                    //         0.0, -50.0, 0.0)
                                    //     : null,
                                    child: Text(
                                      _projects[index].skills == null
                                          ? Lang.get("nothing_here")
                                          : _projects[index].skills!.isNotEmpty
                                              ? _projects[index]
                                                  .skills!
                                                  .join(", ")
                                              : "...",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    width: MediaQuery.of(context).orientation ==
                                            Orientation.landscape
                                        ? MediaQuery.of(context).size.width *
                                            0.93
                                        : MediaQuery.of(context).size.width *
                                            0.84,
                                    child: ChipsInput<Skill>(
                                      maxInputHeight: 35,
                                      totalHeight: 150,
                                      nonEmptyInputHeight: 100,
                                      initialChips:
                                          _projects[index].skills != null
                                              ? _projects[index].skills!
                                              : [],
                                      onChipTapped: _onChipTapped,
                                      decoration: InputDecoration(
                                          prefixIconConstraints:
                                              const BoxConstraints(),
                                          // prefixIcon: Container(
                                          //     margin: EdgeInsets.only(top: 13),
                                          //     child: Icon(
                                          //       Icons.search,
                                          //     )),
                                          hintText: Lang.get(
                                              'profile_choose_skillset'),
                                          hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          )),
                                      findSuggestions: _findSuggestions,
                                      onChanged: (value) {
                                        _projects[index].skills = value;
                                        setPE();
                                      },
                                      chipBuilder: (BuildContext context,
                                          ChipsInputState<Skill> state,
                                          Skill profile) {
                                        return InputChip(
                                          elevation: 8,
                                          pressElevation: 9,
                                          key: ObjectKey(profile),
                                          label: Text(profile.name),
                                          labelStyle:
                                              const TextStyle(fontSize: 10),
                                          visualDensity: VisualDensity.compact,
                                          avatar: CircleAvatar(
                                            backgroundImage: profile
                                                    .imageUrl.isNotEmpty
                                                ? NetworkImage(profile.imageUrl)
                                                : null,
                                          ),
                                          onDeleted: () {
                                            state.deleteChip(profile);
                                            setPE();
                                          },
                                          onSelected: (_) =>
                                              _onChipTapped(profile),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        );
                                      },
                                      suggestionBuilder: (BuildContext context,
                                          ChipsInputState<Skill> state,
                                          Skill profile) {
                                        return ListTile(
                                          key: ObjectKey(profile),
                                          // leading: CircleAvatar(
                                          //   backgroundImage: NetworkImage(profile.imageUrl),
                                          // ),
                                          leading:
                                              const Icon(Icons.developer_mode),
                                          title: Text(profile.name),
                                          subtitle: Text(profile.description),
                                          onTap: () =>
                                              state.selectSuggestion(profile),
                                        );
                                      },
                                    ),
                                  ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget navigate(BuildContext context) {
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
    _userEmailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
