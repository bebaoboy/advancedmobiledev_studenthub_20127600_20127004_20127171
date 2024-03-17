import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:flutter/material.dart';

class ProposalItem extends StatefulWidget {
  final Student proposal;
  const ProposalItem({super.key, required this.proposal});

  @override
  State<ProposalItem> createState() => _ProposalItemState();
}

class _ProposalItemState extends State<ProposalItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.horizontal_padding),
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
                      Text(widget.proposal.name,
                          style: Theme.of(context).textTheme.bodyText1),
                      Text(widget.proposal.education,
                          style: Theme.of(context).textTheme.bodyText1)
                    ],
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.proposal.title,
                    style: Theme.of(context).textTheme.bodyText1),
                // ToDo: need a field for expertise
                Text('Excellent', style: Theme.of(context).textTheme.bodyText1),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Text(widget.proposal.introduction,
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
                  MaterialButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: () => print('send a hire notification'),
                    child: const Text('Hire'),
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
