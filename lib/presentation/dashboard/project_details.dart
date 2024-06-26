// ignore_for_file: deprecated_member_use

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/core/extensions/cap_extension.dart';
import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/proposal_list.dart';
import 'package:boilerplate/presentation/dashboard/components/hired_item.dart';
import 'package:boilerplate/presentation/dashboard/components/proposal_item.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/dashboard/store/update_project_form_store.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:toastification/toastification.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project project;
  final int? initialIndex;
  const ProjectDetailsPage(
      {super.key, required this.project, this.initialIndex = 0});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late List<Proposal>? hiredList;
  late List<Proposal>? messageList;
  @override
  void initState() {
    super.initState();
    _updateStore.updateResult.addListener(
      () {
        print("change tabs");
        try {
          if (mounted) {
            setState(() {});
          }
        } catch (e) {
          ///
        }
      },
    );
    if (widget.initialIndex != null && widget.initialIndex == -1) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).push(MaterialPageRoute2(
            routeName: Routes.viewProjectProposalsCard,
            arguments: widget.project));
      });
    }

    hiredList = widget.project.proposal
        ?.where(
          (element) => element.hiredStatus == HireStatus.hired,
        )
        .toList();
    messageList = widget.project.proposal?.where((element) {
      return element.hiredStatus == HireStatus.pending ||
          element.hiredStatus == HireStatus.offer;
    }).toList();
  }

  final _updateStore = getIt<UpdateProjectFormStore>();
  final _projectStore = getIt<ProjectStore>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        name: widget.project.objectId ?? "error id",
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Padding(
        padding: const EdgeInsets.all(Dimens.horizontal_padding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.55,
                  child: AutoSizeText(
                    widget.project.title.toTitleCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                Visibility(
                  visible: widget.project.countNewProposals > 0,
                  child: GestureDetector(
                    onTap: () {
                      _projectStore.currentProps =
                          ProposalList(proposals: widget.project.proposal);
                      Navigator.of(context).push(MaterialPageRoute2(
                          routeName: Routes.viewProjectProposalsCard,
                          arguments: widget.project));
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const Icon(Icons.credit_card_rounded),
                            const Text(
                              "Proposals",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                            Text('${widget.project.countNewProposals} new',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          DefaultTabController(
            initialIndex: (widget.initialIndex ?? 0).clamp(0, 2),
            length: 3,
            child: Stack(children: [
              SegmentedTabControl(
                height: Dimens.tab_height + 8,
                radius: const Radius.circular(12),
                indicatorColor: Theme.of(context).colorScheme.primaryContainer,
                tabTextColor: Colors.black45,
                selectedTabTextColor: Colors.white,
                backgroundColor: Colors.grey.shade300,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(fontSize: 12),
                //.copyWith(fontSize: 11.7),
                tabs: [
                  // SegmentTab(label: 'Proposals'),
                  const SegmentTab(label: 'Detail'),
                  SegmentTab(
                      label:
                          'Message ${messageList == null || messageList!.isEmpty ? '' : '(${messageList!.length})'}'),
                  SegmentTab(
                      label:
                          'Hired ${hiredList == null || hiredList!.isEmpty ? '' : '(${hiredList!.length})'}'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60, bottom: 20),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      DetailTabLayout(
                        project: widget.project,
                      ),
                      MessageTabLayout(
                        messages:
                            widget.project.proposal == null ? [] : messageList!
                              ..sort((a, b) => b.hiredStatus.index
                                  .compareTo(a.hiredStatus.index)),
                        onHired: (Proposal p) {
                          p.hiredStatus = HireStatus.offer;
                          _projectStore
                              .updateProposal(p, "something")
                              .then((value) {
                            if (value) {
                              setState(() {});
                            } else {
                              Toastify.show(context, "", "Failed to send hire",
                                  ToastificationType.error, () {});
                            }
                          });
                        },
                        project: widget.project,
                      ),
                      HiredTabLayout(
                        hired: widget.project.proposal == null ? [] : hiredList,
                        project: widget.project,
                      ),
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

// ignore: must_be_immutable
class DetailTabLayout extends StatefulWidget {
  final Project project;
  const DetailTabLayout({super.key, required this.project});

  @override
  State<DetailTabLayout> createState() => _DetailTabLayoutState();
}

class _DetailTabLayoutState extends State<DetailTabLayout> {
  var userStore = getIt<UserStore>();

  final _languageStore = getIt<LanguageStore>();
  var createdText = '';
  var createdText2 = '';
  var updatedText = "";

  @override
  void initState() {
    super.initState();

    createdText =
        "Created: ${DateFormat("HH:mm dd/MM/yyyy").format(widget.project.timeCreated.toLocal())}";
    createdText2 = timeago.format(
        locale: _languageStore.locale, widget.project.timeCreated);

    if (widget.project.updatedAt != null &&
        widget.project.updatedAt! != widget.project.timeCreated) {
      updatedText =
          "Edit at ${DateFormat("HH:mm dd/MM/yyyy").format(widget.project.updatedAt!.toLocal())}";
    }
  }

  String name = "";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ScrollController(),
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
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      // margin: const EdgeInsetsDirectional.only(
                      //     top: Dimens.vertical_padding + 10),
                      width: MediaQuery.of(context).size.width,
                      constraints: const BoxConstraints(maxHeight: 350),
                      decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(width: 1, color: Colors.black),
                              bottom:
                                  BorderSide(width: 1, color: Colors.black))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SingleChildScrollView(
                            controller: ScrollController(),
                            child: Text(widget.project.description)),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
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
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Lang.get('project_scope'),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                widget.project.scope.title,
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
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${Lang.get('project_item_students')} ${widget.project.numberOfStudents}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 45,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                createdText2,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                createdText,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                updatedText.isEmpty
                                    ? Lang.get('project_update_same')
                                    : updatedText,
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
                          Icons.business_outlined,
                          size: 45,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: AutoSizeText(
                                maxLines: 5,
                                '${Lang.get('profile_question_title_2')}: ${name.isNotEmpty ? ("$name (${widget.project.companyId})") : widget.project.companyId}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ]),
                )),
            if (widget.project.companyId == userStore.companyId)
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
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
                            MediaQuery.of(context).size.width / 2 - 48,
                            40), // NEW
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute2(
                                    routeName: Routes.updateProject,
                                    arguments: widget.project))
                            .then((value) {
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      },
                      child: Text(
                        Lang.get('project_edit'),
                        style: Theme.of(context).textTheme.bodyMedium!.merge(
                            TextStyle(
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HiredTabLayout extends StatelessWidget {
  final List<Proposal>? hired;
  final Project project;
  const HiredTabLayout({super.key, required this.hired, required this.project});

  @override
  Widget build(BuildContext context) {
    return (hired?.length ?? 0) == 0
        ? Center(child: Text(Lang.get("nothing_here")))
        : ListView.builder(
            controller: ScrollController(),
            itemCount: hired?.length ?? 0,
            itemBuilder: (context, index) {
              return HiredItem(
                hired: hired![index],
                pending: false,
                project: project,
              );
            },
          );
  }
}

class MessageTabLayout extends StatelessWidget {
  final List<Proposal>? messages;
  final Project project;

  const MessageTabLayout(
      {super.key,
      required this.messages,
      required this.onHired,
      required this.project});
  final Function(Proposal p)? onHired;

  @override
  Widget build(BuildContext context) {
    return (messages?.length ?? 0) == 0
        ? Center(child: Text(Lang.get("nothing_here")))
        : ListView.builder(
            controller: ScrollController(),
            itemCount: messages?.length ?? 0,
            itemBuilder: (context, index) {
              return ProposalItem(
                  proposal: messages![index],
                  project: project,
                  // pending: false,
                  onHired: () => onHired!(messages![index]));
            },
          );
  }
}
