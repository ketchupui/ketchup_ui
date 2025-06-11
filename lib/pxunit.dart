import 'dart:ui';

import 'model/model.dart';

enum PxUnit { vh, vw, rpx, px, wpc, hpc }
typedef PxUnitValue<T> = (T value, PxUnit unit);
typedef PxUnitDouble = PxUnitValue<double>;
typedef PxUnitGetter = double Function(Size viewport);
typedef PxUnitValueGetter<T> = T Function(Size viewport);
typedef PxUnitDoubleGetter = PxUnitValueGetter<double>;

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
PxUnitGetter widthPercentToPxUnitGetter(PxUnit toPu){
  if(toPu == PxUnit.wpc) return (Size viewport) => 1;
  return (Size viewport)=> pxUnitGetter(PxUnit.wpc)(viewport) / pxUnitGetter(toPu)(viewport); 
}
/// 宽度百分比 的 值转换((X,wpc)->(N，?)), 默认 1：1转换为 wpc
PxUnitValueGetter<PxUnitDouble> widthPercentToPxUnitDoubleGetter(double wpcValue, [PxUnit toPu = PxUnit.wpc]){
  return (Size viewport)=> (wpcValue * widthPercentToPxUnitGetter(toPu)(viewport), toPu);
}
/// 高度百分比 的 单位转换(/hpc->/?)
PxUnitGetter heightPercentToPxUnitGetter(PxUnit toPu){
  if(toPu == PxUnit.hpc) return (Size viewport) => 1;
  return (Size viewport)=> pxUnitGetter(PxUnit.hpc)(viewport) / pxUnitGetter(toPu)(viewport); 
}
/// 高度百分比 的 值转换((Y,hpc)->(M，?)), 默认 1：1转换为 hpc
PxUnitValueGetter<PxUnitDouble> heightPercentToPxUnitDoubleGetter(double hpcValue, [PxUnit toPu = PxUnit.hpc]){
  return (Size viewport)=> (hpcValue * heightPercentToPxUnitGetter(toPu)(viewport), toPu);
}

PxUnitGetter pxUnitGetter(PxUnit pu){
  return switch(pu){
    PxUnit.vh => (Size viewport) => viewport.height / 100,
    PxUnit.vw => (Size viewport) => viewport.width / 100,
    PxUnit.rpx => (Size viewport) => viewport.width / 750,
    PxUnit.px => (Size viewport) => 1,
    PxUnit.wpc => (Size viewport) => viewport.width,
    PxUnit.hpc => (Size viewport) => viewport.height
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
PxUnitDoubleGetter rpx(double value) => pxUnitDoubleGetter((value, PxUnit.rpx));