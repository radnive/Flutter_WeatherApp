import 'package:flutter/material.dart';

class SquareImage extends StatelessWidget {
  final String image;
  final Color? color;
  final double dimension;
  final Alignment alignment;
  const SquareImage.asset(this.image, {
    Key? key,
    required this.dimension,
    this.alignment = Alignment.center,
    this.color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: SizedBox.square(
        dimension: dimension,
        child: Image.asset(
          image,
          width: dimension,
          height: dimension,
          fit: BoxFit.fill,
          color: color
        )
      ),
    );
  }
}
