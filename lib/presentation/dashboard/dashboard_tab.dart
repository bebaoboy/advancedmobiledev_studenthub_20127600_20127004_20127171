import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class DashBoardTab extends StatefulWidget {
  @override
  State<DashBoardTab> createState() => _DashBoardTabState();
}

class _DashBoardTabState extends State<DashBoardTab> {
  @override
  Widget build(BuildContext context) {
    return _buildDashBoardContent();
  }

  Widget _buildDashBoardContent() {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                  AppLocalizations.of(context).translate('Dashboard_your_job')),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 100,
                height: 30,
                child: FloatingActionButton(
                  heroTag: "F3",
                  onPressed: () {},
                  child: Text(
                    AppLocalizations.of(context)
                        .translate('Dashboard_post_job'),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 34,
        ),
        Align(
          alignment: Alignment.center,
          child:
              Text(AppLocalizations.of(context).translate('Dashboard_intro')),
        ),
        Align(
          alignment: Alignment.center,
          child:
              Text(AppLocalizations.of(context).translate('Dashboard_content')),
        ),
      ],
    );
  }
}