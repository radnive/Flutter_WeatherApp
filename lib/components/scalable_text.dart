import 'package:flutter/material.dart';

class ScalableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double leftPadding;
  final double rightPadding;
  const ScalableText(this.text, {
    Key? key,
    this.style,
    this.leftPadding = 0,
    this.rightPadding = 0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(width: leftPadding),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(text, style: style, maxLines: 1, textAlign: TextAlign.start)
          )
        ),
        SizedBox(width: rightPadding)
      ]
    );
  }
}
