import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/domain/entity/project/myMockData.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class SubmitProjectProposal extends StatefulWidget {
  final Project project;
  const SubmitProjectProposal({super.key, required this.project});

  @override
  State<SubmitProjectProposal> createState() => _SubmitProjectProposalState();
}

class _SubmitProjectProposalState extends State<SubmitProjectProposal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cover letter',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(Lang.get('project_submit_proposal'),
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black)),
              child: const TextField(
                decoration:
                    InputDecoration(contentPadding: EdgeInsets.all(8.0)),
                minLines: 6,
                maxLines: 10,
                textInputAction: TextInputAction.done,
                maxLength: 500,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  textColor: Colors.white,
                  color: Theme.of(context).primaryColor,
                  child: Text(Lang.get('cancel')),
                ),
                const SizedBox(
                  width: 12,
                ),
                MaterialButton(
                  onPressed: () {
                    // TODO: check id proposal + add cb
                    var newStudentProject = StudentProject(
                      title: widget.project.title,
                      description: widget.project.description,
                      numberOfStudents: widget.project.numberOfStudents,
                      scope: widget.project.scope,
                      id: widget.project.objectId ?? "",
                      timeCreated: DateTime.now(),
                      projectId: widget.project.companyId,
                      // timeCreated: widget.project.timeCreated
                    );
                    studentProjects.add(newStudentProject);
                  },
                  color: Colors.amber.shade300,
                  child: Text(Lang.get('proposal_submit')),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
