import 'package:flutter/material.dart';

class SquareImage extends StatelessWidget {
  final String image;
  final Color? color;
  final double dimension;
  const SquareImage.asset(this.image, {
    Key? key,
    required this.dimension,
    this.color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: Image.asset(
        image,
        width: dimension,
        height: dimension,
        fit: BoxFit.fill,
        color: color
      )
    );
  }
}
