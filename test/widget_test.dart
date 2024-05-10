// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:boilerplate/core/data/local/sembast/sembast_client.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/data/di/module/network_module.dart';
import 'package:boilerplate/data/di/module/repository_module.dart';
import 'package:boilerplate/data/local/datasources/chat/chat_datasource.dart';
import 'package:boilerplate/data/local/datasources/post/post_datasource.dart';
import 'package:boilerplate/data/local/datasources/project/project_datasource.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/di/domain_layer_injection.dart';
import 'package:boilerplate/main.dart';
import 'package:boilerplate/presentation/di/presentation_layer_injection.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/login/login.dart';
import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_whiteboard.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';

initDb() async {
  // preference manager:------------------------------------------------------
  getIt.registerSingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance());
  getIt.registerSingleton<SharedPreferenceHelper>(
    SharedPreferenceHelper(await getIt.getAsync<SharedPreferences>()),
  );
  // data sources:------------------------------------------------------------
  // Prevent calling Future.delayed that seems to hang in flutter test
  disableSembastCooperator();
  var sb = SembastClient(await databaseFactoryMemory.openDatabase('database'));
  getIt.registerSingleton(PostDataSource(sb));

  getIt.registerSingleton(ProjectDataSource(sb));
  getIt.registerSingleton(ChatDataSource(sb));
  await NetworkModule.configureNetworkModuleInjection();
  await RepositoryModule.configureRepositoryModuleInjection();

  await DomainLayerInjection.configureDomainLayerInjection();
  await PresentationLayerInjection.configurePresentationLayerInjection();
  log("done init db testing");
  // Workmanager().initialize(
  //     callbackDispatcher, // The top level function, aka callbackDispatcher
  //     isInDebugMode:
  //         true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  //     );
  // database:----------------------------------------------------------------
  // each database has a unique name
}

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
    tester.view.physicalSize = const Size(2000, 4000);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  testWidgets('Initial test', (WidgetTester tester) async {
    setPreferredOrientations();
    // await ServiceLocator.configureDependencies();
    // Build our app and trigger a frame.
    await tester
        .pumpWidget(const MaterialApp(home: Scaffold(body: Text("data"))));
    // Verify if the splash image is visible
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets("Login Widget Test", (WidgetTester tester) async {
    // WidgetsFlutterBinding.ensureInitialized();
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
                child: LoginScreen()))));

    await tester.pumpAndSettle(const Duration(seconds: 10));
    expect(find.text(Lang.get("login_main_text")), findsOne);
    expect(find.byType(RoundedButtonWidget), findsAny);
    expect(find.byType(Image), findsAny);
  });
}
