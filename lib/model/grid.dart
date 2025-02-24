// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

enum DIRECTION {vertical, horizontal, all}

const String SCREEN_DIVIDES = 'screen_divides';
const String PERCENT_DIVIDES = 'percent_divides';
const String STATIC_DIVIDES = 'static_divides';
const String GOLDEN_RATIO_DIVIDES = 'golden_ratio_divides';

const String NAME_DIVIDE = 'divide';

const String NAME_CONTAINER = 'container';
const String NAME_LEFT = 'left';
const String NAME_RIGHT = 'right';
const String NAME_TOP = 'top';
const String NAME_BOTTOM = 'bottom';
const String NAME_CENTER = 'center';

const String NAME_MARGIN = 'margin';

const String NAME_START = 'start';
const String NAME_END = 'end';

/// 快查询标记
const String QUICK_PREFIX = '_QUICK_';

typedef PercentGetter = double Function(Size size);
typedef PercentPair = (double percent, PercentGetter getter);
typedef SizeChangeListener = void Function(Size newSize, Size? oldSize);
typedef RatioChangeListener = void Function(Size size, double newRatio, double? oldRatio);
typedef LinesDoAction = List<NamedLine> Function(DIRECTION direction, String linesFatherName, List<NamedLine> lines);

class NamedLine{
  final String name;
  final bool isGroup;
  final double percent;
  final PercentGetter percentGetter;
  final Paint? paint;
  final String? father;
  const NamedLine({required this.name, required this.percent, required this.percentGetter, this.paint, this.father, this.isGroup = false});
  factory NamedLine.percent({required String name, required double value, Paint? paint, String? father})=>NamedLine(name: name, percent: value, percentGetter: (_)=>value, paint: paint, father: father);
  factory NamedLine.getter({required String name, Size initSize = const Size.square(1.0), required PercentGetter value})=>NamedLine(name: name, percent: value(initSize), percentGetter: value);
  factory NamedLine.copy({required NamedLine copy})=>NamedLine(name: copy.name, percent: copy.percent, percentGetter: copy.percentGetter, paint: copy.paint, father: copy.father);
  factory NamedLine.repaint({required Paint repaint,required NamedLine copy})=>NamedLine(name: copy.name, percent: copy.percent, percentGetter: copy.percentGetter, paint: repaint, father: copy.father);
}

class GridContext extends ChangeNotifier{
  
  final List<SizeChangeListener> _sizeChangeListeners = [];
  final List<RatioChangeListener> _ratioChangeListeners = [];

  Map<String, List<NamedLine>> verticalLines = {
    NAME_CONTAINER: [NamedLine.percent(name: NAME_LEFT, value: 0.0), NamedLine.percent(name: NAME_CENTER, value: .5), NamedLine.percent(name: NAME_RIGHT, value: 1.0)],
  };
  Map<String, List<NamedLine>> horizontalLines = {
    NAME_CONTAINER: [NamedLine.percent(name: NAME_TOP, value: 0.0), NamedLine.percent(name: NAME_CENTER, value: .5), NamedLine.percent(name: NAME_BOTTOM, value: 1.0)]
  };

  List<NamedLine> linesDo(DIRECTION direction, LinesDoAction doAction, {List<String> includes = const [], List<String> excludes = const []} ){
    List<NamedLine> ret = [];
    if(direction == DIRECTION.all || direction == DIRECTION.vertical){
      for (var me in verticalLines.entries) {
        /// 默认全部模式 || 剔除模式 || 包含模式 
        if(includes.isEmpty && (excludes.isEmpty || excludes.isNotEmpty && !excludes.contains(me.key)) || 
          includes.isNotEmpty && includes.contains(me.key)){
          ret.addAll(doAction(DIRECTION.vertical, me.key, me.value));
        }
      }
    }
    if(direction == DIRECTION.all || direction == DIRECTION.horizontal){
      for (var me in horizontalLines.entries) {
        /// 默认全部模式 || 剔除模式 || 包含模式 
        if(includes.isEmpty && (excludes.isEmpty || excludes.isNotEmpty && !excludes.contains(me.key)) || 
          includes.isNotEmpty && includes.contains(me.key)){
          ret.addAll(doAction(DIRECTION.horizontal, me.key, me.value));
        }
      }
    }
    return ret;
  }

  Map<String, List<NamedLine>> directionLines(DIRECTION direction){
    if(DIRECTION.horizontal == direction) return horizontalLines;
    if(DIRECTION.vertical == direction) return verticalLines;
    throw Exception('DIRECTION.all should not be use here.');
  }
  
  List<NamedLine> lines(DIRECTION direction, {List<String> includes = const [], List<String> excludes = const []}){
    return linesDo(direction, (_, __, ret)=>ret, includes: includes, excludes: excludes);
  }

  List<NamedLine> linesDoPaint(DIRECTION direction, Paint paint, {List<String> includes = const [], List<String> excludes = const []}){
    return linesDo(direction, (DIRECTION d, name, _){
      if (kDebugMode) {
        ketchupDebug('Model d: $d, name: $name, list.paint: ${_[0].paint}, paint: $paint');
      }
      return directionLines(d).update(name, (list)=>list.map<NamedLine>((unPaint){
        return NamedLine.repaint(repaint: paint, copy: unPaint);
      }).toList());
    }, includes: includes, excludes: excludes);
  }

  /// 模糊查询(默认查询全部轴向)
  List<NamedLine> queryLines(String queryString, [DIRECTION direction = DIRECTION.all]){
    return lines(direction).expand((NamedLine line){
      if(queryString.contains(line.name)){
        return [line];
      }else {
        return [] as List<NamedLine>;
      }
      }).toList();
  }

  NamedLine queryFirst(String queryString, [DIRECTION direction = DIRECTION.all]){
    return queryLines(queryString, direction).first;
  }

  List<NamedLine> qureyCouple(String queryString, [DIRECTION direction = DIRECTION.all]){
    return queryLines(queryString, direction).sublist(0, 2);
  }

  void notifySizeChange(Size newSize, Size? oldSize){
    for (var listener in _sizeChangeListeners) {
      listener.call(newSize, oldSize);
    }
  }
  
  void notifyRatioChange(Size size, double newRatio, double? oldRatio){
    for (var listener in _ratioChangeListeners) {
      listener.call(size, newRatio, oldRatio);
    }
  }

  /// 快表
  Map<String, NamedLine> quickCheck = {};

  List<String> includes =[];
  List<String> excludes =[];
  
  bool get isIncludeMode => includes.isNotEmpty;

  void addSizeChangeListener(SizeChangeListener listener){
    _sizeChangeListeners.add(listener);
  }

  bool removeSizeChangeListener(SizeChangeListener listener){
    return _sizeChangeListeners.remove(listener);
  }
  
  void addRatioChangeListener(RatioChangeListener listener){
    _ratioChangeListeners.add(listener);
  }

  bool removeRatioChangeListener(RatioChangeListener listener){
    return _ratioChangeListeners.remove(listener);
  }

  
  /// 创建单条线两侧边距
  /// 支持多条辅助线一同创建
  List<NamedLine> createSingleLineMargin(List<NamedLine> singleLines, PercentGetter plusGetter, PercentGetter minusGetter){
    var samplePlusPercent = plusGetter(Size.square(1.0));
    var sampleMinusPercent = minusGetter(Size.square(1.0));
    return singleLines.expand((line){
      return ([] as List<NamedLine>)
        ..addAll(samplePlusPercent >0.0 && line.percent + samplePlusPercent < 1.0 ?
          [
            NamedLine.getter(
              name: '(${line.name})+$NAME_MARGIN:$samplePlusPercent',
              value: (size)=>line.percentGetter(size) + plusGetter(size)
            )
          ] : [])
        ..addAll(sampleMinusPercent >0.0 && line.percent-sampleMinusPercent < 1.0 ?
          [
            NamedLine.getter(
              name: '(${line.name})-$NAME_MARGIN:$sampleMinusPercent',
              value: (size)=>line.percentGetter(size) - minusGetter(size)
            )
          ] : []);
        
    }).toList();
  }

  ///创建内双边距线
  List<NamedLine> createInnerMarginDivides(PercentGetter marginPercent, [
    NamedLine? fromStartLine, 
    NamedLine? toEndLine ]){
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(name: NAME_START, value: 0.0);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(name: NAME_END, value: 1.0);
    // assert(marginPercent < toEnd.percent - fromStart.percent);
    // if(fromStart.percent + marginPercent >= toEnd.percent - marginPercent) return [];
    
    var sampleMarginPercent = marginPercent(Size.square(1.0));
    return [
        NamedLine.getter(
          name: '$NAME_MARGIN-$NAME_START:(1/1)=>$sampleMarginPercent',
          value: (size)=>fromStart.percentGetter(size) + marginPercent(size)
        ),
        NamedLine.getter(
          name: '$NAME_MARGIN-$NAME_END:(1/1)=>$sampleMarginPercent',
          value: (size)=>toEnd.percentGetter(size) - marginPercent(size)
        )
      ];
  }
  
  /// 创建黄金分割线
  List<NamedLine> createGoldenRatioDivides([
    NamedLine? fromStartLine,
    NamedLine? toEndLine]){
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(name: NAME_START, value: 0.0);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(name: NAME_END, value: 1.0);
    goldenStartPercentGetter(size)=> 0.382 * (toEnd.percentGetter(size) - fromStart.percentGetter(size)) + fromStart.percentGetter(size);
    goldenEndPercentGetter(size)=> 0.618 * (toEnd.percentGetter(size) - fromStart.percentGetter(size)) + fromStart.percentGetter(size);
    return [
      NamedLine.getter(
        name: '$GOLDEN_RATIO_DIVIDES-$NAME_START:(1/1)=>${goldenStartPercentGetter(Size.square(1.0))}',
        value: goldenStartPercentGetter
      ),
      NamedLine.getter(
        name: '$GOLDEN_RATIO_DIVIDES-$NAME_END:(1/1)=>${goldenEndPercentGetter(Size.square(1.0))}',
        value: goldenEndPercentGetter
      )
    ];
  }
  
  /// 创建百分比等分线
  /// 二等分，三条线
  /// 三等分，四条线
  /// 四等分，五条线
  List<NamedLine> createPercentDivides(int count, [
    NamedLine? fromStartLine,
    NamedLine? toEndLine,]){
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(name: NAME_START, value: 0.0);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(name: NAME_END, value: 1.0);
    assert(count >= 2);
    return List.generate(count - 1, (index){
      // var stepPercent = (toEnd.percent - fromStart.percent) / count;
      percentGetter(size) => (index + 1) * (toEnd.percentGetter(size) - fromStart.percentGetter(size)) / count + fromStart.percentGetter(size);
      return NamedLine.getter(
        name: '${index + 1}/$count$NAME_DIVIDE:(1/1)=>${percentGetter(Size.square(1.0))}',
        value: percentGetter
      );
    });
  }

  /// 创建定宽等分线(start end可以颠倒)
  /// 注意只从start开始定宽
  /// Size大小会改变数量，无法使用 PercentGetter 创建，需要在外部根据Size变化每次重新 createStaticDivides
  List<NamedLine> createStaticDivides(double staticPercent, [double count = double.infinity,
    NamedLine? fromStartLine,
    NamedLine? toEndLine]){
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(name: NAME_START, value: 0.0);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(name: NAME_END, value: 1.0);
    assert(staticPercent >0 && staticPercent <1);
    if(fromStart.percent < toEnd.percent){
      if(staticPercent + fromStart.percent > toEnd.percent) return [];
      return List.generate(min<double>(((toEnd.percent - fromStart.percent) / staticPercent), count).floor(), (index){
        var plusPercent = fromStart.percent + (index + 1) * staticPercent; 
        return NamedLine.percent(
          name: '$STATIC_DIVIDES-${index+1}:+$staticPercent:$plusPercent',
          value: plusPercent
        );
      });
    }else{
      if(fromStart.percent - staticPercent < toEnd.percent) return [];
      return List.generate(min<double>(((fromStart.percent - toEnd.percent) / staticPercent), count).floor(), (index){
        var minusPercent = fromStart.percent - (index + 1) * staticPercent; 
        return NamedLine.percent(
          name: '$STATIC_DIVIDES-${index+1}:-$staticPercent:$minusPercent',
          value: minusPercent
        );
      });
    } 
      
  }
}
