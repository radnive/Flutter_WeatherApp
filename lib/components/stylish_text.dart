import 'package:flutter/material.dart';

class StylishText extends StatelessWidget {
  final String text, sub, sup;
  final TextStyle style;
  const StylishText({
    Key? key,
    this.text = '',
    this.sub = '',
    this.sup = '',
    required this.style
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double supAndSubY = (style.fontSize != null)? (style.fontSize! / 3) : 4;
    return RichText(
      textDirection: TextDirection.ltr,
      text: TextSpan(children: [
        TextSpan(text: text, style: style),
        (sub.isEmpty)? const TextSpan() : WidgetSpan(
          child: Transform.translate(
            offset: Offset(1, supAndSubY),
            child: Text(
              sub,
              textDirection: TextDirection.ltr,
              textScaleFactor: 0.7,
              style: style
            ),
          ),
        ),
        (sup.isEmpty)? const TextSpan() : WidgetSpan(
          child: Transform.translate(
            offset: Offset(1, -supAndSubY),
            child: Text(
              sup,
              textScaleFactor: 0.7,
              textDirection: TextDirection.ltr,
              style: style
            ),
          ),
        ),
      ])
    );
  }
}