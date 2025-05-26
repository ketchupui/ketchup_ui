import 'package:flutter/material.dart';
import '../model/context.dart';

abstract class ContextPainter extends CustomPainter{
  Size? lastSize;
  BaseContext get context;
  void paintContext(Canvas ctxCanvas, Size ctxSize);
  
  @override
  void paint(Canvas canvas, Size size) {
    // ketchupDebug('Painter paint size: $size');
    // if(lastSize != size){
    //   context.notifySizeChange(size, lastSize);
    //   double newRatio = size.aspectRatio;
    //   double? oldRatio = lastSize?.aspectRatio;
    //   if(oldRatio != newRatio){
    //     context.notifyRatioChange(size, newRatio, oldRatio);
    //   }
    //   lastSize = size;
    // }
    paintContext(canvas, size);
  }
  
}