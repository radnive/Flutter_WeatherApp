import 'package:flutter/material.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/res/assets.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/types.dart';

class Message {
  final BuildContext context;
  const Message(this.context);

  // Create SnackBar.
  SnackBar _createSnackBar({
    required Color color,
    required String icon,
    String title = '',
    String subtitle = '',
    String buttonText = '',
    void Function()? onButtonPressed
  }) {
    // Get onError color.
    final Color onAlertColor = Palette.of(context).onError;

    // Build SnackBar.
    return SnackBar(
      duration: const Duration(days: 1),
      dismissDirection: DismissDirection.horizontal,
      backgroundColor: color,
      padding: (S.of(context).locale == 'en')?
        const EdgeInsets.fromLTRB(12, 8, 0, 8) : const EdgeInsets.fromLTRB(0, 8, 12, 8),
      action: SnackBarAction(
        textColor: onAlertColor,
        disabledTextColor: onAlertColor,
        label: buttonText,
        onPressed: () { if(onButtonPressed != null) onButtonPressed(); }
      ),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            width: 24,
            height: 24,
            color: onAlertColor
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Types.of(context).subtitle2!.apply(color: onAlertColor)
                ),
                Text(
                  subtitle,
                  style: Types.of(context).caption!.apply(color: onAlertColor.withAlpha(150))
                ),
              ],
            ),
          )
        ],
      )
    );
  }

  /// Success message style.
  void s({
    String title = '',
    String subtitle = '',
    String buttonText = '',
    void Function()? onButtonPressed
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      _createSnackBar(
        color: Palette.of(context).success,
        icon: IconAssets.remixCheckDoubleLine,
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed
      )
    );
  }

  /// Info message style.
  void i({
    String title = '',
    String subtitle = '',
    String buttonText = '',
    void Function()? onButtonPressed
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      _createSnackBar(
        color: Palette.of(context).info,
        icon: IconAssets.remixInformationLine,
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed
      )
    );
  }

  /// Warning message style.
  void w({
    String title = '',
    String subtitle = '',
    String buttonText = '',
    void Function()? onButtonPressed
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      _createSnackBar(
        color: Palette.of(context).warning,
        icon: IconAssets.remixAlertLine,
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed
      )
    );
  }

  /// Error message style.
  void e({
    String title = '',
    String subtitle = '',
    String buttonText = '',
    void Function()? onButtonPressed
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      _createSnackBar(
        color: Palette.of(context).error,
        icon: IconAssets.remixCloseCircleLine,
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed
      )
    );
  }

  /// Custom message style.
  void show({
    required Color color,
    required String icon,
    String title = '',
    String subtitle = '',
    String buttonText = '',
    void Function()? onButtonPressed
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      _createSnackBar(
        color: color,
        icon: icon,
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed
      )
    );
  }
}
