import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/res/assets.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/dimens.dart';
import 'package:weather_app/res/types.dart';

enum DataRefreshState { pullDown, release, loadData, success, noResponse, error }

class HomePageRefreshIndicator extends StatefulWidget {
  final Widget child;
  final IndicatorController? controller;
  final GlobalKey<CustomRefreshIndicatorState>? indicatorKey;
  final Future<DataRefreshState> Function(BuildContext context) onRefresh;

  const HomePageRefreshIndicator({
    Key? key,
    required this.child,
    this.controller,
    required this.onRefresh,
    this.indicatorKey
  }) : super(key: key);

  @override
  State<HomePageRefreshIndicator> createState() => _HomePageRefreshIndicatorState();
}

class _HomePageRefreshIndicatorState extends State<HomePageRefreshIndicator> {
  double _initialHeight = 22;
  DataRefreshState _indicatorState = DataRefreshState.pullDown;
  
  @override
  Widget build(BuildContext context) {
    // Calculate top padding.
    final double topPadding =
        MediaQuery.of(context).viewPadding.top - Dimens.refreshIndicatorMessageIconSize;

    return CustomRefreshIndicator(
      key: widget.indicatorKey,
      controller: widget.controller,
      offsetToArmed: Dimens.refreshIndicatorOffsetToArmed,
      onRefresh: () => _refreshData(context),
      onStateChanged: _onStateChanged,
      builder: (_, child, controller) => AnimatedBuilder(
        animation: controller,
        child: child,
        builder: (_, childWidget) => Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: _initialHeight + (Dimens.refreshIndicatorOffsetToArmed * controller.value),
              child: _RefreshIndicatorMessage(state: _indicatorState, topPadding: topPadding)
            ),
            Transform.translate(
              offset: Offset(0, Dimens.refreshIndicatorOffsetToArmed * controller.value),
              child: childWidget,
            )
          ],
        ),
      ),
      child: widget.child
    );
  }

  /// This method call when refresh indicator armed.
  Future<void> _refreshData(BuildContext context) async {
    DataRefreshState state;
    state = await widget.onRefresh(context);
    setState(() => _indicatorState = state);
    await Future.delayed(const Duration(seconds: 3));
  }

  /// This method call when refresh indicator state change.
  void _onStateChanged(IndicatorStateChange state) {
    if (state.currentState == IndicatorState.idle) {
      _initialHeight = 22;
      setState(() => _indicatorState = DataRefreshState.pullDown);
    } else if (state.currentState == IndicatorState.dragging && state.newState != IndicatorState.hiding) {
      setState(() => _indicatorState = DataRefreshState.release);
    } else if (state.currentState == IndicatorState.armed) {
      setState(() => _indicatorState = DataRefreshState.loadData);
    } else if (state.currentState == IndicatorState.hiding) {
      _initialHeight = 0;
    }
  }
}

class _RefreshIndicatorMessage extends StatelessWidget {
  final DataRefreshState state;
  final double topPadding;
  const _RefreshIndicatorMessage({
    Key? key,
    this.state = DataRefreshState.pullDown,
    this.topPadding = 0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get resources.
    final palette = Palette.of(context);
    final types = Types.of(context);
    final strings = S.of(context);
    
    Color onBackground;
    Color background;
    String text = '';
    Widget leading;

    switch(state) {
      case DataRefreshState.pullDown:
        onBackground = palette.onBackground;
        background = palette.refreshIndicatorNormalBackground;
        text = strings.refreshIndicatorPullDownMessage;
        leading = Image.asset(
          IconAssets.remixArrowDownCircleLine,
          width: Dimens.refreshIndicatorMessageIconSize,
          height: Dimens.refreshIndicatorMessageIconSize,
          color: onBackground,
        );
        break;

      case DataRefreshState.release:
        onBackground = palette.onBackground;
        background = palette.refreshIndicatorNormalBackground;
        text = strings.refreshIndicatorReleaseMessage;
        leading = Image.asset(
          IconAssets.remixRocketLine,
          width: Dimens.refreshIndicatorMessageIconSize,
          height: Dimens.refreshIndicatorMessageIconSize,
          color: onBackground,
        );
        break;

      case DataRefreshState.loadData:
        onBackground = palette.onBackground;
        background = palette.refreshIndicatorNormalBackground;
        text = strings.refreshIndicatorLoadingState;
        leading = CupertinoActivityIndicator(
          radius: Dimens.refreshIndicatorMessageLoadingIndicatorRadius,
          color: onBackground,
        );
        break;

      case DataRefreshState.success:
        onBackground = palette.background;
        background = palette.success;
        text = strings.refreshIndicatorSuccessMessage;
        leading = Image.asset(
          IconAssets.remixCheckDoubleLine,
          width: Dimens.refreshIndicatorMessageIconSize,
          height: Dimens.refreshIndicatorMessageIconSize,
          color: onBackground,
        );
        break;

      case DataRefreshState.noResponse:
        onBackground = palette.background;
        background = palette.warning;
        text = strings.refreshIndicatorNoResponseMessage;
        leading = Image.asset(
          IconAssets.remixAlertLine,
          width: Dimens.refreshIndicatorMessageIconSize,
          height: Dimens.refreshIndicatorMessageIconSize,
          color: onBackground,
        );
        break;

      case DataRefreshState.error:
        onBackground = palette.background;
        background = palette.error;
        text = strings.refreshIndicatorErrorMessage;
        leading = Image.asset(
          IconAssets.remixCloseCircleLine,
          width: Dimens.refreshIndicatorMessageIconSize,
          height: Dimens.refreshIndicatorMessageIconSize,
          color: onBackground,
        );
        break;
    }

    // Build widget.
    return Container(
      height: Dimens.refreshIndicatorOffsetToArmed,
      color: background,
      padding: EdgeInsets.only(
        top: (topPadding > 0)? topPadding : 0,
        right: Dimens.horizontalPadding,
        left: Dimens.horizontalPadding
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(width: 8),
            Text(
              text,
              style: types.button!.apply(color: onBackground)
            )
          ],
        ),
      ),
    );
  }
}
