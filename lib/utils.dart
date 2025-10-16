import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ketchup_ui/logger.dart';
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

// T ketchupDebug<T>(T object, {String? prefix, String? suffix}){
//   if(kDebugMode){
//     if(prefix != null || suffix != null){
//       print('${prefix ?? ''}$object${suffix ?? ''}');
//     } else {
//       print('ketchupDebug:$object');
//     }
//   }
//   return object;
// }

// bool isGridInclude(String name, GridContext grid){
//   List<String> includes = grid.includes;
//   List<String> excludes = grid.excludes;
//   return includes.isEmpty && (excludes.isEmpty || excludes.isNotEmpty && !excludes.contains(name)) || 
//     includes.isNotEmpty && includes.contains(name);
// }

P updateBuildDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.d([LogCategory.update, LogCategory.build], object.toString());
  }
  return object;
}

P updateGrid<P>(P object){
  if(kDebugMode){
    CategoryLogger.d([LogCategory.update, LogCategory.grid], object.toString());
  }
  return object;
}

P updateDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.dSingle(LogCategory.update, object.toString());
  }
  return object;
}

P layoutDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.dSingle(LogCategory.layout, object.toString());
  }
  return object;
}

P buildDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.dSingle(LogCategory.build, object.toString());
  }
  return object;
}

P stateLifecycleDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.d([LogCategory.state, LogCategory.lifecycle], object.toString());
  }
  return object;
}

P stateDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.dSingle(LogCategory.state, object.toString());
  }
  return object;
}

P measureUpdateDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.d([LogCategory.measure, LogCategory.update], object.toString());
  }
  return object;
}

P measureDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.dSingle(LogCategory.measure, object.toString());
  }
  return object;
} 

P focusDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.dSingle(LogCategory.focus, object.toString());
  }
  return object;
}

P gridDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.dSingle(LogCategory.grid, object.toString());
  }
  return object;
}

P uiDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.dSingle(LogCategory.ui, object.toString());
  }
  return object;
}

P pageBuildDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.d([LogCategory.page, LogCategory.build], object.toString());
  }
  return object;
}

P pageLifecycleDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.d([LogCategory.page, LogCategory.lifecycle], object.toString());
  }
  return object;
}

P navPageDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.d([LogCategory.nav, LogCategory.page], object.toString());
  }
  return object;
}

P navDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.dSingle(LogCategory.nav, object.toString());
  }
  return object;
}

P pageDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.dSingle(LogCategory.page, object.toString());
  }
  return object;
}

P lifecycleDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.dSingle(LogCategory.lifecycle, object.toString());
  }
  return object;
}

P screenDebug<P>(P object){
  if(kDebugMode){
    CategoryLogger.dSingle(LogCategory.screen, object.toString());
  }
  return object;
}

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