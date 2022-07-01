import 'dart:convert';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:text_marquee/text_marquee.dart';
import 'package:weather_app/components/blur_container.dart';
import 'package:weather_app/components/home_page_refresh_indicator.dart';
import 'package:weather_app/components/shadow.dart';
import 'package:weather_app/components/shimmer_loading.dart';
import 'package:weather_app/components/top_app_bar.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/database/entities/saved_location_entity.dart';
import 'package:weather_app/database/entities/settings_entity.dart';
import 'package:weather_app/extensions/internet.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/models/weather_conditions.dart';
import 'package:weather_app/res/assets.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/dimens.dart';
import 'package:weather_app/res/themes.dart';
import 'package:weather_app/res/types.dart';
import 'package:weather_app/res/urls.dart';
import 'package:weather_app/router.dart';
import 'package:http/http.dart' as http;

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

  /// Hold current weather conditions data.
  CurrentWeather _currentWeather = CurrentWeather.empty();
  /// Hold hourly weather forecasts data.
  List<HourlyForecast> _hourlyForecastsList = [];
  /// Hold sunrise and sunset data.
  SunStatus _sunStatus = SunStatus();

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
          Positioned.fill(
            child: FlexibleSpaceBar(
              collapseMode: CollapseMode.none,
              background: _CurrentWeatherConditions(
                currentWeather: _currentWeather,
                isOnLoading: _isOnLoading,
                isDataUnavailable: _isDataUnavailable
              ),
            )
          )
        ]
      )
    );
  }

  /// Build divider line.
  SliverToBoxAdapter _buildDivider() => SliverToBoxAdapter(
    child: Divider(thickness: 1, color: _palette.divider, height: 1)
  );

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
          onRefresh: () => _refreshHomePage(context),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(context),
                    _buildDivider(), // -----------------
                    SliverToBoxAdapter(
                      child: _HourlyWeatherForecast(
                        forecasts: _hourlyForecastsList,
                        isOnLoading: _isOnLoading,
                        isDataUnavailable: _isDataUnavailable
                      ),
                    ),
                    _buildDivider(), // -----------------
                    SliverToBoxAdapter(
                      child: _SunStatus(
                        status: _sunStatus,
                        isOnLoading: _isOnLoading,
                        isDataUnavailable: _isDataUnavailable
                      )
                    ),
                    _buildDivider(), // -----------------
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

  /// Refresh home page data.
  Future<DataRefreshState> _refreshHomePage(BuildContext context) async {
    // Handle errors.
    void handleErrors(DataRefreshState state) {
      switch(state) {
        // When server requests exceeded.
        case DataRefreshState.noResponse:
          // TODO Handle no response state.
          break;

        // When request failed.
        case DataRefreshState.error:
        // TODO Handle error state.
          break;

        // When everything is normal.
        default:
          _isOnLoading = false;
          _isDataUnavailable = false;
          break;
      }

      // Repaint widgets.
      setState(() {});
    }

    // Try send requests to get all data.
    try {
      // Get all home page data from APIs.
      final refreshState = await _getAllData();
      // Handle errors.
      handleErrors(refreshState);
      // Return state.
      return refreshState;
    } catch(_) {
      // Handle errors.
      handleErrors(DataRefreshState.error);
      // If something went wrong, return error state.
      return DataRefreshState.error;
    }
  }

  /// Get all home page data from APIs.
  Future<DataRefreshState> _getAllData() async {
    // :: Activate loading state.
    if (!_isOnLoading) { setState(() => _isOnLoading = true); }

    // :: Send GET current weather conditions request.
    DataRefreshState currentWeatherState = await _getCurrentWeatherConditions();
    if(currentWeatherState != DataRefreshState.success) return currentWeatherState;

    // :: Send GET hourly weather forecasts request.
    DataRefreshState hourlyForecastState = await _getHourlyForecast();
    if (hourlyForecastState != DataRefreshState.success) return currentWeatherState;

    // :: Send get sunrise and sunset request.
    DataRefreshState sunStatusState = await _getSunStatus();
    if (sunStatusState != DataRefreshState.success) return sunStatusState;

    // :: If no error happened return success state.
    return DataRefreshState.success;
  }

  /// Get current weather conditions from AccuWeather API.
  Future<DataRefreshState> _getCurrentWeatherConditions() async {
    // Send request and get response.
    final currentWeatherRes = await http.get(Urls.currentCondition(
      _pinnedLocation!.locationKey,
      details: true,
      locale: _strings.locale
    ));

    // Manage response.
    if(currentWeatherRes.statusCode == Internet.okayStatusCode) {
      // Convert and save received data.
      _currentWeather = CurrentWeather.fromJsonRes(jsonDecode(currentWeatherRes.body)[0]);
      // Return success state.
      return DataRefreshState.success;
    } else {
      return (currentWeatherRes.statusCode == Internet.exceededRequestNumberStatusCode)?
        DataRefreshState.noResponse : DataRefreshState.error;
    }
  }
  /// Get hourly weather forecast from AccuWeather API.
  Future<DataRefreshState> _getHourlyForecast() async {
    // Send request and get response.
    final hourlyForecastRes = await http.get(Urls.hourlyForecast(
      _pinnedLocation!.locationKey,
      isMetric: _userSettings.temperatureUnit.isMetric
    ));

    // Manage response.
    if (hourlyForecastRes.statusCode == 200) {
      // Convert and save received data.
      _hourlyForecastsList = HourlyForecast.fromJsonArrayRes(jsonDecode(hourlyForecastRes.body));
      // Return success state.
      return DataRefreshState.success;
    } else {
      return (hourlyForecastRes.statusCode == Internet.exceededRequestNumberStatusCode)?
        DataRefreshState.noResponse : DataRefreshState.error;
    }
  }
  /// Get sunrise and sunset from IpGeoLocation API.
  Future<DataRefreshState> _getSunStatus() async {
    // Send request and get response.
    final sunStatusRes = await http.get(Urls.sunStatus(
      lat: _pinnedLocation!.latitude,
      long: _pinnedLocation!.longitude,
    ));

    if (sunStatusRes.statusCode == 200) {
      // Convert and save received data.
      _sunStatus = SunStatus.fromJsonRes(jsonDecode(sunStatusRes.body));
      // Return success state.
      return DataRefreshState.success;
    } else {
      return (sunStatusRes.statusCode == Internet.exceededRequestNumberStatusCode)?
      DataRefreshState.noResponse : DataRefreshState.error;
    }
  }
}

// :: CurrentWeatherConditions
class _CurrentWeatherConditions extends StatelessWidget {
  final CurrentWeather currentWeather;
  final bool isOnLoading;
  final bool isDataUnavailable;
  const _CurrentWeatherConditions({
    Key? key,
    required this.currentWeather,
    this.isOnLoading = false,
    this.isDataUnavailable = false
  }) : super(key: key);

  /// Build current weather conditions shimmer.
  Container _buildWeatherConditionsShimmer() {
    Color color = _palette.onPrimarySubtitle;
    return Container(
      padding: const EdgeInsets.only(top: Dimens.topAppbarHeight + 48, left: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 48),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius)
                ),
              )
            ),
          ),
          const SizedBox(height: 32),
          ShimmerContainer(width: 98, height: 80, color: color),
          const SizedBox(height: 32),
          ShimmerContainer(width: 120, height: 24, color: color),
          const SizedBox(height: 5),
          ShimmerContainer(width: 88, height: 16, color: color),
        ],
      ),
    );
  }
  /// Build current weather information shimmer.
  Container _buildWeatherInfoShimmer() {
    return Container(
      padding: const EdgeInsets.only(top: Dimens.topAppbarHeight, left: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WeatherInfoItem.shimmer(),
          const SizedBox(height: Dimens.weatherInfoDividerSize),
          _WeatherInfoItem.shimmer(),
          const SizedBox(height: Dimens.weatherInfoDividerSize),
          _WeatherInfoItem.shimmer(),
          const SizedBox(height: Dimens.weatherInfoDividerSize),
          _WeatherInfoItem.shimmer(),
          const SizedBox(height: Dimens.weatherInfoDividerSize),
          _WeatherInfoItem.shimmer(),
        ],
      )
    );
  }
  /// Build shimmer layout.
  Stack _buildShimmer() => Stack(
    children: [
      Positioned.fill(child: Row(
        children: [
          Expanded(
            flex: 12,
            child: Container(color: _palette.primary),
          ),
          Expanded(
            flex: 10,
            child: Container(color: _palette.background),
          )
        ],
      )),
      Positioned.fill(
        child: ShimmerLoading(
          child: Row(
            children: [
              Expanded(
                flex: 12,
                child: _buildWeatherConditionsShimmer(),
              ),
              Expanded(
                flex: 10,
                child: _buildWeatherInfoShimmer(),
              )
            ],
          ),
        ),
      )
    ]
  );

  /// Build current weather conditions.
  Container _buildWeatherCondition() => Container(
    color: _palette.primary,
    padding: const EdgeInsets.only(top: Dimens.topAppbarHeight + 48),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: (_strings.locale == 'en')?
            const EdgeInsets.only(right: 48, left: 32) :
            const EdgeInsets.only(right: 32, left: 48),
          child: AspectRatio(
            aspectRatio: 1,
            child: ImageWithShadow(
              (isDataUnavailable)? ImageAssets.unknownWeatherIcon : ImageAssets.weatherIcons[currentWeather.weatherIcon],
            )
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: (_strings.locale == 'en')? 0 : 16
          ),
          child: TextMarquee(
            '${(isDataUnavailable)? 'x' : currentWeather.getTemperature(_userSettings.temperatureUnit.isMetric)}°',
            style: _types.currentTemperature.apply(color: _palette.onPrimary),
            startPaddingSize: 32
          ),
        ),
        TextMarquee(
          (isDataUnavailable)? _strings.unavailableText : currentWeather.weatherText,
          style: _types.headline6!.apply(color: _palette.onPrimary),
          startPaddingSize: 32
        ),
        Padding(
          padding: (_strings.locale == 'en')?
            const EdgeInsets.only(left: 32) :
            const EdgeInsets.only(right: 32, top: 8),
          child: Text(
            (isDataUnavailable)? _strings.unavailableText : currentWeather.date.toStr(_strings.locale == 'en'),
            style: _types.caption!.apply(color: _palette.onPrimarySubtitle)
          ),
        )
      ],
    ),
  );
  /// Build current weather information.
  Container _buildWeatherInfo() => Container(
    color: _palette.background,
    padding: EdgeInsets.only(
      top: Dimens.topAppbarHeight,
      left: (_strings.locale == 'en')? 32 : 0,
      right: (_strings.locale == 'en')? 0 : 32,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WeatherInfoItem(
          iconSrc: IconAssets.remixWind,
          title: _strings.windTitle,
          subtitle: '${currentWeather.getWindSpeed(_userSettings.windSpeedUnit.isMetric)} ${_userSettings.windSpeedUnit.text}',
          isDataUnavailable: isDataUnavailable
        ),
        const SizedBox(height: Dimens.weatherInfoDividerSize),
        _WeatherInfoItem(
          iconSrc: IconAssets.remixSunLine,
          title: _strings.uvIndexTitle,
          subtitle: '${currentWeather.uvIndex}',
          isDataUnavailable: isDataUnavailable
        ),
        const SizedBox(height: Dimens.weatherInfoDividerSize),
        _WeatherInfoItem(
          iconSrc: IconAssets.remixTemperatureHotLine,
          title: _strings.feelsLikeTitle,
          subtitle: '${currentWeather.getRealFeelTemperature(_userSettings.temperatureUnit.isMetric)}°${_userSettings.temperatureUnit.text}',
          isDataUnavailable: isDataUnavailable
        ),
        const SizedBox(height: Dimens.weatherInfoDividerSize),
        _WeatherInfoItem(
          iconSrc: IconAssets.remixDrop,
          title: _strings.humidityTitle,
          subtitle: '${currentWeather.humidity}%',
          isDataUnavailable: isDataUnavailable
        ),
        const SizedBox(height: Dimens.weatherInfoDividerSize),
        _WeatherInfoItem(
          iconSrc: IconAssets.remixEyeLine,
          title: _strings.visibilityTitle,
          subtitle: '${currentWeather.getVisibility(_userSettings.visibilityUnit.isMetric)} ${_userSettings.visibilityUnit.name}',
          isDataUnavailable: isDataUnavailable
        )
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return (isOnLoading)? _buildShimmer() : Row(
      children: [
        Expanded(flex: 12, child: _buildWeatherCondition()),
        Expanded(flex: 10, child: _buildWeatherInfo())
      ],
    );
  }
}

class _WeatherInfoItem extends StatelessWidget {
  final String iconSrc;
  final String title;
  final String subtitle;
  final bool isOnLoading;
  final bool isDataUnavailable;
  const _WeatherInfoItem({
    Key? key,
    this.iconSrc= '',
    this.title = '',
    this.subtitle = '',
    this.isOnLoading = false,
    this.isDataUnavailable = false
  }) : super(key: key);

  factory _WeatherInfoItem.shimmer() => const _WeatherInfoItem(isOnLoading: true);

  @override
  Widget build(BuildContext context) {
    return (isOnLoading)? Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ShimmerContainer(width: 24, height: 24, color: _palette.background),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerContainer(width: 55, height: 12, color: _palette.background),
            const SizedBox(height: 5),
            ShimmerContainer(width: 82, height: 20, color: _palette.background),
          ],
        )
      ],
    ) : Row(
      children: [
        Image.asset(
          iconSrc,
          width: Dimens.weatherConditionsInfoIconSize,
          height: Dimens.weatherConditionsInfoIconSize,
          color: _palette.onBackground
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _types.caption!.apply(color: _palette.subtitle)),
            Text(
              (isDataUnavailable)? '---' : subtitle,
              textDirection: TextDirection.ltr,
              style: _types.bodyText2!.apply(color: _palette.onBackground)
            )
          ],
        )
      ],
    );
  }
}

// :: HourlyWeatherForecast
class _HourlyWeatherForecast extends StatelessWidget {
  final List<HourlyForecast> forecasts;
  final bool isOnLoading;
  final bool isDataUnavailable;
  const _HourlyWeatherForecast({
    Key? key,
    required this.forecasts,
    this.isOnLoading = false,
    this.isDataUnavailable = false
  }) : super(key: key);

  /// Build shimmer style.
  ShimmerLoading _buildShimmer() {
    List<Widget> items = [];
    for (int index = 0; index < 12; index++) {
      items.add(_HourlyForecastItem.shimmer());
      if (index != 11) { items.add(const SizedBox(width: 32)); }
    }
    return ShimmerLoading(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [ Row(children: items) ],
      ),
    );
  }

  /// Build unavailable style.
  Column _buildUnavailable() {
    List<Widget> items = [];
    for (int index = 0; index < 12; index++) {
      items.add(_HourlyForecastItem.unavailable());
      if (index != 11) { items.add(const SizedBox(width: 32)); }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [ Row(children: items) ],
    );
  }

  /// Build weather forecast items.
  Column _buildForecastList() {
    List<Widget> items = [];
    for (int index = 0; index < forecasts.length; index++) {
      HourlyForecast hf = forecasts[index];
      items.add(_HourlyForecastItem(
        icon: ImageAssets.weatherIcons[hf.weatherIcon],
        time: hf.date.timeStr,
        temperature: hf.temperature.toInt(),
        isDataUnavailable: isDataUnavailable,
      ));
      if (index != forecasts.length - 1) { items.add(const SizedBox(width: 32)); }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [ Row(children: items) ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: Dimens.horizontalPadding),
      child: (isOnLoading)? _buildShimmer() : (isDataUnavailable)? _buildUnavailable() : _buildForecastList(),
    );
  }
}

class _HourlyForecastItem extends StatelessWidget {
  final String time;
  final String icon;
  final int temperature;
  final bool isOnLoading;
  final bool isDataUnavailable;
  const _HourlyForecastItem({
    Key? key,
    this.time = '',
    this.icon = '',
    this.temperature = 0,
    this.isOnLoading = false,
    this.isDataUnavailable = false
  }) : super(key: key);

  factory _HourlyForecastItem.shimmer() => const _HourlyForecastItem(isOnLoading: true);
  factory _HourlyForecastItem.unavailable() => const _HourlyForecastItem(isDataUnavailable: true);

  /// Build shimmer style.
  Column _buildShimmer() => Column(
    children: [
      ShimmerContainer(width: 40, height: 14, color: _palette.background),
      const SizedBox(height: 5),
      ShimmerContainer(width: 30, height: 20, color: _palette.background),
      const SizedBox(height: 16),
      ShimmerContainer(width: 24, height: 24, color: _palette.background)
    ]
  );

  @override
  Widget build(BuildContext context) {
    return (isOnLoading)? _buildShimmer() : Column(
      children: [
        Text(
          (isDataUnavailable)? '---' : time,
          style: _types.caption!.apply(color: _palette.subtitle)
        ),
        const SizedBox(height: 8),
        Text(
          '${(isDataUnavailable)? 'x' : temperature}°',
          style: _types.headline6!.apply(color: _palette.onBackground)
        ),
        const SizedBox(height: 16),
        Image.asset(
          (isDataUnavailable)? ImageAssets.unknownWeatherIcon : icon,
          width: Dimens.hourlyWeatherIconSize,
          height: Dimens.hourlyWeatherIconSize
        )
      ],
    );
  }
}

// :: SunStatus
class _SunStatus extends StatelessWidget {
  final SunStatus status;
  final bool isOnLoading;
  final bool isDataUnavailable;
  const _SunStatus({
    Key? key,
    required this.status,
    this.isOnLoading = false,
    this.isDataUnavailable = false
  }) : super(key: key);

  /// Build shimmer style.
  ShimmerLoading _buildShimmer(BuildContext context) => ShimmerLoading(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SunStatusTimeItem.shimmer(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: DashedCircularProgressBar.aspectRatio(
              aspectRatio: 2,
              startAngle: 270,
              sweepAngle: 180,
              backgroundStrokeWidth: 2,
              backgroundColor: _palette.background,
              circleCenterAlignment: Alignment.bottomCenter,
            ),
          )
        ),
        _SunStatusTimeItem.shimmer()
      ],
    )
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.horizontalPadding,
        vertical: Dimens.verticalPadding
      ),
      child: (isOnLoading)? _buildShimmer(context) : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SunStatusTimeItem(
            label: _strings.sunriseText,
            time: (isDataUnavailable)? '---' : status.sunrise,
            icon: IconAssets.remixSunriseLine
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: DashedCircularProgressBar.aspectRatio(
                aspectRatio: 2,
                progress: (isDataUnavailable)? 0 : status.sunProgress,
                startAngle: 270,
                sweepAngle: 180,
                animation: true,
                foregroundStrokeWidth: 2,
                backgroundStrokeWidth: 1,
                foregroundColor: _palette.onBackground,
                backgroundColor: _palette.subtitle,
                backgroundDashSize: 2,
                backgroundGapSize: 3,
                seekSize: 16,
                seekColor: _palette.warning,
                circleCenterAlignment: Alignment.bottomCenter,
                ltr: _strings.locale == 'en'
              ),
            )
          ),
          _SunStatusTimeItem(
            label: _strings.sunsetText,
            time: (isDataUnavailable)? '---' : status.sunset,
            icon: IconAssets.remixSunsetLine
          )
        ],
      ),
    );
  }
}

class _SunStatusTimeItem extends StatelessWidget {
  final String label;
  final String time;
  final String icon;
  final bool isOnLoading;
  const _SunStatusTimeItem({
    Key? key,
    this.label = '',
    this.time = '',
    this.icon = '',
    this.isOnLoading = false
  }) : super(key: key);

  factory _SunStatusTimeItem.shimmer() => const _SunStatusTimeItem(isOnLoading: true);

  /// Build shimmer style.
  Column _buildShimmer(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShimmerContainer(width: 32, height: 32, color: _palette.background),
        const SizedBox(height: 10),
        ShimmerContainer(width: 72, height: 19, color: _palette.background),
        const SizedBox(height: 8),
        ShimmerContainer(width: 56, height: 11, color: _palette.background),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (isOnLoading)? _buildShimmer(context) : Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: Dimens.sunStatusIconSize,
          child: Image.asset(icon,
            color: _palette.onBackground,
            fit: BoxFit.fill
          ),
        ),
        const SizedBox(height: 10),
        Text(time, style: _types.headline6!.apply(color: _palette.onBackground)),
        const SizedBox(height: 3),
        Text(label, style: _types.caption!.apply(color: _palette.subtitle))
      ],
    );
  }
}
