
import 'dart:ui';

import 'package:ketchup_ui/model/grid.dart';
import 'package:ketchup_ui/pxunit.dart';

class ExpressionOld {
  final PercentGetter percentGetter;
  final PxUnitVector? literalCache; /// 遇到 vh+vw wpc+hpc 或者 vh+wpc vw+hpc 时启用
  final LiteralGetter? literal;
  const ExpressionOld(this.percentGetter, this.literal, { this.literalCache });
  factory ExpressionOld.literal((double, PxUnit) lt) => ExpressionOld((Size size)=>0, (Size size)=>lt);
  factory ExpressionOld.literalGetter(LiteralGetter getter) => ExpressionOld((Size size)=>0, getter);
  factory ExpressionOld.percent(double value) => ExpressionOld((Size size)=>value, null);
  factory ExpressionOld.percentGetter(PercentGetter getter) => ExpressionOld(getter, null);

  operator +(Object o){
    switch(o){
      case NamedLine n:
        return this + n.expression;
      case (double, PxUnit) ldouble:
        return this + ExpressionOld.literal(ldouble);
      case (int, PxUnit) lint:
        return this + ExpressionOld.literal(pxIntToDouble(lint));
      case LiteralGetter lg:
        return this + ExpressionOld.literalGetter(lg);
      case double p:
        return this + ExpressionOld.percent(p);
      case PercentGetter pg:
        return this + ExpressionOld.percentGetter(pg);
      case ExpressionOld e:
        if(literal != null || e.literal != null){
          return ExpressionOld((Size size)=>percentGetter(size) + e.percentGetter(size), (Size size){
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
            /// 单位里没有 wpc 和 hpc 的统一到 px(不能统一到 px 会导致失去响应式)
            }else{
              return (pxUnitDoubleGetter(a)(size) + pxUnitDoubleGetter(b)(size), PxUnit.px);
            }
          });
        }else{
          return ExpressionOld((Size size)=>percentGetter(size) + e.percentGetter(size), null);
        }
    }
  }

  operator -(Object o){
    switch(o){
      case NamedLine n:
        return this - n.expression;
      case (double, PxUnit) ldouble:
        return this - ExpressionOld.literal(ldouble);
      case (int, PxUnit) lint:
        return this - ExpressionOld.literal(pxIntToDouble(lint));
      // case (double, PxUnit) l:
      //   return this - Expression.literal(l);
      case LiteralGetter lg:
        return this - ExpressionOld.literalGetter(lg);
      case double p:
        return this - ExpressionOld.percent(p);
      case PercentGetter pg:
        return this - ExpressionOld.percentGetter(pg);
      case ExpressionOld e:
        if(literal != null || e.literal != null){
          return ExpressionOld((Size size)=>percentGetter(size) - e.percentGetter(size), (Size size){
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
          return ExpressionOld((Size size)=>percentGetter(size) - e.percentGetter(size), null);
        }
    }
  }

  operator *(Object o){
    switch(o){
      case int i:
        if(literal != null){
          return ExpressionOld((Size size)=>percentGetter(size) * i, (Size size){
            final a = literal!.call(size);
            return (a.$1 * i, a.$2);
          });
        }else{
          return ExpressionOld((Size size)=>percentGetter(size) * i, null);
        }
      case double d:
        if(literal != null){
          return ExpressionOld((Size size)=>percentGetter(size) * d, (Size size){
            final a = literal!.call(size);
            return (a.$1 * d, a.$2);
          });
        }else{
          return ExpressionOld((Size size)=>percentGetter(size) * d, null);
        }
    }
  }

  operator /(Object o){
    switch(o){
      case int i:
        if(literal != null){
          return ExpressionOld((Size size)=>percentGetter(size) / i, (Size size){
            final a = literal!.call(size);
            return (a.$1 / i, a.$2);
          });
        }else{
          return ExpressionOld((Size size)=>percentGetter(size) / i, null);
        }
      case double d:
        if(literal != null){
          return ExpressionOld((Size size)=>percentGetter(size) / d, (Size size){
            final a = literal!.call(size);
            return (a.$1 / d, a.$2);
          });
        }else{
          return ExpressionOld((Size size)=>percentGetter(size) / d, null);
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
  ExpressionOld verticalWidthMergeLiteralExpression([PxUnit? pu]) => ExpressionOld.literalGetter(verticalWidthMergeLiteral(pu));
  /// 横线(纵轴)转为字面量(单位值)表示，优先转成指定单位，其次同一单位，否则转成 hpc(heightPercent)
  LiteralGetter horizontalHeightMergeLiteral([PxUnit? pu]){
    return (Size size){
        final target = literal?.call(size);
        final unit = pu ?? target?.$2 ?? PxUnit.hpc;
        return (heightPercentToPxUnitDoubleGetter(percentGetter(size), unit)(size).$1 + (literal?.call(size).$1 ?? 0), unit);
    };
  }
  ExpressionOld horizontalHeightMergeLiteralExpression([PxUnit? pu]) => ExpressionOld.literalGetter(horizontalHeightMergeLiteral(pu));
  
  bool looseEqual(ExpressionOld other, [Size sampleSize = const Size.square(100)]){
    return percentGetter(sampleSize) == other.percentGetter(sampleSize) && literal?.call(sampleSize) == other.literal?.call(sampleSize);
  }

  String looseEqualString(ExpressionOld other, [Size sampleSize = const Size.square(100)]){
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