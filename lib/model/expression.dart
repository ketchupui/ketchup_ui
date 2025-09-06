import 'dart:ui';

import 'package:ketchup_ui/ketchup_ui.dart';

class Expression {
  double landscapePercent;
  double portraitPercent;
  double landscapeWpc;
  double portraitWpc;
  double landscapeHpc;
  double portraitHpc;
  double landscapePx;
  double portraitPx;
  Expression({
    this.landscapePercent = .0, this.landscapeWpc = .0, this.landscapeHpc = .0, this.landscapePx =.0, 
    this.portraitPercent = .0, this.portraitWpc = .0, this.portraitHpc = .0, this.portraitPx = .0
  });
  factory Expression.literal((double, PxUnit) lt) => switch(lt.$2){
    PxUnit.wpc => Expression(landscapeWpc: lt.$1, portraitWpc: lt.$1),
    PxUnit.vw => Expression(landscapeWpc: lt.$1 / 100, portraitWpc: lt.$1 / 100),
    PxUnit.rpx => Expression(landscapeWpc: lt.$1 / 750, portraitWpc: lt.$1 / 750),
    PxUnit.hpc => Expression(landscapeHpc: lt.$1, portraitHpc: lt.$1),
    PxUnit.vh => Expression(landscapeHpc: lt.$1 / 100, portraitHpc: lt.$1 / 100),
    PxUnit.vmin => Expression(landscapeHpc: lt.$1 / 100, portraitWpc: lt.$1 / 100),
    PxUnit.vmax => Expression(landscapeWpc: lt.$1 / 100, portraitHpc: lt.$1 / 100),
    PxUnit.px => Expression(landscapePx: lt.$1, portraitPx: lt.$1),
  };
  factory Expression.percent(double value) => Expression(landscapePercent: value, portraitPercent: value);
  operator +(Object o){
     switch(o){
      case NamedLine nl:
        return this + nl.expression;
      case (double, PxUnit) ldouble:
        return this + Expression.literal(ldouble);
      case (int, PxUnit) lint:
        return this + Expression.literal(pxIntToDouble(lint));
      case double p:
        return this + Expression.percent(p);
      case Expression exp:
        return Expression(landscapePercent: landscapePercent + exp.landscapePercent, landscapeHpc: landscapeHpc + exp.landscapeHpc, landscapeWpc: landscapeWpc + exp.landscapeWpc, landscapePx: landscapePx + exp.landscapePx,
          portraitPercent: portraitPercent + exp.portraitPercent, portraitHpc: portraitHpc + exp.portraitHpc, portraitWpc: portraitWpc + exp.portraitWpc, portraitPx: portraitPx + exp.portraitPx
        );
     }
  }

  operator -(Object o){
     switch(o){
      case NamedLine nl:
        return this - nl.expression;
      case (double, PxUnit) ldouble:
        return this - Expression.literal(ldouble);
      case (int, PxUnit) lint:
        return this - Expression.literal(pxIntToDouble(lint));
      case double p:
        return this - Expression.percent(p);
      case Expression exp:
        return Expression(landscapePercent: landscapePercent - exp.landscapePercent, landscapeHpc: landscapeHpc - exp.landscapeHpc, landscapeWpc: landscapeWpc - exp.landscapeWpc, landscapePx: landscapePx - exp.landscapePx,
          portraitPercent: portraitPercent - exp.portraitPercent, portraitHpc: portraitHpc - exp.portraitHpc, portraitWpc: portraitWpc - exp.portraitWpc, portraitPx: portraitPx - exp.portraitPx
        );
     }
  }

  operator *(Object o){
     switch(o){
      case int i:
        return Expression(landscapePercent: landscapePercent * i, landscapeHpc: landscapeHpc * i, landscapeWpc: landscapeWpc * i, landscapePx: landscapePx * i,
          portraitPercent: portraitPercent * i, portraitHpc: portraitHpc * i, portraitWpc: portraitWpc * i, portraitPx: portraitPx * i
        );
      case double d:
        return Expression(landscapePercent: landscapePercent * d, landscapeHpc: landscapeHpc * d, landscapeWpc: landscapeWpc * d, landscapePx: landscapePx * d,
          portraitPercent: portraitPercent * d, portraitHpc: portraitHpc * d, portraitWpc: portraitWpc * d, portraitPx: portraitPx * d
        );
     }
  }
  
  operator /(Object o){
     switch(o){
      case int i:
        return this * (1 / i);
      case double d:
        return this * (1 / d);
     }
  }

  Expression get pcToWpc => Expression(landscapeWpc: landscapeWpc + landscapePercent, portraitWpc: portraitWpc + portraitPercent, landscapeHpc: landscapeHpc, portraitHpc: portraitHpc, landscapePx: landscapePx, portraitPx: portraitPx);
  Expression get pcToHpc => Expression(landscapeHpc: landscapeHpc + landscapePercent, portraitHpc: portraitHpc + portraitPercent, landscapeWpc: landscapeWpc, portraitWpc: portraitWpc, landscapePx: landscapePx, portraitPx: portraitPx);
  double computeWidth(Size viewport) => viewport.width >= viewport.height ? landscapePercent * viewport.width + landscapeWpc * viewport.width + landscapeHpc * viewport.height + landscapePx :
   portraitPercent * viewport.width + portraitWpc * viewport.width + portraitHpc * viewport.height + portraitPx;
  double computeHeight(Size viewport) => viewport.width >= viewport.height ? landscapePercent * viewport.height + landscapeWpc * viewport.width + landscapeHpc * viewport.height + landscapePx :
   portraitPercent * viewport.height + portraitWpc * viewport.width + portraitHpc * viewport.height + portraitPx;
  double computeAny(double any, Size viewport) => viewport.width >= viewport.height ? landscapePercent * any + landscapeWpc * viewport.width + landscapeHpc * viewport.height + landscapePx :
   portraitPercent * any + portraitWpc * viewport.width + portraitHpc * viewport.height + portraitPx;
  
  @override
  String toString() {
    StringBuffer sb = StringBuffer('(');
    pretty(landscape, portrait, name){
      if(landscape != portrait){
        if(landscape != .0){
          sb.write(' landscape$name:$landscape');
        }
        if(portrait != .0){
          sb.write(' portrait$name:$portrait');
        }
      }else
      if(landscape == portrait && landscape != .0){
        sb.write(' $name:$portrait');
      }
    }
    pretty(landscapePercent, portraitPercent, 'Percent');
    sb.write(',');
    pretty(landscapeWpc, portraitWpc, 'Wpc');
    sb.write(',');
    pretty(landscapeHpc, portraitHpc, 'Hpc');
    sb.write(',');
    pretty(landscapePx, portraitPx, 'Px');
    sb.write(')');
    return sb.toString();
  }
}