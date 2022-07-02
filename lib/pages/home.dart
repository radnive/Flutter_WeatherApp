import 'dart:convert';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:text_marquee/text_marquee.dart';
import 'package:weather_app/components/blur_container.dart';
import 'package:weather_app/components/home_page_refresh_indicator.dart';
import 'package:weather_app/components/image_with_shadow.dart';
import 'package:weather_app/components/linear_progress_bar.dart';
import 'package:weather_app/components/message.dart';
import 'package:weather_app/components/shimmer_loading.dart';
import 'package:weather_app/components/stylish_text.dart';
import 'package:weather_app/components/top_app_bar.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/database/entities/home_page_data.dart';
import 'package:weather_app/database/entities/saved_location_entity.dart';
import 'package:weather_app/database/entities/settings_entity.dart';
import 'package:weather_app/extensions/internet.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/models/aqi.dart';
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
late HomePageData? _savedHomePageData;
late ColorScheme _palette;
late TextTheme _types;
late S _strings;
late Message _message;

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
  /// Hold AQI data. [FAKE DATA]
  AqiStatus _aqiStatus = AqiStatus.empty();
  /// Hold next 4 days weather forecasts data.
  List<WeatherForecast> _weatherForecastsList = [];
  String _next12DaysForecastUrl = '';

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

    // These lines run after page built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check for auto update setting.
      if(_userSettings.autoUpdate || _savedHomePageData == null) {
        // Refresh home page.
        _refreshIndicatorKey.currentState!.refresh(draggingDuration: const Duration(milliseconds: 100));
      } else if(_savedHomePageData != null) {
        if (_savedHomePageData!.locationKey != _pinnedLocation?.locationKey) {
          // Show error message.
          _message.e(
            title: _strings.noSavedDataForLocationErrorMessageTitle,
            subtitle: _strings.noSavedDataForLocationErrorMessageSubtitle,
            buttonText: _strings.refreshButtonText,
            onButtonPressed: () {
              // Refresh home page.
              _refreshIndicatorKey.currentState!.refresh(draggingDuration: const Duration(milliseconds: 100));
            }
          );
        } else if(!_savedHomePageData!.isUpToDate) {
          // Show warning message.
          _message.w(
            title: _strings.outOfDateDataWarningMessageTitle,
            subtitle: _strings.outOfDateDataWarningMessageSubtitle,
            buttonText: _strings.refreshButtonText,
            onButtonPressed: () {
              // Refresh home page.
              _refreshIndicatorKey.currentState!.refresh(draggingDuration: const Duration(milliseconds: 100));
            }
          );
        }
      }
    });
  }

  /// Repaint home page.
  void update() {
    _userSettings = Settings.get(_db);
    setState(() {});
  }

  /// Refresh home page.
  void refresh({bool isNewLocationPinned = false}) {
    _userSettings = Settings.get(_db);
    if(isNewLocationPinned) _pinnedLocation = SavedLocation.pinnedLocation(_db);
    // Refresh home page.
    _refreshIndicatorKey.currentState!.refresh(draggingDuration: const Duration(milliseconds: 100));
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
          ltr: _strings.locale == 'en',
          onManageLocationsButtonPressed: () {
            widget.navigateTo(AppRoutePath.manageLocations());
          },
          onSettingsButtonPressed: () {
            widget.navigateTo(AppRoutePath.settings());
          }
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

    // Create message creator.
    _message = Message(context);

    // Load data from database.
    _loadDataFromDatabase();

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
                      )
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
                    SliverToBoxAdapter(
                      child: _AirQualityIndex(
                        aqiStatus: _aqiStatus,
                        isOnLoading: _isOnLoading,
                        isDataUnavailable: _isDataUnavailable
                      )
                    ),
                    _buildDivider(), // -----------------
                    SliverToBoxAdapter(
                      child: _Next4DaysForecasts(
                        forecasts: _weatherForecastsList,
                        next12DaysUrl: _next12DaysForecastUrl,
                        isOnLoading: _isOnLoading,
                        isDataUnavailable: _isDataUnavailable
                      )
                    ),
                    _buildDivider(), // -----------------
                    const SliverToBoxAdapter(child: _DeveloperIntro())
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

  /// Load saved data from database.
  void _loadDataFromDatabase() {
    // Check for saved home page data in database.
    if(HomePageData.isDataSavedFor(_db, _pinnedLocation!.locationKey)) {
      _savedHomePageData = HomePageData.get(_db);
      // Check saved data is up to date or not!
      if (_savedHomePageData!.isUpToDate || !_userSettings.autoUpdate) {
        // Load saved home page data from database.
        _currentWeather = _savedHomePageData!.savedCurrentWeather;
        _hourlyForecastsList = _savedHomePageData!.savedHourlyForecasts;
        _sunStatus = _savedHomePageData!.savedSunStatus;
        _aqiStatus = AqiStatus.random(_strings.aqiScaleText.split(','));
        _weatherForecastsList = _savedHomePageData!.savedWeatherForecast;

        // Deactivate unavailable state.
        _isDataUnavailable = false;
      }
    }
  }

  /// Refresh home page data.
  Future<DataRefreshState> _refreshHomePage(BuildContext context) async {
    // Handle errors.
    void handleErrors(DataRefreshState state) {
      switch(state) {
        // When server requests exceeded.
        case DataRefreshState.noResponse:
          // Show warning message.
          _message.w(
            title: _strings.requestsNumberErrorMessageTitle,
            subtitle: _strings.requestsNumberErrorMessageSubtitle,
            buttonText: _strings.okayButtonText
          );
          // Change state.
          _isOnLoading = false;
          _isDataUnavailable = !HomePageData.isDataSavedFor(_db, _pinnedLocation!.locationKey);
          break;

        // When request failed.
        case DataRefreshState.error:
          // Show warning message.
          _message.e(
            title: _strings.somethingWentWrongTitle,
            subtitle: _strings.somethingWentWrongSubtitle,
            buttonText: _strings.retryButtonText,
            onButtonPressed: () {
              // Refresh home page.
              _refreshIndicatorKey.currentState!.refresh(draggingDuration: const Duration(milliseconds: 100));
            }
          );
          // Change state.
          _isOnLoading = false;
          _isDataUnavailable = !HomePageData.isDataSavedFor(_db, _pinnedLocation!.locationKey);
          break;

        // When everything is normal.
        default:
          // Change state.
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
      // Handle error.
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

    // :: Send GET sunrise and sunset request.
    DataRefreshState sunStatusState = await _getSunStatus();
    if (sunStatusState != DataRefreshState.success) return sunStatusState;

    // :: Create AQI fake data.
    _aqiStatus = AqiStatus.random(_strings.aqiScaleText.split(','));

    // :: Send GET next 4 days weather forecasts request.
    DataRefreshState next5DaysForecastState = await _getNext5DaysForecast();
    if (next5DaysForecastState != DataRefreshState.success) return currentWeatherState;

    // :: Save all received data to database.
    HomePageData.from(
      locationKey: _pinnedLocation!.locationKey,
      currentWeather: _currentWeather,
      hourlyForecasts: _hourlyForecastsList,
      sunStatus: _sunStatus,
      weatherForecasts: _weatherForecastsList
    ).put(_db);

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
      isMetric: _userSettings.getTemperatureUnit.isMetric
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
  /// Get next 4 days weather forecast from AccuWeather API.
  Future<DataRefreshState> _getNext5DaysForecast() async {
    final weatherForecastRes = await http.get(Urls.weatherForecast(
      _pinnedLocation!.locationKey,
      isMetric: _userSettings.getTemperatureUnit.isMetric
    ));

    if (weatherForecastRes.statusCode == 200) {
      final Map<String, dynamic> jsonBody = jsonDecode(weatherForecastRes.body);
      _weatherForecastsList = WeatherForecast.fromJsonArrayRes(jsonBody);
      _next12DaysForecastUrl = jsonBody['Headline']['MobileLink'];
      return DataRefreshState.success;
    } else {
      return (weatherForecastRes.statusCode == Internet.exceededRequestNumberStatusCode)?
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
            '${(isDataUnavailable)? 'x' : currentWeather.getTemperature(_userSettings.getTemperatureUnit.isMetric)}°',
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
          subtitle: '${currentWeather.getWindSpeed(_userSettings.getWindSpeedUnit.isMetric)} ${_userSettings.getWindSpeedUnit.text}',
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
          subtitle: '${currentWeather.getRealFeelTemperature(_userSettings.getTemperatureUnit.isMetric)}°${_userSettings.getTemperatureUnit.text}',
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
          subtitle: '${currentWeather.getVisibility(_userSettings.getVisibilityUnit.isMetric)} ${_userSettings.getVisibilityUnit.name}',
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

// :: AirQualityIndex
class _AirQualityIndex extends StatelessWidget {
  final AqiStatus aqiStatus;
  final bool isOnLoading;
  final bool isDataUnavailable;
  const _AirQualityIndex({
    Key? key,
    required this.aqiStatus,
    this.isOnLoading = false,
    this.isDataUnavailable = false
  }) : super(key: key);

  /// Build title shimmer style.
  Row _buildTitleShimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerContainer(width: 24, height: 24, color: _palette.background),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerContainer(width: 166, height: 20, color: _palette.background),
                const SizedBox(width: 8),
                ShimmerContainer(width: 67, height: 20, color: _palette.background)
              ],
            ),
            const SizedBox(height: 5),
            ShimmerContainer(width: 200, height: 10, color: _palette.background)
          ]
        )
      ]
    );
  }
  /// Build title.
  Row _buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: SizedBox.square(
            dimension: Dimens.topAppbarIconSize,
            child: Image.asset(
              IconAssets.remixLeaf,
              color: _palette.onBackground,
              fit: BoxFit.fill
            ),
          ),
        ),
        const SizedBox(width: 8),
        FittedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _strings.airQualityIndexTitle,
                    style: _types.headline6!.apply(color: _palette.onBackground)
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _palette.divider,
                      borderRadius: BorderRadius.circular(Dimens.smallShapesBorderRadius)
                    ),
                    child: Text(
                      _strings.aqiFakeDateTagText,
                      style: _types.overline!.apply(color: _palette.subtitle)
                    ),
                  )
                ],
              ),
              const SizedBox(height: 3),
              RichText(
                text: TextSpan(
                  children: <TextSpan> [
                    TextSpan(
                      text: _strings.airQualityIndexSubtitle(
                        _pinnedLocation!.getName(_strings.locale)
                      ),
                      style: _types.caption!.apply(color: _palette.subtitle)
                    ),
                    TextSpan(
                      text: (isDataUnavailable)? '---' : aqiStatus.status,
                      style: _types.caption!.copyWith(
                        color: aqiStatus.aqi.getColor(_palette),
                        fontWeight: FontWeight.w500
                      )
                    ),
                    TextSpan(
                      text: (_strings.locale == 'en')? '.' : ' است.',
                      style: _types.caption!.apply(color: _palette.subtitle)
                    ),
                  ]
                )
              )
            ],
          ),
        )
      ],
    );
  }
  /// Build shimmer style for the widget.
  ShimmerLoading _buildShimmer() => ShimmerLoading(
      child: Column(
        children: [
          _buildTitleShimmer(),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                DashedCircularProgressBar.square(
                  dimensions: Dimens.aqiProgressBarSize,
                  startAngle: 225,
                  sweepAngle: 270,
                  backgroundColor: _palette.background,
                  backgroundStrokeWidth: 12,
                  child: Align(
                    alignment: Alignment.center,
                    child: ShimmerContainer(
                      width: 42, height: 27,
                      color: _palette.background
                    )
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GasInfo.shimmer(),
                          const SizedBox(height: 16),
                          GasInfo.shimmer(),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GasInfo.shimmer(),
                          const SizedBox(height: 16),
                          GasInfo.shimmer(),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GasInfo.shimmer(),
                          const SizedBox(height: 16),
                          GasInfo.shimmer(),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
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
        child: (isOnLoading)? _buildShimmer() : Column(
          children: [
            _buildTitle(),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                color: Colors.transparent,
                child: Row(
                  children: [
                    DashedCircularProgressBar.square(
                      dimensions: Dimens.aqiProgressBarSize,
                      startAngle: 225,
                      sweepAngle: 270,
                      progress: (isDataUnavailable)? 0 : aqiStatus.aqi.value.toDouble(),
                      maxProgress: aqiStatus.aqi.maxValue.toDouble(),
                      foregroundColor: aqiStatus.aqi.getColor(_palette),
                      backgroundColor: _palette.border,
                      foregroundStrokeWidth: 12,
                      backgroundStrokeWidth: 12,
                      ltr: _strings.locale == 'en',
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${(isDataUnavailable)? '---' : aqiStatus.aqi.value}',
                          style: _types.aqiValue.apply(color: aqiStatus.aqi.getColor(_palette)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GasInfo(gasFormula: 'PM', gasSub: '10', gasInfo: aqiStatus.pm10, isDataUnavailable: isDataUnavailable),
                              const SizedBox(height: 16),
                              GasInfo(gasFormula: 'PM', gasSub: '2.5', gasInfo: aqiStatus.pm2_5, isDataUnavailable: isDataUnavailable),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GasInfo(gasFormula: 'CO', gasInfo: aqiStatus.co, isDataUnavailable: isDataUnavailable),
                              const SizedBox(height: 16),
                              GasInfo(gasFormula: 'SO', gasSub: '2', gasInfo: aqiStatus.so2, isDataUnavailable: isDataUnavailable),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GasInfo(gasFormula: 'NO', gasSub: '2', gasInfo: aqiStatus.no2, isDataUnavailable: isDataUnavailable),
                              const SizedBox(height: 16),
                              GasInfo(gasFormula: 'O', gasSub: '3', gasInfo: aqiStatus.o3, isDataUnavailable: isDataUnavailable),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        )
    );
  }
}

class GasInfo extends StatelessWidget {
  final String gasFormula, gasSub;
  final AqiInfo gasInfo;
  final bool isOnLoading;
  final bool isDataUnavailable;
  const GasInfo({
    Key? key,
    this.gasFormula = '',
    this.gasSub = '',
    required this.gasInfo,
    this.isOnLoading = false,
    this.isDataUnavailable = false
  }) : super(key: key);

  factory GasInfo.shimmer() => GasInfo(gasInfo: AqiInfo(0, 0), isOnLoading: true);

  /// Build shimmer style.
  Row _buildShimmer(BuildContext context) {
    return Row(
      children: [
        ShimmerContainer(width: 3, height: 30, color: _palette.background),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerContainer(width: 24, height: 10, color: _palette.background),
            const SizedBox(height: 5),
            ShimmerContainer(width: 32, height: 15, color: _palette.background)
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (isOnLoading)? _buildShimmer(context) : Row(
      children: [
        LinearProgressBar(
          width: 3,
          height: 32,
          progress: gasInfo.value.toDouble(),
          maxProgress: gasInfo.maxValue.toDouble(),
          foregroundColor: gasInfo.getColor(_palette),
          backgroundColor: _palette.border,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StylishText(
              text: gasFormula,
              sub: gasSub,
              style: _types.caption!.apply(color: _palette.subtitle),
            ),
            Text(
              '${(isDataUnavailable)? '---' : gasInfo.value}',
              style: _types.subtitle1!.apply(color: _palette.onBackground)
            )
          ],
        )
      ],
    );
  }
}

// :: Next4DaysForecasts
class _Next4DaysForecasts extends StatelessWidget {
  final List<WeatherForecast> forecasts;
  final bool isOnLoading;
  final bool isDataUnavailable;
  final String next12DaysUrl;
  const _Next4DaysForecasts({
    Key? key,
    required this.forecasts,
    this.isOnLoading = false,
    this.isDataUnavailable = false,
    this.next12DaysUrl = ''
  }) : super(key: key);

  /// Build shimmer style.
  ShimmerLoading _buildShimmer(BuildContext context) {
    List<Widget> items = [];
    for(int index = 0; index < 5; index++) {
      items.add(_WeatherForecastItem.shimmer());
      items.add(const SizedBox(height: 32));
    }
    items.add(ShimmerContainer(width: null, height: 47, color: _palette.background));
    return ShimmerLoading(child: Column(children: items));
  }

  /// Build unavailable style.
  Column _buildUnavailable() {
    List<Widget> items = [];
    for(int index = 0; index < 5; index++) {
      items.add(_WeatherForecastItem.unavailable());
      items.add(const SizedBox(height: 32));
    }
    items.add(ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.square(
              dimension: Dimens.next4DaysButtonIconSize,
              child: Image.asset(
                IconAssets.remixCloudyLine,
                fit: BoxFit.fill,
                color: _palette.onPrimary
              )
            ),
            const SizedBox(width: 8),
            Text(
              _strings.unavailableText,
              style: _types.button!.apply(color: _palette.onPrimary)
            )
          ],
        )
    ));
    return Column(children: items);
  }

  Column _buildWeatherForecasts(BuildContext context) {
    List<Widget> items = [];
    for(WeatherForecast wf in forecasts) {
      items.add(_WeatherForecastItem(
        forecast: wf,
        isForTomorrow: items.isEmpty,
      ));
      items.add(const SizedBox(height: 32));
    }

    items.add(ElevatedButton(
      onPressed: () => Internet.openUrl(context, url: next12DaysUrl),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: Dimens.next4DaysButtonIconSize,
            child: Image.asset(
              IconAssets.remixCloudyLine,
              fit: BoxFit.fill,
              color: _palette.onPrimary
            )
          ),
          const SizedBox(width: 8),
          Text(
            _strings.next12DaysForecastButtonText,
            style: _types.button!.apply(color: _palette.onPrimary)
          )
        ],
      )
    ));

    return Column(children: items);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.horizontalPadding,
        vertical: Dimens.verticalPadding
      ),
      child: (isOnLoading)? _buildShimmer(context) : (isDataUnavailable)? _buildUnavailable() : _buildWeatherForecasts(context)
    );
  }
}

class _WeatherForecastItem extends StatelessWidget {
  final WeatherForecast forecast;
  final bool isOnLoading;
  final bool isDataUnavailable;
  final bool isForTomorrow;
  const _WeatherForecastItem({
    Key? key,
    required this.forecast,
    this.isOnLoading = false,
    this.isDataUnavailable = false,
    this.isForTomorrow = false
  }) : super(key: key);

  factory _WeatherForecastItem.shimmer() =>
      _WeatherForecastItem(forecast: WeatherForecast.empty(), isOnLoading: true);
  factory _WeatherForecastItem.unavailable() =>
      _WeatherForecastItem(forecast: WeatherForecast.empty(), isDataUnavailable: true);

  /// Build shimmer style.
  Row _buildShimmer() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        flex: 17,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerContainer(width: 96, height: 20, color: _palette.background),
            const SizedBox(height: 5),
            ShimmerContainer(width: 63, height: 12, color: _palette.background)
          ]
        ),
      ),
      Expanded(
        flex: 15,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerContainer(width: 64, height: 36, color: _palette.background),
            ShimmerContainer(width: 48, height: 48, color: _palette.background)
          ],
        ),
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    // Get week day name.
    String dayText = (isForTomorrow)? _strings.tomorrowText : forecast.date.weekDayStr(_strings.locale == 'en');

    return (isOnLoading)? _buildShimmer() : Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 17,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (isDataUnavailable)? '---' : dayText,
                style: _types.subtitle1!.apply(color: _palette.onBackground),
              ),
              const SizedBox(height: 5),
              Text(
                (isDataUnavailable)? '---' : forecast.date.toStrWithoutWeekDay(_strings.locale == 'en'),
                style: _types.subtitle2!.apply(color: _palette.subtitle)
              ),
            ]
          ),
        ),
        Expanded(
          flex: 15,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StylishText(
                text: '${(isDataUnavailable)? 'x' : forecast.temperature.toInt()}',
                sup: '°${_userSettings.getTemperatureUnit.text}',
                style: _types.headline4!.apply(color: _palette.onBackground)
              ),
              SizedBox.square(
                dimension: Dimens.weatherForecastIconSize,
                child: Image.asset(
                  (isDataUnavailable)? ImageAssets.unknownWeatherIcon : ImageAssets.weatherIcons[forecast.iconIndex],
                  fit: BoxFit.fill
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

// :: DeveloperIntro.
class _DeveloperIntro extends StatelessWidget {
  const _DeveloperIntro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.horizontalPadding, vertical: 32),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: <TextSpan> [
            TextSpan(
              text: _strings.developerItemText,
              style: _types.caption!.apply(color: _palette.subtitle)
            ),
            TextSpan(
              text: _strings.developerName,
              style: _types.caption!.copyWith(
                color: _palette.onBackground,
                fontWeight: FontWeight.w700
              )
            )
          ]
        )
      )
    );
  }
}
