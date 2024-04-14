import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/routes/page_transformer.dart';
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
  List<String> dioList = [];

  Future<List<Widget>> getAllPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dioList = prefs.getStringList("dio") ?? [];
    return prefs
        .getKeys()
        .map<Widget>((key) => ListTile(
              title: Text(
                key,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              subtitle: LimitedBox(
                maxHeight: 200,
                child: SingleChildScrollView(
                  child: Text(prefs.get(key).toString()),
                ),
              ),
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
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
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
          alignment: Alignment.topLeft,
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Result: ${_projectStore.projects.length}"),
              ),
              ListTile(
                  title: const Text(
                    "All projects",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: LimitedBox(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Text(_projectStore.projects.isNotEmpty
                              ? _projectStore.projects
                                  .map(
                                    (e) => e.toString(),
                                  )
                                  .join("\n")
                              : "No projects"),
                        ),
                      ))),
            ],
          )),
    );
  }

  Widget getProject() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Result: ${_projectStore.projects.length}"),
              ),
              ListTile(
                title: const Text(
                  "Company projects",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                subtitle: LimitedBox(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                    child: Scrollbar(
                      child: SingleChildScrollView(
                          child: Text(_projectStore.companyProjects.isNotEmpty
                              ? _projectStore.companyProjects
                                      .map(
                                        (e) => e.toString(),
                                      )
                                      .join("\n")
                              : "No company projects")),
                    )),
              ),
            ],
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
                  ]);
                  var list = [
                    Scrollbar(
                      child: ListView(
                        children: data,
                      ),
                    ),
                    getAllProject(),
                    getProject(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 10),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: dioList.isEmpty
                            ? const Text(
                                "Dio list empty",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              )
                            : TransformerPageView(
                                itemCount: dioList.length,
                                itemBuilder: (context, index) => Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: ListTile(
                                    title: const Text(
                                      "Dio list",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: LimitedBox(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        child: Scrollbar(
                                          child: SingleChildScrollView(
                                              child: Text(
                                            dioList[index],
                                            style: const TextStyle(fontSize: 8),
                                          )),
                                        )),
                                  ),
                                ),
                              ),
                      ),
                    )
                  ];
                  return TransformerPageView(
                    viewportFraction: 0.8,
                    transformer: DepthPageTransformer(),
                    itemCount: list.length,
                    itemBuilder: (context, index) => Material(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      elevation: 12,
                      borderRadius: BorderRadius.circular(20),
                      child: list[index],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
