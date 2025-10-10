
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

  group('Test vscreen page manager', (){
    final simple = SinglePageVirtualScreenTester(FocusPageMode.multiLR, ['1','2','(3-4-5)','(6-7)','8'], null);
    test('(LR)SinglePageManager.singlePageNext', (){
      expect(simple.focusPageSingleLR(), '1');
      /// state
      expect(simple.focusPagePrevPT, null);
      expect(simple.focusPageCurrentPT, '1');
      expect(simple.focusPageNextPT, '2');
      /// action
      expect(simple.focusPageNext(), '2');
      /// state
      expect(simple.focusPagePrevPT, '1');
      expect(simple.focusPageCurrentPT, '2');
      expect(simple.focusPageNextPT, '(3-4-5)');
      /// action
      expect(simple.focusPageNext(), '(3-4-5)');
      /// state
      expect(simple.focusPagePrevPT, '2');
      expect(simple.focusPageCurrentPT, '(3-4-5)');
      expect(simple.focusPageNextPT, '(6-7)');
      /// action
      expect(simple.focusPageNext(), '(6-7)');
      /// state
      expect(simple.focusPagePrevPT, '(3-4-5)');
      expect(simple.focusPageCurrentPT, '(6-7)');
      expect(simple.focusPageNextPT, '8');
      /// action
      expect(simple.focusPageNext(), '8');
      /// state
      expect(simple.focusPagePrevPT, '(6-7)');
      expect(simple.focusPageCurrentPT, '8');
      expect(simple.focusPageNextPT, null);
    });
    test('(LR)SinglePageVirtualScreenTester.singlePagePrev', (){
      /// action
      expect(simple.focusPagePrev(), '(6-7)');
      /// state
      expect(simple.focusPagePrevPT, '(3-4-5)');
      expect(simple.focusPageCurrentPT, '(6-7)');
      expect(simple.focusPageNextPT, '8');
      /// action
      expect(simple.focusPagePrev(), '(3-4-5)');
      /// state
      expect(simple.focusPagePrevPT, '2');
      expect(simple.focusPageCurrentPT, '(3-4-5)');
      expect(simple.focusPageNextPT, '(6-7)');
      /// action
      expect(simple.focusPagePrev(), '2');
      /// state
      expect(simple.focusPagePrevPT, '1');
      expect(simple.focusPageCurrentPT, '2');
      expect(simple.focusPageNextPT, '(3-4-5)');
      /// action
      expect(simple.focusPagePrev(), '1');
      /// state
      expect(simple.focusPagePrevPT, null);
      expect(simple.focusPageCurrentPT, '1');
      expect(simple.focusPageNextPT, '2');
    });
    test('(simpleLR)SinglePageManager.vscreenSinglePageNext', (){
      /// action
      expect(simple.vscreenFocusPageNext(), ['2']);
      /// state
      expect(simple.focusPagePrevPT, '1');
      expect(simple.vscreenFocusPrevIndexList, [0]);
      expect(simple.focusPageCurrentPT, '2');
      expect(simple.vscreenFocusCurrentIndexList, [1]);
      expect(simple.focusPageNextPT, '(3-4-5)');
      expect(simple.vscreenFocusNextIndexList, [2]);
      /// action
      expect(simple.vscreenFocusPageNext(), ['(3-4-5)']);
      /// state
      expect(simple.focusPagePrevPT, '2');
      expect(simple.focusPageCurrentPT, '(3-4-5)');
      expect(simple.focusPageNextPT, '(6-7)');
      /// action
      expect(simple.vscreenFocusPageNext(), ['(6-7)']);
      /// state
      expect(simple.focusPagePrevPT, '(3-4-5)');
      expect(simple.focusPageCurrentPT, '(6-7)');
      expect(simple.focusPageNextPT, '8');
      /// action
      expect(simple.vscreenFocusPageNext(), ['8']);
      /// state
      expect(simple.focusPagePrevPT, '(6-7)');
      expect(simple.focusPageCurrentPT, '8');
      expect(simple.focusPageNextPT, null);
    });
    test('(simpleLR)SinglePageManager.vscreenSinglePagePrev', (){
      /// action
      expect(simple.vscreenFocusPagePrev(), ['(6-7)']);
      /// state
      expect(simple.focusPagePrevPT, '(3-4-5)');
      expect(simple.focusPageCurrentPT, '(6-7)');
      expect(simple.focusPageNextPT, '8');
      /// action
      expect(simple.vscreenFocusPagePrev(), ['(3-4-5)']);
      /// state
      expect(simple.focusPagePrevPT, '2');
      expect(simple.focusPageCurrentPT, '(3-4-5)');
      expect(simple.focusPageNextPT, '(6-7)');
      /// action
      expect(simple.vscreenFocusPagePrev(), ['2']);
      /// state
      expect(simple.focusPagePrevPT, '1');
      expect(simple.focusPageCurrentPT, '2');
      expect(simple.focusPageNextPT, '(3-4-5)');
      /// action
      expect(simple.vscreenFocusPagePrev(), ['1']);
      /// state
      expect(simple.focusPagePrevPT, null);
      expect(simple.focusPageCurrentPT, '1');
      expect(simple.focusPageNextPT, '2');
    });
    /// https://immvpc32u2.feishu.cn/docx/Bq2adq4zPo8fUSxqzzRckqb4nUP#share-THfCd1EXxoAeBBx18yqcjuNFnWe
    final vscreenLR = createVirtualScreenTester();
    test('(LR)SinglePageManager.vscreenSinglePageNext', (){
      expect(vscreenLR.vscreenFocusPageSingleLR(), [0, 0, 0, 0]); /// ['(1-2-3-4-5-6-7)', '(1-2-3)', '1', '1']
      /// state
      expect(vscreenLR.vscreenFocusPageCurrent(), ['(1-2-3-4-5-6-7)', '(1-2-3)', '1', '1']);

      expect(vscreenLR.vscreenFocusPrevIndexList, []);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [0, 0, 0, 0]);
      expect(vscreenLR.vscreenFocusNextIndexList, [0, 0, 1, 0]);
      /// action
      expect(vscreenLR.vscreenFocusPageNext(), ['(1-2-3-4-5-6-7)', '(1-2-3)', '2', '1']);
      /// state
      expect(vscreenLR.vscreenFocusPrevIndexList, [0, 0, 0, 0]);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [0, 0, 1, 0]);
      expect(vscreenLR.vscreenFocusNextIndexList, [0, 0, 2]);
      /// action
      expect(vscreenLR.vscreenFocusPageNext(), ['(1-2-3-4-5-6-7)', '(1-2-3)', '3']);
      /// state
      expect(vscreenLR.vscreenFocusPrevIndexList, [0, 0, 1, 0]);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [0, 0, 2]);
      expect(vscreenLR.vscreenFocusNextIndexList, [0 , 1]);
      /// action
      expect(vscreenLR.vscreenFocusPageNext(), ['(1-2-3-4-5-6-7)', '4']);
      /// state
      expect(vscreenLR.vscreenFocusPrevIndexList, [0, 0, 2]);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [0 , 1]);
      expect(vscreenLR.vscreenFocusNextIndexList, [0, 2, 0, 0]);
      /// action
      expect(vscreenLR.vscreenFocusPageNext(), ['(1-2-3-4-5-6-7)', '(5-6-7)', '1', '1']);
      /// state
      expect(vscreenLR.vscreenFocusPrevIndexList, [0, 1]);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [0, 2, 0, 0]);
      expect(vscreenLR.vscreenFocusNextIndexList, [0, 2, 1]);
      /// action
      expect(vscreenLR.vscreenFocusPageNext(), ['(1-2-3-4-5-6-7)', '(5-6-7)', '2']);
      /// state
      expect(vscreenLR.vscreenFocusPrevIndexList, [0, 2, 0, 0]);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [0, 2, 1]);
      expect(vscreenLR.vscreenFocusNextIndexList, [0, 2, 2, 0]);
      /// action
      expect(vscreenLR.vscreenFocusPageNext(), ['(1-2-3-4-5-6-7)', '(5-6-7)', '3', '1']);
      /// state
      expect(vscreenLR.vscreenFocusPrevIndexList, [0 ,2, 1]);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [0 ,2, 2, 0]);
      expect(vscreenLR.vscreenFocusNextIndexList, [1]);
      /// action
      expect(vscreenLR.vscreenFocusPageNext(), ['8']);
      /// state
      expect(vscreenLR.vscreenFocusPrevIndexList, [0 ,2, 2, 0]);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [1]);
      expect(vscreenLR.vscreenFocusNextIndexList, []);
    });
    test('(LR)SinglePageManager.vscreenSinglePagePrev', (){
      /// action
      expect(vscreenLR.vscreenFocusPagePrev(), ['(1-2-3-4-5-6-7)', '(5-6-7)', '3', '1']);
      /// state
      expect(vscreenLR.vscreenFocusPrevIndexList, [0 ,2, 1]);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [0 ,2, 2, 0]);
      expect(vscreenLR.vscreenFocusNextIndexList, [1]);
      /// action
      expect(vscreenLR.vscreenFocusPagePrev(), ['(1-2-3-4-5-6-7)', '(5-6-7)', '2']);
      /// state
      expect(vscreenLR.vscreenFocusPrevIndexList, [0, 2, 0, 0]);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [0, 2, 1]);
      expect(vscreenLR.vscreenFocusNextIndexList, [0, 2, 2, 0]);
      /// action
      expect(vscreenLR.vscreenFocusPagePrev(), ['(1-2-3-4-5-6-7)', '(5-6-7)', '1', '1']);
      /// state
      expect(vscreenLR.vscreenFocusPrevIndexList, [0, 1]);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [0, 2, 0, 0]);
      expect(vscreenLR.vscreenFocusNextIndexList, [0, 2, 1]);
      /// action
      expect(vscreenLR.vscreenFocusPagePrev(), ['(1-2-3-4-5-6-7)', '4']);
      /// state
      expect(vscreenLR.vscreenFocusPrevIndexList, [0, 0, 2]);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [0 , 1]);
      expect(vscreenLR.vscreenFocusNextIndexList, [0, 2, 0, 0]);
      /// action
      expect(vscreenLR.vscreenFocusPagePrev(), ['(1-2-3-4-5-6-7)', '(1-2-3)', '3']);
      /// state
      expect(vscreenLR.vscreenFocusPrevIndexList, [0, 0, 1, 0]);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [0, 0, 2]);
      expect(vscreenLR.vscreenFocusNextIndexList, [0 , 1]);
      /// action
      expect(vscreenLR.vscreenFocusPagePrev(), ['(1-2-3-4-5-6-7)', '(1-2-3)', '2', '1']);
      /// state
      expect(vscreenLR.vscreenFocusPrevIndexList, [0, 0, 0, 0]);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [0, 0, 1, 0]);
      expect(vscreenLR.vscreenFocusNextIndexList, [0, 0, 2]);
      /// action
      expect(vscreenLR.vscreenFocusPagePrev(), ['(1-2-3-4-5-6-7)', '(1-2-3)', '1', '1']);
      /// state
      expect(vscreenLR.vscreenFocusPrevIndexList, []);
      expect(vscreenLR.vscreenFocusCurrentIndexList, [0, 0, 0, 0]);
      expect(vscreenLR.vscreenFocusNextIndexList, [0, 0, 1, 0]);
    });
    
    final vscreenRL = createVirtualScreenTester();
    test('(RL)SinglePageManager.vscreenSinglePageNext', (){
      expect(vscreenRL.vscreenFocusPageSingleRL(), [1]);/// ['8']
      expect(vscreenRL.vscreenFocusPageCurrent(), ['8']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, []);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [1]);
      expect(vscreenRL.vscreenFocusNextIndexList, [0 ,2, 2, 0]);
      /// action
      expect(vscreenRL.vscreenFocusPageNext(), ['(1-2-3-4-5-6-7)', '(5-6-7)', '3', '1']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, [1]);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [0 ,2, 2, 0]);
      expect(vscreenRL.vscreenFocusNextIndexList, [0 ,2, 1]);
      /// action
      expect(vscreenRL.vscreenFocusPageNext(), ['(1-2-3-4-5-6-7)', '(5-6-7)', '2']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, [0, 2, 2, 0]);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [0, 2, 1]);
      expect(vscreenRL.vscreenFocusNextIndexList, [0, 2, 0, 0]);
      /// action
      expect(vscreenRL.vscreenFocusPageNext(), ['(1-2-3-4-5-6-7)', '(5-6-7)', '1', '1']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, [0, 2, 1]);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [0, 2, 0, 0]);
      expect(vscreenRL.vscreenFocusNextIndexList, [0, 1]);
      /// action
      expect(vscreenRL.vscreenFocusPageNext(), ['(1-2-3-4-5-6-7)', '4']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, [0, 2, 0, 0]);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [0, 1]);
      expect(vscreenRL.vscreenFocusNextIndexList, [0, 0, 2]);
      /// action
      expect(vscreenRL.vscreenFocusPageNext(), ['(1-2-3-4-5-6-7)', '(1-2-3)', '3']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, [0 , 1]);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [0, 0, 2]);
      expect(vscreenRL.vscreenFocusNextIndexList, [0, 0, 1, 0]);
      /// action
      expect(vscreenRL.vscreenFocusPageNext(), ['(1-2-3-4-5-6-7)', '(1-2-3)', '2', '1']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, [0, 0, 2]);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [0, 0, 1, 0]);
      expect(vscreenRL.vscreenFocusNextIndexList, [0, 0, 0, 0]);
      /// action
      expect(vscreenRL.vscreenFocusPageNext(), ['(1-2-3-4-5-6-7)', '(1-2-3)', '1', '1']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, [0, 0, 1, 0]);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [0, 0, 0, 0]);
      expect(vscreenRL.vscreenFocusNextIndexList, []);
    });
    test('(RL)SinglePageManager.vscreenSinglePagePrev', (){
      /// action
      expect(vscreenRL.vscreenFocusPagePrev(), ['(1-2-3-4-5-6-7)', '(1-2-3)', '2', '1']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, [0, 0, 2]);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [0, 0, 1, 0]);
      expect(vscreenRL.vscreenFocusNextIndexList, [0, 0, 0, 0]);
      /// action
      expect(vscreenRL.vscreenFocusPagePrev(), ['(1-2-3-4-5-6-7)', '(1-2-3)', '3']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, [0 , 1]);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [0, 0, 2]);
      expect(vscreenRL.vscreenFocusNextIndexList, [0, 0, 1, 0]);
      /// action
      expect(vscreenRL.vscreenFocusPagePrev(), ['(1-2-3-4-5-6-7)', '4']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, [0, 2, 0, 0]);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [0, 1]);
      expect(vscreenRL.vscreenFocusNextIndexList, [0, 0, 2]);
      /// action
      expect(vscreenRL.vscreenFocusPagePrev(), ['(1-2-3-4-5-6-7)', '(5-6-7)', '1', '1']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, [0, 2, 1]);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [0, 2, 0, 0]);
      expect(vscreenRL.vscreenFocusNextIndexList, [0, 1]);
      /// action
      expect(vscreenRL.vscreenFocusPagePrev(), ['(1-2-3-4-5-6-7)', '(5-6-7)', '2']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, [0, 2, 2, 0]);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [0, 2, 1]);
      expect(vscreenRL.vscreenFocusNextIndexList, [0, 2, 0, 0]);
      /// action
      expect(vscreenRL.vscreenFocusPagePrev(), ['(1-2-3-4-5-6-7)', '(5-6-7)', '3', '1']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, [1]);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [0 ,2, 2, 0]);
      expect(vscreenRL.vscreenFocusNextIndexList, [0 ,2, 1]);
      /// action
      expect(vscreenRL.vscreenFocusPagePrev(), ['8']);
      /// state
      expect(vscreenRL.vscreenFocusPrevIndexList, []);
      expect(vscreenRL.vscreenFocusCurrentIndexList, [1]);
      expect(vscreenRL.vscreenFocusNextIndexList, [0 ,2, 2, 0]);
    });
  });

  
}

SinglePageVirtualScreenTester createVirtualScreenTester() => SinglePageVirtualScreenTester(FocusPageMode.multiLR, ['(1-2-3-4-5-6-7)','8'], {
  '(1-2-3-4-5-6-7)': SinglePageVirtualScreenTester(FocusPageMode.multiLR, ['(1-2-3)','4','(5-6-7)'], {
    '(1-2-3)': SinglePageVirtualScreenTester(FocusPageMode.multiLR, ['1','2','3'], {
        '1': SinglePageVirtualScreenTester(FocusPageMode.multiLR, ['1'], null),
        '2': SinglePageVirtualScreenTester(FocusPageMode.multiLR, ['1'], null),
      }),
    '(5-6-7)': SinglePageVirtualScreenTester(FocusPageMode.multiLR, ['1','2','3'], {
        '1': SinglePageVirtualScreenTester(FocusPageMode.multiLR, ['1'], null),
        '3': SinglePageVirtualScreenTester(FocusPageMode.multiLR, ['1'], null),
      }),
  })
});