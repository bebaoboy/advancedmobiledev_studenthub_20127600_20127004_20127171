import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_string_pretty/to_string_pretty.dart';

class SharedPreferenceView extends StatefulWidget {
  const SharedPreferenceView({super.key});

  @override
  State<SharedPreferenceView> createState() => _SharedPreferenceViewState();
}

class _SharedPreferenceViewState extends State<SharedPreferenceView> {
  final UserStore _userStore = getIt<UserStore>();
  final ProjectStore _projectStore = getIt<ProjectStore>();

  Future<List<Widget>> getAllPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs
        .getKeys()
        .map<Widget>((key) => ListTile(
              title: Text(
                key,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18,),
              ),
              subtitle: Text(prefs.get(key).toString()),
            ))
        .toList(growable: false);
  }

  Widget getUser() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
          child: ListTile(
        title: const Text(
          "User",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18,),
        ),
        subtitle: Text(_userStore.user != null
            ? toStringPretty(_userStore.user!.toMap())
            : "No user"),
      )),
    );
  }

  Widget getAllProject() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
          child: ListTile(
        title: const Text(
          "All projects",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18,),
        ),
        subtitle: Text(_projectStore.projects.isNotEmpty
            ? toStringPretty(_projectStore.projects)
            : "No projects"),
      )),
    );
  }

  Widget getProject() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
          child: ListTile(
        title: const Text(
          "Company projects",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18,),
        ),
        subtitle: Text(_projectStore.companyProjects.isNotEmpty
            ? toStringPretty(_projectStore.companyProjects)
            : "No company projects"),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EmptyAppBar(),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Widget>>(
                future: getAllPrefs(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Container();
                  }
                  var data = List<Widget>.from([
                    getUser(),
                    ...snapshot.data!,
                    getAllProject(),
                    getProject()
                  ]);
                  return ListView(
                    controller: ScrollController(),
                    children: data,
                  );
                }),
          ),
        ],
      ),
    );
  }
}
