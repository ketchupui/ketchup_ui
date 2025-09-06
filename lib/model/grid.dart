// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:ketchup_ui/ketchup_ui.dart';

enum DIRECTION_ENUM { vertical, horizontal }
enum END_POINT { include_start_only, include_end_only, include_start_end, exclude_start_end }

class DIRECTION {
  final Set<DIRECTION_ENUM> sets;

  const DIRECTION._(this.sets);
  factory DIRECTION.from(DIRECTION_ENUM d) => DIRECTION._({d});

  static const DIRECTION horizontal = DIRECTION._({DIRECTION_ENUM.horizontal});
  static const DIRECTION vertical = DIRECTION._({DIRECTION_ENUM.vertical});
  static const DIRECTION both = DIRECTION._({
    DIRECTION_ENUM.horizontal,
    DIRECTION_ENUM.vertical,
  });

  bool contains(DIRECTION_ENUM direction) => sets.contains(direction);
}

// enum DIRECTION_ORDER { start, end }

const String SCREEN_DIVIDES = 'screen_divides';
const String PERCENT_DIVIDES = 'percent_divides';
const String STATIC_DIVIDES = 'static_divides';
const String GOLDEN_RATIO_DIVIDES = 'golden_ratio_divides';

const String NAME_DIVIDE = 'divide';
const String NAME_CUSTOM = 'custom';

const String NAME_CONTAINER = 'container';
const String NAME_LEFT = 'left';
const String NAME_RIGHT = 'right';
const String NAME_TOP = 'top';
const String NAME_BOTTOM = 'bottom';
const String NAME_MIDDLE = 'middle';

const String NAME_MARGIN = 'margin';

const String NAME_START = 'start';
const String NAME_END = 'end';

const String NAME_RENAME = 'rename';

/// 快查询标记
const String QUICK_PREFIX = '_QUICK_';

typedef RectGetter = Rect Function(Size size);
typedef LinesDoAction = List<NamedLine> Function(DIRECTION_ENUM direction, String linesFatherName, List<NamedLine> lines);


class NamedLine{
  final String name;
  final bool isGroup;
  // final LiteralGetter? literalGetter;
  // final double percent;
  // final PercentGetter percentGetter;
  final Expression expression;
  final Paint? paint;
  final String? father;
  // const NamedLine({required this.name, required this.percent, required this.percentGetter, this.paint, this.father, this.literalGetter, this.isGroup = false});
  const NamedLine({required this.name, required this.expression, this.paint, this.father, this.isGroup = false});
  /// 表达式计算结果
  factory NamedLine.expression(Expression expression, {required String name, Size sample = const Size.square(1.0), Paint? paint, String? father})=>NamedLine(name: name, expression: expression, paint: paint, father: father);
  /// literal 和 percent 混合计算的结果值(使用expression代替)
  // factory NamedLine.result({required String name, Size sample = const Size.square(1.0), required PercentGetter percentGetter, required LiteralGetter? literalGetter, Paint? paint, String? father})=>NamedLine(name: name, percent: percentGetter(sample), percentGetter: percentGetter, literalGetter: literalGetter, paint: paint, father: father);
  /// 支持 vh vw rpx 等相对单位值 以及 px 绝对值
  factory NamedLine.literal((double, PxUnit) value, {required String name, Paint? paint, String? father})=>NamedLine(name: name, expression: Expression.literal(value), paint: paint, father: father);
  factory NamedLine.percent(double value, {required String name, Paint? paint, String? father})=>NamedLine(name: name, expression: Expression.percent(value), paint: paint, father: father);
  /// vertical 创建的是 vw
  /// horizental 创建的是 vh
  // factory NamedLine.viewport(double vhOrVW, {required String name, Paint? paint, String? father})=>NamedLine(name: name, percent: vhOrVW / 100, percentGetter: (_)=> vhOrVW / 100, paint: paint, father: father);
  // factory NamedLine.getter(PercentGetter value, {required String name, Size sample = const Size.square(1.0)})=>NamedLine(name: name, percent: value(sample), percentGetter: value);
  factory NamedLine.copy(NamedLine copy)=>NamedLine(name: copy.name, expression: copy.expression, paint: copy.paint, father: copy.father);
  factory NamedLine.rename({required String rename,required NamedLine copy})=>NamedLine(name: rename, expression: copy.expression, paint: copy.paint, father: copy.father);
  factory NamedLine.repaint({required Paint repaint,required NamedLine copy})=>NamedLine(name: copy.name, expression: copy.expression, paint: repaint, father: copy.father);
  
  // ExpressionOld get expression => ExpressionOld(percentGetter, literalGetter);

  operator +(Object o){
    return expression + o;
  }

  operator -(Object o){
    return expression - o;
  }

  operator *(Object o){
    return expression * o;
  }

  operator /(Object o){
    return expression / o;
  }

  /// 计算终值
  // double computeWidth(Size size) => literalGetter != null ? pxUnitDoubleGetter(literalGetter!.call(size))(size) + percentGetter(size) * size.width : percentGetter(size) * size.width;
  // double computeHeight(Size size) => literalGetter != null ? pxUnitDoubleGetter(literalGetter!.call(size))(size) + percentGetter(size) * size.height : percentGetter(size) * size.height;
  double computeWidth(Size viewport) => expression.computeWidth(viewport);
  double computeHeight(Size viewport) => expression.computeHeight(viewport);
  double computeAny(double any, Size viewport) => expression.computeAny(any, viewport);

  // bool looseEqual(Object other){
  //   if(identical(this, other)) return true;
  //   final equal = other is NamedLine && expression.looseEqual(other.expression);    
  //   return equal;
  // }

  @override
  String toString(){
    return name;
  }
  
}

class GridContext extends BaseContext{

  Map<String, List<NamedLine>> verticalLines = {
    NAME_CONTAINER: [NamedLine.percent(0.0, name: NAME_LEFT,), NamedLine.percent(.5, name: NAME_MIDDLE), NamedLine.percent(1.0, name: NAME_RIGHT)],
  };
  Map<String, List<NamedLine>> horizontalLines = {
    NAME_CONTAINER: [NamedLine.percent(0.0, name: NAME_TOP), NamedLine.percent(.5, name: NAME_MIDDLE), NamedLine.percent(1.0, name: NAME_BOTTOM)]
  };

  List<NamedLine> createAddtoVertical(String name, List<NamedLine> Function() ifAbsent){
    return verticalLines.putIfAbsent(name, ifAbsent);
  }

  List<NamedLine> createAddtoHorizontal(String name, List<NamedLine> Function() ifAbsent){
    return horizontalLines.putIfAbsent(name, ifAbsent);
  }

  List<NamedLine> createUpdateAddVertical(String name, List<NamedLine> Function() updateAdd){
    return verticalLines.update(name, (old)=>[ ...old, ...updateAdd()], ifAbsent: updateAdd);
  }
  
  List<NamedLine> createUpdateAddHorizontal(String name, List<NamedLine> Function() updateAdd){
    return horizontalLines.update(name, (old)=>[ ...old, ...updateAdd()], ifAbsent: updateAdd);
  }

  List<NamedLine> createUpdateVertical(String name, List<NamedLine> Function() update){
    return verticalLines.update(name, (_)=>update(), ifAbsent: update);
  }

  List<NamedLine> createUpdateHorizontal(String name, List<NamedLine> Function() update){
    return horizontalLines.update(name, (_)=>update(), ifAbsent: update);
  }

  List<List<RectGetter>> createRectGetterMatrix({bool reverseX = false, bool reverseY = false, 
                    // bool looseEqualIgnored = false, double xMinFactor = 0.00001, double yMinFactor = 0.00001,
                    bool Function(NamedLine later, NamedLine prev)? equalIgnoreCompare,
                    List<String> includes = const [], List<String> excludes = const [], Size? sampleSortSize}){
    var vLines = lines(DIRECTION.vertical, includes: includes, excludes: excludes);
    if(sampleSortSize != null) vLines = useSampleWidthSorted(sampleSortSize, vLines);
    ketchupDebug(
      vLines = reverseX ? vLines.reversed.toList(): vLines
    );
    var hLines = lines(DIRECTION.horizontal, includes: includes, excludes: excludes);
    if(sampleSortSize != null) hLines = useSampleHeightSorted(sampleSortSize, hLines);
    ketchupDebug(
      hLines = reverseY ? hLines.reversed.toList(): hLines
    );
    return createRectGetterMatrixFromLines(reverseX: reverseX, reverseY: reverseY, vLines: vLines, hLines: hLines, equalIgnoreCompare: equalIgnoreCompare );
  }

  List<List<RectGetter>> createRectGetterMatrixFromLines({bool reverseX = false, bool reverseY = false, 
                  // bool looseEqualIgnored = false, double xMinFactor = 0.00001, double yMinFactor = 0.00001,
                  bool Function(NamedLine later, NamedLine prev)? equalIgnoreCompare,
                  required List<NamedLine> vLines, required List<NamedLine> hLines}){
    assert(vLines.length >= 2 && hLines.length >= 2);
    List<List<RectGetter>> retColumns = [];
    for(var yGetterIndex = 0; yGetterIndex < hLines.length - 1; yGetterIndex++){
      var yLessGetter = reverseY ? hLines[yGetterIndex + 1] : hLines[yGetterIndex];
      var yMoreGetter = reverseY ? hLines[yGetterIndex] : hLines[yGetterIndex + 1];
      if(equalIgnoreCompare?.call(yMoreGetter, yLessGetter) ?? false) continue;
      // if(!looseEqualIgnored && yMoreGetter.percent - yLessGetter.percent < yMinFactor || yMoreGetter.looseEqual(yLessGetter)) continue;
      List<RectGetter> newRow = []; 
      for(var xGetterIndex =0; xGetterIndex < vLines.length - 1; xGetterIndex++){
        var xLessGetter = reverseX ? vLines[xGetterIndex + 1] : vLines[xGetterIndex];
        var xMoreGetter = reverseX ? vLines[xGetterIndex] : vLines[xGetterIndex + 1];
        if(equalIgnoreCompare?.call(xMoreGetter, xLessGetter) ?? false) continue;
        // if(!looseEqualIgnored && xMoreGetter.percent - xLessGetter.percent < xMinFactor || xMoreGetter.looseEqual(xLessGetter)) continue;
        newRow.add((Size size)=>Rect.fromPoints(
          Offset(xLessGetter.computeWidth(size), yLessGetter.computeHeight(size)),
          Offset(xMoreGetter.computeWidth(size), yMoreGetter.computeHeight(size))
        ));
      }
      retColumns.add(newRow);
    }
    return retColumns;
  }

  List<NamedLine> linesDo(DIRECTION direction, LinesDoAction doAction, {
    List<String> includes = const [], 
    List<String> excludes = const []}){
    List<NamedLine> ret = [];
    if(direction.contains(DIRECTION_ENUM.vertical)){
      for (var me in verticalLines.entries) {
        /// 默认全部模式 || 剔除模式 || 包含模式 
        if(includes.isEmpty && (excludes.isEmpty || excludes.isNotEmpty && !excludes.contains(me.key)) || 
          includes.isNotEmpty && includes.contains(me.key)){
          ret.addAll(doAction(DIRECTION_ENUM.vertical, me.key, me.value));
        }
      }
    }
    if(direction.contains(DIRECTION_ENUM.horizontal)){
      for (var me in horizontalLines.entries) {
        /// 默认全部模式 || 剔除模式 || 包含模式 
        if(includes.isEmpty && (excludes.isEmpty || excludes.isNotEmpty && !excludes.contains(me.key)) || 
          includes.isNotEmpty && includes.contains(me.key)){
          ret.addAll(doAction(DIRECTION_ENUM.horizontal, me.key, me.value));
        }
      }
    }
    return ret;
  }

  bool isEmpty(String tagName){
    return !verticalLines.containsKey(tagName) && !horizontalLines.containsKey(tagName); 
  }

  bool isNotEmpty(String tagName){
    return verticalLines.containsKey(tagName) || horizontalLines.containsKey(tagName);
  }

  Map<String, List<NamedLine>> directionLines(DIRECTION_ENUM direction){
    switch(direction){
      case DIRECTION_ENUM.horizontal:
        return horizontalLines;
      case DIRECTION_ENUM.vertical:
        return verticalLines;
    }
  }
  
  List<NamedLine> lines(DIRECTION direction, {List<String> includes = const [], List<String> excludes = const []}){
    return linesDo(direction, (_, __, ret)=>ret, includes: includes, excludes: excludes);
  }

  List<NamedLine> linesDoPaint(DIRECTION direction, Paint paint, {List<String> includes = const [], List<String> excludes = const []}){
    return linesDo(direction, (DIRECTION_ENUM d, name, _){
      // if (kDebugMode) {
      //   ketchupDebug('Model d: $d, name: $name, list.paint: ${_[0].paint}, paint: $paint');
      // }
      return directionLines(d).update(name, (list)=>list.map<NamedLine>((unPaint){
        return NamedLine.repaint(repaint: paint, copy: unPaint);
      }).toList());
    }, includes: includes, excludes: excludes);
  }

  /// 模糊查询(默认查询全部轴向)
  List<NamedLine> queryLines(String queryString, [DIRECTION_ENUM direction = DIRECTION_ENUM.vertical]){
    return lines(DIRECTION.from(direction)).expand<NamedLine>((NamedLine line){
      if(line.name.contains(queryString)){
        return [line];
      }else {
        return [];
      }
      }).toList();
  }

  NamedLine queryFirst(String queryString, DIRECTION_ENUM direction){
    return queryLines(queryString, direction).first;
  }

  NamedLine queryLast(String queryString, DIRECTION_ENUM direction){
    return queryLines(queryString, direction).last;
  }

  List<NamedLine> qureyFirstCouple(String queryString, DIRECTION_ENUM direction){
    final query = queryLines(queryString, direction);
    assert(query.length > 1);
    return [query.first, query.last];
  }
  
  List<NamedLine> qureySecondCouple(String queryString, DIRECTION_ENUM direction){
    final query = queryLines(queryString, direction);
    assert(query.length > 3);
    return [query[1], query[query.length - 2]];
  }

  /// 快表
  Map<String, NamedLine> quickCheck = {};

  List<String> includes =[];
  List<String> excludes =[];
  List<String> get nameUnions => verticalLines.keys.toSet()
      .union(horizontalLines.keys.toSet()).toList();
  List<String> get nameDifferences => verticalLines.keys.toSet()
      .difference(horizontalLines.keys.toSet()).toList();
  List<String> get nameIntersections => verticalLines.keys.toSet()
      .intersection(horizontalLines.keys.toSet()).toList();
  
  bool get isIncludeMode => includes.isNotEmpty;

  static List<NamedLine> useSampleWidthSorted(Size sample, List<NamedLine> chaos){
    return chaos..sort((a, b)=>a.computeWidth(sample).compareTo(b.computeWidth(sample)));
  }

  static List<NamedLine> useSampleHeightSorted(Size sample, List<NamedLine> chaos){
    return chaos..sort((a, b)=>a.computeHeight(sample).compareTo(b.computeHeight(sample)));
  }
  
  /// 创建单条线两侧边距
  /// 支持多条辅助线一同创建
  static List<NamedLine> createSingleLineMargin(List<NamedLine> singleLines, { Expression? plus, Expression? minus, END_POINT endPoint = END_POINT.exclude_start_end}){
    assert(plus != null || minus != null);
    return singleLines.expandIndexed<NamedLine>((index, line){
      if(index == 0 && endPoint == END_POINT.include_end_only || endPoint == END_POINT.exclude_start_end) return [];
      if(index == singleLines.length - 1 && endPoint == END_POINT.include_start_only || endPoint == END_POINT.exclude_start_end) return [];
      return [
        if(minus != null)
        NamedLine.expression(line - minus, name: '(${line.name})-$NAME_MARGIN:$minus'),
        if(plus != null)
        NamedLine.expression(line + plus, name: '(${line.name})+$NAME_MARGIN:$plus')
      ];
    }).toList();
  }

  /// 创建内双边距线
  /// https://immvpc32u2.feishu.cn/docx/ZMTVd0gWkoRVRBxmXtIcRyVPnhd?from=from_copylink
  static List<NamedLine> createLiteralInnerMarginDivides((double, PxUnit) literal, {
    NamedLine? fromStartLine, 
    NamedLine? toEndLine,
    END_POINT endPoint = END_POINT.exclude_start_end}){
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(0.0, name: NAME_START);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(1.0, name: NAME_END);

    List<NamedLine> excludeStartEnd = [
        NamedLine.expression(fromStart + literal, 
          name: '$NAME_MARGIN-$NAME_START:$literal',
        ),
        NamedLine.expression(toEnd - literal, 
          name: '$NAME_MARGIN-$NAME_END:$literal',
        ),
      ];
    return [
      if(endPoint == END_POINT.include_start_only || endPoint == END_POINT.include_start_end)
      NamedLine.rename(rename: '$NAME_MARGIN-$NAME_START-$NAME_RENAME-${fromStart.name}', copy: fromStart),
      ...excludeStartEnd,
      if(endPoint == END_POINT.include_end_only || endPoint == END_POINT.include_start_end)
      NamedLine.rename(rename: '$NAME_MARGIN-$NAME_END-$NAME_RENAME-${toEnd.name}', copy: toEnd)
    ];
  }
  
  ///创建内双边距线
  static List<NamedLine> createInnerMarginDivides(Expression divide, {
    NamedLine? fromStartLine, 
    NamedLine? toEndLine,
    END_POINT endPoint = END_POINT.exclude_start_end}){
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(0.0, name: NAME_START);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(1.0, name: NAME_END);
    List<NamedLine> excludeStartEnd = [
        NamedLine.expression(fromStart + divide, 
          name: '$NAME_MARGIN-$NAME_START:$divide',
        ),
        NamedLine.expression(toEnd - divide, 
          name: '$NAME_MARGIN-$NAME_END:$divide',
        ),
      ];
    return [
      if(endPoint == END_POINT.include_start_only || endPoint == END_POINT.include_start_end)
      NamedLine.rename(rename: '$NAME_MARGIN-$NAME_START', copy: fromStart),
      ...excludeStartEnd,
      if(endPoint == END_POINT.include_end_only || endPoint == END_POINT.include_start_end)
      NamedLine.rename(rename: '$NAME_MARGIN-$NAME_END', copy: toEnd)
    ];
  }
  
  /// 创建黄金分割线
  // @Deprecated('not support expression')
  /// not support expression
  // static List<NamedLine> createGoldenRatioDivides({
  //   NamedLine? fromStartLine,
  //   NamedLine? toEndLine,
  //   bool includeStartEnd = false}){
  //   NamedLine fromStart = fromStartLine ?? NamedLine.percent(0.0, name: NAME_START);
  //   NamedLine toEnd = toEndLine ?? NamedLine.percent(1.0, name: NAME_END);
  //   goldenStartPercentGetter(size)=> 0.382 * (toEnd.percentGetter(size) - fromStart.percentGetter(size)) + fromStart.percentGetter(size);
  //   goldenEndPercentGetter(size)=> 0.618 * (toEnd.percentGetter(size) - fromStart.percentGetter(size)) + fromStart.percentGetter(size);
  //   List<NamedLine> excludeStartEnd = [
  //     NamedLine.getter(
  //       goldenStartPercentGetter,
  //       name: '$GOLDEN_RATIO_DIVIDES-$NAME_START:(1/1)=>${goldenStartPercentGetter(Size.square(1.0))}',
  //     ),
  //     NamedLine.getter(
  //       goldenEndPercentGetter,
  //       name: '$GOLDEN_RATIO_DIVIDES-$NAME_END:(1/1)=>${goldenEndPercentGetter(Size.square(1.0))}',
  //     )
  //   ];
  //   return includeStartEnd ? [
  //     NamedLine.rename(rename: '$GOLDEN_RATIO_DIVIDES-$NAME_START', copy: fromStart),
  //     ... excludeStartEnd,
  //     NamedLine.rename(rename: '$GOLDEN_RATIO_DIVIDES-$NAME_END', copy: toEnd)
  //   ] : excludeStartEnd;
  // }

  /// 创建自定义线(分段占比重权值，加和占首尾线区间=1)
  static List<NamedLine> createCustomSeperateSpaces(List<int> weights, {
    NamedLine? fromStartLine,
    NamedLine? toEndLine,
    END_POINT endPoint = END_POINT.exclude_start_end}){
    assert(weights.length >= 2);
    var addups = weights.fold<List<int>>([], (addup, weight)=>addup..add(addup.isEmpty ? weight : addup.last + weight));
    return createCustomDivides(addups.map<double>((addup)=>addup/addups.last).toList()..removeLast(), fromStartLine: fromStartLine, toEndLine: toEndLine, endPoint: endPoint);
  }

  /// 创建自定义线(占首尾线区间比值 < 1)
  static List<NamedLine> createCustomDivides(List<double> customs, {
    NamedLine? fromStartLine,
    NamedLine? toEndLine,
    END_POINT endPoint = END_POINT.exclude_start_end}){
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(0.0, name: NAME_START);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(1.0, name: NAME_END);
    assert(customs.isNotEmpty && customs.every((custom)=>custom <= 1));
    final rangeFromStartToEnd = toEnd - fromStart;
    var excludeStartEnd =  customs.mapIndexed<NamedLine>((int index, double custom){
      final expr = rangeFromStartToEnd * custom;
      return NamedLine.expression(expr, name: '$index/$NAME_CUSTOM:$expr');
    }).toList();
    return [
      if(endPoint == END_POINT.include_start_only || endPoint == END_POINT.include_start_end)
      NamedLine.rename(rename: '$NAME_CUSTOM-$NAME_START', copy: fromStart),
      ... excludeStartEnd, 
      if(endPoint == END_POINT.include_end_only || endPoint == END_POINT.include_start_end)
      NamedLine.rename(rename: '$NAME_CUSTOM-$NAME_END', copy: toEnd),
    ];
  }
  
  /// 创建百分比等分线(含首尾线)
  /// 二等分，三条线
  /// 三等分，四条线
  /// 四等分，五条线
  static List<NamedLine> createPercentDivides(int count, {
    NamedLine? fromStartLine,
    NamedLine? toEndLine,
    END_POINT endPoint = END_POINT.exclude_start_end}){
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(0.0, name: NAME_START);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(1.0, name: NAME_END);
    assert(count >= 2);
    var excludeStartEnd = List.generate(count - 1, (index){
      return NamedLine.expression(fromStart + (toEnd - fromStart) * ((index + 1) / count),
        name: '${index + 1}/$count:$NAME_DIVIDE}',
      );
    });
    return [
      if(endPoint == END_POINT.include_start_only || endPoint == END_POINT.include_start_end)
        NamedLine.rename(rename: '0/$count$NAME_DIVIDE', copy: fromStart),
      ... excludeStartEnd, 
      if(endPoint == END_POINT.include_end_only || endPoint == END_POINT.include_start_end)
        NamedLine.rename(rename: '$count/$count$NAME_DIVIDE', copy: toEnd), 
    ];
  }

  static List<NamedLine> createExpressionStaticDivides(Expression static, double count, {(DIRECTION_ENUM, Size)? infinitySample, 
    NamedLine? fromStartLine,
    NamedLine? toEndLine,
    END_POINT endPoint = END_POINT.exclude_start_end}){
    assert(count != double.infinity || infinitySample != null);
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(0.0, name: NAME_START);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(1.0, name: NAME_END);
    Expression rangeFromStartToEnd = toEnd - fromStart;
    if(count == double.infinity){
      switch(infinitySample!.$1){
        case DIRECTION_ENUM.vertical:
          count = rangeFromStartToEnd.computeWidth(infinitySample.$2) / static.computeWidth(infinitySample.$2);
          break;
        case DIRECTION_ENUM.horizontal:
          count = rangeFromStartToEnd.computeHeight(infinitySample.$2) / static.computeHeight(infinitySample.$2);
      }
    }
    List<NamedLine> excludeStartEnd = List.generate(count.floor(), (index){
      var plusExpr = fromStart + static * (index + 1); 
      return NamedLine.expression(plusExpr, name: '$STATIC_DIVIDES-${index+1}:$plusExpr');
    });

    return [
      if(endPoint == END_POINT.include_start_only || endPoint == END_POINT.include_start_end)
        NamedLine.rename(rename: '$STATIC_DIVIDES-$NAME_START', copy: fromStart),
      ...excludeStartEnd,
      if(endPoint == END_POINT.include_end_only || endPoint == END_POINT.include_start_end)
        NamedLine.rename(rename: '$STATIC_DIVIDES-$NAME_END', copy: toEnd),
    ];
  }

  /// 创建定宽等分线(start end可以颠倒)
  /// 注意只从start开始定宽
  /// Size大小会改变数量，无法使用 PercentGetter 创建，需要在外部根据Size变化每次重新 createStaticDivides
  // @Deprecated('not support expression, use createExpressionStaticDivides instead !')
  // static List<NamedLine> createStaticDivides(double staticPercent, {double count = double.infinity,
  //   NamedLine? fromStartLine,
  //   NamedLine? toEndLine,
  //   bool includeStartEnd = false}){
  //   NamedLine fromStart = fromStartLine ?? NamedLine.percent(0.0, name: NAME_START);
  //   NamedLine toEnd = toEndLine ?? NamedLine.percent(1.0, name: NAME_END);
  //   assert(staticPercent >0 && staticPercent <1);
  //   if(fromStart.percent < toEnd.percent){
  //     List<NamedLine> excludeStartEnd;
  //     if(staticPercent + fromStart.percent > toEnd.percent) {
  //       excludeStartEnd = [];
  //     }else{
  //       excludeStartEnd = List.generate(min<double>(((toEnd.percent - fromStart.percent) / staticPercent), count).floor(), (index){
  //         var plusPercent = fromStart.percent + (index + 1) * staticPercent; 
  //         return NamedLine.percent(
  //           plusPercent,
  //           name: '$STATIC_DIVIDES-${index+1}:+$staticPercent:$plusPercent',
  //         );
  //       });
  //     }
  //     return includeStartEnd ? [
  //       NamedLine.rename(rename: '$STATIC_DIVIDES-$NAME_START', copy: fromStart),
  //       ...excludeStartEnd,
  //       NamedLine.rename(rename: '$STATIC_DIVIDES-$NAME_END', copy: toEnd),
  //     ]: excludeStartEnd;
  //   }else{
  //     return createReverseStaticDivides(staticPercent, 
  //       count: count, fromEndLine: toEndLine, toStartLine: fromStartLine, includeStartEnd: includeStartEnd);
  //   } 
  // }
  
  // @Deprecated('not support expression, use createReverseExpressionStaticDivides instead !')
  // static List<NamedLine> createReverseStaticDivides(double staticPercent, {double count = double.infinity, 
  //   NamedLine? fromEndLine,
  //   NamedLine? toStartLine,
  //   bool includeStartEnd = false}){
  //   NamedLine fromStart = fromEndLine ?? NamedLine.percent(1.0, name: NAME_END);
  //   NamedLine toEnd = toStartLine ?? NamedLine.percent(0.0, name: NAME_START);
  //   assert(staticPercent >0 && staticPercent <1);
  //   List<NamedLine> excludeStartEnd;
  //   if(toEnd.percent + staticPercent > fromStart.percent ){
  //     excludeStartEnd = [];
  //   }else{
  //     excludeStartEnd = List.generate(min<double>(((fromStart.percent - toEnd.percent) / staticPercent), count).floor(), (index){
  //       var minusPercent = fromStart.percent - (index + 1) * staticPercent;
  //       return NamedLine.percent(
  //         minusPercent,
  //         name: '$STATIC_DIVIDES-${index+1}:-$staticPercent:$minusPercent',
  //       );
  //     /// 反序输出确保从小到大排列
  //     }).reversed.toList();
  //   }
  //   /// 起始点也应该反序
  //   return includeStartEnd ? [
  //     NamedLine.rename(rename: '$STATIC_DIVIDES-$NAME_END', copy: toEnd),
  //     ...excludeStartEnd,
  //     NamedLine.rename(rename: '$STATIC_DIVIDES-$NAME_START', copy: fromStart),
  //   ]: excludeStartEnd;
  // }

  static List<NamedLine> createReverseExpressionStaticDivides(Expression static, double count, {(DIRECTION_ENUM, Size)? infinitySample, 
    NamedLine? fromEndLine,
    NamedLine? toStartLine,
    END_POINT endPoint = END_POINT.exclude_start_end,
  }){
    assert(count != double.infinity || infinitySample != null);
    NamedLine fromStart = fromEndLine ?? NamedLine.percent(1.0, name: NAME_END);
    NamedLine toEnd = toStartLine ?? NamedLine.percent(0.0, name: NAME_START);
    Expression rangeFromStartToEnd = fromStart - toEnd;
    if(count == double.infinity){
      switch(infinitySample!.$1){
        case DIRECTION_ENUM.vertical:
          // count = ((fromStart - toEnd) as Expression).verticalWidthMergeLiteral(infinitySample.$3 ?? PxUnit.wpc)(infinitySample.$2).$1 / staticExpr.verticalWidthMergeLiteral(infinitySample.$3 ?? PxUnit.wpc)(infinitySample.$2).$1;
          count = rangeFromStartToEnd.computeWidth(infinitySample.$2) / static.computeWidth(infinitySample.$2);
          break;
        case DIRECTION_ENUM.horizontal:
          // count = ((fromStart - toEnd) as Expression).horizontalHeightMergeLiteral(infinitySample.$3 ?? PxUnit.hpc)(infinitySample.$2).$1 / staticExpr.horizontalHeightMergeLiteral(infinitySample.$3 ?? PxUnit.hpc)(infinitySample.$2).$1;
          count = rangeFromStartToEnd.computeHeight(infinitySample.$2) / static.computeWidth(infinitySample.$2);
      }
    }
    List<NamedLine> excludeStartEnd = List.generate(count.floor(), (index){
      var minusExpr = fromStart - static * (index + 1);
      return NamedLine.expression(minusExpr, name: '$STATIC_DIVIDES-${index+1}:$minusExpr');
    /// 反序输出确保从小到大排列
    }).reversed.toList();
    
    /// 起始点也应该反序
    return [
      if(endPoint == END_POINT.include_end_only || endPoint == END_POINT.include_start_end) 
        NamedLine.rename(rename: '$STATIC_DIVIDES-$NAME_END', copy: toEnd),
      ...excludeStartEnd,
      if(endPoint == END_POINT.include_start_only || endPoint == END_POINT.include_start_end) 
        NamedLine.rename(rename: '$STATIC_DIVIDES-$NAME_START', copy: fromStart),
    ];
  }

  /// 是否绘制拼缝
  static bool gridNeedPaintSplitLine = true;
}
