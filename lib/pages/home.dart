import 'package:flutter/material.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/database/entities/settings_entity.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/themes.dart';
import 'package:weather_app/res/types.dart';
import 'package:weather_app/router.dart';

late Database _db;
late Settings _userSettings;
late ColorScheme _palette;
late TextTheme _types;
late S _strings;

class HomePage extends StatefulWidget {
  final void Function(AppRoutePath routePath) navigateTo;
  final void Function(bool isDisabled) changeBackButtonStatus;
  const HomePage({
    Key? key,
    required this.navigateTo,
    required this.changeBackButtonStatus
  }) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    _db = Database();
    _userSettings = Settings.get(_db);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get resources.
    _palette = Palette.of(context);
    _types = Types.of(context);
    _strings = S.of(context);

    return Scaffold(
      backgroundColor: _palette.background,
      body: AnnotatedRegion(
      value: Theme.of(context).uiOverlayStyle,
        child: Stack()
      )
    );
  }
}
