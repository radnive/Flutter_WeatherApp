import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:weather_app/components/blur_container.dart';
import 'package:weather_app/components/square_image.dart';
import 'package:weather_app/components/top_app_bar.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/database/entities/settings_entity.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/res/assets.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/dimens.dart';
import 'package:weather_app/res/themes.dart';
import 'package:weather_app/res/types.dart';
import 'package:weather_app/router.dart';

late ColorScheme _palette;
late TextTheme _types;
late S _strings;
late Database _db;
late Settings _userSettings;

late final TextEditingController _searchTextFieldController;

class ManageLocations extends StatelessWidget {
  final void Function(AppRoutePath routePath) navigateTo;
  final void Function(bool isDisabled) changeBackButtonStatus;
  final GlobalKey<TopAppBarState>? appBarKey;
  const ManageLocations({
    Key? key,
    this.appBarKey,
    required this.navigateTo,
    required this.changeBackButtonStatus
  }) : super(key: key);

  @override
  StatelessElement createElement() {
    _db = Database();
    _userSettings = Settings.get(_db);
    _searchTextFieldController = TextEditingController();
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
        child: Stack(
          children: [
            Positioned(
              top: 0, left: 0, right: 0,
              child: _TopAppBar(
                key: appBarKey,
                navigateTo: navigateTo,
                changeBackButtonStatus: changeBackButtonStatus
              )
            )
          ],
        ),
      ),
    );
  }
}

class _TopAppBar extends StatefulWidget {
  final void Function(AppRoutePath routePath) navigateTo;
  final void Function(bool isDisabled) changeBackButtonStatus;
  const _TopAppBar({
    Key? key,
    required this.navigateTo,
    required this.changeBackButtonStatus
  }) : super(key: key);

  @override
  State<_TopAppBar> createState() => TopAppBarState();
}

class TopAppBarState extends State<_TopAppBar> {
  bool _isCollapsed = false;
  bool _isOnError = false;
  bool _isOnLoadUserLocation = false;

  // Call when back button pressed. (TopAppBar/NavigationBar back button)
  void onBackPressed() {
    if(_isCollapsed) {
      setState(() => _isCollapsed = false);
    }
  }

  // Build TopAppBar.
  AnimatedSize _buildTopAppBar() => AnimatedSize(
    duration: const Duration(milliseconds: 200),
    reverseDuration: const Duration(milliseconds: 200),
    curve: Curves.fastOutSlowIn,
    child: SizedBox(
      height: (_isCollapsed)? 0 : null,
      child: Padding(
        padding: const EdgeInsets.only(top: Dimens.topAppbarTopPadding),
        child: TopAppBar.withBackButton(
          title: _strings.manageCitiesTitle,
          titleStyle: _types.headline6!.apply(color: _palette.onBackground),
          subtitle: _strings.manageCitiesSubtitle,
          subtitleStyle: _types.caption!.apply(color: _palette.subtitle),
          buttonBorder: _palette.border,
          buttonIconColor: _palette.onBackground,
          ltr: _strings.locale == 'en',
          onButtonPressed: onBackPressed
        )
      )
    )
  );

  // Build SearchBox widget.
  // :: Build primary button icon.
  Widget _getPrimaryButtonIcon() {
    if(_isOnLoadUserLocation) {
      return CupertinoActivityIndicator(color: _palette.onPrimarySubtitle);
    } else {
      return SquareImage.asset(
        (_isCollapsed)? IconAssets.remixSearch : IconAssets.remixLocation,
        dimension: Dimens.searchBoxIconsSize,
        color: _palette.onPrimary
      );
    }
  }
  // :: Build primary button widget.
  InkWell _buildPrimaryButton() => InkWell(
    onTap: () {
      if(!_isOnLoadUserLocation) {
        // TODO Search location.
        setState(() => _isOnLoadUserLocation = true);
      } else {
        // TODO Get user location.
      }
    },
    borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius),
    child: Container(
      margin: const EdgeInsets.all(5),
      width: Dimens.searchBoxButtonSize,
      height: Dimens.searchBoxButtonSize,
      decoration: BoxDecoration(
        color: _palette.primary,
        borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius)
      ),
      child: _getPrimaryButtonIcon(),
    ),
  );

  // :: Build textField.
  TextField _buildTextField() => TextField(
    controller: _searchTextFieldController,
    style: _types.subtitle1!.apply(color: _palette.onBackground),
    onTap: () {
      widget.changeBackButtonStatus(true);
      // TODO Go to PopularLocationsList
      setState(() => _isCollapsed = true);
    },
    onChanged: (text) {
      if(_isOnError && text.isNotEmpty) {
        setState(() => _isOnError = false);
      }
    },
    onSubmitted: (text) {
      if(text.isEmpty) {
        // TODO Show error message.
        setState(() => _isOnError = true);
      } else {
        // TODO Go to SearchResultList.
        // TODO Send text query to SearchResultList widget.
      }
    },
    decoration: InputDecoration(
      hintText: _strings.searchCityTextFieldHint,
      hintStyle: _types.subtitle1!.apply(color: _palette.divider),
      border: const OutlineInputBorder(borderSide: BorderSide.none),
      fillColor: Colors.transparent,
      contentPadding: (_strings.locale == 'en')?
        const EdgeInsets.only(left: 16, right: 3) :
        const EdgeInsets.only(left: 3, right: 8),
      prefixIcon: (_isCollapsed)? null : Image.asset(
        IconAssets.remixSearch,
        width: Dimens.searchBoxIconsSize,
        height: Dimens.searchBoxIconsSize,
        color: _palette.onBackground
      )
    ),
  );
  // :: Build SearchBox.
  Container _buildSearchBox() => Container(
    decoration: BoxDecoration(
      color: _palette.textFieldBackground,
      borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius),
      border: Border.all(color: (_isOnError)? _palette.error : Colors.transparent)
    ),
    child: Row(
      children: [
        Expanded(child: _buildTextField()),
        _buildPrimaryButton()
      ],
    ),
  );

  // :: Build back button.
  AnimatedSize _buildBackButton(BuildContext context) => AnimatedSize(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
      child: SizedBox(
        width: (_isCollapsed)? null : 0,
        child: InkWell(
          onTap: onBackPressed,
          child: Container(
            margin: (_strings.locale == 'en')?
              const EdgeInsets.only(right: 8) :
              const EdgeInsets.only(left: 8),
            width: Dimens.searchBoxBackButtonSize,
            height: Dimens.searchBoxBackButtonSize,
            decoration: BoxDecoration(
              color: _palette.textFieldBackground,
              borderRadius: BorderRadius.circular(24)
            ),
            child: SquareImage.asset(
              (_strings.locale == 'en')? IconAssets.remixLeftArrow : IconAssets.remixRightArrow,
              dimension: Dimens.searchBoxBackButtonIconSize,
              color: _palette.onBackground,
            ),
          ),
        )
      )
  );

  @override
  Widget build(BuildContext context) {
    return BlurContainer(
      border: Border(bottom: BorderSide(color: _palette.border)),
      padding: EdgeInsets.fromLTRB(
        Dimens.horizontalPadding,
        MediaQuery.of(context).viewPadding.top,
        Dimens.horizontalPadding,
        Dimens.topAppbarBottomPadding
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTopAppBar(),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildBackButton(context),
              Expanded(child: _buildSearchBox())
            ],
          )
        ]
      )
    );
  }
}
