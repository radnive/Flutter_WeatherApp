class Dimens {
  // :: Main
  static const double horizontalPadding = 24;
  static const double verticalPadding = 40;
  static const double smallShapesBorderRadius = 3;
  static const double mediumShapesBorderRadius = 7;

  // :: TopAppBar
  static const double topAppbarTopPadding = 24;
  static const double topAppbarBottomPadding = 32;
  static const double topAppbarButtonSize = 40;
  static const double topAppbarIconSize = 22;
  static const double topAppbarButtonIconSize = 24;
  static const double topAppbarHeight = (topAppbarButtonSize + topAppbarTopPadding + topAppbarBottomPadding);
  static const double appbarHeightWithChild = (topAppbarHeight + searchBoxBackButtonSize + topAppbarTopPadding + 14);
  static const double appbarHeightWithOnlySearchBox = (searchBoxBackButtonSize + topAppbarTopPadding + topAppbarBottomPadding);

  // :: BlurContainer
  static const double blurContainerSigma = 5;

  // :: Home page.
  static const double sliverAppbarFullHeight = 480;
  static const double weatherConditionsInfoIconSize = 24;
  static const double weatherInfoDividerSize = 24;
  static const double hourlyWeatherIconSize = 24;
  static const double sunStatusIconSize = 32;

  // :: HomePageRefreshIndicator
  static const double refreshIndicatorOffsetToArmed = 136;
  static const double refreshIndicatorMessageIconSize = 22;
  static const double refreshIndicatorMessageLoadingIndicatorRadius = 10;

  // :: Settings page.
  static const double settingsItemsIconSize = 22;

  // :: ManageLocations page.
  static const double searchBoxIconsSize = 22;
  static const double searchBoxButtonSize = 42;
  static const double searchBoxBackButtonSize = 47;
  static const double searchBoxBackButtonIconSize = 32;
}