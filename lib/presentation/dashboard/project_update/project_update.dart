import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/core/widgets/under_text_field_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/store/update_project_form_store.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:toastification/toastification.dart';

class ProjectUpdateScreen extends StatefulWidget {
  final Project project;
  const ProjectUpdateScreen({super.key, required this.project});

  @override
  State<ProjectUpdateScreen> createState() => _ProjectUpdateScreenState();
}

class _ProjectUpdateScreenState extends State<ProjectUpdateScreen> {
  //stores:---------------------------------------------------------------------
  final UpdateProjectFormStore _formStore = getIt<UpdateProjectFormStore>();
  final ThemeStore _themeStore = getIt<ThemeStore>();

  // controller
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _numberController = TextEditingController();

  late Scope _projectScope;

  @override
  void initState() {
    super.initState();
    _projectScope = widget.project.scope;
    _titleController.text = widget.project.title;
    _descriptionController.text = widget.project.description;
    _numberController.text = widget.project.numberOfStudents.toString();
    _formStore.setValue(widget.project);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
        child: _buildBody(context),
      ),
    );
  }

  String transformText(TextEditingController textController, String value) {
    var val = value.replaceAll(RegExp(r'\D'), '');
    if (val.isEmpty) val = value;
    textController.text = val;
    return val;
  }

  bool somethingChanged() {
    return widget.project.title != _formStore.title ||
        widget.project.numberOfStudents != _formStore.numberOfStudents ||
        widget.project.scope != _formStore.scope ||
        widget.project.description != _formStore.description;
  }

  bool firstEnter = false;

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
              alignment: Alignment.topLeft,
              child: Text(Lang.get("project_title"))),
          Observer(
            builder: (context) => BorderTextField(
              inputDecoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
              ),
              inputType: TextInputType.name,
              iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
              textController: _titleController,
              inputAction: TextInputAction.done,
              onChanged: (value) {
                _formStore.setTitle(_titleController.text);
              },
              isIcon: false,
              padding: const EdgeInsets.symmetric(horizontal: 1),
              errorText: _formStore.formErrorStore.title,
            ),
          ),
          const SizedBox(height: 10),
          Container(
              alignment: Alignment.topLeft,
              child: Text(Lang.get("project_length"))),
          _buildCompanySizeSelection(context),
          const SizedBox(height: 10),
          Container(
              alignment: Alignment.topLeft,
              child: Text(Lang.get("project_students"))),
          Observer(
            builder: (context) => BorderTextField(
              inputDecoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
              ),
              inputType: const TextInputType.numberWithOptions(decimal: true),
              icon: Icons.people,
              iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
              textController: _numberController,
              inputAction: TextInputAction.done,
              padding: const EdgeInsets.symmetric(horizontal: 1),
              onChanged: (value) {
                String numberString = transformText(_numberController, value);
                if (numberString.isNotEmpty) {
                  _formStore.setNumberOfStudents(int.parse(numberString));
                } else {
                  _formStore.setNumberOfStudents(0);
                }
              },
              errorText: _formStore.formErrorStore.numberOfStudent,
            ),
          ),
          const SizedBox(height: 10),
          Container(
              alignment: Alignment.topLeft,
              child: Text(Lang.get("project_description"))),
          Observer(
            builder: (context) => BorderTextField(
              minLines: 4,
              maxLines: 8,
              inputDecoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
              ),
              inputType: TextInputType.text,
              iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
              textController: _descriptionController,
              inputAction: TextInputAction.done,
              isIcon: false,
              onChanged: (value) {
                _formStore.setDescription(_descriptionController.text);
              },
              errorText: _formStore.formErrorStore.description,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            alignment: Alignment.bottomRight,
            child: MaterialButton(
              onPressed: () {
                try {
                  if (_formStore.canUpdate && somethingChanged()) {
                    _formStore.updateProject(
                        int.parse(widget.project.objectId!),
                        _titleController.text,
                        _descriptionController.text,
                        int.parse(_numberController.text),
                        _projectScope);
                  } else {
                    _formStore.updateResult = false;
                    _formStore.errorStore.errorMessage = "Wrong";
                  }
                } catch (e) {
                  _formStore.updateResult = false;
                  _formStore.errorStore.errorMessage = "Wrong";
                }
                firstEnter = true;
              },
              textColor: Colors.white,
              color: Theme.of(context).colorScheme.primary,
              child: Text(Lang.get("project_update")),
            ),
          ),
          Observer(builder: (ctx) {
            // TODO: nó hem hiện
            if (_formStore.updateResult) {
              Future.delayed(const Duration(seconds: 100), () {
                Toastify.show(context, "Update", _formStore.notification,
                    ToastificationType.info, () => _formStore.reset());
              });
              _formStore.reset();
              return Container();
            } else if (firstEnter) {
              Future.delayed(const Duration(seconds: 100), () {
                Toastify.show(
                    context,
                    "Update failed",
                    _formStore.errorStore.errorMessage,
                    ToastificationType.error,
                    () => _formStore.reset());
              });
              return Container();
            }
            return Container();
          })
        ],
      ),
    );
  }

  Widget _buildCompanySizeSelection(BuildContext context) {
    int length = Scope.values.length;
    return Observer(
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
                              _formStore.setScope(value ?? Scope.short);
                            },
                    ),
                  ),
              ],
            ));
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return const MainAppBar();
  }
}
