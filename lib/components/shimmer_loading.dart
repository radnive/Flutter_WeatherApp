import 'package:flutter/material.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/dimens.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget? child;
  final Duration duration;
  const ShimmerLoading({
    Key? key,
    this.child,
    this.duration = const Duration(milliseconds: 700)
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> gradientAnim;

  @override
  void initState() {
    animationController = AnimationController(
      duration: widget.duration,
      vsync: this
    );
    gradientAnim = Tween<double>(begin: -0.5, end: 1.5).animate(animationController);
    animationController
      ..forward()
      ..addListener(() { if(animationController.isCompleted) animationController.repeat(); });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get colors resource.
    final palette = Palette.of(context);

    return AnimatedBuilder(
        animation: animationController,
        builder: (_, __) => ShaderMask(
          blendMode: BlendMode.srcATop,
          child: widget.child,
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              palette.border,
              palette.divider,
              palette.border
            ],
            stops: const [.1, .3, .4],
            begin: const Alignment(-1.0, -0.3),
            end: const Alignment(1.0, 0.3),
            tileMode: TileMode.clamp,
            transform: _SlidingGradiantTransform(slidePercent: gradientAnim.value)
          ).createShader(bounds),
        )
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class _SlidingGradiantTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradiantTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
}

/// Create simple container for shimmer loading.
class ShimmerContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Color color;
  const ShimmerContainer({
    Key? key,
    this.width,
    this.height,
    this.color = Colors.white
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Dimens.smallShapesBorderRadius)
      )
    );
  }
}
