import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/core/widgets/under_text_field_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/store/project_form_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:toastification/toastification.dart';

class ProjectPostScreen extends StatefulWidget {
  const ProjectPostScreen({super.key});

  @override
  State<ProjectPostScreen> createState() => _ProjectPostScreenState();
}

class _ProjectPostScreenState extends State<ProjectPostScreen> {
  //stores:---------------------------------------------------------------------
  // final ThemeStore _themeStore = getIt<ThemeStore>();
  // final LanguageStore _languageStore = getIt<LanguageStore>();
  final ProjectFormStore _projectFormStore = getIt<ProjectFormStore>();
  final UserStore _userStore = getIt<UserStore>();

  //textEdittingController
  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();

  int _startIndex = 0;
  String? groupValue;
  int length = Scope.values.length;
  Scope _projectScope = Scope.short;

  @override
  void initState() {
    super.initState();
    controller1.text = _projectFormStore.title;
    controller3.text = _projectFormStore.description;
    controller3.text = _projectFormStore.numberOfStudents.toString();
    _projectScope = Scope.values[_projectFormStore.projectScopeFlag];
  }

  String transformText(TextEditingController textController, String value) {
    var val = value.replaceAll(RegExp(r'\D'), '');
    if (val.isEmpty) val = value;
    textController.text = val;
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_startIndex) {
      case 0:
        return _buildOneContent();
      case 1:
        return _buildTwoContent();
      case 2:
        return _buildThreeContent();
      case 3:
        return _buildFourContent();
      default:
        return Container();
    }
  }

  Widget _buildOneContent() {
    return SingleChildScrollView(
      controller: ScrollController(),
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              Lang.get('1/4'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              Lang.get('description_title'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w200),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Observer(
            builder: (context) => BorderTextField(
              inputDecoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
              ),
              icon: Icons.title,
              inputType: TextInputType.name,
              textController: controller1,
              inputAction: TextInputAction.done,
              onChanged: (value) {
                _projectFormStore.setTitle(controller1.text);
              },
              hint: Lang.get('title_guide'),
              padding: const EdgeInsets.symmetric(horizontal: 1),
              errorText: _projectFormStore.formErrorStore.title,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              Lang.get('examples_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            Lang.get('example_description'),
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(
            height: 40,
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: MaterialButton(
                  color: Theme.of(context).colorScheme.primary,
                  shape: const StadiumBorder(
                      side: BorderSide(color: Colors.transparent)),
                  onPressed: () {
                    if (_projectFormStore.formErrorStore.title == null &&
                        _projectFormStore.title.isNotEmpty) {
                      setState(() {
                        _startIndex++;
                      });
                    }
                  },
                  child: AutoSizeText(
                    Lang.get('next'),
                    minFontSize: 16,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoContent() {
    return SingleChildScrollView(
        controller: ScrollController(),
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                Lang.get('2/4'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                Lang.get('scope_title'),
                style:
                    const TextStyle(fontWeight: FontWeight.w200, fontSize: 12),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(Lang.get('how_long'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            Observer(
                builder: (context) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        for (int i = 1; i <= length; i++)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: i > Scope.values.length + 1
                                ? null
                                : () {
                                    setState(() {
                                      _projectScope = Scope.values[i - 1];
                                    });
                                  },
                            title: Text(Lang.get('project_length_choice_$i'),
                                style: Theme.of(context).textTheme.bodyLarge),
                            leading: Radio<Scope>(
                              value: Scope.values[i - 1],
                              groupValue: _projectScope,
                              onChanged: i > Scope.values.length + 1
                                  ? null
                                  : (Scope? value) {
                                      setState(() => _projectScope = value!);
                                      _projectFormStore
                                          .setScope(value ?? Scope.short);
                                    },
                            ),
                          ),
                      ],
                    )),
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(Lang.get('how_many'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(
              height: 10,
            ),
            Observer(
              builder: (context) => BorderTextField(
                inputDecoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                ),
                inputType: const TextInputType.numberWithOptions(decimal: true),
                icon: Icons.people,
                textController: controller2,
                hint: Lang.get('number'),
                inputAction: TextInputAction.done,
                padding: const EdgeInsets.symmetric(horizontal: 1),
                onChanged: (value) {
                  String numberString = transformText(controller2, value);
                  if (numberString.isNotEmpty) {
                    _projectFormStore
                        .setNumberOfStudents(int.parse(numberString));
                  } else {
                    _projectFormStore.setNumberOfStudents(0);
                  }
                },
                errorText: _projectFormStore.formErrorStore.numberOfStudent,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: MaterialButton(
                    color: Theme.of(context).colorScheme.primary,
                    shape: const StadiumBorder(
                        side: BorderSide(color: Colors.transparent)),
                    onPressed: () {
                      if (_projectFormStore.formErrorStore.numberOfStudent ==
                              null &&
                          _projectFormStore.numberOfStudents > 0) {
                        setState(() {
                          _startIndex++;
                        });
                      }
                    },
                    child: Text(
                      Lang.get('next'),
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )),
            ),
          ],
        ));
  }

  Widget _buildThreeContent() {
    return SingleChildScrollView(
        controller: ScrollController(),
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Text(Lang.get('3/4'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor)),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                Lang.get('looking'),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(Lang.get('looking_description'),
                  style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(Lang.get('project_describe'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              height: 10,
            ),
            Observer(
              builder: (context) => BorderTextField(
                minLines: 4,
                maxLines: 8,
                inputDecoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                ),
                inputType: TextInputType.text,
                textController: controller3,
                isIcon: false,
                onChanged: (value) {
                  _projectFormStore.setDescription(controller3.text);
                },
                errorText: _projectFormStore.formErrorStore.description,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
                alignment: Alignment.topRight,
                child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: MaterialButton(
                      color: Theme.of(context).colorScheme.primary,
                      shape: const StadiumBorder(
                          side: BorderSide(color: Colors.transparent)),
                      onPressed: () {
                        if (_projectFormStore.formErrorStore.description ==
                                null &&
                            _projectFormStore.description.isNotEmpty) {
                          setState(() {
                            _startIndex++;
                          });
                        }
                      },
                      child: AutoSizeText(
                        Lang.get('review'),
                        minFontSize: 14,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ))),
          ],
        ));
  }

  Widget _buildFourContent() {
    return SingleChildScrollView(
        controller: ScrollController(),
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    Lang.get('4/4'),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit project Info',
                  onPressed: () {
                    
                    setState(() {
                      _startIndex = 0;
                    });
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 35,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Project Name: ${_projectFormStore.title}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(color: Colors.black),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  controller: ScrollController(),
                  child: AutoSizeText(_projectFormStore.description),
                ),
              ),
            ),
            const Divider(color: Colors.black),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.alarm,
                  size: 30,
                ),
                const SizedBox(
                    width:
                        10), // You can adjust the space between the icon and the text
                Text(
                    '${Lang.get('project_scope')}\n  - ${Scope.values[_projectFormStore.projectScopeFlag].title}'),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.people,
                  size: 30,
                ),
                const SizedBox(
                    width:
                        10), // You can adjust the space between the icon and the text
                Text(
                    '${Lang.get('student_require')}\n  - ${_projectFormStore.numberOfStudents} students'),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: MaterialButton(
                    color: Theme.of(context).colorScheme.primary,
                    shape: const StadiumBorder(
                        side: BorderSide(color: Colors.transparent)),
                    onPressed: () {
                      if (_projectFormStore.canPost) {
                        _projectFormStore
                            .createProject(
                                _userStore.user!.companyProfile!.objectId ?? "",
                                controller1.text,
                                controller3.text,
                                int.parse(controller2.text),
                                _projectScope.index,
                                true)
                            .then((value) {
                          if (_projectFormStore.success) {
                            Toastify.show(
                                context,
                                "Update",
                                _projectFormStore.notification,
                                ToastificationType.info, () {
                              _projectFormStore.reset();
                            });
                            _projectFormStore.reset();
                            Future.delayed(const Duration(seconds: 1), () {
                              Navigator.of(context).pop<Project>(Project(
                                title: _projectFormStore.title,
                                description: _projectFormStore.description,
                                scope: _projectScope,
                                numberOfStudents:
                                    _projectFormStore.numberOfStudents,
                                timeCreated: DateTime.now(),
                              ));
                            });
                          } else {
                            Toastify.show(
                                context,
                                "Update failed",
                                _projectFormStore.errorStore.errorMessage,
                                ToastificationType.error, () {
                              _projectFormStore.reset();
                            });
                          }
                        });
                      }
                    },
                    child: Text(
                      Lang.get('post_job'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  )),
            ),
          ],
        ));
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return const MainAppBar();
  }
}
