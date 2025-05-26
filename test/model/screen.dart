
import 'package:flutter_test/flutter_test.dart';
import 'package:ketchup_ui/ketchup_ui.dart';

void main(){
  group('Test screen model', (){
    ScreenContext screen = ScreenContext(rowColumn: (row: 1, column: 5));
    test('ScreenContext.screenPTColumnsLR', (){
      expect(ScreenContext.screenPTColumnsLR(0, 6), null);
      expect(ScreenContext.screenPTColumnsLR(0, 5), null);
      expect(ScreenContext.screenPTColumnsLR(0, 4), null);
      expect(ScreenContext.screenPTColumnsLR(0, 3), null);
      expect(ScreenContext.screenPTColumnsLR(0, 2), null);
      expect(ScreenContext.screenPTColumnsLR(0, 1), null);
      expect(ScreenContext.screenPTColumnsLR(0, 0), null);
      
      expect(ScreenContext.screenPTColumnsLR(1, 6), null);
      expect(ScreenContext.screenPTColumnsLR(1, 5), PT_12345);
      expect(ScreenContext.screenPTColumnsLR(1, 4), PT_1234);
      expect(ScreenContext.screenPTColumnsLR(1, 3), PT_123);
      expect(ScreenContext.screenPTColumnsLR(1, 2), PT_12);
      expect(ScreenContext.screenPTColumnsLR(1, 1), PT_1);
      expect(ScreenContext.screenPTColumnsLR(1, 0), null);
      
      expect(ScreenContext.screenPTColumnsLR(2, 5), null);
      expect(ScreenContext.screenPTColumnsLR(2, 4), PT_2345);
      expect(ScreenContext.screenPTColumnsLR(2, 3), PT_234);
      expect(ScreenContext.screenPTColumnsLR(2, 2), PT_23);
      expect(ScreenContext.screenPTColumnsLR(2, 1), PT_2);
      expect(ScreenContext.screenPTColumnsLR(2, 0), null);

      expect(ScreenContext.screenPTColumnsLR(3, 4), null);
      expect(ScreenContext.screenPTColumnsLR(3, 3), PT_345);
      expect(ScreenContext.screenPTColumnsLR(3, 2), PT_34);
      expect(ScreenContext.screenPTColumnsLR(3, 1), PT_3);
      expect(ScreenContext.screenPTColumnsLR(3, 0), null);

      expect(ScreenContext.screenPTColumnsLR(4, 3), null);
      expect(ScreenContext.screenPTColumnsLR(4, 2), PT_45);
      expect(ScreenContext.screenPTColumnsLR(4, 1), PT_4);
      expect(ScreenContext.screenPTColumnsLR(4, 0), null);

      expect(ScreenContext.screenPTColumnsLR(5, 2), null);
      expect(ScreenContext.screenPTColumnsLR(5, 1), PT_5);
      expect(ScreenContext.screenPTColumnsLR(5, 0), null);
    
      expect(ScreenContext.screenPTColumnsLR(6, 1), null);
      expect(ScreenContext.screenPTColumnsLR(6, 0), null);
    });
    test('ScreenContext.screenPTColumnsRL', (){
      expect(ScreenContext.screenPTColumnsRL(6, 6), null);
      expect(ScreenContext.screenPTColumnsRL(6, 5), null);
      expect(ScreenContext.screenPTColumnsRL(6, 4), null);
      expect(ScreenContext.screenPTColumnsRL(6, 3), null);
      expect(ScreenContext.screenPTColumnsRL(6, 2), null);
      expect(ScreenContext.screenPTColumnsRL(6, 1), null);
      expect(ScreenContext.screenPTColumnsRL(6, 0), null);
      
      expect(ScreenContext.screenPTColumnsRL(5, 6), null);
      expect(ScreenContext.screenPTColumnsRL(5, 5), PT_12345);
      expect(ScreenContext.screenPTColumnsRL(5, 4), PT_2345);
      expect(ScreenContext.screenPTColumnsRL(5, 3), PT_345);
      expect(ScreenContext.screenPTColumnsRL(5, 2), PT_45);
      expect(ScreenContext.screenPTColumnsRL(5, 1), PT_5);
      expect(ScreenContext.screenPTColumnsRL(5, 0), null);
      
      expect(ScreenContext.screenPTColumnsRL(4, 5), null);
      expect(ScreenContext.screenPTColumnsRL(4, 4), PT_1234);
      expect(ScreenContext.screenPTColumnsRL(4, 3), PT_234);
      expect(ScreenContext.screenPTColumnsRL(4, 2), PT_34);
      expect(ScreenContext.screenPTColumnsRL(4, 1), PT_4);
      expect(ScreenContext.screenPTColumnsRL(4, 0), null);

      expect(ScreenContext.screenPTColumnsRL(3, 4), null);
      expect(ScreenContext.screenPTColumnsRL(3, 3), PT_123);
      expect(ScreenContext.screenPTColumnsRL(3, 2), PT_23);
      expect(ScreenContext.screenPTColumnsRL(3, 1), PT_3);
      expect(ScreenContext.screenPTColumnsRL(3, 0), null);

      expect(ScreenContext.screenPTColumnsRL(2, 3), null);
      expect(ScreenContext.screenPTColumnsRL(2, 2), PT_12);
      expect(ScreenContext.screenPTColumnsRL(2, 1), PT_2);
      expect(ScreenContext.screenPTColumnsRL(2, 0), null);

      expect(ScreenContext.screenPTColumnsRL(1, 2), null);
      expect(ScreenContext.screenPTColumnsRL(1, 1), PT_1);
      expect(ScreenContext.screenPTColumnsRL(1, 0), null);

      expect(ScreenContext.screenPTColumnsRL(0, 1), null);
      expect(ScreenContext.screenPTColumnsRL(0, 0), null);
    });
    test('screen.genContextPTColumnsLR',(){
      expect(screen.genContextPTColumnsLR([]), PT_COLUMN_FIVE);
      expect(screen.genContextPTColumnsLR([5]), PT_FULL_FIVE);

      expect(screen.genContextPTColumnsLR([4]), PT_1234_5);
      expect(screen.genContextPTColumnsLR([4,4]), null);
      expect(screen.genContextPTColumnsLR([4,1]), PT_1234_5);
      expect(screen.genContextPTColumnsLR([1,4]), PT_1_2345);
      expect(screen.genContextPTColumnsLR([1,1,4]), null);
      expect(screen.genContextPTColumnsLR([4,1,1]), null);
      
      expect(screen.genContextPTColumnsLR([3]), PT_123_4_5);
      expect(screen.genContextPTColumnsLR([3,3]), null);
      expect(screen.genContextPTColumnsLR([3,2]), PT_123_45);
      expect(screen.genContextPTColumnsLR([3,2,3]), null);
      expect(screen.genContextPTColumnsLR([2,3]), PT_12_345);
      expect(screen.genContextPTColumnsLR([2,3,2]), null);
      expect(screen.genContextPTColumnsLR([3,1]), PT_123_4_5);
      expect(screen.genContextPTColumnsLR([3,1,1]), PT_123_4_5);
      expect(screen.genContextPTColumnsLR([1,1,3]), PT_1_2_345);
      expect(screen.genContextPTColumnsLR([1,3]), PT_1_234_5);
      expect(screen.genContextPTColumnsLR([1,3,1]), PT_1_234_5);
      
      expect(screen.genContextPTColumnsLR([2]), PT_12_3_4_5);
      expect(screen.genContextPTColumnsLR([2,2]), PT_12_34_5);
      expect(screen.genContextPTColumnsLR([2,2,1]), PT_12_34_5);
      expect(screen.genContextPTColumnsLR([1,2,2]), PT_1_23_45);
      expect(screen.genContextPTColumnsLR([2,1,2]), PT_12_3_45);
      expect(screen.genContextPTColumnsLR([1,2,1]), PT_1_23_4_5);
      expect(screen.genContextPTColumnsLR([1,2,1,1]), PT_1_23_4_5);
      expect(screen.genContextPTColumnsLR([1,2,1,2]), null);
      expect(screen.genContextPTColumnsLR([2,2,2]), null);
    });

    test('screen.genContextPTColumnsRL',(){
      expect(screen.genContextPTColumnsRL([]), PT_COLUMN_FIVE);
      // debugger();
      expect(screen.genContextPTColumnsRL([5]), PT_FULL_FIVE);

      expect(screen.genContextPTColumnsRL([4]), PT_1_2345);
      expect(screen.genContextPTColumnsRL([4,4]), null);
      expect(screen.genContextPTColumnsRL([4,1]), PT_1_2345);
      expect(screen.genContextPTColumnsRL([1,4]), PT_1234_5);
      expect(screen.genContextPTColumnsRL([1,1,4]), null);
      expect(screen.genContextPTColumnsRL([4,1,1]), null);
      
      expect(screen.genContextPTColumnsRL([3]), PT_1_2_345);
      expect(screen.genContextPTColumnsRL([3,3]), null);
      expect(screen.genContextPTColumnsRL([3,2]), PT_12_345);
      expect(screen.genContextPTColumnsRL([3,2,3]), null);
      expect(screen.genContextPTColumnsRL([2,3]), PT_123_45);
      expect(screen.genContextPTColumnsRL([2,3,2]), null);
      expect(screen.genContextPTColumnsRL([3,1]), PT_1_2_345);
      expect(screen.genContextPTColumnsRL([3,1,1]), PT_1_2_345);
      expect(screen.genContextPTColumnsRL([1,1,3]), PT_123_4_5);
      expect(screen.genContextPTColumnsRL([1,3]), PT_1_234_5);
      expect(screen.genContextPTColumnsRL([1,3,1]), PT_1_234_5);
      
      expect(screen.genContextPTColumnsRL([2]), PT_1_2_3_45);
      expect(screen.genContextPTColumnsRL([2,2]), PT_1_23_45);
      expect(screen.genContextPTColumnsRL([2,2,1]), PT_1_23_45);
      expect(screen.genContextPTColumnsRL([1,2,2]), PT_12_34_5);
      expect(screen.genContextPTColumnsRL([2,1,2]), PT_12_3_45);
      expect(screen.genContextPTColumnsRL([1,2,1]), PT_1_2_34_5);
      expect(screen.genContextPTColumnsRL([1,2,1,1]), PT_1_2_34_5);
      expect(screen.genContextPTColumnsRL([1,2,1,2]), null);
      expect(screen.genContextPTColumnsRL([2,2,2]), null);
    });

  });  
}