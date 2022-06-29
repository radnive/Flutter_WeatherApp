import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/res/dimens.dart';

class BlurContainer extends StatelessWidget {
  final double blurSigma;
  final Color? color;
  final BoxBorder? border;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  const BlurContainer({
    Key? key,
    this.blurSigma = Dimens.blurContainerSigma,
    this.color,
    this.border,
    this.padding,
    this.child
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(color: color, border: border),
          child: child,
        ),
      ),
    );
  }
}
