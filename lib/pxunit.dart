import 'dart:math';
import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';

typedef PercentGetter = double Function(Size size);
typedef LiteralGetter = PxUnitDouble Function(Size size);
enum PxUnit { vh, vw, vmin, vmax, rpx, px, wpc, hpc,
  /// 一种中间存储形态 1 whpc = 1wpc + 1hpc = (1.0, 1.0) whpc
  // whpc, vwh 
  }
typedef PxUnitValue<T> = (T value, PxUnit unit);
typedef PxUnitDouble = PxUnitValue<double>;
typedef PxUnitVector = PxUnitValue<Vector2>;
// typedef PxUnitGetter = double Function(Size viewport);
typedef PxUnitValueGetter<T> = T Function(Size viewport);
typedef PxUnitDoubleGetter = PxUnitValueGetter<double>;
typedef PxUnitVectorGetter = PxUnitValueGetter<Vector2>;

PercentGetter pxUnitWidthPercentGetter(PxUnit pu){
  return (Size viewport)=>pxUnitGetter(pu)(viewport) / viewport.width;
}

PercentGetter pxUnitHeightPercentGetter(PxUnit pu){
  return (Size viewport)=>pxUnitGetter(pu)(viewport) / viewport.height;
}

PercentGetter pxUnitDoubleWidthPercentGetter(PxUnitDouble value){
  return (Size viewport)=>pxUnitDoubleGetter(value)(viewport) / viewport.width;
}

PercentGetter pxUnitDoubleHeightPercentGetter(PxUnitDouble value){
  return (Size viewport)=>pxUnitDoubleGetter(value)(viewport) / viewport.height;
}

/// 宽度百分比 的 单位转换(/wpc->/?)
PxUnitDoubleGetter widthPercentToPxUnitGetter(PxUnit toPu){
  if(toPu == PxUnit.wpc) return (Size viewport) => 1;
  return (Size viewport)=> pxUnitGetter(PxUnit.wpc)(viewport) / pxUnitGetter(toPu)(viewport); 
}
/// 宽度百分比 的 值转换((X,wpc)->(N，?)), 默认 1：1转换为 wpc
PxUnitValueGetter<PxUnitDouble> widthPercentToPxUnitDoubleGetter(double wpcValue, [PxUnit toPu = PxUnit.wpc]){
  return (Size viewport)=> (wpcValue * widthPercentToPxUnitGetter(toPu)(viewport), toPu);
}
/// 高度百分比 的 单位转换(/hpc->/?)
PxUnitDoubleGetter heightPercentToPxUnitGetter(PxUnit toPu){
  if(toPu == PxUnit.hpc) return (Size viewport) => 1;
  return (Size viewport)=> pxUnitGetter(PxUnit.hpc)(viewport) / pxUnitGetter(toPu)(viewport); 
}
/// 高度百分比 的 值转换((Y,hpc)->(M，?)), 默认 1：1转换为 hpc
PxUnitValueGetter<PxUnitDouble> heightPercentToPxUnitDoubleGetter(double hpcValue, [PxUnit toPu = PxUnit.hpc]){
  return (Size viewport)=> (hpcValue * heightPercentToPxUnitGetter(toPu)(viewport), toPu);
}

PxUnitValueGetter<double> pxUnitGetter(PxUnit pu){
  return switch(pu){
    PxUnit.vh => (Size viewport) => viewport.height / 100,
    PxUnit.vw => (Size viewport) => viewport.width / 100,
    PxUnit.vmin => (Size viewport) => min(viewport.height, viewport.width) / 100,
    PxUnit.vmax => (Size viewport) => max(viewport.height, viewport.width) / 100,
    PxUnit.rpx => (Size viewport) => viewport.width / 750,
    PxUnit.px => (Size viewport) => 1,
    PxUnit.wpc => (Size viewport) => viewport.width,
    PxUnit.hpc => (Size viewport) => viewport.height,
  };
}

PxUnitDoubleGetter pxUnitDoubleGetter(PxUnitDouble value){
  return (Size viewport)=> value.$1 * pxUnitGetter(value.$2)(viewport);
}

PxUnitValueGetter<Size> vhSize(Size size) => (Size viewport) => size * pxUnitGetter(PxUnit.vh)(viewport);
PxUnitValueGetter<Offset> vhOffset(Offset offset) => (Size viewport) => offset * pxUnitGetter(PxUnit.vh)(viewport);
PxUnitValueGetter<Rect> vhRect(Rect rect) => (Size viewport) => rect.topLeft * pxUnitGetter(PxUnit.vh)(viewport) & rect.size * pxUnitGetter(PxUnit.vh)(viewport);
PxUnitValueGetter<Rect> vhRectOnlySize(Rect rect) => (Size viewport) => rect.topLeft & rect.size * pxUnitGetter(PxUnit.vh)(viewport);


PxUnitDoubleGetter vh(double value) => pxUnitDoubleGetter((value, PxUnit.vh));
PxUnitDoubleGetter vw(double value) => pxUnitDoubleGetter((value, PxUnit.vw));
PxUnitDoubleGetter vmin(double value) => pxUnitDoubleGetter((value, PxUnit.vmin));
PxUnitDoubleGetter vmax(double value) => pxUnitDoubleGetter((value, PxUnit.vmax));
PxUnitDoubleGetter rpx(double value) => pxUnitDoubleGetter((value, PxUnit.rpx));

PxUnitDouble pxUnitDouble(double value, PxUnit unit) => (value, unit);
PxUnitDouble pxIntToDouble(PxUnitValue<int> pxInt) => (pxInt.$1.toDouble(), pxInt.$2);