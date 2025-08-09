import 'package:flutter/widgets.dart';

import 'grid.dart';
import 'layer.dart';
import 'screen.dart';

abstract class ContextAccessorUpdate{
  void Function(VoidCallback, [String? d]) get update;
}

/// 语境访问器
abstract class ContextAccessor implements ContextAccessorUpdate{
  ScreenContext get screen;
  GridContext get grid;
  LayerContext get fgLayers;
  LayerContext get bgLayers;
  Size get size;
  // void Function(VoidCallback) get update;
  // void Function(VoidCallback, [String? d]) get update;
  void lazyUpdate(VoidCallback c, [String? d, VoidCallback? afterUpdate]);
}