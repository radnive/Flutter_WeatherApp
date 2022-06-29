import 'package:flutter/material.dart';
import 'package:weather_app/components/top_app_bar.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/database/entities/settings_entity.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/themes.dart';
import 'package:weather_app/res/types.dart';
import 'package:weather_app/router.dart';

late Database db;
late Settings userSettings;
late ColorScheme _palette;
late TextTheme _types;
late S _strings;

class SettingsPage extends StatefulWidget {
  final void Function(AppRoutePath routePath) navigateTo;
  final void Function(bool isDisabled) changeBackButtonStatus;
  const SettingsPage({
    Key? key,
    required this.navigateTo,
    required this.changeBackButtonStatus
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    db = Database();
    userSettings = Settings.get(db);
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
        child: Stack(
          children: [
            Positioned(
              top: 0, left: 0, right: 0,
              child: TopAppBar.withBackButton(
                context,
                title: _strings.settingsTitle,
                titleStyle: _types.headline6!.apply(color: _palette.onBackground),
                subtitle: _strings.settingsSubtitle,
                subtitleStyle: _types.caption!.apply(color: _palette.subtitle),
                buttonBorder: _palette.border,
                buttonIconColor: _palette.onBackground,
                bottomBorder: _palette.divider
              )
            )
          ],
        ),
      ),
    );
  }
}
