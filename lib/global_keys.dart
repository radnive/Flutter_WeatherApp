import 'package:flutter/material.dart' show GlobalKey;
import 'package:weather_app/pages/home.dart' show HomePageState;
import 'package:weather_app/pages/manage_locations.dart' show TopAppBarState;
import 'package:weather_app/pages/settings.dart' show SettingsPageState;

final GlobalKey<HomePageState> homePageGlobalKey = GlobalKey<HomePageState>();
final GlobalKey<SettingsPageState> settingsPageGlobalKey = GlobalKey<SettingsPageState>();
final GlobalKey<TopAppBarState> manageLocationsAppBarPageGlobalKey = GlobalKey<TopAppBarState>();