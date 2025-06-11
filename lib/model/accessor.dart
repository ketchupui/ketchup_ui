import 'package:flutter/widgets.dart';

import 'grid.dart';
import 'layer.dart';
import 'screen.dart';

/// 语境访问器
abstract class ContextAccessor{
  ScreenContext get screen;
  GridContext get grid;
  LayerContext get fgLayers;
  LayerContext get bgLayers;
  Size get size;
  // void Function(VoidCallback) get update;
  void Function(VoidCallback, [String? d]) get update;
  void lazyUpdate(VoidCallback c, [String? d, VoidCallback? afterUpdate]);
}