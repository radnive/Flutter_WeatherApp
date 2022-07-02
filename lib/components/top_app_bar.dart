import 'package:flutter/material.dart';
import 'package:weather_app/components/square_image.dart';
import 'package:weather_app/res/assets.dart';
import 'package:weather_app/res/dimens.dart';

class TopAppBar {
  /// Build [TopAppBar] with location info and two button.
  /// One to go to the [SettingsPage] and the other to go to the [ManageLocations].
  static Row main({
    String title = '',
    required TextStyle titleStyle,
    String subtitle = '',
    required TextStyle subtitleStyle,
    Color buttonBorder = Colors.black,
    Color? buttonIconColor,
    bool ltr = true,
    void Function()? onSettingsButtonPressed,
    void Function()? onManageLocationsButtonPressed
  }) {
    return Row(
      children: [
        Expanded(
          flex: 12,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: (ltr)? 5 : 0),
                child: Image.asset(
                  IconAssets.remixMapPin,
                  width: Dimens.topAppbarIconSize,
                  height: Dimens.topAppbarIconSize,
                  color: titleStyle.color
                ),
              ),
              const SizedBox(width: 5),
              Expanded(child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(subtitle, style: subtitleStyle, maxLines: 1, overflow: TextOverflow.ellipsis)
                ],
              )),
            ],
          ),
        ),
        Expanded(
          flex: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: onManageLocationsButtonPressed,
                child: Container(
                  width: Dimens.topAppbarButtonSize,
                  height: Dimens.topAppbarButtonSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius),
                    border: Border.all(color: buttonBorder)
                  ),
                  child: Image.asset(
                    IconAssets.remixCompass,
                    width: Dimens.topAppbarButtonIconSize,
                    height: Dimens.topAppbarButtonIconSize,
                    color: buttonIconColor
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onSettingsButtonPressed,
                child: Container(
                  width: Dimens.topAppbarButtonSize,
                  height: Dimens.topAppbarButtonSize,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius),
                      border: Border.all(color: buttonBorder)
                  ),
                  child: Image.asset(
                    IconAssets.remixSettings,
                    width: Dimens.topAppbarButtonIconSize,
                    height: Dimens.topAppbarButtonIconSize,
                    color: buttonIconColor
                  )
                )
              )
            ],
          ),
        )
      ],
    );
  }

  /// Build [TopAppBar] with only back button.
  /// This type of app bar use in [SettingsPage] and [ManageLocations].
  static Row withBackButton({
    String title = '',
    required TextStyle titleStyle,
    String subtitle = '',
    required TextStyle subtitleStyle,
    Color buttonBorder = Colors.black,
    Color? buttonIconColor,
    bool ltr = true,
    void Function()? onButtonPressed
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onButtonPressed,
          borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius),
          child: Container(
            width: Dimens.topAppbarButtonSize,
            height: Dimens.topAppbarButtonSize,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius),
                border: Border.all(color: buttonBorder)
            ),
            child: Center(
              child: SquareImage.asset(
                (ltr)? IconAssets.remixLeftArrow : IconAssets.remixRightArrow,
                dimension: Dimens.topAppbarButtonIconSize,
                color: buttonIconColor
              ),
            )
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: titleStyle),
            Text(subtitle, style: subtitleStyle)
          ]
        ),
        const SizedBox.square(dimension: Dimens.topAppbarButtonSize)
      ]
    );
  }
}
