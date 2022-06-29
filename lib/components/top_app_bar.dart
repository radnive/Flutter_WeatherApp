import 'package:flutter/material.dart';
import 'package:weather_app/components/square_image.dart';
import 'package:weather_app/res/assets.dart';
import 'package:weather_app/res/dimens.dart';

class TopAppBar {

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
