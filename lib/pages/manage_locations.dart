import 'dart:convert';

import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:location/location.dart';
import 'package:weather_app/components/blur_container.dart';
import 'package:weather_app/components/empty_list_message.dart';
import 'package:weather_app/components/message.dart';
import 'package:weather_app/components/shimmer_loading.dart';
import 'package:weather_app/components/square_image.dart';
import 'package:weather_app/components/top_app_bar.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/database/entities/saved_location_entity.dart';
import 'package:weather_app/database/entities/settings_entity.dart';
import 'package:weather_app/extensions/internet.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/models/search_result_location.dart';
import 'package:weather_app/res/assets.dart';
import 'package:weather_app/res/colors.dart';
import 'package:weather_app/res/dimens.dart';
import 'package:weather_app/res/themes.dart';
import 'package:weather_app/res/types.dart';
import 'package:weather_app/res/urls.dart';
import 'package:weather_app/router.dart';
import 'package:http/http.dart' as http;

late ColorScheme _palette;
late TextTheme _types;
late S _strings;
late Database _db;
late Settings _userSettings;

late TextEditingController _searchTextFieldController;

enum _ListPages { savedLocations, searchResult }
late PageController _pageController;
void _jumpToListPage(_ListPages page) => _pageController.jumpToPage(page.index);

// ValueNotifiers.
// :: For _SavedLocationsList.
late ValueNotifier<bool> _savedLocationsChangeNotifier;
void notifySavedLocationsList() => _savedLocationsChangeNotifier.value = !_savedLocationsChangeNotifier.value;

// :: For _SearchResultList.
late final _SearchResultNotifier _searchChangeNotifier;

// ManageLocations page.
class ManageLocations extends StatelessWidget {
  final void Function(AppRoutePath routePath) navigateTo;
  final void Function(bool isDisabled) changeBackButtonStatus;
  final GlobalKey<TopAppBarState>? appBarKey;
  const ManageLocations({
    Key? key,
    this.appBarKey,
    required this.navigateTo,
    required this.changeBackButtonStatus
  }) : super(key: key);

  @override
  StatelessElement createElement() {
    _db = Database();
    _userSettings = Settings.get(_db);
    // Create controllers.
    _pageController = PageController(initialPage: 0);
    _searchTextFieldController = TextEditingController();
    // Create ValueNotifiers.
    _savedLocationsChangeNotifier = ValueNotifier<bool>(false);
    _searchChangeNotifier = _SearchResultNotifier(_SearchResultData());
    return super.createElement();
  }

  @override
  Widget build(BuildContext context) {
    // Get resources.
    _palette = Palette.of(context);
    _types = Types.of(context);
    _strings = S.of(context);

    // Build page.
    return Scaffold(
      backgroundColor: _palette.background,
      body: AnnotatedRegion(
        value: Theme.of(context).uiOverlayStyle,
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _SavedLocationsList(),
                  _SearchResultList()
                ]
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0,
              child: _TopAppBar(
                key: appBarKey,
                navigateTo: navigateTo,
                changeBackButtonStatus: changeBackButtonStatus
              )
            )
          ],
        ),
      ),
    );
  }
}

// :: TopAppBar widget.
class _TopAppBar extends StatefulWidget {
  final void Function(AppRoutePath routePath) navigateTo;
  final void Function(bool isDisabled) changeBackButtonStatus;
  const _TopAppBar({
    Key? key,
    required this.navigateTo,
    required this.changeBackButtonStatus
  }) : super(key: key);

  @override
  State<_TopAppBar> createState() => TopAppBarState();
}

class TopAppBarState extends State<_TopAppBar> {
  bool _isCollapsed = false;
  bool _isOnError = false;
  bool _isOnLoadUserLocation = false;
  bool _isReadOnly = true;

  // Call when back button pressed. (TopAppBar/NavigationBar back button)
  void onBackPressed() {
    if(_isCollapsed) {
      // Enable NavigationBar back button.
      widget.changeBackButtonStatus(false);
      // Set TextField read only. (If internet connection lost it remains read only)
      _isReadOnly = true;
      // Clear SearchBox TextField.
      _searchTextFieldController.clear();
      // Clear SearchBox TextField focus.
      FocusManager.instance.primaryFocus?.unfocus();
      // Jump to SavedLocationsList page.
      _jumpToListPage(_ListPages.savedLocations);
      // Reset all states.
      setState(() {
        _isCollapsed = false;
        _isOnError = false;
        _isOnLoadUserLocation = false;
      });
    } else {
      // TODO Navigate to Home page.
    }
  }

  // Build TopAppBar.
  AnimatedSize _buildTopAppBar() => AnimatedSize(
    duration: const Duration(milliseconds: 200),
    reverseDuration: const Duration(milliseconds: 200),
    curve: Curves.fastOutSlowIn,
    child: SizedBox(
      height: (_isCollapsed)? 0 : null,
      child: Padding(
        padding: const EdgeInsets.only(top: Dimens.topAppbarTopPadding),
        child: TopAppBar.withBackButton(
          title: _strings.manageLocationsTitle,
          titleStyle: _types.headline6!.apply(color: _palette.onBackground),
          subtitle: _strings.manageLocationsSubtitle,
          subtitleStyle: _types.caption!.apply(color: _palette.subtitle),
          buttonBorder: _palette.border,
          buttonIconColor: _palette.onBackground,
          ltr: _strings.locale == 'en',
          onButtonPressed: onBackPressed
        )
      )
    )
  );

  // Build SearchBox widget.
  // :: Build primary button icon.
  Widget _getPrimaryButtonIcon() {
    if(_isOnLoadUserLocation) {
      return CupertinoActivityIndicator(color: _palette.onPrimarySubtitle);
    } else {
      return SquareImage.asset(
        (_isCollapsed)? IconAssets.remixSearch : IconAssets.remixLocation,
        dimension: Dimens.searchBoxIconsSize,
        color: _palette.onPrimary
      );
    }
  }
  // :: Build primary button widget.
  InkWell _buildPrimaryButton(BuildContext context) => InkWell(
    onTap: () {
      if(!_isOnLoadUserLocation) {
        if(_isCollapsed) {
          if(_searchTextFieldController.text.isNotEmpty) {
            // Jump to SearchResultList.
            _jumpToListPage(_ListPages.searchResult);
            // Search location name.
            _searchChangeNotifier.changeSearchQuery(true, _searchTextFieldController.text);
          } else {
            // Show error message.
            Message(context).e(
              title: _strings.emptySearchBoxErrorMessageTitle,
              subtitle: _strings.emptySearchBoxErrorMessageSubtitle,
              buttonText: _strings.okayButtonText
            );
            // Activate error state.
            setState(() => _isOnError = true);
          }
        } else {
          // Check Internet then get user location.
          Internet.check(context, ifConnected: () => _getUserLocation(context));
        }
      }
    },
    borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius),
    child: Container(
      margin: const EdgeInsets.all(5),
      width: Dimens.searchBoxButtonSize,
      height: Dimens.searchBoxButtonSize,
      decoration: BoxDecoration(
        color: _palette.primary,
        borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius)
      ),
      child: _getPrimaryButtonIcon(),
    ),
  );

  // :: Build textField.
  TextField _buildTextField(BuildContext context) => TextField(
    controller: _searchTextFieldController,
    readOnly: _isReadOnly,
    style: _types.subtitle1!.apply(color: _palette.onBackground),
    onTap: () {
      // Set TextField read only. (If internet connection lost it remains read only)
      _isReadOnly = true;

      // Check for internet connection.
      Internet.check(context, ifConnected: () {
        // Disable NavigationBar back button.
        widget.changeBackButtonStatus(true);
        // Set TextField editable.
        _isReadOnly = false;
        // TODO Go to PopularLocationsList
        // Collapse AppBar.
        setState(() => _isCollapsed = true);
      });
    },
    onChanged: (text) {
      if(_isOnError && text.isNotEmpty) {
        // Deactivate error state.
        setState(() => _isOnError = false);
      }
    },
    onSubmitted: (text) {
      if(text.isEmpty) {
        // Show error message.
        Message(context).e(
          title: _strings.emptySearchBoxErrorMessageTitle,
          subtitle: _strings.emptySearchBoxErrorMessageSubtitle,
          buttonText: _strings.okayButtonText
        );
        // Activate error state.
        setState(() => _isOnError = true);
      } else {
        // Jump to SearchResultList.
        _jumpToListPage(_ListPages.searchResult);
        // Search location name.
        _searchChangeNotifier.changeSearchQuery(true, _searchTextFieldController.text);
      }
    },
    decoration: InputDecoration(
      hintText: _strings.searchLocationTextFieldHint,
      hintStyle: _types.subtitle1!.apply(color: _palette.divider),
      border: const OutlineInputBorder(borderSide: BorderSide.none),
      fillColor: Colors.transparent,
      contentPadding: (_strings.locale == 'en')?
        const EdgeInsets.only(left: 16, right: 3) :
        const EdgeInsets.only(left: 3, right: 8),
      prefixIcon: (_isCollapsed)? null : Image.asset(
        IconAssets.remixSearch,
        width: Dimens.searchBoxIconsSize,
        height: Dimens.searchBoxIconsSize,
        color: _palette.onBackground
      )
    ),
  );
  // :: Build SearchBox.
  Container _buildSearchBox(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _palette.textFieldBackground,
      borderRadius: BorderRadius.circular(Dimens.mediumShapesBorderRadius),
      border: Border.all(color: (_isOnError)? _palette.error : Colors.transparent)
    ),
    child: Row(
      children: [
        Expanded(child: _buildTextField(context)),
        _buildPrimaryButton(context)
      ],
    ),
  );

  // :: Build back button.
  AnimatedSize _buildBackButton(BuildContext context) => AnimatedSize(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
      child: SizedBox(
        width: (_isCollapsed)? null : 0,
        child: InkWell(
          onTap: onBackPressed,
          child: Container(
            margin: (_strings.locale == 'en')?
              const EdgeInsets.only(right: 8) :
              const EdgeInsets.only(left: 8),
            width: Dimens.searchBoxBackButtonSize,
            height: Dimens.searchBoxBackButtonSize,
            decoration: BoxDecoration(
              color: _palette.textFieldBackground,
              borderRadius: BorderRadius.circular(24)
            ),
            child: SquareImage.asset(
              (_strings.locale == 'en')? IconAssets.remixLeftArrow : IconAssets.remixRightArrow,
              dimension: Dimens.searchBoxBackButtonIconSize,
              color: _palette.onBackground,
            ),
          ),
        )
      )
  );

  @override
  Widget build(BuildContext context) {
    return BlurContainer(
      border: Border(bottom: BorderSide(color: _palette.border)),
      padding: EdgeInsets.fromLTRB(
        Dimens.horizontalPadding,
        MediaQuery.of(context).viewPadding.top,
        Dimens.horizontalPadding,
        Dimens.topAppbarBottomPadding
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTopAppBar(),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildBackButton(context),
              Expanded(child: _buildSearchBox(context))
            ]
          )
        ]
      )
    );
  }

  /// Get user location using Location Service.
  void _getUserLocation(BuildContext context) async {
    Location location = Location();

    // :: Check for location service.
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) { return; }
    }

    // :: Check for user permission.
    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus == PermissionStatus.denied) { return; }
    }

    // :: Change pageView to _SearchResultList.
    // Jump to SearchResultList.
    _jumpToListPage(_ListPages.searchResult);
    // Clear SearchNotifier text query and activate loading state.
    _searchChangeNotifier.changeSearchQuery(true, '');

    // :: Active loading state.
    setState(() {
      _isCollapsed = true;
      _isOnLoadUserLocation = true;
    });

    // :: Get location data and send latitude and longitude to AccuWeather server.
    location.getLocation().then((locationData) {
      Internet.get(context,
        uri: Urls.searchLocationByData(locationData, locale: _strings.locale),
        onComplete: (isOkay) {
          // Show empty search list if its NOT OKAY.
          if(!isOkay) _searchChangeNotifier.changeSearchResult([]);
          // Deactivate loading state.
          setState(() => _isOnLoadUserLocation = false);
        },
        onRetry: () {
          // Activate loading state.
          setState(() => _isOnLoadUserLocation = true);
        },
        onResponse: (response) {
          // Convert json to SearchResultLocation object.
          SearchResultLocation srl = SearchResultLocation.fromJson(jsonDecode(response.body), _db);
          // Set SearchBox text field to location name.
          _searchTextFieldController.text = srl.name;
          // Show user location to search result list.
          _searchChangeNotifier.changeSearchResult([srl]);
        }
      );
    });
  }
}

// :: SavedLocationsList
class _SavedLocationsList extends StatelessWidget {
  const _SavedLocationsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _savedLocationsChangeNotifier,
      builder: (_, __, ___) {
        // Show empty list message if saved locations collection is empty.
        if(SavedLocation.isCollectionEmpty(_db)) {
          return const EmptyListMessage.empty();
        } else {
          // Get all saved locations from database.
          final List<SavedLocation> locations = SavedLocation.getAll(_db);
          // Build saved locations list.
          return ListView.builder(
              padding: EdgeInsets.only(
                  top: Dimens.appbarHeightWithChild + Dimens.verticalPadding + MediaQuery.of(context).viewPadding.top,
                  bottom: Dimens.verticalPadding
              ),
              itemCount: locations.length,
              itemBuilder: (_, index) => _SavedLocationItem(
                  key: ValueKey(locations[index].id),
                  index: index,
                  location: locations[index]
              )
          );
        }
      },
    );
  }
}

class _SavedLocationItem extends StatefulWidget {
  /// The index of location in list.
  final int index;
  /// The SavedLocation object.
  final SavedLocation location;
  const _SavedLocationItem({
    Key? key,
    required this.index,
    required this.location
  }) : super(key: key);

  @override
  State<_SavedLocationItem> createState() => _SavedLocationItemState();
}

class _SavedLocationItemState extends State<_SavedLocationItem> {
  bool _isCollapsed = false;
  bool _isOnLoadTemperature = false;
  String _locationTemperature = '0';

  @override
  void initState() {
    super.initState();
    if (!widget.location.isUpToDate) {
      // Activate loading state.
      _isOnLoadTemperature = true;
      // Load current temperature from server.
      _getTemperature();
    } else {
      // Load saved temperature from database.
      _locationTemperature = '${widget.location.getTemperature(
        _userSettings.temperatureUnit.isMetric
      )}°';
    }
  }

  /// Build actions list.
  List<CustomSlidableAction> _buildActions(BuildContext context) {
    // Create empty list.
    List<CustomSlidableAction> actions = [];
    // Don't add pin action if location already pinned.
    if (!widget.location.isPinned) {
      // Add pin action.
      actions.add(CustomSlidableAction(
        onPressed: (_) => onPinActionPressed(context),
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 32,
              child: Image.asset(
                IconAssets.remixMapPin,
                color: _palette.success,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _strings.pinButtonText,
              style: _types.button!.apply(color: _palette.success)
            )
          ],
        ),
      ));
    }
    // Add delete action.
    actions.add(CustomSlidableAction(
      onPressed: (_) {
        if(widget.location.isPinned) {
          // Check internet connection.
          Internet.check(context, ifConnected: () => onDeleteActionPressed(context));
        } else {
          onDeleteActionPressed(context);
        }
      },
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 32,
              child: Image.asset(
                IconAssets.remixDeleteBinFill,
                color: _palette.error,
                fit: BoxFit.fill
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _strings.deleteButtonText,
              style: _types.button!.apply(color: _palette.error)
            )
          ],
        )
      ),
    ));
    return actions;
  }

  /// Build item widget.
  Widget _buildItemWidget() {
    final borderRadius = BorderRadius.circular(Dimens.mediumShapesBorderRadius);
    final backgroundColor = (widget.location.isPinned)? _palette.primary : Colors.transparent;
    final titleColor = (widget.location.isPinned)? _palette.onPrimary : _palette.onBackground;
    final subtitleColor = (widget.location.isPinned)? _palette.onPrimarySubtitle : _palette.subtitle;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: (widget.location.isPinned)? null : Border.all(color: Palette.of(context).border)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.location.getName(_strings.locale),
                  style: _types.searchResultLocationTitle.apply(color: titleColor)
                ),
                Text(
                  widget.location.getAddress(_strings.locale),
                  style: _types.caption!.apply(color: subtitleColor)
                )
              ],
            )),
            const SizedBox(width: 8),
            Stack(
              children: [
                Opacity(
                  opacity: (_isOnLoadTemperature)? 0 : 1,
                  child: Text(
                    _locationTemperature,
                    style: _types.savedLocationTemperature.apply(color: titleColor)
                  ),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: (_isOnLoadTemperature)? 1 : 0,
                    child: Center(child: CupertinoActivityIndicator(color: subtitleColor))
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      child: SizedBox(
        height: (_isCollapsed)? 0 : null,
        child: Slidable(
          key: UniqueKey(),
          closeOnScroll: true,
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: (widget.location.isPinned)? .3 : .6,
            children: _buildActions(context)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.horizontalPadding, vertical: 6),
            child: _buildItemWidget(),
          ),
        ),
      ),
    );
  }

  /// Send GET request to server to get current temperature.
  void _getTemperature() async {
    try {
      final result = await http.get(Urls.currentCondition(
        widget.location.locationKey,
        details: false,
        locale: _strings.locale
      ));
      if (result.statusCode == 200) {
        // Decode result form json.
        Map<String, dynamic> res = jsonDecode(result.body)[0];
        // Update saved temperature.
        widget.location.apply(
          temperatureC: res['Temperature']['Metric']['Value'],
          temperatureF: res['Temperature']['Imperial']['Value'],
          lastUpdate: DateTime.now()
        ).update(_db);
        // Set temperature.
        _locationTemperature = '${widget.location.getTemperature(
            _userSettings.temperatureUnit.isMetric
        )}°';
      } else {
        // Set temperature to x. (It means data is unavailable)
        _locationTemperature = 'x°';
      }
    } catch(_) {
      // Set temperature to x. (It means data is unavailable)
      _locationTemperature = 'x°';
    }

    // Repaint widget.
    setState(() => _isOnLoadTemperature = false);
  }

  /// Pin location.
  void onPinActionPressed(BuildContext context) {
    // Check internet connection.
    Internet.check(context, ifConnected: () {
      // Confirm user decision.
      Message(context).w(
        title: _strings.confirmMessageTitle,
        subtitle: _strings.confirmMessageSubtitle,
        buttonText: _strings.yesButtonText,
        onButtonPressed: () {
          // Pin location.
          widget.location.pin(_db);
          // Notify SavedLocationsList.
          notifySavedLocationsList();
        }
      );
    });
  }

  /// Remove location form database.
  void onDeleteActionPressed(BuildContext context) {
    // Confirm user decision.
    Message(context).e(
      title: _strings.confirmMessageTitle,
      subtitle: _strings.confirmMessageSubtitle,
      buttonText: _strings.yesButtonText,
      onButtonPressed: () {
        // Collapse item widget.
        setState(() => _isCollapsed = true);
        // Delete from database.
        widget.location.remove(_db);
        // Notify _SavedLocationsList.
        if(SavedLocation.isCollectionEmpty(_db)) {
          notifySavedLocationsList();
        } else if(widget.location.isPinned) {
          Future.delayed(const Duration(milliseconds: 200))
            .then((_) => notifySavedLocationsList());
        }
      }
    );
  }
}

// :: SearchResultList
class _SearchResultList extends StatelessWidget {
  const _SearchResultList({Key? key}) : super(key: key);

  /// Build shimmer list.
  ShimmerLoading _buildShimmerList(BuildContext context) => ShimmerLoading(
    child: ListView.separated(
      padding: EdgeInsets.fromLTRB(
        Dimens.horizontalPadding,
        Dimens.appbarHeightWithOnlySearchBox +
          MediaQuery.of(context).viewPadding.top +
          Dimens.verticalPadding,
        Dimens.horizontalPadding,
        Dimens.verticalPadding
      ),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 40),
      itemBuilder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerContainer(width: 120, height: 21, color: _palette.background),
              const SizedBox(height: 8),
              ShimmerContainer(width: 152, height: 13, color: _palette.background)
            ]
          ),
          ShimmerContainer(width: 32, height: 32, color: _palette.background)
        ]
      )
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _searchChangeNotifier,
      builder: (_, _SearchResultData data, __) {
        // Check for loading status.
        if (data.isOnLoadData) {
          // Send search request if search query is not empty.
          if (data.searchQuery.isNotEmpty) { _sendSearchRequest(context, data.searchQuery); }
          // Show loading shimmer list.
          return _buildShimmerList(context);
        }
        // Show not found message if search result list in empty.
        if(data.searchResultLocations.isEmpty) {
          return const EmptyListMessage.notFound();
        }
        // Show search result list.
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(
            Dimens.horizontalPadding,
            Dimens.appbarHeightWithOnlySearchBox + MediaQuery.of(context).viewPadding.top + Dimens.verticalPadding,
            Dimens.horizontalPadding,
            Dimens.verticalPadding
          ),
          itemCount: data.searchResultLocations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 40),
          itemBuilder: (_, int index) => _SearchResultItem(location: data.searchResultLocations[index])
        );
      },
    );
  }

  /// Send search location by name request to AccuWeather API.
  void _sendSearchRequest(BuildContext context, String textQuery) {
    // Send get request.
    Internet.get(context,
      uri: Urls.searchLocationByName(textQuery, locale: _strings.locale),
      onResponse: (response) {
        // Show search result locations.
        _searchChangeNotifier.changeSearchResult(
          SearchResultLocation.fromJsonArray(jsonDecode(response.body), _db)
        );
      }
    );
  }
}

// :::: Search result location item widget.
class _SearchResultItem extends StatefulWidget {
  final SearchResultLocation location;
  const _SearchResultItem({Key? key, required this.location}) : super(key: key);

  @override
  State<_SearchResultItem> createState() => _SearchResultItemState();
}

class _SearchResultItemState extends State<_SearchResultItem> {
  bool _isOnLoadData = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.location.name,
                style: _types.searchResultLocationTitle.apply(color: _palette.onBackground)
              ),
              const SizedBox(height: 3),
              Text(
                widget.location.address,
                style: _types.caption!.apply(color: _palette.subtitle)
              )
            ],
          )
        ),
        _buildTrailing(context)
      ],
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (widget.location.isAdded) {
      return Row(
        children: [
          Text(
            _strings.addedButtonText,
            style: _types.button!.apply(color: _palette.subtitle)
          ),
          Image.asset(
            (_strings.locale == 'en')? IconAssets.remixRightArrow : IconAssets.remixLeftArrow,
            color: _palette.subtitle,
            width: 24,
            height: 24,
          )
        ]
      );
    } else if(_isOnLoadData) {
      return Padding(
        padding: const EdgeInsets.all(5),
        child: CupertinoActivityIndicator(
          color: _palette.subtitle,
          radius: 12,
        ),
      );
    } else {
      return InkWell(
        splashColor: Colors.transparent,
        borderRadius: BorderRadius.circular(Dimens.smallShapesBorderRadius),
        onTap: () => Internet.check(context, ifConnected: () {
          _getCityInfoAndSaveToDatabase(context);
        }),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: SizedBox.square(
            dimension: 24,
            child: Image.asset(
              IconAssets.remixAddFill,
              fit: BoxFit.fill,
              color: _palette.subtitle,
            )
          ),
        ),
      );
    }
  }

  void _getCityInfoAndSaveToDatabase(BuildContext context) async {
    // Activate loading state.
    setState(() => _isOnLoadData = true);
    // Get location data from server.
    Internet.get(context,
      uri: Urls.searchLocationByKey(widget.location.locationKey),
      onComplete: (_) => setState(() => _isOnLoadData = false),
      onResponse: (response) {
        // Save to database.
        SavedLocation.fromJson(jsonDecode(response.body)).put(_db);
        // Change location add status.
        widget.location.isAdded = true;
      }
    );
  }
}

// :::: SearchResultList Notifier.
/// Custom ValueNotifier data model.
class _SearchResultData {
  bool isOnLoadData = true;
  String searchQuery = '';
  List<SearchResultLocation> searchResultLocations = const [];
  _SearchResultData();
}

/// Custom ValueNotifier for SearchResultList.
class _SearchResultNotifier extends ValueNotifier<_SearchResultData> {
  final _SearchResultData data;
  _SearchResultNotifier(this.data) : super(data);

  // Value Notifiers
  /// Update search query text value.
  void changeSearchQuery(bool isLoading, String text) {
    data.searchQuery = (text.toLowerCase().trim());
    data.isOnLoadData = isLoading;
    notifyListeners();
  }

  /// Update search result locations list.
  void changeSearchResult(List<SearchResultLocation> result) {
    data.searchResultLocations = result;
    data.isOnLoadData = false;
    data.searchQuery = '';
    notifyListeners();
  }
}

