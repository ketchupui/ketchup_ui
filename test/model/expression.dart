import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ketchup_ui/ketchup_ui.dart';

void main(){
  group('Test screen model', (){
    test('Expression test', (){
      expect(
        (Expression.percent(1.0) - (15, PxUnit.vh) + Expression.literal((25, PxUnit.vmin))).toString(), 
        '( Percent:1.0, portraitWpc:0.25, landscapeHpc:0.1 portraitHpc:-0.15,)');
      expect(
        /// 纵向界面
        (Expression.percent(1.0) - (15, PxUnit.vh) + Expression.literal((25, PxUnit.vmin)) as Expression).computeWidth(Size(1080, 2340)), 
        999.0);
      expect(
        /// 纵向界面
        (Expression.percent(1.0) - (25, PxUnit.vmax) - (45, PxUnit.px) as Expression).computeWidth(Size(1080, 2340)), 
        450.0);
      expect(
        /// 横向界面
        (Expression.percent(1.0) - (15, PxUnit.vh) + Expression.literal((25, PxUnit.vmin)) as Expression).computeWidth(Size(2340, 1080)), 
        2448.0);
      expect(
        /// 横向界面
        (Expression.percent(1.0) - (25, PxUnit.vmax) - (45, PxUnit.px) as Expression).computeHeight(Size(2340, 1080)), 
        450.0);
    });
  });
}