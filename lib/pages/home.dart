import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/components/blur_container.dart';
import 'package:weather_app/components/home_page_refresh_indicator.dart';
import 'package:weather_app/components/shimmer_loading.dart';
import 'package:weather_app/components/top_app_bar.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/database/entities/saved_location_entity.dart';
import 'package:weather_app/database/entities/settings_entity.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/dimens.dart';
import 'package:weather_app/res/themes.dart';
import 'package:weather_app/res/types.dart';
import 'package:weather_app/router.dart';

late Database _db;
late Settings _userSettings;
late SavedLocation? _pinnedLocation;
late ColorScheme _palette;
late TextTheme _types;
late S _strings;

class HomePage extends StatefulWidget {
  final void Function(AppRoutePath routePath) navigateTo;
  final void Function(bool isDisabled) changeBackButtonStatus;
  const HomePage({
    Key? key,
    required this.navigateTo,
    required this.changeBackButtonStatus
  }) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _refreshIndicatorKey = GlobalKey<CustomRefreshIndicatorState>();
  bool _isCollapsed = false;
  bool _isOnLoading = false;
  bool _isDataUnavailable = true;

  @override
  void initState() {
    _db = Database();
    _userSettings = Settings.get(_db);
    _pinnedLocation = SavedLocation.pinnedLocation(_db);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this
    );
    super.initState();
  }

  /// Build TopAppBar.
  AnimatedBuilder _buildTopAppBar() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) => BlurContainer(
        color: (_isCollapsed)? _palette.blurBackground : Colors.transparent,
        border: Border(bottom: BorderSide(color: (_isCollapsed)? _palette.divider : Colors.transparent)),
        blurSigma: (_isCollapsed)? Dimens.blurContainerSigma : 0,
        padding: EdgeInsets.fromLTRB(
          Dimens.horizontalPadding,
          MediaQuery.of(context).viewPadding.top + Dimens.topAppbarTopPadding,
          Dimens.horizontalPadding,
          Dimens.topAppbarBottomPadding
        ),
        child: (_isOnLoading)? _buildTopAppBarShimmer() : TopAppBar.main(
          title: _pinnedLocation?.getName(_strings.locale) ?? '--',
          titleStyle: _types.headline6!.apply(
            color: (_isCollapsed)? _palette.onBackground : _palette.onPrimary
          ),
          subtitle: _pinnedLocation?.getAddress(_strings.locale) ?? '--',
          subtitleStyle: _types.caption!.apply(
            color: (_isCollapsed)? _palette.subtitle : _palette.onPrimarySubtitle
          ),
          buttonBorder: _palette.border,
          buttonIconColor: _palette.onBackground,
          ltr: _strings.locale == 'en'
        )
      ),
    );
  }
  /// Build TopAppBar shimmer style.
  ShimmerLoading _buildTopAppBarShimmer() {
    // Get color based on collapse status.
    final Color color = (_isCollapsed)? _palette.background : _palette.onPrimarySubtitle;
    // Build shimmer style.
    return ShimmerLoading(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerContainer(width: 24, height: 24, color: color),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerContainer(width: 120, height: 24, color: color),
                  const SizedBox(height: 3),
                  ShimmerContainer(width: 88, height: 13, color: color),
                ],
              )
            ],
          ),
          Row(
            children: [
              ShimmerContainer(
                width: Dimens.topAppbarButtonSize,
                height: Dimens.topAppbarButtonSize,
                color: _palette.background
              ),
              const SizedBox(width: 8),
              ShimmerContainer(
                width: Dimens.topAppbarButtonSize,
                height: Dimens.topAppbarButtonSize,
                color: _palette.background
              )
            ]
          )
        ]
      )
    );
  }
  /// Play hide/show TopAppBar blur background.
  Future<void> _playAnimation(bool isForward) async {
    try {
      if (isForward) {
        await _animationController.forward().orCancel;
      } else {
        await _animationController.reverse().orCancel;
      }
    } on TickerCanceled { return; }
  }
  /// Build SliverAppBar.
  SliverAppBar _buildSliverAppBar(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    double topAppBarHeight = statusBarHeight + Dimens.topAppbarHeight;

    return SliverAppBar(
      floating: true,
      automaticallyImplyLeading: false, // <- Remove back button
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: Dimens.topAppbarHeight,
      backgroundColor: _palette.background,
      expandedHeight: Dimens.sliverAppbarFullHeight,
      stretch: true,
      stretchTriggerOffset: 15,
      flexibleSpace: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (_, constraint) {
                // Calculate current expanded height.
                double eh = constraint.biggest.height;
                // Change TopAppBar background if flexibleSpace collapsed.
                if(eh <= topAppBarHeight){
                  if (!_isCollapsed) {
                    _isCollapsed = true;
                    _playAnimation(true);
                  }
                } else {
                  if (_isCollapsed) {
                    _isCollapsed = false;
                    _playAnimation(false);
                  }
                }

                return const SizedBox.expand();
              }
            )
          ),
          // TODO Add CurrentConditions widget.
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get resources.
    _palette = Palette.of(context);
    _types = Types.of(context);
    _strings = S.of(context);

    return Scaffold(
      backgroundColor: _palette.background,
      body: AnnotatedRegion(
      value: Theme.of(context).uiOverlayStyle,
        child: HomePageRefreshIndicator(
          indicatorKey: _refreshIndicatorKey,
          controller: IndicatorController(refreshEnabled: true),
          onRefresh: (_) async {
            await Future.delayed(const Duration(seconds: 2));
            return DataRefreshState.success;
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(context)
                  ]
                )
              ),
              Positioned(
                  top: 0, left: 0, right: 0,
                  child: _buildTopAppBar()
              )
            ]
          )
        )
      )
    );
  }
}
