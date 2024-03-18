import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

class HiredItem extends StatefulWidget {
  final Student hired;
  final bool pending;
  // final Function? onHired;
  const HiredItem(
      {super.key,
      required this.hired,
      required this.pending,
      // required this.onHired
      });

  @override
  State<HiredItem> createState() => _HiredItemState();
}

class _HiredItemState extends State<HiredItem> {
  late bool isPending;

  @override
  void initState() {
    super.initState();
    isPending = widget.pending;
  }

  @override
  Widget build(BuildContext context) {
    var buttonHireText = 'Hire';
    if (isPending) {
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
                      Text(widget.hired.name,
                          style: Theme.of(context).textTheme.bodyText1),
                      Text(widget.hired.education,
                          style: Theme.of(context).textTheme.bodyText1)
                    ],
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.hired.title,
                    style: Theme.of(context).textTheme.bodyText1),
                // ToDo: need a field for expertise
                Text('Excellent', style: Theme.of(context).textTheme.bodyText1),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Text(widget.hired.introduction,
                    style: Theme.of(context).textTheme.bodyText1),
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
                    onPressed: () => print('send a message'),
                    child: const Text('Message'),
                  ),
                  // MaterialButton(
                  //   color: Theme.of(context).primaryColor,
                  //   textColor: Colors.white,
                  //   onPressed: () {
                  //     if (isPending) {
                  //       return;
                  //     }
                  //     print('send a hire notification');
                  //     showAnimatedDialog(
                  //       context: context,
                  //       barrierDismissible: true,
                  //       builder: (BuildContext context) {
                  //         return ClassicGeneralDialogWidget(
                  //           titleText: 'Hired offer',
                  //           contentText:
                  //               'Do you really want to send hired offer for student to do this project',
                  //           negativeText: 'Cancel',
                  //           positiveText: 'Send',
                  //           onPositiveClick: () {
                  //             setState(() {
                  //               // if (!isPending) {
                  //               //   widget.onHired!();
                  //               // }
                  //               // isPending = !isPending;
                  //             });
                  //             Navigator.of(context).pop();
                  //           },
                  //           onNegativeClick: () {
                  //             Navigator.of(context).pop();
                  //           },
                  //         );
                  //       },
                  //       animationType: DialogTransitionType.size,
                  //       curve: Curves.fastOutSlowIn,
                  //       duration: const Duration(seconds: 1),
                  //     );
                  //   },
                  //   child: Text(buttonHireText),
                  // ),
                
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}