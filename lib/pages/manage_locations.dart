import 'package:flutter/material.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/database/entities/settings_entity.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/themes.dart';
import 'package:weather_app/res/types.dart';

late ColorScheme _palette;
late TextTheme _types;
late S _strings;
late Database _db;
late Settings _userSettings;

class ManageLocations extends StatelessWidget {
  const ManageLocations({Key? key}) : super(key: key);

  @override
  StatelessElement createElement() {
    _db = Database();
    _userSettings = Settings.get(_db);
    return super.createElement();
  }

  @override
  Widget build(BuildContext context) {
    // Get resources.
    _palette = Palette.of(context);
    _types = Types.of(context);
    _strings = S.of(context);

    // Build page.
    return Scaffold(
      backgroundColor: _palette.background,
      body: AnnotatedRegion(
        value: Theme.of(context).uiOverlayStyle,
        child: Stack(),
      ),
    );
  }
}
