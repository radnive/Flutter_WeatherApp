import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/material.dart';
import 'package:weather_app/components/blur_container.dart';
import 'package:weather_app/components/bottom_sheets/contact_me_bottom_sheet.dart';
import 'package:weather_app/components/bottom_sheets/feedback_bottom_sheet.dart';
import 'package:weather_app/components/bottom_sheets/multi_option_bottom_sheet.dart';
import 'package:weather_app/components/top_app_bar.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/database/entities/settings_entity.dart';
import 'package:weather_app/extensions/internet.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/global_keys.dart';
import 'package:weather_app/provider.dart';
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

const String _appVersion = '1.0.0';

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
  void onBackPressed() {
    if(_isHomePageNeedsToRefresh) {
      // Tell Home page to refresh itself.
      homePageGlobalKey.currentState?.refresh();
    } else if(_isHomePageNeedsToRepaint) {
      // Tell Home page to repaint itself.
      homePageGlobalKey.currentState?.update();
    }
    // Navigate to home page.
    widget.navigateTo(AppRoutePath.home());
  }

  // Build item divider.
  Divider _buildDivider() => Divider(height: 48, thickness: 1, color: _palette.divider, indent: 24, endIndent: 24);

  // Build TopAppBar.
  BlurContainer _buildTopAppBar(BuildContext context) => BlurContainer(
    border: Border(bottom: BorderSide(color: _palette.border)),
    padding: EdgeInsets.fromLTRB(
      Dimens.horizontalPadding,
      MediaQuery.of(context).viewPadding.top + Dimens.topAppbarTopPadding,
      Dimens.horizontalPadding,
      Dimens.topAppbarBottomPadding
    ),
    child: TopAppBar.withBackButton(
      title: _strings.settingsTitle,
      titleStyle: _types.headline6!.apply(color: _palette.onBackground),
      subtitle: _strings.settingsSubtitle,
      subtitleStyle: _types.caption!.apply(color: _palette.subtitle),
      buttonBorder: _palette.border,
      buttonIconColor: _palette.onBackground,
      ltr: _strings.locale == 'en',
      onButtonPressed: onBackPressed
    )
  );

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
                      text: userSettings.getTemperatureUnit.text,
                      onPressed: () => _showSelectTemperatureUnitBottomSheet(context),
                      topPadding: 16,
                    ),
                    _MultiSelectItem(
                      title: _strings.windSpeedUnitItemText,
                      text: userSettings.getWindSpeedUnit.text,
                      onPressed: () => _showSelectWindSpeedUnitBottomSheet(context),
                    ),
                    _MultiSelectItem(
                      title: _strings.visibilityUnitItemText,
                      text: userSettings.getVisibilityUnit.name,
                      onPressed: () => _showSelectVisibilityUnitBottomSheet(context),
                    ),
                    _buildDivider(), // --------------------------------------
                    _TitleItem(title: _strings.otherSettingsTitle),
                    _MultiSelectItem(
                      title: _strings.languageItemText,
                      text: _strings.languagesChoiceTitles.split(',')[userSettings.language],
                      topPadding: 16,
                      onPressed: () => _showSelectLanguageBottomSheet(context),
                    ),
                    _MultiSelectItem(
                      title: _strings.themeItemText,
                      text: _strings.themeChoiceTitles.split(',')[userSettings.themeMode],
                      onPressed: () => _showSelectThemeBottomSheet(context),
                    ),
                    _SwitchItem(
                        title: _strings.autoUpdateItemText,
                        firstValue: Settings.get(db).autoUpdate,
                        onChanged: (isOn) => userSettings.apply(autoUpdate: isOn).update(db)
                    ),
                    _buildDivider(), // --------------------------------------
                    _TitleItem(title: _strings.communicationSettingsTitle),
                    _ChevronSettingItem(
                      title: _strings.feedbackItemText,
                      topPadding: 16,
                      onPressed: () => _showFeedbackBottomSheet(context)
                    ),
                    _ChevronSettingItem(
                      title: _strings.contactMeItemText,
                      onPressed: () => _showContactMeBottomSheet(context)
                    ),
                    _buildDivider(), // --------------------------------------
                    _TitleItem(title: _strings.aboutTitle),
                    _TextSettingItem(
                        title: _strings.appVersionItemText,
                        text: _appVersion,
                        topPadding: 16
                    ),
                    _TextSettingItem(
                        title: _strings.developerItemText,
                        text: _strings.developerName
                    ),
                    _TextSettingItem(
                        title: _strings.weatherDataProviderItemText,
                        text: 'AccuWeather'
                    ),
                    _TextSettingItem(
                        title: _strings.sunStatusDataProviderItemText,
                        text: 'IPGeolocation'
                    ),
                    _ChevronSettingItem(
                      title: _strings.privacyPolicyItemText,
                      topPadding: 8
                    )
                  ],
                ),
              )
            ),
            Positioned(
              top: 0, left: 0, right: 0,
              child: _buildTopAppBar(context)
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
        selectedItemIndex: userSettings.temperatureUnit,
        cancelButtonText: _strings.cancelButtonText,
        onChange: (index) {
          Internet.check(context, ifConnected: () {
            userSettings.apply(temperatureUnit: index).update(db);
            _isHomePageNeedsToRefresh = (index != _currentSettings.temperatureUnit);
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
        selectedItemIndex: userSettings.windSpeedUnit,
        cancelButtonText: _strings.cancelButtonText,
        onChange: (index) {
          userSettings.apply(windSpeedUnit: index).update(db);
          _isHomePageNeedsToRepaint = (index != _currentSettings.windSpeedUnit);
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
        selectedItemIndex: userSettings.visibilityUnit,
        cancelButtonText: _strings.cancelButtonText,
        onChange: (index) {
          userSettings.apply(visibilityUnit: index).update(db);
          _isHomePageNeedsToRepaint = (index != _currentSettings.visibilityUnit);
          setState(() {});
        }
      )
    );
  }
  // :: Language
  void _showSelectLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) => MultiOptionBottomSheet(
          title: _strings.languageBottomSheetTitle,
          itemTitles: _strings.languagesChoiceTitles.split(','),
          itemSubtitles: _strings.languagesChoiceSubtitles.split(','),
          selectedItemIndex: userSettings.language,
          cancelButtonText: _strings.cancelButtonText,
          onChange: (index) {
            userSettings.apply(language: index).update(db);
            context.appearanceProvider.setLanguage(Language.get(index));
            _isHomePageNeedsToRefresh = (index != _currentSettings.language);
            setState(() {});
          }
        )
    );
  }
  // :: Theme
  void _showSelectThemeBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) => MultiOptionBottomSheet(
            title: _strings.themeBottomSheetTitle,
            itemTitles: _strings.themeChoiceTitles.split(','),
            itemSubtitles: _strings.themeChoiceSubtitles.split(','),
            selectedItemIndex: userSettings.themeMode,
            cancelButtonText: _strings.cancelButtonText,
            onChange: (index) {
              userSettings.apply(themeMode: index).update(db);
              context.appearanceProvider.setThemeMode(ThemeMode.values[index]);
              setState(() {});
            }
        )
    );
  }
  // :: Feedback bottom sheet.
  void _showFeedbackBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => const FeedBackBottomSheet()
    );
  }
  // :: Contact me bottom sheet.
  void _showContactMeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => const ContactMeBottomSheet()
    );
  }
}

// Setting items.
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

// :: Switch
class _SwitchItem extends StatefulWidget {
  final String title;
  final bool firstValue;
  final void Function(bool value)? onChanged;
  const _SwitchItem({
    Key? key,
    this.title = '',
    this.firstValue = false,
    this.onChanged
  }) : super(key: key);

  @override
  State<_SwitchItem> createState() => _SwitchItemState();
}

class _SwitchItemState extends State<_SwitchItem> {
  late bool _isActive;
  @override
  void initState() {
    _isActive = widget.firstValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: _types.subtitle1!.apply(color: _palette.onBackground),
          ),
          CupertinoSwitch(
            value: _isActive,
            onChanged: (bool newValue){
              if(widget.onChanged != null) { widget.onChanged!(newValue); }
              setState(() => _isActive = newValue);
            },
            activeColor: _palette.primary,
            trackColor: _palette.subtitle,
          )
        ],
      ),
    );
  }
}

// :: Chevron
class _ChevronSettingItem extends StatelessWidget {
  final String title;
  final double topPadding;
  final void Function()? onPressed;
  const _ChevronSettingItem({Key? key, this.title = '', this.topPadding = 0, this.onPressed}) : super(key: key);

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
              Image.asset(
                (_strings.locale == 'en')? IconAssets.remixRightArrow : IconAssets.remixLeftArrow,
                width: Dimens.settingsItemsIconSize,
                height: Dimens.settingsItemsIconSize,
                color: _palette.subtitle,
              )
            ],
          ),
        ),
      ),
    );
  }
}

// :: Text
class _TextSettingItem extends StatelessWidget {
  final String title;
  final String text;
  final double topPadding;
  const _TextSettingItem({
    Key? key,
    this.title = '',
    this.text = '',
    this.topPadding = 0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: _types.subtitle1!.apply(color: _palette.onBackground),
            ),
          ),
          Text(
            text,
            style: _types.subtitle1!.apply(color: _palette.subtitle),
          )
        ],
      ),
    );
  }
}