import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

class ImageWithShadow extends StatelessWidget {
  final double? width;
  final double? height;
  final String src;
  final Color shadowColor;
  final double shadowX;
  final double shadowY;
  final double blurSigma;

  const ImageWithShadow(this.src, {
    Key? key,
    this.width,
    this.height,
    this.shadowColor = Colors.black26,
    this.shadowX = 12,
    this.shadowY = 12,
    this.blurSigma = 6
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: shadowX,
          left: shadowY,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Image.asset(src, fit: BoxFit.cover, color: shadowColor)
          )
        ),
        Positioned.fill(child: Image.asset(src, fit: BoxFit.cover))
      ],
    );
  }
}