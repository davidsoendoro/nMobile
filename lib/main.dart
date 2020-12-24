import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:nmobile/services/task_service.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'blocs/wallet/filtered_wallets_bloc.dart';
import 'blocs/wallet/wallets_bloc.dart';
import 'common/global.dart';
import 'common/settings.dart';
import 'generated/l10n.dart';
import 'services/local_authentication_service.dart';
import 'storages/settings.dart';
import 'theme/theme.dart';
import 'common/application.dart';
import 'routes/routes.dart' as routes;

GetIt locator = GetIt.instance;

void setupLocator() {
  locator..registerSingleton(Application())..registerSingleton(TaskService())..registerSingleton(LocalAuthenticationService());
}

void initialize(){
  app.registerInitialize(() async {
    var localAuth = locator.get<LocalAuthenticationService>();
    localAuth.authType = await localAuth.getAuthType();
    SettingsStorage settingsStorage = SettingsStorage();
    localAuth.isProtectionEnabled = await settingsStorage.getSettings(SettingsStorage.AUTH_KEY) ?? false;
    Global.applicationRootDirectory = await getApplicationDocumentsDirectory();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Global.version = packageInfo.version;
    Global.build = packageInfo.buildNumber.replaceAll('.', '');
    // load language
    Settings.locale = (await settingsStorage.getSettings(SettingsStorage.LOCALE_KEY)) ?? 'auto';
    // load settings
    Settings.localNotificationType = (await settingsStorage.getSettings(SettingsStorage.LOCAL_NOTIFICATION_TYPE_KEY)) ?? 0;
    Settings.debug = (await settingsStorage.getSettings(SettingsStorage.DEBUG_KEY)) ?? false;
  });
}

Application app = locator.get<Application>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  routes.init();
  initialize();
  await app.initialize();
  app.registerMounted(() async {
    locator.get<TaskService>().install();
  });
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  runApp(Main());
}

class Main extends StatefulWidget {
  static final String name = 'nMobile';

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  List<BlocProvider> providers = [
    BlocProvider<WalletsBloc>(
      create: (BuildContext context) => WalletsBloc(),
    ),
    BlocProvider<FilteredWalletsBloc>(
      create: (BuildContext context) => FilteredWalletsBloc(
        walletsBloc: BlocProvider.of<WalletsBloc>(context),
      ),
    ),
  ];
  final botToastBuilder = BotToastInit();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: providers,
      child: MaterialApp(
        builder: (context, child) {
          child = FlutterEasyLoading(child: child);
          child = botToastBuilder(context, child);
          return child;
        },
        onGenerateTitle: (context) {
          return S.of(context).nMobile;
        },
        title: Main.name,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: DefaultTheme.primaryColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          sliderTheme: SliderThemeData(
            overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
            trackHeight: 8,
            tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 0),
            // thumbShape: SliderThemeShape(),
          ),
        ),
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          ...S.delegate.supportedLocales,
        ],
        initialRoute: AppScreen.routeName,
        onGenerateRoute: app.onGenerateRoute,
        localeResolutionCallback: (locale, supportLocales) {
          if (locale?.languageCode == 'zh') {
            if (locale?.scriptCode == 'Hant') {
              return const Locale('zh', 'TW');
            } else {
              return const Locale('zh', 'CN');
            }
          } else if (locale?.languageCode == 'zh_Hant_CN') {
            return const Locale('zh', 'TW');
          } else if (locale?.languageCode == 'auto') {
            return null;
          }
          return locale;
        },
      ),
    );
  }
}
