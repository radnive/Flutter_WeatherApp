import 'dart:math' show Random;
import 'package:flutter/material.dart' show ColorScheme, Color;
import 'package:weather_app/res/colors.dart' show ColorSchemeExtension;

class IntRange {
  int startOffset;
  int endOffset;
  IntRange(this.startOffset, this.endOffset);

  double get randomDouble {
    final Random random = Random();
    final int rndInt = (startOffset + random.nextInt(endOffset - startOffset));
    final double rndDouble = random.nextDouble();
    return rndInt + rndDouble;
  }

  int get randomInt {
    final Random random = Random();
    return (startOffset + random.nextInt(endOffset - startOffset));
  }

  bool contains(int num) => (startOffset <= num) && (endOffset >= num);
}

class AqiInfo {
  final int maxValue;
  final int value;
  final int _index;
  AqiInfo(this.value, this._index, {this.maxValue = 0});

  double get toPercent => (value * 100) / maxValue;
  Color getColor(ColorScheme palette) {
    switch (_index) {
      case 0 : return palette.info; // <- Excellent
      case 1 : return palette.success; // <- Good
      case 2 : return palette.warning; // <- Fair
      case 3 : return palette.seriousWarning; // <- Poor
      case 4 : return palette.error; // <- Unhealthy
      case 5 : return palette.danger; // <- Dangerous
      default: return palette.onBackground;
    }
  }
}

class AqiStatus {
  String status;
  AqiInfo aqi, pm10, pm2_5, co, no2, so2, o3;
  AqiStatus({
    this.status = '',
    required this.aqi,
    required this.pm10,
    required this.pm2_5,
    required this.co,
    required this.no2,
    required this.so2,
    required this.o3,
  });

  // Scale ranges.
  static List<IntRange> aqiScale = [
    IntRange(1, 19), // <- Excellent
    IntRange(20, 49), // <- Good
    IntRange(50, 99), // <- Fair
    IntRange(100, 149), // <- Poor
    IntRange(150, 249), // <- Unhealthy
    IntRange(250, 500) // <- Dangerous
  ];

  static List<IntRange> pm10Scale = [
    IntRange(1, 12), // <- Excellent
    IntRange(13, 25), // <- Good
    IntRange(26, 50), // <- Fair
    IntRange(51, 90), // <- Poor
    IntRange(91, 180), // <- Unhealthy
    IntRange(180, 250), // <- Dangerous
  ];

  static List<IntRange> pm2_5Scale = [
    IntRange(1, 7), // <- Excellent
    IntRange(8, 15), // <- Good
    IntRange(16, 30), // <- Fair
    IntRange(31, 55), // <- Poor
    IntRange(56, 110), // <- Unhealthy
    IntRange(110, 170), // <- Dangerous
  ];

  static List<IntRange> coScale = [
    IntRange(1, 2), // <- Excellent
    IntRange(3, 5), // <- Good
    IntRange(6, 8), // <- Fair
    IntRange(9, 30), // <- Poor
    IntRange(31, 100), // <- Unhealthy
    IntRange(101, 150), // <- Dangerous
  ];

  static List<IntRange> no2Scale = [
    IntRange(1, 25), // <- Excellent
    IntRange(26, 50), // <- Good
    IntRange(51, 100), // <- Fair
    IntRange(101, 200), // <- Poor
    IntRange(201, 400), // <- Unhealthy
    IntRange(401, 500), // <- Dangerous
  ];

  static List<IntRange> so2Scale = [
    IntRange(1, 25), // <- Excellent
    IntRange(26, 50), // <- Good
    IntRange(51, 120), // <- Fair
    IntRange(121, 350), // <- Poor
    IntRange(351, 500), // <- Unhealthy
    IntRange(501, 550), // <- Dangerous
  ];

  static List<IntRange> o3Scale = [
    IntRange(1, 32), // <- Excellent
    IntRange(33, 64), // <- Good
    IntRange(65, 119), // <- Fair
    IntRange(120, 179), // <- Poor
    IntRange(180, 239), // <- Unhealthy
    IntRange(240, 280), // <- Dangerous
  ];

  factory AqiStatus.random(List<String> aqiScalesText) {
    final Random random = Random();
    final int randomNumMax = random.nextInt(5);
    final pm10Index = (randomNumMax == 0)? 0 : random.nextInt(randomNumMax);
    final pm2_5Index = (randomNumMax == 0)? 0 : random.nextInt(randomNumMax);
    final coIndex = (randomNumMax == 0)? 0 : random.nextInt(randomNumMax);
    final no2Index = (randomNumMax == 0)? 0 : random.nextInt(randomNumMax);
    final so2Index = (randomNumMax == 0)? 0 : random.nextInt(randomNumMax);
    final o3Index = (randomNumMax == 0)? 0 : random.nextInt(randomNumMax);

    return AqiStatus(
      status: aqiScalesText[randomNumMax],
      aqi: AqiInfo(aqiScale[randomNumMax].randomInt, randomNumMax, maxValue: 500),
      pm10: AqiInfo(pm10Scale[pm10Index].randomInt, pm10Index, maxValue: 250),
      pm2_5: AqiInfo(pm2_5Scale[pm2_5Index].randomInt, pm2_5Index, maxValue: 170),
      co: AqiInfo(coScale[coIndex].randomInt, coIndex, maxValue: 150),
      no2: AqiInfo(no2Scale[no2Index].randomInt, no2Index, maxValue: 500),
      so2: AqiInfo(so2Scale[so2Index].randomInt, so2Index, maxValue: 250),
      o3: AqiInfo(o3Scale[o3Index].randomInt, o3Index, maxValue: 280)
    );
  }

  factory AqiStatus.empty() {
    AqiInfo ai = AqiInfo(1, 0, maxValue: 1);
    return AqiStatus(aqi: ai, pm10: ai, pm2_5: ai, co: ai, no2: ai, so2: ai, o3: ai);
  }
}