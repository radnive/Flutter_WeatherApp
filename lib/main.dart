import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/database/entities/settings_entity.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/provider.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/types.dart';
import 'package:weather_app/router.dart';

late AppRouterDelegate _routerDelegate;
late AppRouteInformationParser _informationParser;
late AppearanceChangeProvider _appearanceChangeProvider;

void main() async {
  // Required for getting application directory by ObjectBox to store database.
  WidgetsFlutterBinding.ensureInitialized();
  // Create database.
  Database db = Database();
  await db.create();
  // Create router and information parser.
  _routerDelegate = AppRouterDelegate(db);
  _informationParser = AppRouteInformationParser();
  // Load user settings into provider.
  _loadUserSettings(db);
  // Start app.
  runApp(const WeatherApp());
}

// Load user settings into provider.
void _loadUserSettings(Database db) {
  // Check for saved settings.
  if(Settings.isSettingsSaved(db)) {
    // Get saved user settings.
    Settings userSettings = Settings.get(db);
    // Load settings into provider.
    _appearanceChangeProvider = AppearanceChangeProvider(
      language: userSettings.language,
      themeMode: userSettings.themeMode
    );
  } else {
    // Insert default settings to database.
    Settings.insertDefaultSettings(db);
    // Create provider with default settings.
    _appearanceChangeProvider = AppearanceChangeProvider();
  }
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppearanceChangeProvider>(
      create: (_) => _appearanceChangeProvider,
      child: Builder(
        builder: (context) {
          final provider = Provider.of<AppearanceChangeProvider>(context, listen: true);
          return MaterialApp.router(
            title: 'Weather App',
            routerDelegate: _routerDelegate,
            routeInformationParser: _informationParser,
            backButtonDispatcher: RootBackButtonDispatcher(),
            locale: Locale(provider.language.locale),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            themeMode: provider.themeMode,
            theme: ThemeData(
              useMaterial3: false,
              colorScheme: Palette.lightColorScheme,
              fontFamily: provider.language.fontFamily,
              textTheme: Types.textTheme
            ),
            darkTheme: ThemeData(
              useMaterial3: false,
              colorScheme: Palette.darkColorScheme,
              fontFamily: provider.language.fontFamily,
              textTheme: Types.textTheme
            )
          );
        }
      )
    );
  }
}
