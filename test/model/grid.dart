import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ketchup_ui/ketchup_ui.dart';
import 'package:ketchup_ui/model/deprecated/expression.old.dart';

void main(){
  group('Test screen model', (){
    GridContext grid = GridContext();
    test('Expression test', (){
      double start(Size size)=>.0;
      double middle(Size size)=>.5;
      double end(Size size)=>1.0;
      final lvh5 = (5.0, PxUnit.vh);
      final lvh10 = (10.0, PxUnit.vh);
      final lvhn5 = (-5.0, PxUnit.vh);
      final lvhn10 = (-10.0, PxUnit.vh);
      (double, PxUnit) vh5(Size size)=>lvh5;
      (double, PxUnit) vh10(Size size)=>lvh10;
      (double, PxUnit) vhn5(Size size)=>lvhn5;
      (double, PxUnit) vhn10(Size size)=>lvhn10;
      ExpressionOld exprStart = ExpressionOld.percentGetter(start);
      ExpressionOld exprMarginStartPlusVh5 = exprStart + lvh5;
      ExpressionOld exprMarginStartPlusVhn5 = exprStart + lvhn5;
      ExpressionOld exprMarginStartMinusVh5 = exprStart - lvh5;
      ExpressionOld exprMarginStartMinusVhn5 = exprStart - lvhn5;
      ExpressionOld exprMarginStartPlusVh5PlusVh5 = exprStart + lvh5 + lvh5;
      ExpressionOld exprMarginStartPlusVh10 = exprStart + lvh10;
      ExpressionOld exprMarginStartMinusVh5MinusVh5 = exprStart - lvh5 - lvh5;
      ExpressionOld exprMarginStartMinusVh10 = exprStart - lvh10;

      ExpressionOld exprEnd = ExpressionOld.percentGetter(end);
      ExpressionOld exprMarginEndMinusVh5 = exprEnd - lvh5;
      ExpressionOld exprMarginEndMinusVh5MinusVh5 = exprEnd - lvh5 - lvh5;

      // expect(expr_start.looseEqualString(Expression.literalGetter(vh5)), '');
      
      expect(exprStart.looseEqual(ExpressionOld.literalGetter(vh5)), false);
      expect(exprMarginStartPlusVh5.looseEqual(ExpressionOld.literalGetter(vh5)), true);
      expect(exprMarginStartPlusVh5PlusVh5.looseEqualString(ExpressionOld.literalGetter(vh5)), '''percent part:0.0 == 0.0
literal part:(10.0, PxUnit.vh) != (5.0, PxUnit.vh)
result: false
''');
      expect(exprMarginStartPlusVh5PlusVh5.looseEqual(ExpressionOld.literalGetter(vh5)), false);
      expect(exprMarginStartPlusVh5PlusVh5.looseEqual(ExpressionOld.literalGetter(vh10)), true);
      
      expect(exprMarginStartPlusVh10.looseEqual(exprMarginStartPlusVh5), false);
      expect(exprMarginStartPlusVh10.looseEqual(exprMarginStartPlusVh5PlusVh5), true);
      expect(exprMarginStartPlusVh10.looseEqual(ExpressionOld.literalGetter(vh10)), true);
      
      expect(exprStart.looseEqual(ExpressionOld.literalGetter(vhn5)), false);
      expect(exprMarginStartPlusVhn5.looseEqual(ExpressionOld.literalGetter(vhn5)), true);
      expect(exprMarginStartMinusVh5.looseEqual(exprMarginStartPlusVhn5), true);
      
      expect(exprMarginStartMinusVh5MinusVh5.looseEqualString(ExpressionOld.literalGetter(vhn5)), '''percent part:0.0 == 0.0
literal part:(-10.0, PxUnit.vh) != (-5.0, PxUnit.vh)
result: false
''');
      expect(exprMarginEndMinusVh5MinusVh5.verticalWidthMergeLiteralExpression().looseEqualString(ExpressionOld.literalGetter(vhn5)), '''percent part:0.0 == 0.0
literal part:(90.0, PxUnit.vh) != (-5.0, PxUnit.vh)
result: false
''');
      expect(exprMarginEndMinusVh5MinusVh5.verticalWidthMergeLiteralExpression().looseEqualString(ExpressionOld.literalGetter(vhn5), Size(200, 100)), '''percent part:0.0 == 0.0
literal part:(190.0, PxUnit.vh) != (-5.0, PxUnit.vh)
result: false
''');
      // expect(expr_margin_start_plus_vh5_plus_vh5.looseEqual(Expression.literalGetter(vh5)), false);
      // expect(expr_margin_start_plus_vh5_plus_vh5.looseEqual(Expression.literalGetter(vh10)), true);
      
      // expect(expr_margin_start_plus_vh10.looseEqual(expr_margin_start_plus_vh5), false);
      // expect(expr_margin_start_plus_vh10.looseEqual(expr_margin_start_plus_vh5_plus_vh5), true);
      // expect(expr_margin_start_plus_vh10.looseEqual(Expression.literalGetter(vh10)), true);

      
    });
  });
}