import 'package:flutter/material.dart';
import '../model/accessor.dart';
import '../model/layer.dart';
import 'context.dart';

class LayerPainter extends ContextPainter{

  @override
  final LayerContext context;
  ContextAccessor accessor;
  LayerPainter({required this.context, required this.accessor});

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
  
  @override
  void paintContext(Canvas ctxCanvas, Size ctxSize) {
    for (var lpo in context.layers) {
      lpo.delegatePaint(ctxCanvas, ctxSize);
    }
  }

}
