import 'package:boilerplate/constants/app_theme.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:flutter/material.dart';

class ProjectItem extends StatefulWidget {
  final Project project;
  final bool isFavorite;

  const ProjectItem(
      {super.key, required this.project, required this.isFavorite});

  @override
  _ProjectItemState createState() => _ProjectItemState();
}

class _ProjectItemState extends State<ProjectItem> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    var icon = _isFavorite
        ? const Icon(Icons.favorite)
        : const Icon(Icons.favorite_border);

    var createdText = '';
    int differenceWithToday = widget.project.getModifiedTimeCreated();
    if (differenceWithToday == 0) {
      createdText = 'Created just now';
    } else if (differenceWithToday == 1) {
      createdText = 'Created 1 day ago';
    } else {
      createdText = 'Created $differenceWithToday days ago';
    }

    var proposalText = 'Proposals: ';
    if (widget.project.proposal != null) {
      if (widget.project.proposal!.length > 6) {
        proposalText +=
            'Less than ${widget.project.proposal!.length.toString()}';
      } else {
        proposalText += widget.project.proposal!.length.toString();
      }
    } else {
      proposalText += '0';
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black, width: 1.0),
          bottom: BorderSide(color: Colors.black, width: 1.0),
        ),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                flex: 9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      createdText,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      widget.project.title,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(
                      'Time: ${widget.project.scope.title}, ${widget.project.numberOfStudents} students needed',
                    ),
                    Text(widget.project.description),
                    Text(proposalText),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
                icon: icon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
