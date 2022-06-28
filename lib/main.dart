import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/provider.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/types.dart';

late AppearanceChangeProvider _appearanceChangeProvider;

void main() {
  _appearanceChangeProvider = AppearanceChangeProvider();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppearanceChangeProvider>(
      create: (_) => _appearanceChangeProvider,
      child: Builder(
        builder: (context) {
          final provider = Provider.of<AppearanceChangeProvider>(context, listen: true);
          return MaterialApp(
            title: 'Weather App',
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
