import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

class ProjectItem extends StatefulWidget {
  final Project project;

  final Function onFavoriteTap;
  const ProjectItem({super.key, required this.project, required this.onFavoriteTap});

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
      var icon = widget.project.isFavorite
          ? const Icon(Icons.favorite)
          : const Icon(Icons.favorite_border);

      var createdText = '';
      int differenceWithToday = widget.project.getModifiedTimeCreated();
      if (differenceWithToday == 0) {
        createdText = Lang.get("created_now");
      } else if (differenceWithToday == 1) {
        createdText = 'Created 1 day ago';
      } else {
      createdText = 'Created $differenceWithToday${Lang.get('day_ago')}';
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
        constraints: const BoxConstraints(maxHeight: 230),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black, width: 1.0),
            bottom: BorderSide(color: Colors.black, width: 1.0),
          ),
        ),

//       Card(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             children: [
//               Expanded(
//                 flex: 9,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       createdText,
//                       style: Theme.of(context).textTheme.labelSmall,
//                     ),
//                     Text(
//                       widget.project.title,
//                       style: Theme.of(context).textTheme.bodyText1,
//                     ),
//                     Text(
//                       'Time: ${widget.project.scope.title}, ${widget.project.numberOfStudents} students needed',
//                     ),
//                     Text(widget.project.description),
//                     Text(proposalText),
//                   ],
        child: Card(
          child: InkWell(
            onTap: () {
              //NavbarNotifier2.pushNamed(Routes.projectDetails, 1, widget.project);
              Navigator.of(NavigationService.navigatorKey.currentContext!)
                  .pushNamed(Routes.projectDetailsStudent,
                      arguments: widget.project);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 9,
                    child: SingleChildScrollView(
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
                  ),
                  IconButton(
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      setState(() {
                        widget.onFavoriteTap();
                      });
                    },
                    icon: icon,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
