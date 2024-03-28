import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:boilerplate/presentation/dashboard/components/hired_item.dart';
import 'package:boilerplate/presentation/dashboard/components/proposal_item.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project project;
  const ProjectDetailsPage({super.key, required this.project});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Dimens.horizontal_padding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Text(widget.project.title),
          ),
          DefaultTabController(
            length: 4,
            child: Stack(children: [
              SegmentedTabControl(
                height: Dimens.tab_height + 6,
                radius: const Radius.circular(12),
                indicatorColor: Theme.of(context).colorScheme.primaryContainer,
                tabTextColor: Colors.black45,
                selectedTabTextColor: Colors.white,
                backgroundColor: Colors.grey.shade300,
                tabs: const [
                  SegmentTab(label: 'Proposals'),
                  SegmentTab(label: 'Detail'),
                  SegmentTab(label: 'Message'),
                  SegmentTab(label: 'Hired'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ProposalTabLayout(
                          proposals: widget.project.proposal,
                          onHired: (index) {
                            setState(() {
                              try {
                                widget.project.hired != null
                                    ? widget.project.hired!.add(widget
                                        .project.proposal!
                                        .removeAt(index))
                                    : widget.project.hired = [
                                        widget.project.proposal!.removeAt(index)
                                      ];
                              } catch (e) {}
                            });
                          }),
                      DetailTabLayout(
                        project: widget.project,
                      ),
                      MessageTabLayout(messages: widget.project.messages),
                      HiredTabLayout(hired: widget.project.hired),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class ProposalTabLayout extends StatelessWidget {
  final List<StudentProfile>? proposals;

  const ProposalTabLayout(
      {super.key, required this.proposals, required this.onHired});
  final Function? onHired;

  @override
  Widget build(BuildContext context) {
    return (proposals?.length ?? 0) == 0
        ? Center(child: Text(Lang.get("nothing_here")))
        : ListView.builder(
            itemCount: proposals?.length ?? 0,
            itemBuilder: (context, index) {
              return ProposalItem(
                  proposal: proposals![index],
                  pending: false,
                  onHired: () => onHired!(index));
            },
          );
  }
}

class DetailTabLayout extends StatelessWidget {
  final Project project;

  const DetailTabLayout({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7),
                  child: Column(children: [
                    Container(
                      // margin: const EdgeInsetsDirectional.only(
                      //     top: Dimens.vertical_padding + 10),
                      width: MediaQuery.of(context).size.width,
                      height: 400,
                      decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(width: 1, color: Colors.black),
                              bottom:
                                  BorderSide(width: 1, color: Colors.black))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SingleChildScrollView(
                            child: Text(project.description)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.alarm,
                            size: 45,
                          ),
                          Column(
                            children: [
                              Text(
                                'Project scope',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                project.scope.title,
                                style: Theme.of(context).textTheme.bodyLarge,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 45,
                        ),
                        Column(
                          children: [
                            Text(
                              'Student required',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              '${project.numberOfStudents} students',
                              style: Theme.of(context).textTheme.bodyLarge,
                            )
                          ],
                        )
                      ],
                    )
                  ]),
                )),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Flexible(
                //   fit: FlexFit.tight,
                //   child: TextButton(
                //     onPressed: () {
                //       widget.onSheetDismissed();
                //     },
                //     child: const Text(Lang.get('Cancel'),
                //   ),
                // ),
                // const SizedBox(width: 16),
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor:
                //         Theme.of(context).colorScheme.primaryContainer,
                //     surfaceTintColor: Colors.transparent,

                //     minimumSize: Size(
                //         MediaQuery.of(context).size.width / 2 - 48, 40), // NEW
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(3),
                //     ),
                //   ),
                //   onPressed: () {},
                //   child: Text(Lang.get('Saved',
                //     style: Theme.of(context).textTheme.bodyMedium!.merge(
                //         TextStyle(
                //             color: Theme.of(context).colorScheme.secondary)),
                //   ),
                // ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    surfaceTintColor: Colors.transparent,
                    minimumSize: Size(
                        MediaQuery.of(context).size.width / 2 - 48, 40), // NEW
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    Lang.get('project_edit'),
                    style: Theme.of(context).textTheme.bodyMedium!.merge(
                        TextStyle(
                            color: Theme.of(context).colorScheme.secondary)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HiredTabLayout extends StatelessWidget {
  final List<StudentProfile>? hired;

  const HiredTabLayout({super.key, required this.hired});

  @override
  Widget build(BuildContext context) {
    return (hired?.length ?? 0) == 0
        ? Center(child: Text(Lang.get("nothing_here")))
        : ListView.builder(
            itemCount: hired?.length ?? 0,
            itemBuilder: (context, index) {
              // return ListTile(
              //   title: Text(hired![index].name),
              // );

              return HiredItem(
                hired: hired![index],
                pending: false,
              );
            },
          );
  }
}

class MessageTabLayout extends StatelessWidget {
  final List<StudentProfile>? messages;

  const MessageTabLayout({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return (messages?.length ?? 0) == 0
        ? Center(child: Text(Lang.get("nothing_here")))
        : ListView.builder(
            itemCount: messages?.length ?? 0,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(messages![index].name),
              );
            },
          );
  }
}
