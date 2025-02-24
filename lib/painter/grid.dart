
import 'package:flutter/material.dart';
import '../model/grid.dart';
import '../utils.dart';

typedef DrawEachCallbackReturn = void Function(String, List<NamedLine>);
typedef DrawEachCallback = void Function(NamedLine drawEach);
typedef DrawEachCallbackReturnCallback = DrawEachCallbackReturn Function(DrawEachCallback drawEachCallback); 

class GridPainter extends CustomPainter{
  
  Size? lastSize;
  final GridContext context;
  GridPainter({required this.context});

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    ketchupDebug('Painter paint size: $size');
    if(lastSize != size){
      context.notifySizeChange(size, lastSize);
      double newRatio = size.aspectRatio;
      double? oldRatio = lastSize?.aspectRatio;
      if(oldRatio != newRatio){
        context.notifyRatioChange(size, newRatio, oldRatio);
      }
      lastSize = size;
    }
    var width = size.width;
    var height = size.height;
    // canvas.drawLine(Offset(.5 * width, 0) , Offset(.5 * width, height), Paint()..color = Colors.red ..strokeWidth = 1);
    // canvas.drawLine(Offset(0, .5 * height) , Offset(width, .5 * height), Paint()..color = Colors.red ..strokeWidth = 1);
    drawEach(DrawEachCallback eachcallback){
      return (String name, List<NamedLine> lines){
        var includes = context.includes;
        var excludes = context.excludes;
        /// 默认全部模式 || 剔除模式 || 包含模式 
        if(includes.isEmpty && (excludes.isEmpty || excludes.isNotEmpty && !excludes.contains(name)) || 
          includes.isNotEmpty && includes.contains(name)){
          // ketchupDebug('Painter lines, name: $name');
          // if(name=='static_divides'){
          // ketchupDebug('Painter lines ${lines[0].paint}');
          // ketchupDebug('Painter lines ${lines[1].paint}');
            // ketchupDebug('lines ${lines[2].paint}');
          // }
          lines.forEach(eachcallback);
        }
      };
    }

    /// 优先动态获取百分比值
    double linePercent(NamedLine line) => line.percentGetter.call(size);
    
    context.verticalLines.forEach(drawEach(
      (line){
        double percentWidth = linePercent(line) * width;
        canvas.drawLine(
          Offset(percentWidth, 0) , Offset(percentWidth, height), line.paint 
            ?? (Paint()..color = Colors.redAccent.darken(.5) ..strokeWidth = .5)
          );
        }
    ));
    context.horizontalLines.forEach(drawEach(
      (line){
        double percentHeight = linePercent(line) * height;
        canvas.drawLine(
          Offset(0, percentHeight) , Offset(width, percentHeight), line.paint 
            ?? (Paint()..color = Colors.redAccent.darken(.5) ..strokeWidth = .5)
          );
        }
    ));
  }
  
}