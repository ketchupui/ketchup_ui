import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ketchup_ui/ketchup_ui.dart';

void main(){
  group('Test screen model', (){
    GridContext grid = GridContext();
    test('Expression test', (){
      final start = (Size size)=>.0;
      final middle = (Size size)=>.5;
      final end = (Size size)=>1.0;
      final lvh5 = (5.0, PxUnit.vh);
      final lvh10 = (10.0, PxUnit.vh);
      final lvhn5 = (-5.0, PxUnit.vh);
      final lvhn10 = (-10.0, PxUnit.vh);
      final vh5 = (Size size)=>lvh5;
      final vh10 = (Size size)=>lvh10;
      final vhn5 = (Size size)=>lvhn5;
      final vhn10 = (Size size)=>lvhn10;
      Expression expr_start = Expression.percentGetter(start);
      Expression expr_margin_start_plus_vh5 = expr_start + lvh5;
      Expression expr_margin_start_plus_vhn5 = expr_start + lvhn5;
      Expression expr_margin_start_minus_vh5 = expr_start - lvh5;
      Expression expr_margin_start_minus_vhn5 = expr_start - lvhn5;
      Expression expr_margin_start_plus_vh5_plus_vh5 = expr_start + lvh5 + lvh5;
      Expression expr_margin_start_plus_vh10 = expr_start + lvh10;
      Expression expr_margin_start_minus_vh5_minus_vh5 = expr_start - lvh5 - lvh5;
      Expression expr_margin_start_minus_vh10 = expr_start - lvh10;

      Expression expr_end = Expression.percentGetter(end);
      Expression expr_margin_end_minus_vh5 = expr_end - lvh5;
      Expression expr_margin_end_minus_vh5_minus_vh5 = expr_end - lvh5 - lvh5;

      // expect(expr_start.looseEqualString(Expression.literalGetter(vh5)), '');
      
      expect(expr_start.looseEqual(Expression.literalGetter(vh5)), false);
      expect(expr_margin_start_plus_vh5.looseEqual(Expression.literalGetter(vh5)), true);
      expect(expr_margin_start_plus_vh5_plus_vh5.looseEqualString(Expression.literalGetter(vh5)), '''percent part:0.0 == 0.0
literal part:(10.0, PxUnit.vh) != (5.0, PxUnit.vh)
result: false
''');
      expect(expr_margin_start_plus_vh5_plus_vh5.looseEqual(Expression.literalGetter(vh5)), false);
      expect(expr_margin_start_plus_vh5_plus_vh5.looseEqual(Expression.literalGetter(vh10)), true);
      
      expect(expr_margin_start_plus_vh10.looseEqual(expr_margin_start_plus_vh5), false);
      expect(expr_margin_start_plus_vh10.looseEqual(expr_margin_start_plus_vh5_plus_vh5), true);
      expect(expr_margin_start_plus_vh10.looseEqual(Expression.literalGetter(vh10)), true);
      
      expect(expr_start.looseEqual(Expression.literalGetter(vhn5)), false);
      expect(expr_margin_start_plus_vhn5.looseEqual(Expression.literalGetter(vhn5)), true);
      expect(expr_margin_start_minus_vh5.looseEqual(expr_margin_start_plus_vhn5), true);
      
      expect(expr_margin_start_minus_vh5_minus_vh5.looseEqualString(Expression.literalGetter(vhn5)), '''percent part:0.0 == 0.0
literal part:(-10.0, PxUnit.vh) != (-5.0, PxUnit.vh)
result: false
''');
      expect(expr_margin_end_minus_vh5_minus_vh5.verticalWidthMergeLiteralExpression().looseEqualString(Expression.literalGetter(vhn5)), '''percent part:0.0 == 0.0
literal part:(90.0, PxUnit.vh) != (-5.0, PxUnit.vh)
result: false
''');
      expect(expr_margin_end_minus_vh5_minus_vh5.verticalWidthMergeLiteralExpression().looseEqualString(Expression.literalGetter(vhn5), Size(200, 100)), '''percent part:0.0 == 0.0
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