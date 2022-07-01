import 'dart:math';
import 'package:flutter/material.dart';

enum LinearProgressBarDirection { ltr, rtl }

class LinearProgressBar extends StatelessWidget {
  final double width;
  final double height;
  final double progress;
  final double maxProgress;
  final Color foregroundColor;
  final Color backgroundColor;
  final bool animation;
  final Duration animationDuration;
  final Curve animationCurve;
  final LinearProgressBarDirection direction;
  const LinearProgressBar({
    Key? key,
    this.width = 3,
    this.height = 16,
    this.progress = 0,
    this.maxProgress = 100,
    this.foregroundColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.animation = false,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.animationCurve = Curves.easeOut,
    this.direction = LinearProgressBarDirection.ltr
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double p = _percentageToDistance(progress, max(width, height));

    if (animation) {
      return TweenAnimationBuilder(
          duration: animationDuration,
          curve: animationCurve,
          tween: Tween<double>(begin: 0, end: p),
          builder: (_, double animatedProgress, __) {
            return CustomPaint(
                size: Size(width, height),
                painter: _LinearProgressBarPainter(
                    width: width,
                    height: height,
                    progress: animatedProgress,
                    foregroundColor: foregroundColor,
                    backgroundColor: backgroundColor,
                    direction: direction
                )
            );
          }
      );
    } else {
      return CustomPaint(
          size: Size(width, height),
          painter: _LinearProgressBarPainter(
              width: width,
              height: height,
              progress: p,
              foregroundColor: foregroundColor,
              backgroundColor: backgroundColor,
              direction: direction
          )
      );
    }
  }

  double _percentageToDistance(double p, double distance) => (p * distance) / maxProgress;
}

class _LinearProgressBarPainter extends CustomPainter {
  final double width;
  final double height;
  final double progress;
  final Color foregroundColor;
  final Color backgroundColor;
  final LinearProgressBarDirection direction;
  const _LinearProgressBarPainter({
    required this.width,
    required this.height,
    required this.progress,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.direction
  });

  @override
  void paint(Canvas canvas, Size size) {
    double thickness = min(width, height);

    Paint backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = backgroundColor
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    Paint foregroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = foregroundColor
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    if (width >= height) {
      double start = 0;
      if (direction == LinearProgressBarDirection.ltr) {
        start = 0;
      } else {
        start = size.width;
      }
      canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), backgroundPaint);
      canvas.drawLine(Offset(start, 0), Offset((start - progress).abs(), 0), foregroundPaint);

    } else {
      double start = 0;
      if (direction == LinearProgressBarDirection.rtl) {
        start = 0;
      } else {
        start = size.height;
      }
      canvas.drawLine(const Offset(0, 0), Offset(0, size.height), backgroundPaint);
      canvas.drawLine(Offset(0, start), Offset(0, (start - progress).abs()), foregroundPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
