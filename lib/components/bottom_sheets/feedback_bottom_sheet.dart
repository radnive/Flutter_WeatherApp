import 'package:flutter/material.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/res/assets.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/dimens.dart';
import 'package:weather_app/res/types.dart';

late ColorScheme _palette;
late TextTheme _types;
late S _strings;

class FeedBackBottomSheet extends StatefulWidget {
  const FeedBackBottomSheet({Key? key}) : super(key: key);

  @override
  State<FeedBackBottomSheet> createState() => _FeedBackBottomSheetState();
}

class _FeedBackBottomSheetState extends State<FeedBackBottomSheet> {
  int selectedIconIndex = -1;
  String selectedIconSrc = '';

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
            _strings.feedbackBottomSheetTitle,
            style: _types.subtitle1!.apply(color: _palette.onBackground)
          ),
          const SizedBox(height: 48),
          _buildEmojisRow(context),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(elevation: 0, primary: _palette.cancelButtonBackground),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _strings.cancelButtonText,
                      style: _types.button!.apply(color: _palette.onBackground)
                    )
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(elevation: 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _strings.submitButtonText,
                      style: _types.button!.apply(color: _palette.onPrimary)
                    )
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Row _buildEmojisRow(BuildContext context) {
    List <Widget> items = [];
    for (int index = 0; index < ImageAssets.emojiIcons.length; index++) {
      items.add(Expanded(
        child: _EmojiIconItem(
          icon: (selectedIconSrc.isNotEmpty && index <= selectedIconIndex)? selectedIconSrc : ImageAssets.emojiIcons[index],
          isEnabled: index <= selectedIconIndex,
          onPressed: () {
            selectedIconIndex = index;
            selectedIconSrc = ImageAssets.emojiIcons[index];
            setState(() {});
          },
        ),
      ));

      if(index != ImageAssets.emojiIcons.length -1 ) {
        items.add(const SizedBox(width: 16));
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items,
    );
  }
}

class _EmojiIconItem extends StatelessWidget {
  final String icon;
  final bool isEnabled;
  final void Function()? onPressed;
  const _EmojiIconItem({Key? key, required this.icon, required this.isEnabled, this.onPressed}) : super(key: key);

  final ColorFilter colorFilter = const ColorFilter.matrix(<double>[
    0.2126,0.7152,0.0722,0,0,
    0.2126,0.7152,0.0722,0,0,
    0.2126,0.7152,0.0722,0,0,
    0,0,0,1,0,
  ]);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius),
        onTap: onPressed,
        child: ColorFiltered(
          colorFilter: (isEnabled)? const ColorFilter.mode(Colors.transparent, BlendMode.multiply) : colorFilter,
          child: Image.asset(icon, fit: BoxFit.fill)
        )
      ),
    );
  }
}
