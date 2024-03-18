import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class ProjectPostScreen extends StatefulWidget {
  const ProjectPostScreen({super.key});

  @override
  State<ProjectPostScreen> createState() => _ProjectPostScreenState();
}

class _ProjectPostScreenState extends State<ProjectPostScreen> {
  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();
  int _startIndex = 0;
  String title = "";
  String duration = "";
  String number = "";
  String description = "";
  String? groupValue;
  Scope scope = Scope.short;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: _startIndex == 0
            ? _buildOneContent()
            : _startIndex == 1
                ? _buildTwoContent()
                : _startIndex == 2
                    ? _buildThreeContent()
                    : _buildFourContent(),
      ),
    );
  }

  Widget _buildOneContent() {
    final controller1 = TextEditingController();
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: AutoSizeText(AppLocalizations.of(context).translate('1/4'),
                maxLines: 2,
                minFontSize: 12,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
                AppLocalizations.of(context).translate('description_title')),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: controller1,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: AppLocalizations.of(context).translate('title_guide'),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.topLeft,
            child:
                Text(AppLocalizations.of(context).translate('examples_title')),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
                AppLocalizations.of(context).translate('example_description')),
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: SizedBox(
                    width: 150,
                    height: 50,
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          title = controller1.text;
                          _startIndex++;
                        });
                      },
                      child: AutoSizeText(
                        AppLocalizations.of(context).translate('scope'),
                        minFontSize: 14,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ))),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoContent() {
    final controller2 = TextEditingController();

    return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: AutoSizeText(AppLocalizations.of(context).translate('2/4'),
                  maxLines: 2,
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.topLeft,
              child:
                  Text(AppLocalizations.of(context).translate('scope_title')),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(AppLocalizations.of(context).translate('how_long'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            RadioListTile<String>(
              title: Text(AppLocalizations.of(context).translate('1-3')),
              value: Scope.tight.title,
              groupValue: groupValue,
              onChanged: (String? value) {
                setState(() {
                  groupValue = value;
                  scope = Scope.tight;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(AppLocalizations.of(context).translate('1-3')),
              value: Scope.short.title,
              groupValue: groupValue,
              onChanged: (String? value) {
                setState(() {
                  groupValue = value;
                  scope = Scope.tight;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(AppLocalizations.of(context).translate('1-3')),
              value: Scope.short.title,
              groupValue: groupValue,
              onChanged: (String? value) {
                setState(() {
                  groupValue = value;
                  scope = Scope.short;
                  scope = Scope.short;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(AppLocalizations.of(context).translate('3-6')),
              value: Scope.long.title,
              groupValue: groupValue,
              activeColor: Colors.red,
              onChanged: (String? value) {
                setState(() {
                  groupValue = value;
                  scope = Scope.long;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(AppLocalizations.of(context).translate('1-3')),
              value: Scope.extended.title,
              groupValue: groupValue,
              onChanged: (String? value) {
                setState(() {
                  groupValue = value;
                  scope = Scope.extended;
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(AppLocalizations.of(context).translate('how_many'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: controller2,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context).translate('number'),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: SizedBox(
                      width: 150,
                      height: 50,
                      child: FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            number = controller2.text;
                            duration = groupValue ?? 'Not estimated yet';
                            _startIndex++;
                          });
                        },
                        child: AutoSizeText(
                          AppLocalizations.of(context)
                              .translate('Next_Description'),
                          minFontSize: 12,
                          maxLines: 3,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ))),
            ),
          ],
        ));
  }

  Widget _buildThreeContent() {
    final controller3 = TextEditingController();

    return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: AutoSizeText(AppLocalizations.of(context).translate('3/4'),
                  maxLines: 2,
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(AppLocalizations.of(context).translate('looking')),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(AppLocalizations.of(context)
                  .translate('looking_description')),
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                  AppLocalizations.of(context).translate('project_describe'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              maxLines: 5,
              controller: controller3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: SizedBox(
                      width: 150,
                      height: 50,
                      child: FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            description = controller3.text;
                            _startIndex++;
                          });
                        },
                        child: AutoSizeText(
                          AppLocalizations.of(context).translate('review'),
                          minFontSize: 14,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ))),
            ),
          ],
        ));
  }

  Widget _buildFourContent() {
    return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: AutoSizeText(AppLocalizations.of(context).translate('4/4'),
                  maxLines: 2,
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(title.isEmpty ? "Demo Project" : title),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(color: Colors.black),
            Align(
              alignment: Alignment.topLeft,
              child: Text(description.isEmpty
                  ? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
                      'eiusmod tempor incididunt ut labore et dolore magna aliqua.'
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
                      'eiusmod tempor incididunt ut labore et dolore magna aliqua.'
                  : description),
            ),
            const Divider(color: Colors.black),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                const Icon(Icons.alarm),
                const SizedBox(
                    width:
                        10), // You can adjust the space between the icon and the text
                Text(
                    '${AppLocalizations.of(context).translate('project_scope')}\n  - $duration'),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                const Icon(Icons.people),
                const SizedBox(
                    width:
                        10), // You can adjust the space between the icon and the text
                Text(
                    '${AppLocalizations.of(context).translate('student_require')}\n  - $number'),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: SizedBox(
                      width: 150,
                      height: 50,
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context)
                            ..pop<Project>(Project(
                              title: title,
                              description: description,
                              scope: scope,
                              numberOfStudents: int.tryParse(number) ?? 2,
                              timeCreated: DateTime.now(),
                            ));
                          Navigator.of(context)
                            ..pop<Project>(Project(
                              title: title,
                              description: description,
                              scope: scope,
                              numberOfStudents: int.tryParse(number) ?? 2,
                              timeCreated: DateTime.now(),
                            ));
                        },
                        child: Text(
                          AppLocalizations.of(context).translate('post_job'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ))),
            ),
          ],
        ));
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return const MainAppBar();
  }
}
