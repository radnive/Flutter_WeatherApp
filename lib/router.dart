import 'dart:io' show Platform, exit;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:weather_app/components/message.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/database/entities/saved_location_entity.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:weather_app/global_keys.dart';
import 'package:weather_app/pages/home.dart';
import 'package:weather_app/pages/manage_locations.dart';
import 'package:weather_app/pages/settings.dart';
import 'package:weather_app/pages/start.dart';

// To hold app route path information.
class AppRoutePath {
  final int id;

  AppRoutePath.start() : id = 0;
  AppRoutePath.home() : id = 1;
  AppRoutePath.manageLocations() : id = 2;
  AppRoutePath.settings() : id = 3;

  bool get isStart => id == 0;
  bool get isHome => id == 1;
  bool get isManageLocations => id == 2;
  bool get isSettings => id == 3;
}

// Show destination page with slide animation.
class SlidePage extends Page {
  final Widget child;
  final Object? args;
  const SlidePage({LocalKey? key, required this.child, this.args}) : super(key: key);

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      transitionDuration: const Duration(milliseconds: 700),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (_, animation1, animation2, child) {
        final CurvedAnimation curvedAnimation = CurvedAnimation(
            parent: animation1,
            curve: Curves.fastOutSlowIn
        );

        final Animation<Offset> animation = curvedAnimation.drive(Tween<Offset>(
            begin: const Offset(1, 0),
            end: const Offset(0, 0)
        ));

        return SlideTransition(position: animation, child: child);
      },

    );
  }
}

class AppRouterDelegate extends RouterDelegate<AppRoutePath> with
    ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {

  @override
  GlobalKey<NavigatorState>? navigatorKey;
  Database db;
  AppRoutePath _currentRoute;
  bool _isBackButtonDisabled;

  // Create router.
  AppRouterDelegate(this.db) :
    navigatorKey = GlobalKey<NavigatorState>(),
    _isBackButtonDisabled = false,
    _currentRoute = (SavedLocation.isCollectionEmpty(db))?
      AppRoutePath.start() : AppRoutePath.home();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, result) {
        if (!route.didPop(result)) { return false; }
        popRoute();
        return true;
      },
      pages: [
        // Start page.
        MaterialPage(key: const ValueKey('StartPage'), child: StartPage(navigateTo: _navigateTo)),

        // Home page.
        if(_currentRoute.isHome) MaterialPage(
          key: const ValueKey('HomePage'),
          child: HomePage(
            key: homePageGlobalKey,
            navigateTo: _navigateTo,
            changeBackButtonStatus: _setBackButtonStatus,
          )
        ),

        // ManageLocations page.
        if(_currentRoute.isManageLocations) SlidePage(
          key: const ValueKey('ManageLocations'),
          child: ManageLocations(
            appBarKey: manageLocationsAppBarPageGlobalKey,
            navigateTo: _navigateTo,
            changeBackButtonStatus: _setBackButtonStatus,
          )
        ),

        // Settings page.
        if(_currentRoute.isSettings) SlidePage(
          key: const ValueKey('SettingsPage'),
          child: SettingsPage(
            key: settingsPageGlobalKey,
            navigateTo: _navigateTo,
            changeBackButtonStatus: _setBackButtonStatus
          )
        )
      ]
    );
  }

  @override
  Future<bool> popRoute() async {
    if(_currentRoute.isSettings) {
      // Tell Settings page that back button pressed.
      settingsPageGlobalKey.currentState?.onBackPressed();
    }

    if(_currentRoute.isManageLocations) {
      // Tell Settings page that back button pressed.
      manageLocationsAppBarPageGlobalKey.currentState?.onBackPressed();
    }

    // :: Check for back button availability.
    if(_isBackButtonDisabled) { return true; }

    // :: If saved locations collection is empty, navigate to start page.
    if (_currentRoute.isManageLocations || _currentRoute.isSettings) {
      if(SavedLocation.isCollectionEmpty(db)) {
        _navigateTo(AppRoutePath.start());
        return true;
      } else {
        _navigateTo(AppRoutePath.home());
        return true;
      }
    }

    // :: Confirm exit app when user click on NavigationBar back button in home or start pages.
    return _confirmExitApp();
  }

  // Navigate to any page of app.
  void _navigateTo(AppRoutePath routePath) {
    _currentRoute = routePath;
    notifyListeners();
  }

  // Disable NavigationBar back button.
  void _setBackButtonStatus(bool isDisabled) => _isBackButtonDisabled = isDisabled;

  // Confirm exit app when user click on NavigationBar back button in home or start pages.
  Future<bool> _confirmExitApp() async {
    // Get BuildContext from navigatorKey.
    BuildContext? context = navigatorKey?.currentContext;

    // Check for context.
    if(context != null) {
      // Get Strings resource.
      final strings = S.of(context);

      // Show confirm exit message.
      Message(context).e(
        title: strings.confirmExitMessageTitle,
        subtitle: strings.confirmExitMessageSubtitle,
        buttonText: strings.yesButtonText,
        onButtonPressed: () {
          // Check for platform.
          if (Platform.isAndroid) {
            // Close app on android devices.
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            // Close app on iOS devices.
            exit(0);
          }
        }
      );

      return true; // TRUE means back button is disable and app doesn't close.
    } else {
      return false; // FALSE means back button is enable and app will close.
    }
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {}
}

// For parse url.
class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    final pathSegments = uri.pathSegments;

    // Handle '/'
    if(uri.pathSegments.isEmpty) {
      return AppRoutePath.start();
    }

    // Handle '/home'
    if(pathSegments[0] == 'home') {
      return AppRoutePath.home();
    }

    // Handle '/manageCities'
    if(pathSegments[0] == 'manageCities') {
      return AppRoutePath.manageLocations();
    }

    // Handle '/settings'
    if(pathSegments[0] == 'settings') {
      return AppRoutePath.settings();
    }

    return AppRoutePath.start();
  }
}
