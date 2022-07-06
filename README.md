English | [پارسی](https://github.com/radnive/Flutter_WeatherApp/blob/master/README_PER.md)

<img width="100%" src="https://raw.githubusercontent.com/radnive/Flutter_WeatherApp/master/screenshots/english/intro.png" />

<p>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/github/license/radnive/flutter_weatherapp?logo=github" />
  </a>

  <img src="https://img.shields.io/badge/version-1.0.0-blueviolet" />

  <a href="https://docs.flutter.dev/development/tools/sdk/releases">
    <img src="https://img.shields.io/badge/flutter-3.0.3-blue" />
  </a>

  <a href="https://dart.dev/guides/whats-new">
    <img src="https://img.shields.io/badge/dart-2.17.5-blue" />
  </a>
</p>

## Table of Contents
- [What is Weather App?](#what-is-weather-app)
- [Reasons to love Weather App](#reasons-to-love-weather-app)
    - [1. Easily find the information you need](#1-easily-find-the-information-you-need)
    - [2. Customize the app as you wish](#2-customize-the-app-as-you-wish)
    - [3. Find out about the weather in every corner of the world!](#3-find-out-about-the-weather-in-every-corner-of-the-world)
- [Download application](#download-application)
- [Project cloning tips](#project-cloning-tips)
- [Useful links](#useful-links)


## What is Weather App?

Weather App is an ad-free & free-to-use application to display the weather in the simplest possible way for the user. By summarising the weather in plain-spoken and user-friendly language via its one-of-a-kind Timeline screen. No more scrolling long lists to figure out the weather as it's now summarised for you in a few lines and makes checking the weather fast, easy and actually fun! Also this app will help you plan your time around the weather in a concise and minimalistic manner. Be aware of any precipitation within an hour with a minute precision. Weather App can tell you, which part of the day is going to have a clear sky and light breeze perfect for a run or bike ride for 4 days ahead.This app uses free API plans, so it is only allowed to send 50 requests per day to these APIs. Air quality index information is also fake because currently, there is no free API for Air quality index, but this feature may be added to the app in the future. Now, if you want, [you can download and install the app from this section](#download-application).

## Reasons to love Weather App

In this section, we will review some reasons why we should love the **Weather Application**. In each section, a brief description for each page of the application is given, which introduces the features and capabilities implemented in the application.

### 1. Easily find the information you need

On the home page, you can see information about wind speed, UV index, real feels of temperature, humidity and visibility distance and also be informed about the current weather conditions and 12 hours ahead. In addition, the exact time of sunrise and sunset, the quality of the air (although the data is currently fake) and the weather forecast for the next 4 days will be available.

<img width="100%" src="https://raw.githubusercontent.com/radnive/Flutter_WeatherApp/master/screenshots/english/home.png" />

### 2. Customize the app as you wish

Customization of the app is possible on the settings page. At the top of this page, the units for measuring wind speed, temperature and visibility distance can be seen and changed. In the other settings section, you can choose between Persian and English, change the app theme to light or dark, or order the app to automatically update the home page. In the next section, Communications, there are ways to communicate with me like Instagram and more. And at the end you can see information such as app version, weather data providers, etc.

<img width="100%" src="https://raw.githubusercontent.com/radnive/Flutter_WeatherApp/master/screenshots/english/settings.png" />

### 3. Find out about the weather in every corner of the world!

You must go to the Manage Locations page to add or remove locations. On this page, you can find and add your desired location by searching for its name, or use your mobile location sensor to find your current location. When you enter the search mode, a list of the most popular locations will be displayed to you, if you wish, you can select one of these locations.

<img width="100%" src="https://raw.githubusercontent.com/radnive/Flutter_WeatherApp/master/screenshots/english/manage_locations.png" />

## Download application

This application has been developed to run on iOS and Android devices. You can download and install this app on your device through the following links. Please let me know after the installation in case of any problems so that I can fix it in next versions.

- Android apk file [29.7 MB]: [Download](https://raw.githubusercontent.com/radnive/Flutter_WeatherApp/master/output/android/WeatherApp_1.0.0.apk)
- iOS app: *Coming soon*

## Project cloning tips

Some of the assets of this project, namely the IranSans font collection and Piqo weather icon pack, are not free, so it is not possible to put them in the GitHub repository. Therefore, you should replace these assets after cloning the project on your system, otherwise you will encounter problems during execution. Also, if you wish, you can buy them from the following links.

- IranSans font collection [1,980,000 Rials]: [Purchase page](https://fontiran.com/%d8%ae%d8%a7%d9%86%d9%88%d8%a7%d8%af%d9%87-%d9%81%d9%88%d9%86%d8%aa-%d8%a7%db%8c%d8%b1%d8%a7%d9%86-%d8%b3%d9%86-%d8%b3%d8%b1%db%8c%d9%81-iran-sans-%d9%be%d9%86%d8%ac-%d9%88%d8%b2%d9%86-%d9%87%d9%85-2/)
- Piqo weather icon pack [\$42 or \$114]: [Purchase page](https://piqodesign.gumroad.com/l/weatherly3d)

API keys have also been removed from the project, and you must first create a new account on these websites through the links below and place your keys in the project.

- AccuWeather website: [SignUp page](https://developer.accuweather.com/apis)
- IpGeoLocation website: [SignUp page](https://ipgeolocation.io/signup.html)

After creating the accounts, create a file called **api_keys.dart** in the **lib/models** path and place the following keys instead of **YOUR_API_KEY** statements:

```dart
class ApiKeys {
  static const String accuweather = 'apikey=YOUR_API_KEY';
  static const String ipGeoLocation = 'apiKey=YOUR_API_KEY';
}
```

### Useful links

- UI Design project in Figma: [Project page](https://www.figma.com/file/30uIQipRHF5Zx2gjwsA8fD/WeatherApp-UI-Design?node-id=0%3A1)
- UI Design images on Instagram: [Instagram page](https://www.instagram.com/p/CfoqEusNXPb/?utm_source=ig_web_button_share_sheet)
- UI Design images on Dribbble: [Dribbble page](https://dribbble.com/radnive)
- UI Design images on Pinterest: [Pinterest page](https://nl.pinterest.com/radnivedev/weather-app/)
