import 'package:boilerplate/core/widgets/lazy_loading_card.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:flutter/material.dart';

class ProjectItem extends StatefulWidget {
  final Project project;
  ProjectItem({super.key, required this.project});

  @override
  _ProjectItemState createState() => _ProjectItemState();
}

class _ProjectItemState extends State<ProjectItem> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.project.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
          ],
        ),
      );
    } else {
      var icon = widget.project.isFavorite!
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
                      Text(createdText),
                      Text(widget.project.title),
                      Text(
                        'Time: ${widget.project.scope.title}, ${widget.project.numberOfStudents} students needed',
                      ),
                      Text(widget.project.description),
                      Text(proposalText),
                    ],
                  ),
                ),
                IconButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    setState(() {
                      widget.project.isFavorite =
                          !(widget.project.isFavorite ?? false);
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
}
