import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:boilerplate/presentation/dashboard/components/proposal_item.dart';
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
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ProposalTabLayout(
                          proposals: widget.project.proposal,
                          onHired: (index) {
                            setState(() {
                              try{
                              widget.project.hired != null
                                  ? widget.project.hired!.add(
                                      widget.project.proposal!.removeAt(index))
                                  : widget.project.hired = [
                                      widget.project.proposal!.removeAt(index)
                                    ];
                              } catch(e) {
                                
                              }
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
  final List<Student>? proposals;

  const ProposalTabLayout(
      {super.key, required this.proposals, required this.onHired});
  final Function? onHired;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
          children: [
            Container(
              margin: const EdgeInsetsDirectional.only(
                  top: Dimens.vertical_padding + 10),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(width: 1, color: Colors.black),
                      bottom: BorderSide(width: 1, color: Colors.black))),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(project.description),
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
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      Text(
                        project.scope.title,
                        style: Theme.of(context).textTheme.bodyText1,
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
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(
                      '${project.numberOfStudents} students',
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class HiredTabLayout extends StatelessWidget {
  final List<Student>? hired;

  const HiredTabLayout({super.key, required this.hired});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: hired?.length ?? 0,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(hired![index].name),
        );
      },
    );
  }
}

class MessageTabLayout extends StatelessWidget {
  final List<Student>? messages;

  const MessageTabLayout({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages?.length ?? 0,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(messages![index].name),
        );
      },
    );
  }
}
