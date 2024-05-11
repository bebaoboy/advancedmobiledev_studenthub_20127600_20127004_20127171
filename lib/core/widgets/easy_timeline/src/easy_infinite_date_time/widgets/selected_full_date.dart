// ignore_for_file: unused_import

import 'package:boilerplate/core/widgets/easy_timeline/src/utils/easy_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/easy_date_formatter.dart';

class SelectedFullDateWidget extends StatelessWidget {
  /// Represents a header widget for displaying the date as `01/01/2023`.
  const SelectedFullDateWidget({
    super.key,
    required this.date,
    required this.locale,
  });

  /// Represents the date for the month header.
  final DateTime date;

  /// A `String` that represents the locale code to use for formatting the month name in the header.
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat("yyyy", locale).format(date)
      // EasyDateFormatter.fullDateDMY(
      //   date,
      //   locale,
      // ),
      ,
      style: EasyTextStyles.selectedDateStyle.copyWith(color: Theme.of(context).colorScheme.onPrimary),
    );
  }
}
