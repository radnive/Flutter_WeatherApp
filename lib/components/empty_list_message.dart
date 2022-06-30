import 'package:flutter/material.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/res/assets.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/dimens.dart';
import 'package:weather_app/res/types.dart';

late ColorScheme _palette;
late TextTheme _types;
late S _strings;

class EmptyListMessage extends StatelessWidget {
  final bool useEmptyIcon;
  final double topPadding;
  const EmptyListMessage.empty({Key? key, this.topPadding = Dimens.appbarHeightWithChild}) : useEmptyIcon = true, super(key: key);
  const EmptyListMessage.notFound({Key? key, this.topPadding = Dimens.appbarHeightWithOnlySearchBox}) : useEmptyIcon = false, super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get resources.
    _palette = Palette.of(context);
    _types = Types.of(context);
    _strings = S.of(context);
    
    // Hold message data.
    String image;
    String titleText;
    String subtitleText;

    // Set message data.
    if (useEmptyIcon) {
      image = (_palette.isOnLightMode)? ImageAssets.lightEmptyList : ImageAssets.darkEmptyList;
      titleText = _strings.emptyListMessageTitle;
      subtitleText = _strings.emptyListMessageSubtitle;
    } else {
      image = (_palette.isOnLightMode)? ImageAssets.lightNotFound : ImageAssets.darkNotFound;
      titleText = _strings.locationNotFoundMessageTitle;
      subtitleText = _strings.locationNotFoundMessageSubtitle;
    }

    return Container(
      padding: EdgeInsets.only(
        left: 40, right: 40,
        top: topPadding + MediaQuery.of(context).viewPadding.top
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FractionallySizedBox(
              widthFactor: 0.5,
              child: AspectRatio(aspectRatio: 1, child: Image.asset(image, fit: BoxFit.fill)),
            ),
            const SizedBox(height: 16),
            Text(
              titleText,
              style: _types.messageTitle.apply(color: _palette.subtitle)
            ),
            const SizedBox(height: 5),
            Text(
              subtitleText,
              style: _types.caption!.apply(color: _palette.subtitle)
            )
          ],
        ),
      ),
    );
  }
}