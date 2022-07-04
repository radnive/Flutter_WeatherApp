import 'dart:math';
import 'package:flutter/material.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/res/assets.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/themes.dart';
import 'package:weather_app/res/types.dart';
import 'package:weather_app/router.dart' show AppRoutePath;

late ColorScheme _palette;
late TextTheme _types;
late S _strings;

class StartPage extends StatelessWidget {
  final void Function(AppRoutePath routePath) navigateTo;
  const StartPage({Key? key, required this.navigateTo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get resources.
    _palette = Palette.of(context);
    _types = Types.of(context);
    _strings = S.of(context);

    // Create page.
    return Scaffold(
      backgroundColor: _palette.skyBlueColor,
      body: AnnotatedRegion(
        value: Theme.of(context).uiOverlayStyle.copyWith(
          systemNavigationBarColor: _palette.skyBlueColor
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _strings.introPageText,
                      textAlign: TextAlign.start,
                      style: _types.introPageText.apply(color: Palette.white),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => navigateTo(AppRoutePath.manageLocations()),
                      style: ElevatedButton.styleFrom(primary: Palette.white),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        child: Text(
                          _strings.introPageGetStartedButtonText,
                          style: _types.button!.apply(color: Palette.darkBlue),
                        ),
                      ),
                    )
                  ]
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY((_strings.locale == 'en')? 0 : pi),
                child: Image.asset(ImageAssets.amsterdam, fit: BoxFit.cover)
              ),
            )
          ]
        )
      ),
    );
  }
}
