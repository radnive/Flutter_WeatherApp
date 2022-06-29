import 'package:flutter/material.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/dimens.dart';
import 'package:weather_app/res/types.dart';

late ColorScheme _palette;
late TextTheme _types;

class MultiOptionBottomSheet extends StatefulWidget {
  final String title;
  final List<String> itemTitles;
  final List<String> itemSubtitles;
  final void Function(int index)? onChange;
  final int selectedItemIndex;
  final String cancelButtonText;

  const MultiOptionBottomSheet({
    Key? key,
    this.title = '',
    required this.itemTitles,
    required this.itemSubtitles,
    required this.selectedItemIndex,
    this.onChange,
    this.cancelButtonText = ''
  }) : assert(itemTitles.length == itemSubtitles.length), super(key: key);

  @override
  State<MultiOptionBottomSheet> createState() => _MultiOptionBottomSheetState();
}

class _MultiOptionBottomSheetState extends State<MultiOptionBottomSheet> {
  late int _selectedItemIndex;
  @override
  void initState() {
    _selectedItemIndex = widget.selectedItemIndex;
    super.initState();
  }

  // Build items Row.
  Row _buildChoiceItemsRow(BuildContext context) {
    List<Widget> items = [];
    for(int index = 0; index < widget.itemTitles.length; index++) {
      items.add(Expanded(
        child: _ChoiceItem(
          title: widget.itemTitles[index],
          subtitle: widget.itemSubtitles[index],
          isSelected: index == _selectedItemIndex,
          onPressed: () {
            if (index != widget.selectedItemIndex) {
              setState(() => _selectedItemIndex = index);
              widget.onChange!(index);
            }
            Future.delayed(
              const Duration(milliseconds: 100),
              () => Navigator.of(context).pop(index)
            );
          },
        ),
      ));
      if (index != widget.itemTitles.length - 1) {
        items.add(const SizedBox(width: 8));
      }
    }
    return Row(children: items);
  }

  @override
  Widget build(BuildContext context) {
    // Get resources.
    _palette = Palette.of(context);
    _types = Types.of(context);

    return Container(
      color: _palette.background,
      padding: const EdgeInsets.fromLTRB(Dimens.horizontalPadding, 32, Dimens.horizontalPadding, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title, style: _types.subtitle1!.apply(color: _palette.onBackground)),
          const SizedBox(height: 32),
          _buildChoiceItemsRow(context),
          const SizedBox(height: 24),
          FractionallySizedBox(
            widthFactor: 1,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(elevation: 0, primary: _palette.cancelButtonBackground),
              onPressed: () => Navigator.of(context).pop(null),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(widget.cancelButtonText, style: _types.button!.apply(color: _palette.onBackground))
              ),
            ),
          )
        ]
      ),
    );
  }
}

class _ChoiceItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final void Function()? onPressed;
  const _ChoiceItem({
    Key? key,
    this.title = '',
    this.subtitle = '',
    this.isSelected = false,
    this.onPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: (isSelected)? _palette.primary : Colors.transparent,
          border: (isSelected)? null : Border.all(color: _palette.border),
          borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: _types.multiSelectItemText.apply(
                color: (isSelected)? _palette.onPrimary : _palette.subtitle
              ),
            ),
            Text(
              subtitle,
              style: _types.caption!.apply(
                color: (isSelected)? _palette.onPrimarySubtitle : _palette.subtitle
              ),
            )
          ],
        ),
      ),
    );
  }
}
