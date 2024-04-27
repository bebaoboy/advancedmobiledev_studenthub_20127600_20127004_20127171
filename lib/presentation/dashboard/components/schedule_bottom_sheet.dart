import 'dart:async';

import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class ScheduleBottomSheet extends StatefulWidget {
  const ScheduleBottomSheet({super.key, required this.filter});
  final InterviewSchedule? filter;

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController title = TextEditingController();

  late final InterviewSchedule itv;

  bool _isAllCorrect = true;

  @override
  void initState() {
    super.initState();
    itv = widget.filter ??
        InterviewSchedule(
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            title: "Null meeting");
    title.text = (itv.title).toString();
    startDate.text =
        (DateFormat("EEEE dd/MM/yyyy HH:MM").format(itv.startDate)).toString();
    endDate.text =
        (DateFormat("EEEE dd/MM/yyyy HH:MM").format(itv.endDate)).toString();
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

  @override
  Widget build(BuildContext context) {
    return ScrollableSheet(
      keyboardDismissBehavior: const SheetKeyboardDismissBehavior.onDragDown(
        isContentScrollAware: true,
      ),
      child: Container(
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SheetContentScaffold(
            appBar: AppBar(
              title: Text(Lang.get("schedule_interview")),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 44,
                    ),
                    TextField(
                      controller: title,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: Lang.get("nothing_here"),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        labelText: Lang.get("title"),
                      ),
                      onChanged: (value) {
                        itv.title = value;
                        // itv.endDate = int.tryParse(value) ?? 2;
                      },
                    ),
                    const Divider(height: 32),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: startDate,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: "None",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2)),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2)),
                                labelText: Lang.get('profile_project_start'),
                              ),
                              onChanged: (value) {
                                // itv.endDate = int.tryParse(value) ?? 2;
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFieldWidget(
                                onTap: () async {
                                  DateTime? pickedDate =
                                      await showDateTimePicker(
                                          context: context,
                                          initialDate: itv.startDate,
                                          firstDate: itv.startDate,
                                          //DateTime.now() - not to allow to choose before today.
                                          lastDate: itv.startDate
                                              .add(const Duration(days: 1)));

                                  if (pickedDate != null) {
                                    ////print(pickedDate);
                                    setState(() {
                                      itv.startDate = pickedDate;
                                      startDate.text =
                                          (DateFormat("EEEE dd/MM/yyyy HH:MM")
                                                  .format(itv.startDate))
                                              .toString();
                                    });
                                  }
                                },
                                inputDecoration: const InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2)),
                                ),
                                isIcon: false,
                                label: Text(
                                  Lang.get('profile_project_start'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                enabled: true,
                                enableInteractiveSelection: false,
                                canRequestFocus: false,
                                readOnly: true,
                                fontSize: 15,
                                hint: "Tap",
                                inputType: TextInputType.emailAddress,
                                icon: null,
                                textController: null,
                                inputAction: TextInputAction.next,
                                autoFocus: false,
                                onChanged: (value) {
                                  //_projects[index].proficiency = value;

                                  // _formStore
                                  //     .setUserId(_userEmailController.text);
                                },
                                onFieldSubmitted: (value) {
                                  // FocusScope.of(context)
                                  //     .requestFocus(_passwordFocusNode);
                                },
                                errorText: null
                                // _formStore
                                //             .formErrorStore.userEmail ==
                                //         null
                                //     ? null
                                //     : AppLocalizations.of(context).get(
                                //         _formStore.formErrorStore.userEmail),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 32),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: endDate,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: "None",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2)),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2)),
                                labelText: Lang.get('profile_project_end'),
                              ),
                              onChanged: (value) {
                                // itv.endDate = int.tryParse(value) ?? 2;
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFieldWidget(
                                onTap: () async {
                                  DateTime? pickedDate =
                                      await showDateTimePicker(
                                          context: context,
                                          initialDate: itv.endDate,
                                          firstDate: itv.endDate,
                                          //DateTime.now() - not to allow to choose before today.
                                          lastDate: itv.endDate
                                              .add(const Duration(days: 1)));

                                  if (pickedDate != null) {
                                    ////print(pickedDate);
                                    setState(() {
                                      itv.endDate = pickedDate;
                                      endDate.text =
                                          (DateFormat("EEEE dd/MM/yyyy HH:MM")
                                                  .format(itv.endDate))
                                              .toString();
                                    });
                                  }
                                },
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                inputDecoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2)),
                                ),
                                label: Text(
                                  Lang.get('profile_project_end'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                isIcon: false,
                                enabled: true,
                                enableInteractiveSelection: false,
                                canRequestFocus: false,
                                readOnly: true,
                                fontSize: 15,
                                inputType: TextInputType.emailAddress,
                                icon: null,
                                textController: null,
                                inputAction: TextInputAction.next,
                                autoFocus: false,
                                onChanged: (value) {
                                  //_projects[index].proficiency = value;

                                  // _formStore
                                  //     .setUserId(_userEmailController.text);
                                },
                                onFieldSubmitted: (value) {
                                  // FocusScope.of(context)
                                  //     .requestFocus(_passwordFocusNode);
                                },
                                errorText: null
                                // _formStore
                                //             .formErrorStore.userEmail ==
                                //         null
                                //     ? null
                                //     : AppLocalizations.of(context).get(
                                //         _formStore.formErrorStore.userEmail),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 32),
                    Text(itv.getDuration().toString()),
                  ],
                ),
              ),
            ),
            bottomBar: StickyBottomBarVisibility(
              child: BottomAppBar(
                height: 120,
                surfaceTintColor: Colors.white,
                child: Center(
                  child: Column(
                    children: [
                      Visibility(
                          visible: !_isAllCorrect,
                          child: Container(
                              alignment: Alignment.center,
                              child:
                                  const Text("Some fields are not correct"))),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RoundedButtonWidget(
                            buttonColor: Theme.of(context).colorScheme.primary,
                            onPressed: () {
                              itv.clear();
                              Navigator.pop(context);
                            },
                            buttonText: Lang.get("cancel"),
                          ),
                          const SizedBox(width: 12),
                          RoundedButtonWidget(
                            buttonColor: Theme.of(context).colorScheme.primary,
                            onPressed: () {
                              if (title.text.isEmpty) {
                                setState(() {
                                  _isAllCorrect = false;
                                });
                              } else {
                                setState(() {
                                  _isAllCorrect = false;
                                });
                                Navigator.pop(context, itv);
                              }
                            },
                            buttonText: Lang.get("send"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
