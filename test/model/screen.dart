
import 'package:flutter_test/flutter_test.dart';
import 'package:ketchup_ui/ketchup_ui.dart';

void main(){
  group('Test screen model', (){
    test('ScreenContext.screenPTColumnsLR', (){
      expect(ScreenContext.screenPTColumnsLR(0, 8), null);
      expect(ScreenContext.screenPTColumnsLR(0, 7), null);
      expect(ScreenContext.screenPTColumnsLR(0, 6), null);
      expect(ScreenContext.screenPTColumnsLR(0, 5), null);
      expect(ScreenContext.screenPTColumnsLR(0, 4), null);
      expect(ScreenContext.screenPTColumnsLR(0, 3), null);
      expect(ScreenContext.screenPTColumnsLR(0, 2), null);
      expect(ScreenContext.screenPTColumnsLR(0, 1), null);
      expect(ScreenContext.screenPTColumnsLR(0, 0), null);
      
      expect(ScreenContext.screenPTColumnsLR(1, 8), null);
      expect(ScreenContext.screenPTColumnsLR(1, 7), PT_1234567);
      expect(ScreenContext.screenPTColumnsLR(1, 6), PT_123456);
      expect(ScreenContext.screenPTColumnsLR(1, 5), PT_12345);
      expect(ScreenContext.screenPTColumnsLR(1, 4), PT_1234);
      expect(ScreenContext.screenPTColumnsLR(1, 3), PT_123);
      expect(ScreenContext.screenPTColumnsLR(1, 2), PT_12);
      expect(ScreenContext.screenPTColumnsLR(1, 1), PT_1);
      expect(ScreenContext.screenPTColumnsLR(1, 0), null);
      
      expect(ScreenContext.screenPTColumnsLR(2, 7), null);
      expect(ScreenContext.screenPTColumnsLR(2, 6), PT_234567);
      expect(ScreenContext.screenPTColumnsLR(2, 5), PT_23456);
      expect(ScreenContext.screenPTColumnsLR(2, 4), PT_2345);
      expect(ScreenContext.screenPTColumnsLR(2, 3), PT_234);
      expect(ScreenContext.screenPTColumnsLR(2, 2), PT_23);
      expect(ScreenContext.screenPTColumnsLR(2, 1), PT_2);
      expect(ScreenContext.screenPTColumnsLR(2, 0), null);

      expect(ScreenContext.screenPTColumnsLR(3, 6), null);
      expect(ScreenContext.screenPTColumnsLR(3, 5), PT_34567);
      expect(ScreenContext.screenPTColumnsLR(3, 4), PT_3456);
      expect(ScreenContext.screenPTColumnsLR(3, 3), PT_345);
      expect(ScreenContext.screenPTColumnsLR(3, 2), PT_34);
      expect(ScreenContext.screenPTColumnsLR(3, 1), PT_3);
      expect(ScreenContext.screenPTColumnsLR(3, 0), null);

      expect(ScreenContext.screenPTColumnsLR(4, 5), null);
      expect(ScreenContext.screenPTColumnsLR(4, 4), PT_4567);
      expect(ScreenContext.screenPTColumnsLR(4, 3), PT_456);
      expect(ScreenContext.screenPTColumnsLR(4, 2), PT_45);
      expect(ScreenContext.screenPTColumnsLR(4, 1), PT_4);
      expect(ScreenContext.screenPTColumnsLR(4, 0), null);

      expect(ScreenContext.screenPTColumnsLR(5, 4), null);
      expect(ScreenContext.screenPTColumnsLR(5, 3), PT_567);
      expect(ScreenContext.screenPTColumnsLR(5, 2), PT_56);
      expect(ScreenContext.screenPTColumnsLR(5, 1), PT_5);
      expect(ScreenContext.screenPTColumnsLR(5, 0), null);
    
      expect(ScreenContext.screenPTColumnsLR(6, 3), null);
      expect(ScreenContext.screenPTColumnsLR(6, 2), PT_67);
      expect(ScreenContext.screenPTColumnsLR(6, 1), PT_6);
      expect(ScreenContext.screenPTColumnsLR(6, 0), null);

      expect(ScreenContext.screenPTColumnsLR(7, 2), null);
      expect(ScreenContext.screenPTColumnsLR(7, 1), PT_7);
      expect(ScreenContext.screenPTColumnsLR(7, 0), null);

      expect(ScreenContext.screenPTColumnsLR(8, 1), null);
      expect(ScreenContext.screenPTColumnsLR(8, 0), null);
      
    });
    test('ScreenContext.screenPTColumnsRL', (){

      expect(ScreenContext.screenPTColumnsRL(7, 8), null);
      expect(ScreenContext.screenPTColumnsRL(7, 7), PT_1234567);
      expect(ScreenContext.screenPTColumnsRL(7, 6), PT_234567);
      expect(ScreenContext.screenPTColumnsRL(7, 5), PT_34567);
      expect(ScreenContext.screenPTColumnsRL(7, 4), PT_4567);
      expect(ScreenContext.screenPTColumnsRL(7, 3), PT_567);
      expect(ScreenContext.screenPTColumnsRL(7, 2), PT_67);
      expect(ScreenContext.screenPTColumnsRL(7, 1), PT_7);
      expect(ScreenContext.screenPTColumnsRL(7, 0), null);
      
      expect(ScreenContext.screenPTColumnsRL(6, 7), null);
      expect(ScreenContext.screenPTColumnsRL(6, 6), PT_123456);
      expect(ScreenContext.screenPTColumnsRL(6, 5), PT_23456);
      expect(ScreenContext.screenPTColumnsRL(6, 4), PT_3456);
      expect(ScreenContext.screenPTColumnsRL(6, 3), PT_456);
      expect(ScreenContext.screenPTColumnsRL(6, 2), PT_56);
      expect(ScreenContext.screenPTColumnsRL(6, 1), PT_6);
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
    ScreenContext screen5 = ScreenContext(rowColumn: (row: 1, column: 5), singleAspectRatioSize: null);
    test('screen.genContextPTColumnsLR',(){
      expect(screen5.genContextPTColumnsLR([]), PT_COLUMN_FIVE);
      expect(screen5.genContextPTColumnsLR([5]), PT_FULL_FIVE);

      expect(screen5.genContextPTColumnsLR([4]), PT_1234_5);
      expect(screen5.genContextPTColumnsLR([4,4]), null);
      expect(screen5.genContextPTColumnsLR([4,1]), PT_1234_5);
      expect(screen5.genContextPTColumnsLR([1,4]), PT_1_2345);
      expect(screen5.genContextPTColumnsLR([1,1,4]), null);
      expect(screen5.genContextPTColumnsLR([4,1,1]), null);
      
      expect(screen5.genContextPTColumnsLR([3]), PT_123_4_5);
      expect(screen5.genContextPTColumnsLR([3,3]), null);
      expect(screen5.genContextPTColumnsLR([3,2]), PT_123_45);
      expect(screen5.genContextPTColumnsLR([3,2,3]), null);
      expect(screen5.genContextPTColumnsLR([2,3]), PT_12_345);
      expect(screen5.genContextPTColumnsLR([2,3,2]), null);
      expect(screen5.genContextPTColumnsLR([3,1]), PT_123_4_5);
      expect(screen5.genContextPTColumnsLR([3,1,1]), PT_123_4_5);
      expect(screen5.genContextPTColumnsLR([1,1,3]), PT_1_2_345);
      expect(screen5.genContextPTColumnsLR([1,3]), PT_1_234_5);
      expect(screen5.genContextPTColumnsLR([1,3,1]), PT_1_234_5);
      
      expect(screen5.genContextPTColumnsLR([2]), PT_12_3_4_5);
      expect(screen5.genContextPTColumnsLR([2,2]), PT_12_34_5);
      expect(screen5.genContextPTColumnsLR([2,2,1]), PT_12_34_5);
      expect(screen5.genContextPTColumnsLR([1,2,2]), PT_1_23_45);
      expect(screen5.genContextPTColumnsLR([2,1,2]), PT_12_3_45);
      expect(screen5.genContextPTColumnsLR([1,2,1]), PT_1_23_4_5);
      expect(screen5.genContextPTColumnsLR([1,2,1,1]), PT_1_23_4_5);
      expect(screen5.genContextPTColumnsLR([1,2,1,2]), null);
      expect(screen5.genContextPTColumnsLR([2,2,2]), null);
    });
    test('screen.genContextPTColumnsRL',(){
      expect(screen5.genContextPTColumnsRL([]), PT_COLUMN_FIVE);
      // debugger();
      expect(screen5.genContextPTColumnsRL([5]), PT_FULL_FIVE);

      expect(screen5.genContextPTColumnsRL([4]), PT_1_2345);
      expect(screen5.genContextPTColumnsRL([4,4]), null);
      expect(screen5.genContextPTColumnsRL([4,1]), PT_1_2345);
      expect(screen5.genContextPTColumnsRL([1,4]), PT_1234_5);
      expect(screen5.genContextPTColumnsRL([1,1,4]), null);
      expect(screen5.genContextPTColumnsRL([4,1,1]), null);
      
      expect(screen5.genContextPTColumnsRL([3]), PT_1_2_345);
      expect(screen5.genContextPTColumnsRL([3,3]), null);
      expect(screen5.genContextPTColumnsRL([3,2]), PT_12_345);
      expect(screen5.genContextPTColumnsRL([3,2,3]), null);
      expect(screen5.genContextPTColumnsRL([2,3]), PT_123_45);
      expect(screen5.genContextPTColumnsRL([2,3,2]), null);
      expect(screen5.genContextPTColumnsRL([3,1]), PT_1_2_345);
      expect(screen5.genContextPTColumnsRL([3,1,1]), PT_1_2_345);
      expect(screen5.genContextPTColumnsRL([1,1,3]), PT_123_4_5);
      expect(screen5.genContextPTColumnsRL([1,3]), PT_1_234_5);
      expect(screen5.genContextPTColumnsRL([1,3,1]), PT_1_234_5);
      
      expect(screen5.genContextPTColumnsRL([2]), PT_1_2_3_45);
      expect(screen5.genContextPTColumnsRL([2,2]), PT_1_23_45);
      expect(screen5.genContextPTColumnsRL([2,2,1]), PT_1_23_45);
      expect(screen5.genContextPTColumnsRL([1,2,2]), PT_12_34_5);
      expect(screen5.genContextPTColumnsRL([2,1,2]), PT_12_3_45);
      expect(screen5.genContextPTColumnsRL([1,2,1]), PT_1_2_34_5);
      expect(screen5.genContextPTColumnsRL([1,2,1,1]), PT_1_2_34_5);
      expect(screen5.genContextPTColumnsRL([1,2,1,2]), null);
      expect(screen5.genContextPTColumnsRL([2,2,2]), null);
    });
    test('ScreenContext.combinedState', (){
      expect(ScreenContext.combinedState(PT_12_34_5).toString(), (1, [true, false, true, false]).toString());
      expect(ScreenContext.combinedState(PT_34567).toString(), (3, [true, true, true, true]).toString());
      expect(ScreenContext.combinedState(PT_1_2_3_4567).toString(), (1, [false, false, false, true, true, true]).toString());
    });
    test('ScreenContext.ptFromState', (){
      expect(ScreenContext.ptFromState(1, [true, false, true, false], 5), PT_12_34_5);
      expect(ScreenContext.ptFromState(3, [true, true, true, true], 7), PT_34567);
      expect(ScreenContext.ptFromState(3, [true, true, true, true], 5), null);
      expect(ScreenContext.ptFromState(1, [false, false, false, true, true, true], 7), PT_1_2_3_4567);
      expect(ScreenContext.ptFromState(1, [false, false, false, true, false, true], 7), PT_1_2_3_45_67);
      expect(ScreenContext.ptFromState(1, [false, true, false, true, true, true], 7), PT_1_23_4567);
      expect(ScreenContext.ptFromState(1, [true, false, false, true, true, true], 7), PT_12_3_4567);
    });
  });  
}