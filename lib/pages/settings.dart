import 'package:flutter/material.dart';
import 'package:weather_app/components/bottom_sheets/multi_option_bottom_sheet.dart';
import 'package:weather_app/components/top_app_bar.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/database/entities/settings_entity.dart';
import 'package:weather_app/extensions/internet.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/res/assets.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/dimens.dart';
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
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  // Hold user settings before apply any change.
  late Settings _currentSettings;
  // If temperature unit changed, the Home page needs to refresh.
  bool _isHomePageNeedsToRefresh = false;
  // If other settings changed, the Home page needs to repaint.
  bool _isHomePageNeedsToRepaint = false;

  @override
  void initState() {
    db = Database();
    userSettings = Settings.get(db);
    _currentSettings = userSettings.copy();
    super.initState();
  }

  // Call when user press back button (TopAppBar/NavigationBar back button)
  void onBackPressed() {}

  // Build item divider.
  Divider _buildDivider(BuildContext context) =>
      Divider(height: 48, thickness: 1, color: _palette.divider, indent: 24, endIndent: 24);

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
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: Dimens.topAppbarHeight + MediaQuery.of(context).viewPadding.top + Dimens.verticalPadding,
                  bottom: Dimens.verticalPadding
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TitleItem(title: _strings.unitsSettingsTitle),
                    _MultiSelectItem(
                      title: _strings.temperatureUnitItemText,
                      text: userSettings.temperatureUnit.text,
                      onPressed: () => _showSelectTemperatureUnitBottomSheet(context),
                      topPadding: 16,
                    ),
                    _MultiSelectItem(
                      title: _strings.windSpeedUnitItemText,
                      text: userSettings.windSpeedUnit.text,
                      onPressed: () => _showSelectWindSpeedUnitBottomSheet(context),
                    ),
                    _MultiSelectItem(
                      title: _strings.visibilityUnitItemText,
                      text: userSettings.visibilityUnit.name,
                      onPressed: () => _showSelectVisibilityUnitBottomSheet(context),
                    ),
                    _buildDivider(context), // --------------------------------------
                  ],
                ),
              )
            ),
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
                bottomBorder: _palette.divider,
                onButtonPressed: onBackPressed
              )
            )
          ],
        ),
      ),
    );
  }

  // MultiOptionBottomSheet creator functions.
  // :: Temperature unit.
  void _showSelectTemperatureUnitBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => MultiOptionBottomSheet(
        title: _strings.temperatureUnitBottomSheetTitle,
        itemTitles: const ['C', 'F'],
        itemSubtitles: _strings.temperatureUnitChoiceSubtitles.split(','),
        selectedItemIndex: userSettings.temperatureUnitIndex,
        cancelButtonText: _strings.cancelButtonText,
        onChange: (index) {
          Internet.check(context, ifConnected: () {
            userSettings.apply(temperatureUnit: index).update(db);
            _isHomePageNeedsToRefresh = (index != _currentSettings.temperatureUnitIndex);
            setState(() {});
          });
        }
      )
    );
  }
  // :: Wind speed unit.
  void _showSelectWindSpeedUnitBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => MultiOptionBottomSheet(
        title: _strings.windSpeedUnitBottomSheetTitle,
        itemTitles: const ['km/h', 'mi/h'],
        itemSubtitles: _strings.windSpeedUnitChoiceSubtitles.split(','),
        selectedItemIndex: userSettings.windSpeedUnitIndex,
        cancelButtonText: _strings.cancelButtonText,
        onChange: (index) {
          userSettings.apply(windSpeedUnit: index).update(db);
          _isHomePageNeedsToRepaint = (index != _currentSettings.windSpeedUnitIndex);
          setState(() {});
        }
      )
    );
  }
  // :: Visibility unit.
  void _showSelectVisibilityUnitBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => MultiOptionBottomSheet(
        title: _strings.visibilityUnitBottomSheetTitle,
        itemTitles: const ['km', 'mi'],
        itemSubtitles: _strings.visibilityUnitChoiceSubtitles.split(','),
        selectedItemIndex: userSettings.visibilityUnitIndex,
        cancelButtonText: _strings.cancelButtonText,
        onChange: (index) {
          userSettings.apply(visibilityUnit: index).update(db);
          _isHomePageNeedsToRepaint = (index != _currentSettings.visibilityUnitIndex);
          setState(() {});
        }
      )
    );
  }
}

// :: Title
class _TitleItem extends StatelessWidget {
  final String title;
  const _TitleItem({Key? key, this.title = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.horizontalPadding),
      child: Text(
        title,
        style: _types.subtitle1!.apply(color: _palette.subtitle)
      ),
    );
  }
}
// :: MultiOption
class _MultiSelectItem extends StatelessWidget {
  final String title;
  final String text;
  final double topPadding;
  final void Function()? onPressed;
  const _MultiSelectItem({
    Key? key,
    this.title = '',
    this.text = '',
    this.topPadding = 0,
    this.onPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, left: 8, right: 8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: _types.subtitle1!.apply(color: _palette.onBackground),
              ),
              Row(
                children: [
                  Text(
                    text,
                    style: _types.subtitle1!.apply(color: _palette.subtitle),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    IconAssets.remixArrowDownFill,
                    width: Dimens.settingsItemsIconSize,
                    height: Dimens.settingsItemsIconSize,
                    color: _palette.subtitle,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
