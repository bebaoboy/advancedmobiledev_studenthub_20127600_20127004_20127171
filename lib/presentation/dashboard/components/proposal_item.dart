import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

class ProposalItem extends StatefulWidget {
  final Proposal proposal;
  // final bool pending;
  final Function? onHired;
  const ProposalItem(
      {super.key,
      required this.proposal,
      // required this.pending,
      required this.onHired});

  @override
  State<ProposalItem> createState() => _ProposalItemState();
}

class _ProposalItemState extends State<ProposalItem> {
  // late bool widget.proposal.isHired;

  @override
  void initState() {
    super.initState();
    // widget.proposal.isHired = widget.pending;
  }

  @override
  Widget build(BuildContext context) {
    var buttonHireText = 'Hire';
    if (widget.proposal.isHired) {
      buttonHireText = 'Sent hired offer';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimens.horizontal_padding - 3,
          vertical: Dimens.vertical_padding),
      child: Container(
        decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(width: 0.4, color: Colors.black87))),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.person,
                    size: 45,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.proposal.student.fullName,
                          style: Theme.of(context).textTheme.bodyLarge),
                      Text(widget.proposal.student.education,
                          style: Theme.of(context).textTheme.bodyLarge)
                    ],
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.proposal.student.title,
                    style: Theme.of(context).textTheme.bodyLarge),
                // ToDo: need a field for expertise
                Text(Lang.get('excellent'),
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Text(widget.proposal.student.introduction,
                    style: Theme.of(context).textTheme.bodyLarge),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    color: Colors.grey.shade400,
                    textColor: Colors.black54,
                    onPressed: () => {} //print('send a message')
                    ,
                    child: Text(Lang.get('message')),
                  ),
                  MaterialButton(
                    enableFeedback: !widget.proposal.isHired,
                    color: !widget.proposal.isHired
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade600,
                    textColor: Colors.white,
                    onPressed: () {
                      if (!widget.proposal.isHired) {
                        //print('send a hire notification');
                        showAnimatedDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return ClassicGeneralDialogWidget(
                              titleText: 'Hired offer',
                              contentText:
                                  'Do you really want to send hired offer for student to do this project',
                              negativeText: Lang.get('cancel'),
                              positiveText: 'Send',
                              onPositiveClick: () {
                                setState(() {
                                  if (!widget.proposal.isHired) {
                                    widget.proposal.hiredStatus =
                                        HireStatus.hired;
                                    widget.onHired!();
                                  }
                                });
                                Navigator.of(context).pop();
                              },
                              onNegativeClick: () {
                                Navigator.of(context).pop();
                              },
                            );
                          },
                          animationType: DialogTransitionType.size,
                          curve: Curves.fastOutSlowIn,
                          duration: const Duration(seconds: 1),
                        );
                      }
                    },
                    child: Text(buttonHireText),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
