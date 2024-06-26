import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class SubmitProjectProposal extends StatefulWidget {
  final Project project;
  const SubmitProjectProposal({super.key, required this.project});

  @override
  State<SubmitProjectProposal> createState() => _SubmitProjectProposalState();
}

class _SubmitProjectProposalState extends State<SubmitProjectProposal> {
  TextEditingController coverLetterController = TextEditingController();
  final UserStore _userStore = getIt<UserStore>();
  final ProjectStore _projectStore = getIt<ProjectStore>();

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
                child: TextField(
                  controller: coverLetterController,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8.0)),
                  minLines: 12,
                  maxLines: 20,
                  textInputAction: TextInputAction.done,
                  maxLength: 500,
                )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: () {
                    if (coverLetterController.text.isEmpty) {
                      Toastify.show(context, '', "Description can't be empty",
                          ToastificationType.error, () {});
                    } else if (coverLetterController.text.length > 500) {
                      Toastify.show(
                          context,
                          '',
                          "Description should be less than 500 characters",
                          ToastificationType.error,
                          () {});
                    } else {
                      var newStudentProject = StudentProject(
                        description: '',
                        title: widget.project.title,
                        numberOfStudents: widget.project.numberOfStudents,
                        scope: widget.project.scope,
                        id: widget.project.objectId ?? "",
                        timeCreated: DateTime.now(),
                        projectId: widget.project.companyId,
                        // timeCreated: widget.project.timeCreated
                      );
                      var proposal = Proposal(
                          project: newStudentProject,
                          student: _userStore.user!.studentProfile!,
                          coverLetter: coverLetterController.text.trim());

                      _projectStore
                          .postProposal(proposal, widget.project)
                          .then((value) {
                        if (value) {
                          _userStore.addNewProposal(proposal);
                          Toastify.show(context, '', "Sent successfully",
                              ToastificationType.success, () {});
                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.pop(context, true);
                          });
                        } else {
                          Toastify.show(
                              context,
                              '',
                              _projectStore.errorStore.errorMessage,
                              ToastificationType.error,
                              () {});
                        }
                      });
                    }
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
