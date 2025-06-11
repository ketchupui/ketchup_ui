// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ketchup_ui/ketchup_ui.dart';
import '../pxunit.dart';
import 'context.dart';

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
typedef PercentGetter = double Function(Size size);
typedef LiteralGetter = PxUnitDouble Function(Size size);
// typedef PercentPair = (double percent, PercentGetter getter);
typedef LinesDoAction = List<NamedLine> Function(DIRECTION_ENUM direction, String linesFatherName, List<NamedLine> lines);

class Expression {
  final PercentGetter percentGetter;
  final LiteralGetter? literal;
  const Expression(this.percentGetter, this.literal);
  factory Expression.literal((double, PxUnit) lt) => Expression((Size size)=>0, (Size size)=>lt);
  factory Expression.literalGetter(LiteralGetter getter) => Expression((Size size)=>0, getter);
  factory Expression.percent(double value) => Expression((Size size)=>value, null);
  factory Expression.percentGetter(PercentGetter getter) => Expression(getter, null);

  operator +(Object o){
    switch(o){
      case NamedLine n:
        return this + n.expression;
      case (double, PxUnit) l:
        return this + Expression.literal(l);
      case LiteralGetter lg:
        return this + Expression.literalGetter(lg);
      case double p:
        return this + Expression.percent(p);
      case PercentGetter pg:
        return this + Expression.percentGetter(pg);
      case Expression e:
        if(literal != null || e.literal != null){
          return Expression((Size size)=>percentGetter(size) + e.percentGetter(size), (Size size){
            final a = literal?.call(size); 
            final b = e.literal?.call(size);
            /// 单位相同或者只有一个值
            if(a?.$2 == b?.$2 || a == null || b == null){
              return (((a?.$1 ?? 0) + (b?.$1 ?? 0)), (a?.$2 ?? b?.$2)!);
            }else
            /// 单位里有 wpc 和 hpc 的统一到[w,h]pc
            if(a.$2 == PxUnit.wpc){
              return (a.$1 + pxUnitDoubleWidthPercentGetter(b)(size), PxUnit.wpc);
            }else
            if(a.$2 == PxUnit.hpc){
              return (a.$1 + pxUnitDoubleHeightPercentGetter(b)(size), PxUnit.hpc);
            }else
            if(b.$2 == PxUnit.wpc){
              return (pxUnitDoubleWidthPercentGetter(a)(size) + b.$1, PxUnit.wpc);
            }else
            if(b.$2 == PxUnit.hpc){
              return (pxUnitDoubleWidthPercentGetter(a)(size) + b.$1, PxUnit.hpc);
            /// 单位里没有 wpc 和 hpc 的统一到 px
            }else{
              return (pxUnitDoubleGetter(a)(size) + pxUnitDoubleGetter(b)(size), PxUnit.px);
            }
          });
        }else{
          return Expression((Size size)=>percentGetter(size) + e.percentGetter(size), null);
        }
    }
  }

  operator -(Object o){
    switch(o){
      case NamedLine n:
        return this - n.expression;
      case (double, PxUnit) l:
        return this - Expression.literal(l);
      case LiteralGetter lg:
        return this - Expression.literalGetter(lg);
      case double p:
        return this - Expression.percent(p);
      case PercentGetter pg:
        return this - Expression.percentGetter(pg);
      case Expression e:
        if(literal != null || e.literal != null){
          return Expression((Size size)=>percentGetter(size) - e.percentGetter(size), (Size size){
            final a = literal?.call(size);
            final b = e.literal?.call(size);
            if(a?.$2 == b?.$2 || a == null || b == null){
              return (((a?.$1 ?? 0) - (b?.$1 ?? 0)), (a?.$2 ?? b?.$2)!); 
            /// 单位里有 wpc 和 hpc 的统一到[w,h]pc
            }if(a.$2 == PxUnit.wpc){
              return (a.$1 - pxUnitDoubleWidthPercentGetter(b)(size), PxUnit.wpc);
            }else
            if(a.$2 == PxUnit.hpc){
              return (a.$1 - pxUnitDoubleHeightPercentGetter(b)(size), PxUnit.hpc);
            }else
            if(b.$2 == PxUnit.wpc){
              return (pxUnitDoubleWidthPercentGetter(a)(size) - b.$1, PxUnit.wpc);
            }else
            if(b.$2 == PxUnit.hpc){
              return (pxUnitDoubleWidthPercentGetter(a)(size) - b.$1, PxUnit.hpc);
            /// 单位里没有 wpc 和 hpc 的统一到 px
            }else{
              return (pxUnitDoubleGetter(a)(size) - pxUnitDoubleGetter(b)(size), PxUnit.px);
            }
          });
        }else{
          return Expression((Size size)=>percentGetter(size) - e.percentGetter(size), null);
        }
    }
  }

  operator *(Object o){
    switch(o){
      case int i:
        if(literal != null){
          return Expression((Size size)=>percentGetter(size) * i, (Size size){
            final a = literal!.call(size);
            return (a.$1 * i, a.$2);
          });
        }else{
          return Expression((Size size)=>percentGetter(size) * i, null);
        }
      case double d:
        if(literal != null){
          return Expression((Size size)=>percentGetter(size) * d, (Size size){
            final a = literal!.call(size);
            return (a.$1 * d, a.$2);
          });
        }else{
          return Expression((Size size)=>percentGetter(size) * d, null);
        }
    }
  }

  operator /(Object o){
    switch(o){
      case int i:
        if(literal != null){
          return Expression((Size size)=>percentGetter(size) / i, (Size size){
            final a = literal!.call(size);
            return (a.$1 / i, a.$2);
          });
        }else{
          return Expression((Size size)=>percentGetter(size) / i, null);
        }
      case double d:
        if(literal != null){
          return Expression((Size size)=>percentGetter(size) / d, (Size size){
            final a = literal!.call(size);
            return (a.$1 / d, a.$2);
          });
        }else{
          return Expression((Size size)=>percentGetter(size) / d, null);
        }
    }
  }

  /// 全部转换为宽度的 百分比值
  PercentGetter verticalWidthMergePercent(){
    if(literal != null){
      return (Size size){
        return percentGetter(size) + pxUnitDoubleWidthPercentGetter(literal!.call(size))(size);
      };
    }else{
      return percentGetter;
    }
  }
  /// 全部转换为高度的 百分比值
  PercentGetter horizontalHeightMergePercent(){
    if(literal != null){
      return (Size size){
        return percentGetter(size) + pxUnitDoubleHeightPercentGetter(literal!.call(size))(size);
      };
    }else{
      return percentGetter;
    }
  }

  /// 纵线(横轴)转为字面量(单位值)表示，优先转成指定单位，其次是同一单位，否则转成 wpc(widthPercent)
  LiteralGetter verticalWidthMergeLiteral([PxUnit? pu]){
    return (Size size){
        final target = literal?.call(size);
        final unit = pu ?? target?.$2 ?? PxUnit.wpc;
        return (widthPercentToPxUnitDoubleGetter(percentGetter(size), unit)(size).$1 + (literal?.call(size).$1 ?? 0), unit);
    };
  }
  Expression verticalWidthMergeLiteralExpression([PxUnit? pu]) => Expression.literalGetter(verticalWidthMergeLiteral(pu));
  /// 横线(纵轴)转为字面量(单位值)表示，优先转成指定单位，其次同一单位，否则转成 hpc(heightPercent)
  LiteralGetter horizontalHeightMergeLiteral([PxUnit? pu]){
    return (Size size){
        final target = literal?.call(size);
        final unit = pu ?? target?.$2 ?? PxUnit.hpc;
        return (heightPercentToPxUnitDoubleGetter(percentGetter(size), unit)(size).$1 + (literal?.call(size).$1 ?? 0), unit);
    };
  }
  Expression horizontalHeightMergeLiteralExpression([PxUnit? pu]) => Expression.literalGetter(horizontalHeightMergeLiteral(pu));
  bool looseEqual(Expression other, [Size sampleSize = const Size.square(100)]){
    return percentGetter(sampleSize) == other.percentGetter(sampleSize) && literal?.call(sampleSize) == other.literal?.call(sampleSize);
  }

  String looseEqualString(Expression other, [Size sampleSize = const Size.square(100)]){
    double samplePercent = percentGetter(sampleSize);
    double otherSamplePercent = other.percentGetter(sampleSize);
    String percentEqual = samplePercent == otherSamplePercent ? '==' : '!='; 
    (double, PxUnit)? sampleLiteral = literal?.call(sampleSize);
    (double, PxUnit)? otherSampleLiteral = other.literal?.call(sampleSize);
    String literalEqual = sampleLiteral == otherSampleLiteral ? '==' : '!=';
    String finalEqual = samplePercent == otherSamplePercent && sampleLiteral == otherSampleLiteral ? 'true' : 'false';
    return '''percent part:$samplePercent $percentEqual $otherSamplePercent
literal part:$sampleLiteral $literalEqual $otherSampleLiteral
result: $finalEqual
''';
  }

}

class NamedLine{
  final String name;
  final bool isGroup;
  final LiteralGetter? literalGetter;
  final double percent;
  final PercentGetter percentGetter;
  final Paint? paint;
  final String? father;
  const NamedLine({required this.name, required this.percent, required this.percentGetter, this.paint, this.father, this.literalGetter, this.isGroup = false});
  /// 表达式计算结果
  factory NamedLine.expression(Expression expression, {required String name, Size sample = const Size.square(1.0), Paint? paint, String? father})=>NamedLine(name: name, percent: expression.percentGetter(sample), percentGetter: expression.percentGetter, literalGetter: expression.literal, paint: paint, father: father);
  /// literal 和 percent 混合计算的结果值(使用expression代替)
  // factory NamedLine.result({required String name, Size sample = const Size.square(1.0), required PercentGetter percentGetter, required LiteralGetter? literalGetter, Paint? paint, String? father})=>NamedLine(name: name, percent: percentGetter(sample), percentGetter: percentGetter, literalGetter: literalGetter, paint: paint, father: father);
  /// 支持 vh vw rpx 等相对单位值 以及 px 绝对值
  factory NamedLine.literal((double, PxUnit) value, {required String name, Paint? paint, String? father})=>NamedLine(name: name, percent: 0, percentGetter: (_)=> 0, literalGetter: (_)=>value, paint: paint, father: father);
  /// vertical 创建的是 vw
  /// horizental 创建的是 vh
  factory NamedLine.viewport(double vhOrVW, {required String name, Paint? paint, String? father})=>NamedLine(name: name, percent: vhOrVW / 100, percentGetter: (_)=> vhOrVW / 100, paint: paint, father: father);
  factory NamedLine.percent(double value, {required String name, Paint? paint, String? father})=>NamedLine(name: name, percent: value, percentGetter: (_)=>value, paint: paint, father: father);
  factory NamedLine.getter(PercentGetter value, {required String name, Size sample = const Size.square(1.0)})=>NamedLine(name: name, percent: value(sample), percentGetter: value);
  factory NamedLine.copy(NamedLine copy)=>NamedLine(name: copy.name, percent: copy.percent, percentGetter: copy.percentGetter, paint: copy.paint, father: copy.father, literalGetter: copy.literalGetter);
  factory NamedLine.rename({required String rename,required NamedLine copy})=>NamedLine(name: rename, percent: copy.percent, percentGetter: copy.percentGetter, paint: copy.paint, father: copy.father, literalGetter: copy.literalGetter);
  factory NamedLine.repaint({required Paint repaint,required NamedLine copy})=>NamedLine(name: copy.name, percent: copy.percent, percentGetter: copy.percentGetter, paint: repaint, father: copy.father, literalGetter: copy.literalGetter);
  
  Expression get expression => Expression(percentGetter, literalGetter);

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
  double computeWidth(Size size) => literalGetter != null ? pxUnitDoubleGetter(literalGetter!.call(size))(size) + percentGetter(size) * size.width : percentGetter(size) * size.width;
  double computeHeight(Size size) => literalGetter != null ? pxUnitDoubleGetter(literalGetter!.call(size))(size) + percentGetter(size) * size.height : percentGetter(size) * size.height;

  bool looseEqual(Object other){
    if(identical(this, other)) return true;
    final _equal = other is NamedLine && expression.looseEqual(other.expression);    
    // if(_equal){
    //   ketchupDebug('lq:true,$this,$other');
    // }
    return _equal;
  }

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

  List<List<RectGetter>> createRectGetterMatrix({bool reverseX = false, bool reverseY = false, bool looseEqualIgnored = false, double xMinFactor = 0.00001, double yMinFactor = 0.00001,
                    List<String> includes = const [], List<String> excludes = const [], Size? sampleSortSize}){
    var vLines = lines(DIRECTION.vertical, includes: includes, excludes: excludes);
    if(sampleSortSize != null) vLines = useSampleWidthSorted(sampleSortSize, vLines);
    vLines = reverseX ? vLines.reversed.toList(): vLines;
    // ketchupDebug(vLines);
    var hLines = lines(DIRECTION.horizontal, includes: includes, excludes: excludes);
    if(sampleSortSize != null) hLines = useSampleHeightSorted(sampleSortSize, hLines);
    hLines = reverseY ? hLines.reversed.toList(): hLines;
    // ketchupDebug(hLines);
    // assert(gameDebug(vLines).length >= 2 && gameDebug(hLines).length >= 2);
    assert(vLines.length >= 2 && hLines.length >= 2);
    List<List<RectGetter>> retColumns = [];
    for(var yGetterIndex = 0; yGetterIndex < hLines.length - 1; yGetterIndex++){
      var yLessGetter = reverseY ? hLines[yGetterIndex + 1] : hLines[yGetterIndex];
      var yMoreGetter = reverseY ? hLines[yGetterIndex] : hLines[yGetterIndex + 1];
      if(!looseEqualIgnored && yMoreGetter.percent - yLessGetter.percent < yMinFactor || yMoreGetter.looseEqual(yLessGetter)) continue;
      List<RectGetter> newRow = []; 
      for(var xGetterIndex =0; xGetterIndex < vLines.length - 1; xGetterIndex++){
        var xLessGetter = reverseX ? vLines[xGetterIndex + 1] : vLines[xGetterIndex];
        var xMoreGetter = reverseX ? vLines[xGetterIndex] : vLines[xGetterIndex + 1];
        if(!looseEqualIgnored && xMoreGetter.percent - xLessGetter.percent < xMinFactor || xMoreGetter.looseEqual(xLessGetter)) continue;
        
        newRow.add((Size size)=>Rect.fromPoints(
          Offset(xLessGetter.computeWidth(size), yLessGetter.computeHeight(size)),
          Offset(xMoreGetter.computeWidth(size), yMoreGetter.computeHeight(size))
          // Offset(xLessGetter.percentGetter(size) * size.width, yLessGetter.percentGetter(size) * size.height),
          // Offset(xMoreGetter.percentGetter(size) * size.width, yMoreGetter.percentGetter(size) * size.height),
          // Offset(
          //   literalValue(xLessGetter, size) + xLessGetter.percentGetter(size) * size.width, 
          //   literalValue(yLessGetter, size) + yLessGetter.percentGetter(size) * size.height),
          // Offset(
          //   literalValue(xMoreGetter, size) + xMoreGetter.percentGetter(size) * size.width, 
          //   literalValue(yMoreGetter, size) + yMoreGetter.percentGetter(size) * size.height),
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
  static List<NamedLine> createSingleLineMargin(List<NamedLine> singleLines, PercentGetter plusGetter, PercentGetter minusGetter){
    var samplePlusPercent = plusGetter(Size.square(1.0));
    var sampleMinusPercent = minusGetter(Size.square(1.0));
    return singleLines.expand<NamedLine>((line){
      return []
        ..addAll(samplePlusPercent >0.0 && line.percent + samplePlusPercent < 1.0 ?
          [
            NamedLine.getter(
              (size)=>line.percentGetter(size) + plusGetter(size),
              name: '(${line.name})+$NAME_MARGIN:$samplePlusPercent',
            )
          ] : [])
        ..addAll(sampleMinusPercent >0.0 && line.percent-sampleMinusPercent < 1.0 ?
          [
            NamedLine.getter(
              (size)=>line.percentGetter(size) - minusGetter(size),
              name: '(${line.name})-$NAME_MARGIN:$sampleMinusPercent',
            )
          ] : []);
        
    }).toList();
  }

  /// 创建内双边距线
  /// https://immvpc32u2.feishu.cn/docx/ZMTVd0gWkoRVRBxmXtIcRyVPnhd?from=from_copylink
  static List<NamedLine> createLiteralInnerMarginDivides((double, PxUnit) literal, {
    NamedLine? fromStartLine, 
    NamedLine? toEndLine,
    bool includeStartEnd = false }){
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(0.0, name: NAME_START);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(1.0, name: NAME_END);
    // assert(marginPercent < toEnd.percent - fromStart.percent);
    // if(fromStart.percent + marginPercent >= toEnd.percent - marginPercent) return [];
    // late PxUnitDouble tempLiteral;
    List<NamedLine> excludeStartEnd = [
        NamedLine.expression(fromStart + literal, 
          name: '$NAME_MARGIN-$NAME_START:$literal',
        ),
        // NamedLine.result(
        //   name: '$NAME_MARGIN-$NAME_START:$literal',
        //   percentGetter: fromStart.percentGetter,
        //   literalGetter: fromStart.literalGetter != null ? 
        //     (Size size) => ((tempLiteral = fromStart.literalGetter!(size)).$2 == literal.$2 ? 
        //       (tempLiteral.$1 + literal.$1, literal.$2) : 
        //       (pxUnitDoubleGetter(tempLiteral)(size) + pxUnitDoubleGetter(literal)(size), PxUnit.px)) : 
        //     (Size size) => literal,
        // ),
        NamedLine.expression(toEnd - literal, 
          name: '$NAME_MARGIN-$NAME_END:$literal',
        ),
        // NamedLine.result(
        //   name: '$NAME_MARGIN-$NAME_END:$literal',
        //   percentGetter: toEnd.percentGetter,
        //   literalGetter: toEnd.literalGetter != null ? 
        //     (Size size)=> ((tempLiteral = toEnd.literalGetter!(size)).$2 == literal.$2 ? 
        //       (tempLiteral.$1 - literal.$1, literal.$2) : 
        //       (pxUnitDoubleGetter(tempLiteral)(size) - pxUnitDoubleGetter(literal)(size), PxUnit.px)) : 
        //     (Size size) => ( - literal.$1, literal.$2 ),
        // )
      ];
    return includeStartEnd ? [
      NamedLine.rename(rename: '$NAME_MARGIN-$NAME_START-$NAME_RENAME-${fromStart.name}', copy: fromStart),
      ...excludeStartEnd,
      NamedLine.rename(rename: '$NAME_MARGIN-$NAME_END-$NAME_RENAME-${toEnd.name}', copy: toEnd)
    ] : excludeStartEnd;
  }
  
  ///创建内双边距线
  static List<NamedLine> createInnerMarginDivides(PercentGetter marginPercent, {
    NamedLine? fromStartLine, 
    NamedLine? toEndLine,
    bool includeStartEnd = false }){
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(0.0, name: NAME_START);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(1.0, name: NAME_END);
    // assert(marginPercent < toEnd.percent - fromStart.percent);
    // if(fromStart.percent + marginPercent >= toEnd.percent - marginPercent) return [];
    var sampleMarginPercent = marginPercent(Size.square(1.0));
    List<NamedLine> excludeStartEnd = [
        NamedLine.expression(fromStart + marginPercent, 
          name: '$NAME_MARGIN-$NAME_START:(1/1)=>$sampleMarginPercent',
        ),
        // NamedLine.result(
        //   name: '$NAME_MARGIN-$NAME_START:(1/1)=>$sampleMarginPercent',
        //   percentGetter: (size)=>fromStart.percentGetter(size) + marginPercent(size),
        //   literalGetter: fromStart.literalGetter
        // ),
        NamedLine.expression(toEnd - marginPercent, 
          name: '$NAME_MARGIN-$NAME_END:(1/1)=>$sampleMarginPercent',
        ),
        // NamedLine.result(
        //   name: '$NAME_MARGIN-$NAME_END:(1/1)=>$sampleMarginPercent',
        //   percentGetter: (size)=>toEnd.percentGetter(size) - marginPercent(size),
        //   literalGetter: toEnd.literalGetter
        // )
      ];
    return includeStartEnd ? [
      NamedLine.rename(rename: '$NAME_MARGIN-$NAME_START', copy: fromStart),
      ...excludeStartEnd,
      NamedLine.rename(rename: '$NAME_MARGIN-$NAME_END', copy: toEnd)
    ] : excludeStartEnd;
  }
  
  /// 创建黄金分割线
  static List<NamedLine> createGoldenRatioDivides({
    NamedLine? fromStartLine,
    NamedLine? toEndLine,
    bool includeStartEnd = false}){
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(0.0, name: NAME_START);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(1.0, name: NAME_END);
    goldenStartPercentGetter(size)=> 0.382 * (toEnd.percentGetter(size) - fromStart.percentGetter(size)) + fromStart.percentGetter(size);
    goldenEndPercentGetter(size)=> 0.618 * (toEnd.percentGetter(size) - fromStart.percentGetter(size)) + fromStart.percentGetter(size);
    List<NamedLine> excludeStartEnd = [
      NamedLine.getter(
        goldenStartPercentGetter,
        name: '$GOLDEN_RATIO_DIVIDES-$NAME_START:(1/1)=>${goldenStartPercentGetter(Size.square(1.0))}',
      ),
      NamedLine.getter(
        goldenEndPercentGetter,
        name: '$GOLDEN_RATIO_DIVIDES-$NAME_END:(1/1)=>${goldenEndPercentGetter(Size.square(1.0))}',
      )
    ];
    return includeStartEnd ? [
      NamedLine.rename(rename: '$GOLDEN_RATIO_DIVIDES-$NAME_START', copy: fromStart),
      ... excludeStartEnd,
      NamedLine.rename(rename: '$GOLDEN_RATIO_DIVIDES-$NAME_END', copy: toEnd)
    ] : excludeStartEnd;
  }

  /// 创建自定义线(分段占比重权值，加和占首尾线区间=1)
  static List<NamedLine> createCustomSeperateSpaces(List<int> weights, {
    NamedLine? fromStartLine,
    NamedLine? toEndLine,
    bool includeStartEnd = false}){
    assert(weights.length >= 2);
    var addups = weights.fold<List<int>>([], (addup, weight)=>addup..add(addup.isEmpty ? weight : addup.last + weight));
    return createCustomDivides(addups.map<double>((addup)=>addup/addups.last).toList()..removeLast(), fromStartLine: fromStartLine, toEndLine: toEndLine, includeStartEnd: includeStartEnd);
  }

  /// 创建自定义线(占首尾线区间比值 < 1)
  static List<NamedLine> createCustomDivides(List<double> custom, {
    NamedLine? fromStartLine,
    NamedLine? toEndLine,
    bool includeStartEnd = false}){
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(0.0, name: NAME_START);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(1.0, name: NAME_END);
    assert(custom.isNotEmpty);
    var excludeStartEnd =  custom.indexed.map<NamedLine>((indexed){
      // var stepPercent = (toEnd.percent - fromStart.percent) / count;
      percentGetter(size) => (toEnd.percentGetter(size) - fromStart.percentGetter(size)) * indexed.$2;
      return NamedLine.getter(
        percentGetter,
        name: '${indexed.$1}/$NAME_CUSTOM:(1/1)=>${percentGetter(Size.square(1.0))}',
      );
    }).toList();
    return includeStartEnd ? [
      NamedLine.rename(rename: '$NAME_CUSTOM-$NAME_START', copy: fromStart),
      ... excludeStartEnd, 
      NamedLine.rename(rename: '$NAME_CUSTOM-$NAME_END', copy: toEnd), 
    ]: excludeStartEnd;
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
    // var excludeStartEnd = List.generate(count - 1, (index){
    //   // var stepPercent = (toEnd.percent - fromStart.percent) / count;
    //   percentGetter(size) => (index + 1) * (toEnd.percentGetter(size) - fromStart.percentGetter(size)) / count + fromStart.percentGetter(size);
    //   return NamedLine.getter(
    //     percentGetter,
    //     name: '${index + 1}/$count$NAME_DIVIDE:(1/1)=>${percentGetter(Size.square(1.0))}',
    //   );
    // });
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

  static List<NamedLine> createExpressionStaticDivides(Expression staticExpr, double count, {(DIRECTION_ENUM, Size)? infinitySample, 
    NamedLine? fromStartLine,
    NamedLine? toEndLine,
    END_POINT endPoint = END_POINT.exclude_start_end}){
    assert(count != double.infinity || infinitySample != null);
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(0.0, name: NAME_START);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(1.0, name: NAME_END);
    if(count == double.infinity){
      switch(infinitySample!.$1){
        case DIRECTION_ENUM.vertical:
          count = ((toEnd - fromStart) as Expression).verticalWidthMergeLiteral(PxUnit.wpc)(infinitySample.$2).$1 / staticExpr.verticalWidthMergeLiteral(PxUnit.wpc)(infinitySample.$2).$1;
          break;
        case DIRECTION_ENUM.horizontal:
          count = ((toEnd - fromStart) as Expression).horizontalHeightMergeLiteral(PxUnit.hpc)(infinitySample.$2).$1 / staticExpr.horizontalHeightMergeLiteral(PxUnit.hpc)(infinitySample.$2).$1;
      }
    }
    List<NamedLine> excludeStartEnd = List.generate(count.floor(), (index){
      var plusExpr = fromStart + staticExpr * (index + 1); 
      return NamedLine.expression(plusExpr, name: '$STATIC_DIVIDES-${index+1}');
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
  static List<NamedLine> createStaticDivides(double staticPercent, {double count = double.infinity,
    NamedLine? fromStartLine,
    NamedLine? toEndLine,
    bool includeStartEnd = false}){
    NamedLine fromStart = fromStartLine ?? NamedLine.percent(0.0, name: NAME_START);
    NamedLine toEnd = toEndLine ?? NamedLine.percent(1.0, name: NAME_END);
    assert(staticPercent >0 && staticPercent <1);
    if(fromStart.percent < toEnd.percent){
      List<NamedLine> excludeStartEnd;
      if(staticPercent + fromStart.percent > toEnd.percent) {
        excludeStartEnd = [];
      }else{
        excludeStartEnd = List.generate(min<double>(((toEnd.percent - fromStart.percent) / staticPercent), count).floor(), (index){
          var plusPercent = fromStart.percent + (index + 1) * staticPercent; 
          return NamedLine.percent(
            plusPercent,
            name: '$STATIC_DIVIDES-${index+1}:+$staticPercent:$plusPercent',
          );
        });
      }
      return includeStartEnd ? [
        NamedLine.rename(rename: '$STATIC_DIVIDES-$NAME_START', copy: fromStart),
        ...excludeStartEnd,
        NamedLine.rename(rename: '$STATIC_DIVIDES-$NAME_END', copy: toEnd),
      ]: excludeStartEnd;
    }else{
      return createReverseStaticDivides(staticPercent, 
        count: count, fromEndLine: toEndLine, toStartLine: fromStartLine, includeStartEnd: includeStartEnd);
    } 
  }

  static List<NamedLine> createReverseStaticDivides(double staticPercent, {double count = double.infinity, 
    NamedLine? fromEndLine,
    NamedLine? toStartLine,
    bool includeStartEnd = false}){
    NamedLine fromStart = fromEndLine ?? NamedLine.percent(1.0, name: NAME_END);
    NamedLine toEnd = toStartLine ?? NamedLine.percent(0.0, name: NAME_START);
    assert(staticPercent >0 && staticPercent <1);
    List<NamedLine> excludeStartEnd;
    if(toEnd.percent + staticPercent > fromStart.percent ){
      excludeStartEnd = [];
    }else{
      excludeStartEnd = List.generate(min<double>(((fromStart.percent - toEnd.percent) / staticPercent), count).floor(), (index){
        var minusPercent = fromStart.percent - (index + 1) * staticPercent;
        return NamedLine.percent(
          minusPercent,
          name: '$STATIC_DIVIDES-${index+1}:-$staticPercent:$minusPercent',
        );
      /// 反序输出确保从小到大排列
      }).reversed.toList();
    }
    /// 起始点也应该反序
    return includeStartEnd ? [
      NamedLine.rename(rename: '$STATIC_DIVIDES-$NAME_END', copy: toEnd),
      ...excludeStartEnd,
      NamedLine.rename(rename: '$STATIC_DIVIDES-$NAME_START', copy: fromStart),
    ]: excludeStartEnd;
  }

  static List<NamedLine> createReverseExpressionStaticDivides(Expression staticExpr, double count, {(DIRECTION_ENUM, Size, PxUnit?)? infinitySample, 
    NamedLine? fromEndLine,
    NamedLine? toStartLine,
    END_POINT endPoint = END_POINT.exclude_start_end,
  }){
    
    assert(count != double.infinity || infinitySample != null);
    NamedLine fromStart = fromEndLine ?? NamedLine.percent(1.0, name: NAME_END);
    NamedLine toEnd = toStartLine ?? NamedLine.percent(0.0, name: NAME_START);
    if(count == double.infinity){
      switch(infinitySample!.$1){
        case DIRECTION_ENUM.vertical:
          count = ((fromStart - toEnd) as Expression).verticalWidthMergeLiteral(infinitySample.$3 ?? PxUnit.wpc)(infinitySample.$2).$1 / staticExpr.verticalWidthMergeLiteral(infinitySample.$3 ?? PxUnit.wpc)(infinitySample.$2).$1;
          break;
        case DIRECTION_ENUM.horizontal:
          count = ((fromStart - toEnd) as Expression).horizontalHeightMergeLiteral(infinitySample.$3 ?? PxUnit.hpc)(infinitySample.$2).$1 / staticExpr.horizontalHeightMergeLiteral(infinitySample.$3 ?? PxUnit.hpc)(infinitySample.$2).$1;
      }
    }
    List<NamedLine> excludeStartEnd = List.generate(count.floor(), (index){
      var minusExpr = fromStart - staticExpr * (index + 1); 
      return NamedLine.expression(minusExpr, name: '$STATIC_DIVIDES-${index+1}');
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

}
