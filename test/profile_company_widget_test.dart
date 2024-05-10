// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/under_text_field_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/profile/profile.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widget_test.dart';

void main() {
  setUp(
    () async {
      SharedPreferences.setMockInitialValues({"first_time": true});
      await initDb();
    },
  );

  tearDown(
    () async {
      await getIt.reset();
    },
  );

  Future<void> disableOverflowErrors(tester) async {
    tester.view.physicalSize = const Size(10000, 10000);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  testWidgets("Add company profile Widget Test", (WidgetTester tester) async {
    // WidgetsFlutterBinding.ensureInitialized();
    TestWidgetsFlutterBinding.ensureInitialized();
    disableOverflowErrors(tester);
    final LanguageStore languageStore = getIt<LanguageStore>();

    await tester.pumpWidget(MaterialApp(
        locale: Locale(languageStore.locale),
        supportedLocales: languageStore.supportedLanguages
            .map((language) => Locale(language.locale, language.code))
            .toList(),
        localizationsDelegates: const [
          // A class which loads the translations from JSON files
          Lang.delegate,
          // Built-in localization of basic text for Material widgets
          GlobalMaterialLocalizations.delegate,
          // Built-in localization for text direction LTR/RTL
          GlobalWidgetsLocalizations.delegate,
          // Built-in localization of basic text for Cupertino widgets
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
                data: MediaQueryData(size: Size(10000.0, 10000.0)),
                child: ProfileScreen()))));

    await tester.pump();
    for (int i = 1; i <= CompanyScope.values.length; i++) {
      expect(find.text(Lang.get("profile_question_1_choice_$i")), findsOne);
    }
    expect(find.byType(Radio<CompanyScope>),
        findsExactly(CompanyScope.values.length));
    expect(find.text(Lang.get("profile_question_title_1")), findsOne);
    expect(find.text(Lang.get("profile_question_title_2")), findsOne);
    expect(find.text(Lang.get("profile_question_title_3")), findsOne);
    expect(find.text(Lang.get("profile_question_title_4")), findsOne);
    expect(find.text(Lang.get("profile_welcome_title")), findsOne);
    expect(find.text(Lang.get("profile_common_body")), findsOne);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is RoundedButtonWidget &&
            widget.buttonText == Lang.get('continue')),
        findsAny);
    expect(find.byType(BorderTextField), findsExactly(3));
    // expect(find.text(Lang.get("signup_student_role_text")), findsOne);
    // expect(find.text(Lang.get("signup_company_role_text")), findsOne);
    tester.view.resetPhysicalSize();
  });
}
