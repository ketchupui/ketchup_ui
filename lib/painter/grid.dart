
import 'package:flutter/material.dart';
import '../model/grid.dart';
import '../utils.dart';
import 'context.dart';

typedef DrawEachCallbackReturn = void Function(String, List<NamedLine>);
typedef DrawEachCallback = void Function(NamedLine drawEach);
typedef DrawEachCallbackReturnCallback = DrawEachCallbackReturn Function(DrawEachCallback drawEachCallback); 

class GridPainter extends ContextPainter{
  
  @override
  final GridContext context;
  GridPainter({required this.context});

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paintContext(Canvas canvas, Size size) {
    var width = size.width;
    var height = size.height;
    drawEach(DrawEachCallback eachcallback){
      return (String name, List<NamedLine> lines){
        /// 默认全部模式 || 剔除模式 || 包含模式
        if(isGridInclude(name, context)){
        // if(includes.isEmpty && (excludes.isEmpty || excludes.isNotEmpty && !excludes.contains(name)) || 
        //   includes.isNotEmpty && includes.contains(name)){

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

    /// 优先动态获取百分比值(已被NamdeLine自身方法compute代替)
    // double linePercent(NamedLine line) => line.percentGetter(size);
    // double literalFinal(NamedLine line){
    //   var literal = line.literalGetter?.call(size);
    //   return literal != null ? pxUnitValueGetter(literal)(size) : 0;
    // }
    context.verticalLines.forEach(drawEach(
      (line){
        // double paintWidth = literalFinal(line) + linePercent(line) * width;
        double paintWidth = line.computeWidth(size);
        canvas.drawLine(
          Offset(paintWidth, 0) , Offset(paintWidth, height), line.paint 
            ?? (Paint()..color = Colors.redAccent.kDarken(.5) ..strokeWidth = .5)
          );
        }
    ));
    context.horizontalLines.forEach(drawEach(
      (line){
        // double paintHeight = literalFinal(line) + linePercent(line) * height;
        double paintHeight = line.computeHeight(size);
        canvas.drawLine(
          Offset(0, paintHeight) , Offset(width, paintHeight), line.paint 
            ?? (Paint()..color = Colors.redAccent.kDarken(.5) ..strokeWidth = .5)
          );
        }
    ));
  }
  
}