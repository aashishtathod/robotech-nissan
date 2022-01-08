import 'package:robotech/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:robotech/util/language_notifier.dart';
import 'package:robotech/util/theme_notifier.dart';
import 'package:robotech/res/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

bool? loggedIn = false;
String? role = "", state = "";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  loggedIn = prefs.getBool("loggedIn");
  role = prefs.getString("role");
  state = prefs.getString("state");
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]).then((_) {
    SharedPreferences.getInstance().then((prefs) {
      var darkModeOn = prefs.getBool('darkMode') ?? false;
      runApp(
        ChangeNotifierProvider<ThemeChanger>(
          create: (_) => ThemeChanger(darkModeOn ? darkTheme : lightTheme),
          child: const MyApp(),
        ),
      );
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your applicatio n.
  @override
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context);
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => LocaleChanger())],
      child: Consumer<LocaleChanger>(builder: (context, locale, child) {
        return ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: () => MaterialApp(
                  title: 'Inventory Tracker',
                  debugShowCheckedModeBanner: false,
                  theme: themeChanger.getTheme(),
                  localizationsDelegates: const [
                    AppLocalizations.delegate, // Add this line
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en', ''), // English, no country code
                    Locale('hi', ''), // Hindi, no country code
                  ],
                  locale: locale.locale,
                  initialRoute: "/",
                  routes: {
                    '/': (context) => const SplashScreen(),
                  },
                  builder: (context, widget) {
                    return MediaQuery(
                      //Setting font does not change with system font size
                      data:
                          MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                      child: widget!,
                    );
                  },
                ));
      }),
    );
  }
}
