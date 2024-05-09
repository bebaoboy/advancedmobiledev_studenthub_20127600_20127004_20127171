import 'dart:async';

import 'package:boilerplate/core/widgets/menu_bottom_sheet.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/dashboard/chat/chat_store.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/message/schedule_message.dart';
import 'package:boilerplate/presentation/dashboard/components/schedule_bottom_sheet.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:uuid/uuid.dart';

class AllScheduleBottomSheet extends StatefulWidget {
  const AllScheduleBottomSheet(
      {super.key,
      required this.filter,
      required this.user,
      required this.scaffoldKey});
  final List<ScheduleMessageType> filter;
  final ChatUser user;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<AllScheduleBottomSheet> createState() => _AllScheduleBottomSheetState();
}

class _AllScheduleBottomSheetState extends State<AllScheduleBottomSheet> {
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController title = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.day,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    return selectedTime == null
        ? selectedDate
        : DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
  }

  var userStore = getIt<UserStore>();
  var chatStore = getIt<ChatStore>();

  @override
  Widget build(BuildContext context) {
    return ScrollableSheet(
      keyboardDismissBehavior: const SheetKeyboardDismissBehavior.onDragDown(
        isContentScrollAware: true,
      ),
      minExtent: const Extent.proportional(0.4),
      initialExtent: const Extent.proportional(0.5),
      child: Container(
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SheetContentScaffold(
          appBar: AppBar(
            title: Text("All interviews (${widget.filter.length})"),
          ),
          body: ListView.builder(
              itemCount: widget.filter.length,
              itemBuilder: (context, index) {
                var p0 = widget.filter[index];
                var t = InterviewSchedule.fromJsonApi(p0.metadata!);

                return ScheduleMessage(
                    scheduleFilter: t,
                    message: ScheduleMessageType(
                        author: p0.author,
                        metadata: p0.metadata,
                        id: p0.id,
                        type: p0.type,
                        messageWidth:
                            (MediaQuery.of(context).size.width * 0.9).round()),
                    messageWidth: MediaQuery.of(context).size.width * 0.9,
                    user: widget.user,
                    onMenuCallback: (scheduleFilter) async {
                      if (userStore.user!.type == UserType.company) {
                        showAdaptiveActionSheet(
                          title: Text(
                            "Interview ${Lang.get("option")}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          context:
                              NavigationService.navigatorKey.currentContext!,
                          isDismissible: true,
                          barrierColor: Colors.black87,
                          actions: <BottomSheetAction>[
                            if (userStore.user!.type == UserType.company)
                              BottomSheetAction(
                                title: Container(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      Lang.get('reschedule'),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal),
                                    )),
                                onPressed: (context) async {
                                  ////print(scheduleFilter);
                                  await Future.delayed(
                                          const Duration(microseconds: 500))
                                      .then((value) async {
                                    await Navigator.push<InterviewSchedule>(
                                      widget.scaffoldKey.currentContext!,
                                      ModalSheetRoute(
                                          builder: (context) =>
                                              ScheduleBottomSheet(
                                                filter: scheduleFilter,
                                              )),
                                    );
                                    // showScheduleBottomSheet(
                                    //     widget.scaffoldKey.currentContext!,
                                    //     flt: scheduleFilter,
                                    //     id: p0.id);
                                  });
                                },
                              ),
                            BottomSheetAction(
                              visibility: !t.isCancel,
                              title: Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(Lang.get('cancel'),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w100))),
                              onPressed: (context) {
                                int i = chatStore.currentProjectMessages
                                    .indexWhere(
                                        (element) => element.id == p0.id);
                                if (i != -1) {
                                  setState(() {
                                    chatStore.currentProjectMessages[i] =
                                        ScheduleMessageType(
                                            messageWidth:
                                                (MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.9)
                                                    .round(),
                                            author: widget.user,
                                            id: const Uuid().v4(),
                                            type: AbstractMessageType.schedule,
                                            status: Status.delivered,
                                            createdAt: DateTime.now()
                                                .millisecondsSinceEpoch,
                                            metadata: {
                                          ...chatStore.currentProjectMessages[i]
                                              .metadata!,
                                          "isCancel": true,
                                        });
                                    // _sortMessages();
                                  });
                                }
                              },
                            ),
                          ],
                        );
                      }
                    });
              }),
        ),
      ),
    );
  }
}
