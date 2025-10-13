import 'package:flutter/widgets.dart';
import 'package:ketchup_ui/ketchup_ui.dart';

import 'grid.dart';
import 'layer.dart';
import 'screen/screen.dart';

abstract class ContextAccessorUpdate{
  void Function(VoidCallback, [String? d]) get update;
}

/// 语境访问器
abstract class ContextAccessor implements ContextAccessorUpdate{
  ScreenContext get screen;
  // BasicNavigatorBuilder? get nav;
  GridContext get grid;
  LayerContext get fgLayers;
  LayerContext get bgLayers;
  Size get size;
  // void Function(VoidCallback) get update;
  // void Function(VoidCallback, [String? d]) get update;
  // void measureUpdate(VoidCallback c, [String? d, VoidCallback? afterMeasured]);
}

/// TODO: 没写完哈
// class ContextAccessorImpl extends ContextAccessor {

//   ContextAccessorImpl({required this.bgLayers, required this.fgLayers, required this.grid, required this.screen, required this.size, required setState});

//   @override
//   LayerContext bgLayers;

//   @override
//   LayerContext fgLayers;

//   @override
//   GridContext grid;

//   @override
//   void lazyUpdate(VoidCallback c, [String? d, VoidCallback? afterUpdate]) {
//     // TODO: implement lazyUpdate
//   }

//   @override
//   ScreenContext screen;

//   @override
//   Size size;

//   @override
//   // TODO: implement update
//   void Function(VoidCallback p1, [String? d]) get update => throw UnimplementedError();
  
// }