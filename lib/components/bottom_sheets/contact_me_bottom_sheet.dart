import 'package:flutter/material.dart';
import 'package:weather_app/components/square_image.dart';
import 'package:weather_app/extensions/internet.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/res/assets.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/dimens.dart';
import 'package:weather_app/res/types.dart';

late ColorScheme _palette;
late TextTheme _types;
late S _strings;

class ContactMeBottomSheet extends StatelessWidget {
  const ContactMeBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get resources.
    _palette = Palette.of(context);
    _types = Types.of(context);
    _strings = S.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(Dimens.horizontalPadding, 32, Dimens.horizontalPadding, 24),
      color: _palette.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _strings.contactMeBottomSheetTitle,
            style: _types.subtitle1!.apply(color: _palette.onBackground)
          ),
          const SizedBox(height: 32),
          _buildItemsRow(context),
          const SizedBox(height: 24),
          FractionallySizedBox(
            widthFactor: 1,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(elevation: 0, primary: _palette.cancelButtonBackground),
              onPressed: () => Navigator.of(context).pop(null),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _strings.cancelButtonText,
                  style: _types.button!.apply(color: _palette.onBackground)
                )
              ),
            ),
          )
        ],
      ),
    );
  }

  Row _buildItemsRow(BuildContext context) {
    List<String> icons = [IconAssets.remixInstagramFill, IconAssets.remixGithubFill, IconAssets.remixDribbbleLine];
    List<String> subtitles = _strings.contactMeChoiceSubtitles.split(',');
    List<String> urls = [
      'https://www.instagram.com/radnive.dev/', // <- Instagram
      'https://github.com/radnive', // <- Github
      'https://dribbble.com/radnive' // <- Dribbble
    ];

    List<Widget> items = [];
    for(int index = 0; index < icons.length; index++) {
      items.add(Expanded(
        child: _SocialMediaItem(
          icon: icons[index],
          subtitle: subtitles[index],
          url: urls[index]
        ),
      ));
      if (index != icons.length - 1) { items.add(const SizedBox(width: 8)); }
    }

    return Row(children: items);
  }
}

class _SocialMediaItem extends StatelessWidget {
  final String icon;
  final String subtitle;
  final String url;
  const _SocialMediaItem({
    Key? key,
    this.icon = '',
    this.subtitle = '',
    required this.url
  }) : super(key: key);

  void _openWebPage(BuildContext context) async {
    Internet.openUrl(context, url: url, onError: () {
      // Dismiss bottomSheet.
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius),
      onTap: () => _openWebPage(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Dimens.verticalPadding),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: _palette.border),
          borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SquareImage.asset(
              icon,
              dimension: 48,
              color: _palette.onBackground,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: _types.caption!.apply(color: _palette.subtitle),
            )
          ],
        ),
      ),
    );
  }
}
