import 'package:flutter/material.dart';
import '../model/accessor.dart';
import '../model/layer.dart';
import 'context.dart';

class LayerPainter extends ContextPainter{

  @override
  final LayerContext context;
  ContextAccessor accessor;
  /// 启用 repaint 机制重绘 CusotmPainter
  LayerPainter({required this.context, required this.accessor}):super(repaint: context);

  @override
  /// 关闭 Widget diff 机制下的重绘判断
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
  
  @override
  void paintContext(Canvas ctxCanvas, Size ctxSize) {
    for (var lpo in context.layers) {
      lpo.delegatePaint(ctxCanvas, ctxSize);
    }
  }

  @override
  bool? hitTest(Offset position) {
    return false;
    // return super.hitTest(position);
  }

}
