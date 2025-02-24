import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';


extension ColorExtension on Color {
  
  Color blacken(double amount){
    assert(amount >= 0 && amount <= 1);
    return whiten(1 - amount);      
  }

  Color whiten(double amount) {
    assert(amount >= 0 && amount <= 1);
    double r = clampDouble(this.r * amount, 0.0, 1.0);
    double g = clampDouble(this.g * amount, 0.0, 1.0);
    double b = clampDouble(this.b * amount, 0.0, 1.0);
    return Color.from(red:r, green:g, blue:b, alpha: a);
  }

  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness(
          clampDouble(hsl.lightness * amount, 0.0, 1.0),
        )
        .toColor();
  }

  /// Brighten the shade of the color by the [amount].
  ///
  /// [amount] is a double between 0 and 1.
  ///
  /// Based on: https://stackoverflow.com/a/60191441.
  Color brighten(double amount) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness(
          clampDouble(hsl.lightness + (1 - hsl.lightness) * amount, 0.0, 1.0),
        )
        .toColor();
  }
}

void ketchupDebug(Object? object){
  if(kDebugMode){
    print(object);
  }
}