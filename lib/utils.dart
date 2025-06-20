import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'model/grid.dart';

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

  Color kDarken(double amount) {
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
  Color kBrighten(double amount) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness(
          clampDouble(hsl.lightness + (1 - hsl.lightness) * amount, 0.0, 1.0),
        )
        .toColor();
  }
}

// Object? ketchupDebug(Object? object){
//   if(kDebugMode){
//     print('ketchup-ui:$object');
//   }
//   return object;
// }

T ketchupDebug<T>(T object, {String? prefix, String? suffix}){
  if(kDebugMode){
    if(prefix != null || suffix != null){
      print('${prefix ?? ''}$object${suffix ?? ''}');
    } else {
      print('ketchupDebug:$object');
    }
  }
  return object;
}

// bool isGridInclude(String name, GridContext grid){
//   List<String> includes = grid.includes;
//   List<String> excludes = grid.excludes;
//   return includes.isEmpty && (excludes.isEmpty || excludes.isNotEmpty && !excludes.contains(name)) || 
//     includes.isNotEmpty && includes.contains(name);
// }

bool isGridInclude(String name, GridContext grid){
  return !isGridExclude(name, grid);
}

bool isGridExclude(String name, GridContext grid){
  return grid.excludes.contains(name);
}

class FractionLike {
  final int numerator;
  final int denominator;

  FractionLike(this.numerator, this.denominator)
      : assert(denominator != 0, 'Denominator cannot be zero');

  /// 加法
  FractionLike operator +(FractionLike other) {
    return FractionLike(
      numerator * other.denominator + other.numerator * denominator,
      denominator * other.denominator,
    );
  }

  /// 减法
  FractionLike operator -(FractionLike other) {
    return FractionLike(
      numerator * other.denominator - other.numerator * denominator,
      denominator * other.denominator,
    );
  }

  /// 乘法
  FractionLike operator *(FractionLike other) {
    return FractionLike(
      numerator * other.numerator,
      denominator * other.denominator,
    );
  }

  /// 除法
  FractionLike operator /(FractionLike other) {
    assert(other.numerator != 0, 'Cannot divide by a fraction with zero numerator');
    return FractionLike(
      numerator * other.denominator,
      denominator * other.numerator,
    );
  }

  /// 转为 double
  double toDouble() => numerator / denominator;

  /// 约分（返回新的简化分数）
  FractionLike simplify() {
    int gcdVal = _gcd(numerator.abs(), denominator.abs());
    return FractionLike(numerator ~/ gcdVal, denominator ~/ gcdVal);
  }

  /// 最大公约数（欧几里得算法）
  int _gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  @override
  String toString() => '$numerator/$denominator';
}




//// 先写两层
// void addPostFrameCallbackUntil(bool Function() test, VoidCallback callback){
//   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       if(!test()){
//         WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//             if(test()){
//               callback();
//             }
//           },);
//       }else{
//         callback();
//       }
//     },);
// }