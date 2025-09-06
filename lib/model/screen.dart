// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import '../state.dart';
import 'context.dart';
import 'grid.dart';

enum CATEGORY { tv_gamepad, pc_mousekeyboard, mobile_gesture, all}

typedef GKeyValueRecord = (GlobalKey, Rect?);
typedef RCPair = ({int row, int column});
// typedef ScreenPTNull = (String? singlePT, String? contextPT);
typedef ScreenPT = (String singlePT, String contextPT);
typedef ColumnPos = (int posLR, int posRL, int columns);

const String PT_FULLSCREEN = 'fullscreen';
const Null PT_CELL = null;
const String PT_CELL_ABOVE_5 = 'cell_above_5';

const String PT_COLUMN_ONE = PT_1;
const String PT_COLUMN_TWO = '$PT_1,$PT_2';
const String PT_COLUMN_THREE = '$PT_COLUMN_TWO,$PT_3';
const String PT_COLUMN_FOUR = '$PT_COLUMN_THREE,$PT_4';
const String PT_COLUMN_FIVE = '$PT_COLUMN_FOUR,$PT_5';

const String PT_FULL_ONE = '($PT_1)';
const String PT_FULL_TWO = PT_12;
const String PT_FULL_THREE = PT_123;
const String PT_FULL_FOUR = PT_1234;
const String PT_FULL_FIVE = PT_12345;


const String PT_12 = '(1-2)';
const String PT_123 = '(1-2-3)';
const String PT_1234 = '(1-2-3-4)';
const String PT_12345 = '(1-2-3-4-5)';
const String PT_23 = '(2-3)';
const String PT_234 = '(2-3-4)';
const String PT_2345 = '(2-3-4-5)';
const String PT_34 = '(3-4)';
const String PT_345 = '(3-4-5)';
const String PT_45 = '(4-5)';

const String PT_1 = '1';
const String PT_2 = '2';
const String PT_3 = '3';
const String PT_4 = '4';
const String PT_5 = '5';


/// 五联屏语境
const String PT_12_3_4_5 ='$PT_12,$PT_3,$PT_4,$PT_5';
const String PT_1_23_4_5 ='$PT_1,$PT_23,$PT_4,$PT_5';
const String PT_1_2_34_5 ='$PT_1,$PT_2,$PT_34,$PT_5';
const String PT_12_34_5 ='$PT_12,$PT_34,$PT_5';
const String PT_1_2_3_45 ='$PT_1,$PT_2,$PT_3,$PT_45';
const String PT_12_3_45 ='$PT_12,$PT_3,$PT_45';
const String PT_1_23_45 ='$PT_1,$PT_23,$PT_45';

const String PT_123_4_5 ='$PT_123,$PT_4,$PT_5';
const String PT_123_45 ='$PT_123,$PT_45';
const String PT_1_234_5 ='$PT_1,$PT_234,$PT_5';
const String PT_1_2_345 ='$PT_1,$PT_2,$PT_345';
const String PT_12_345 ='$PT_12,$PT_345';

const String PT_1234_5 ='$PT_1234,$PT_5';
const String PT_1_2345 ='$PT_1,$PT_2345';

/// 四联屏语境
const String PT_12_3_4 ='$PT_12,$PT_3,$PT_4';
const String PT_1_23_4 ='$PT_1,$PT_23,$PT_4';
const String PT_1_2_34 ='$PT_1,$PT_2,$PT_34';
const String PT_12_34 ='$PT_12,$PT_34';
const String PT_123_4 ='$PT_123,$PT_4';
const String PT_1_234 ='$PT_1,$PT_234';

/// 三联屏语境
const String PT_12_3 ='$PT_12,$PT_3';
const String PT_1_23 ='$PT_1,$PT_23';

enum TailColumnExpand { left, right, none }

enum SingleMode { LR, RL, none }

class ScreenContext extends BaseContext{
  ScreenContext({RUNMODE mode = RUNMODE.debug, Size? singleAspectRatioSize, TailColumnExpand tailColumnExpand = TailColumnExpand.none, required RCPair rowColumn }): 
  _mode = mode, _singleAspectRatioSize = singleAspectRatioSize, _rowColumn = rowColumn , _tailColumnExpand = tailColumnExpand {
    /// 同时计算 fullscreenAspectRatioSize
    rowColumn = _rowColumn;
  }

  factory ScreenContext.fromRVG(ResponsiveValueGroup rvg) => ScreenContext( rowColumn: rvg.rowColumn , singleAspectRatioSize: rvg.singleAspectRatio );

  RUNMODE _mode;
  Size? _singleAspectRatioSize;
  Size? _fullscreenAspectRatioSize;
  TailColumnExpand _tailColumnExpand;
  RCPair _rowColumn;
  
  /// 初始化 Key
  Map<String, GlobalKey> gKeys = {};
  /// 跟测量相关
  Map<String, GKeyValueRecord> gKeyMappedValues = {};

  int get row => _rowColumn.row;
  int get column => _rowColumn.column;
  RCPair get rowColumn => _rowColumn;
  
  /// 更改行列会导致
  /// 重新布局 gKeys.clear();
  /// 需要测量 gKeyMappedValues.clear();
  /// 恢复 语境初始分屏模式
  set rowColumn(RCPair rowColumn){
    _rowColumn = rowColumn;

    gKeys.clear();
    gKeyMappedValues.clear();
    resetPattern();
  }
  
  /// 更改模式不引起重新布局
  set mode(RUNMODE mode){
    _mode = mode;
    notifyListeners();
  }

  /// 更改屏幕比例导致
  /// 重新测量 gKeyMappedValues.clear();
  set singleAspectRatioSize(Size? size){
    _singleAspectRatioSize = size;
    _fullscreenAspectRatioSize = size != null && TailColumnExpand.none == tailColumnExpand ? Size(size.width * column, size.height * row) : null;
    gKeyMappedValues.clear();
    resetPattern();
  }

  void handSet(ScreenHandset setting){
    rowColumn = setting.rowColumn;
    singleAspectRatioSize = setting.singleAspectRatio;
  }

  Size? get fullscreenAspectRatioSize => _fullscreenAspectRatioSize;

  bool get isNeedMeasure => gKeyMappedValues.isEmpty; 

  bool get measured => gKeyMappedValues.isNotEmpty;

  Size? get singleAspectRatioSize => _singleAspectRatioSize; 

  TailColumnExpand get tailColumnExpand => _tailColumnExpand;

  set tailColumnExpand(TailColumnExpand expand)=>_tailColumnExpand = expand;

  RUNMODE get mode => _mode;

  List<String> get singles => _currentPattern == PT_CELL ? List.generate(column, (index)=>'${index+1}') : _currentPattern!.split(',');
   /// 六联屏、七联屏(暂不设计)
  /// 五联屏
  /// 5:全屏(1,2,3,4,5), 左边(1,2), 中左(2,3), 正中央(3), 中右(3,4), 右边(4,5), 中间(2,3,4), 左(1,2,3), 右(3,4,5), 最左=左左(1), 最右=右右(5), 靠左=左中(2), 靠右=右中(4), 左全屏(1,2,3,4), 右全屏(2,3,4,5)
  /// 4:全屏(1,2,3,4), 左边(1,2), 中间(2,3), 右边(2,3), 左全屏(1,2,3), 右全屏(2,3,4), 最左=左左(1), 最右=右右(4), 中左=左中(2), 中右=右中(3) 
  /// 3:全屏(1,2,3), 左屏=左边(1,2), 右屏=右边(2,3), 左(1), 中(2), 右(3)
  /// 2:中间(1,2), 左=左边=左左=最左=中左=左中(1), 右=右边=右右=最右=中右=右中(2)
  /// 
  /// 五联屏语境
  /// 双屏幕版 
  /// (1,2),3,4,5丨1,(2,3),4,5丨1,2,(3,4),5丨1,2,3,(4,5)
  /// (1,2),(3,4),5丨(1,2),3,(4,5)丨1,(2,3),(4,5)
  /// 三屏幕版
  /// (1,2,3),4,5丨1,(2,3,4),5丨1,2,(3,4,5)
  /// 三双屏幕版
  /// (1,2,3),(4,5)丨(1,2),(3,4,5)
  /// 四屏幕版
  /// (1,2,3,4),5丨1,(2,3,4,5)
  /// 
  /// 四联屏语境
  /// 双屏幕版 
  /// (1,2),3,4丨(1,2),(3,4)
  /// 1,(2,3),4
  /// 1,2,(3,4)
  /// 三屏幕版
  /// (1,2,3),4
  /// 1,(2,3,4)
  /// 
  /// 三联屏语境
  /// 双屏幕版 
  /// (1,2),3
  /// 1,(2,3)
  String? _currentPattern;
  String? _lastPattern;
  /// 2025.8.31 新增 _currentSingle 仅在竖屏模式下使用表示展示当前单个屏幕语境(始终单栏)
  int _currentSingleIndex = -1;
  SingleMode singleNextMode = SingleMode.none;

  String singleModeStartRL([int? index]){
    singleNextMode = SingleMode.RL;
    final tempIndex = index ?? _currentSingleIndex;
    _currentSingleIndex = tempIndex >= 0 && tempIndex <= singles.length - 1 ? tempIndex : singles.length - 1;
    // gKeyMappedValues.clear();
    return singleCurrentPT!;
  }

  String singleModeStartLR([int? index]){
    singleNextMode = SingleMode.LR;
    final tempIndex = index ?? _currentSingleIndex;
    _currentSingleIndex = tempIndex >= 0 && tempIndex <= singles.length - 1 ? tempIndex : 0;
    // gKeyMappedValues.clear();
    return singleCurrentPT!;
  }

  String? singleModeNext(){
    _currentSingleIndex = singleNextIndex;
    return singleCurrentPT;
  }

  String? singleModePrev(){
    _currentSingleIndex = singlePrevIndex;
    return singleCurrentPT;
  }

  void singleModeStop(){
    singleNextMode = SingleMode.none;
    // gKeyMappedValues.clear();
  }
  
  String? get singleCurrentPT => singleNextMode != SingleMode.none && _currentSingleIndex >=0 && _currentSingleIndex < singles.length ? singles[_currentSingleIndex] : null;
  int get singleNextIndex => switch(singleNextMode){
    SingleMode.none => -1,
    SingleMode.RL => _currentSingleIndex - 1  >= 0 && _currentSingleIndex < singles.length ? _currentSingleIndex - 1 : -1,
    SingleMode.LR => _currentSingleIndex + 1 < singles.length ? _currentSingleIndex + 1 : -1
  };
  String? get singleNextPT => switch(singleNextMode){
    SingleMode.none => null,
    SingleMode.RL => _currentSingleIndex - 1  >= 0 && _currentSingleIndex < singles.length ? singles[_currentSingleIndex - 1] : null,
    SingleMode.LR => _currentSingleIndex + 1 < singles.length ? singles[_currentSingleIndex + 1] : null
  };
  int get singlePrevIndex => switch(singleNextMode){
    SingleMode.none => -1,
    SingleMode.RL => _currentSingleIndex + 1 < singles.length ? _currentSingleIndex + 1 : -1,
    SingleMode.LR => _currentSingleIndex - 1  >= 0 && _currentSingleIndex < singles.length ? _currentSingleIndex - 1 : -1,
  };
  String? get singlePrevPT => switch(singleNextMode){
    SingleMode.none => null,
    SingleMode.RL => _currentSingleIndex + 1 < singles.length ? singles[_currentSingleIndex + 1] : null,
    SingleMode.LR => _currentSingleIndex - 1  >= 0 && _currentSingleIndex < singles.length ? singles[_currentSingleIndex - 1] : null,
  };

  set currentPatternNullable(String? current){
    _lastPattern = _currentPattern;
    _currentPattern = current;
    /// 确保生命周期 onMeasured 每次都执行
    // if(_currentPattern != _lastPattern){
    gKeyMappedValues.clear();
    // }
  } 

  void autoSetPatternByColumnNum(){
    currentPatternNullable = switch(column){
      5=>PT_COLUMN_FIVE, 4=>PT_COLUMN_FOUR, 3=>PT_COLUMN_THREE, 2=>PT_COLUMN_TWO, 1=>PT_COLUMN_ONE, _=>PT_CELL
    };
  }

  void resetPattern(){
    _currentPattern = null;
    _lastPattern = null;
  }
  
  String? get currentPatternNullable => _currentPattern;
  String get currentPattern => _currentPattern == null ? switch(column){
    1=>PT_COLUMN_ONE,2=>PT_COLUMN_TWO,3=>PT_COLUMN_THREE,4=>PT_COLUMN_FOUR,5=>PT_COLUMN_FIVE,_=>PT_CELL_ABOVE_5
  } : (currentPatternNullable == PT_FULLSCREEN ? switch(column){
    1=>PT_FULL_ONE,2=>PT_FULL_TWO,3=>PT_FULL_THREE,4=>PT_FULL_FOUR,5=>PT_FULL_FIVE,_=>PT_FULLSCREEN
  } : currentPatternNullable!);
  String? get lastPattern => _lastPattern; 
  
  Map<String, Color> contextScreenColorMap = {
    PT_12: Colors.accents[2][100]!,
    PT_23: Colors.accents[5][100]!,
    PT_34: Colors.accents[8][100]!,
    PT_45: Colors.accents[11][100]!,
    PT_123: Colors.accents[14][100]!,
    PT_234: Colors.accents[1][100]!,
    PT_345: Colors.accents[4][100]!,
    PT_1234: Colors.accents[7][100]!,
    PT_2345: Colors.accents[10][100]!,
    PT_FULLSCREEN: Colors.accents[13][100]!
  };
  Map<int, Map<String, Map<String?, String?>>> contextScreenPatternsMap = {
    5: {
      PT_12:{
        PT_CELL: PT_12_3_4_5, PT_12_3_4_5: PT_CELL, 
        PT_1_23_4_5: PT_123_4_5, PT_123_4_5: PT_1_23_4_5, 
        PT_1_2_34_5: PT_12_34_5, PT_12_34_5: PT_1_2_34_5,
        PT_1_2_3_45: PT_12_3_45, PT_12_3_45: PT_1_2_3_45,
        PT_1_234_5: PT_1234_5,PT_1234_5: PT_1_234_5,
        PT_1_23_45: PT_123_45, PT_123_45: PT_1_23_45,
        PT_1_2_345: PT_12_345, PT_12_345: PT_1_2_345,
        PT_1_2345: PT_FULLSCREEN, PT_FULLSCREEN: PT_1_2345
      },
      PT_23:{
        PT_CELL: PT_1_23_4_5, PT_1_23_4_5: PT_CELL, 
        PT_12_3_4_5: PT_123_4_5, PT_123_4_5: PT_12_3_4_5,
        PT_12_34_5: PT_1234_5, PT_1234_5: PT_12_34_5,
        PT_12_345: PT_FULLSCREEN, PT_FULLSCREEN: PT_12_345,
        PT_12_3_45: PT_123_45,PT_123_45: PT_12_3_45,
        PT_1_2_34_5: PT_1_234_5,PT_1_234_5: PT_1_2_34_5,
        PT_1_2_3_45: PT_1_23_45, PT_1_23_45: PT_1_2_3_45,
        PT_1_2_345: PT_1_2345, PT_1_2345: PT_1_2_345
      },
      PT_34:{
        PT_CELL: PT_1_2_34_5, PT_1_2_34_5: PT_CELL,
        PT_12_3_4_5: PT_12_34_5, PT_12_34_5: PT_12_3_4_5,        
        PT_123_4_5: PT_1234_5, PT_1234_5: PT_123_4_5,
        PT_123_45: PT_FULLSCREEN, PT_FULLSCREEN: PT_123_45,
        PT_12_3_45: PT_12_345, PT_12_345: PT_12_3_45,
        PT_1_23_4_5: PT_1_234_5, PT_1_234_5: PT_1_23_4_5,
        PT_1_23_45: PT_1_2345,PT_1_2345: PT_1_23_45,
        PT_1_2_3_45: PT_1_2_345, PT_1_2_345: PT_1_2_3_45,
      },
      PT_45:{
        PT_CELL: PT_1_2_3_45, PT_1_2_3_45: PT_CELL,
        PT_12_3_4_5: PT_12_3_45, PT_12_3_45: PT_12_3_4_5,
        PT_1_23_4_5: PT_1_23_45, PT_1_23_45: PT_1_23_4_5,
        PT_1_2_34_5: PT_1_2_345, PT_1_2_345: PT_1_2_34_5,
        PT_12_34_5: PT_12_345, PT_12_345: PT_12_34_5,
        PT_123_4_5: PT_123_45, PT_123_45: PT_123_4_5,
        PT_1234_5: PT_FULLSCREEN, PT_FULLSCREEN: PT_1234_5,
        PT_1_234_5: PT_1_2345, PT_1_2345: PT_1_234_5
      }
    },
    4:{
      PT_12:{
        PT_12_3_4: PT_CELL, PT_CELL: PT_12_3_4, 
        PT_1_23_4: PT_123_4, PT_123_4: PT_1_23_4,
        PT_1_2_34: PT_12_34, PT_12_34: PT_1_2_34,
        PT_1_234: PT_FULLSCREEN, PT_FULLSCREEN: PT_1_234,
      },
      PT_23:{
        PT_1_23_4: PT_CELL, PT_CELL: PT_1_23_4,
        PT_12_3_4: PT_123_4, PT_123_4: PT_12_3_4,
        PT_12_34: PT_FULLSCREEN, PT_FULLSCREEN: PT_12_34,
        PT_1_2_34: PT_1_234, PT_1_234: PT_1_2_34
      },
      PT_34:{
        PT_1_2_34: PT_CELL, PT_CELL: PT_1_2_34,
        PT_12_3_4: PT_12_34,PT_12_34: PT_12_3_4,
        PT_1_23_4: PT_1_234,PT_1_234: PT_1_23_4,
        PT_123_4: PT_FULLSCREEN, PT_FULLSCREEN: PT_123_4
      }
    },
    3:{
      PT_12:{
        PT_12_3: PT_CELL, PT_CELL:PT_12_3,
        PT_1_23: PT_FULLSCREEN, PT_FULLSCREEN: PT_1_23,
      },
      PT_23:{
        PT_1_23: PT_CELL, PT_CELL: PT_1_23,
        PT_12_3: PT_FULLSCREEN, PT_FULLSCREEN: PT_12_3
      }
    }
  };
  Map<int, Map<String, List<String>>> contextScreenPatterns = {
    5: {
      '2+1拼画': [PT_12_3_4_5, PT_1_23_4_5, PT_1_2_34_5, PT_1_2_3_45],
      '2+2拼画': [PT_12_34_5, PT_12_3_45, PT_1_23_45],
      '3+1拼画': [PT_123_4_5, PT_1_234_5, PT_1_2_345],
      '3+2拼画': [PT_123_45, PT_12_345],
      '4+1拼画': [PT_1234_5, PT_1_2345]
    },
    4: {
      '2+1拼画': [PT_12_3_4, PT_1_23_4, PT_1_2_34],
      '2+2拼画': [PT_12_34],
      '3+1拼画': [PT_123_4, PT_1_234],
    },
    3:{
      '2+1拼画': [PT_12_3,PT_1_23]
    }
  };

  Rect? measuredCell(int column, [int row = 1]){
    if(measured){
      var data = gKeyMappedValues['cell-$column-$row'];
      return data?.$2;
    }
    return null;
  }

  /// 包含 cell-x-1 的情况
  Rect? measuredPT(String singlePT){
    if(measured){
      var data = gKeyMappedValues[singlePT] ?? (row == 1 ? gKeyMappedValues['cell-$singlePT-1'] : null);
      return data?.$2;
    }
    return null;
  }

  // Rect? Function(Size size) columnRect(String screenPT){
  //   columnPosFromScreenPT(screenPT);
  //   /// 平分
  //   if(_singleAspectRatioSize == null){
      
  //   }
  // }

  (String, String)? cellRange(String singlePT){
    switch(singlePT){
      case PT_1:
      case PT_FULL_ONE:
        return ('cell-1-1', 'cell-1-$row');
      case PT_2:
        return ('cell-2-1', 'cell-2-$row');
      case PT_3:
        return ('cell-3-1', 'cell-3-$row');
      case PT_4:
        return ('cell-4-1', 'cell-4-$row');
      case PT_5:
        return ('cell-5-1', 'cell-5-$row');
    }
    if(singlePT.startsWith('(') && singlePT.endsWith(')')){
      var ranges = singlePT.substring(1, singlePT.length - 1).split('-');
      return ('cell-${ranges.first}-1','cell-${ranges.last}-$row');
    }
    return null;
  }

  Rect? paintRect(String singlePT){
    if(singleCurrentPT != null) return currentSize != null ? Offset.zero & currentSize! : null;
    if(measured){
      var data = measuredPT(singlePT);
      if(data != null){
        return data;
      }
      /// 如果没有现成的需要计算
      var range = cellRange(singlePT);
      if(range != null){
        final fromStartCell = gKeyMappedValues[range.$1];
        final toEndCell = gKeyMappedValues[range.$2];
        if(fromStartCell != null && fromStartCell.$2 != null && toEndCell != null && toEndCell.$2 != null){
          return fromStartCell.$2!.expandToInclude(toEndCell.$2!);
        }
      }
    }
    return null;
  }

  Rect? rectFromGrid({int? column, int row = 1, String? singlePT, required List<NamedLine> verticals, required List<NamedLine> horizontals, bool isGlobal = true}){
    assert(verticals.length > 1 && horizontals.length > 1);
    assert(column != null || singlePT != null);
    Rect? measured;
    if(singlePT != null){
      measured = measuredPT(singlePT);
    }else{
      measured = measuredCell(column!, row);
    }
    if(measured != null){
      return Rect.fromLTRB(verticals.first.computeWidth(measured.size), horizontals.first.computeHeight(measured.size),
                          verticals.last.computeWidth(measured.size), horizontals.last.computeHeight(measured.size)).shift( isGlobal ? measured.topLeft : Offset.zero );
    }
    return null;
  }

  Offset? offsetFromGrid({int? column, int row = 1, String? singlePT, required NamedLine vertical, required NamedLine horizontal, bool isGlobal = true}){
    assert(column != null || singlePT != null);
    Rect? measured;
    if(singlePT != null){
      measured = measuredPT(singlePT);
    }else{
      measured = measuredCell(column!, row);
    }
    if(measured != null){
      // ketchupDebug('autoOffset:$measured, vertical(1/1)=>${vertical.percentGetter(Size.square(1))}, horizontal(1/1)=>${horizontal.percentGetter(Size.square(1))}');
      return (isGlobal ? measured.topLeft : Offset.zero ) + Offset(vertical.computeWidth(measured.size), horizontal.computeHeight(measured.size));
    }
    return null;
  }

  bool get tailColumnExpandAvailable => tailColumnExpand != TailColumnExpand.none && singleAspectRatioSize != null;
  
  /// 检查屏幕语境是否包含尾屏
  isTailInclude(String singlePT){
    if(tailColumnExpandAvailable){
      var leftTail = PT_1;
      var rightTail = '$column';
      if(tailColumnExpand == TailColumnExpand.left && singlePT.contains(leftTail)) return true;
      if(tailColumnExpand == TailColumnExpand.right && singlePT.contains(rightTail)) return true;
    }
    return false;
  }

  static ColumnPos? columnPosFromScreenPT(String singlePT){
    switch(singlePT){
      case PT_12345:
        return (1, 5, 5);
      case PT_1234:
        return (1, 4, 4);
      case PT_2345:
        return (2, 5, 4);
      case PT_123:
        return (1, 3, 3);
      case PT_234:
        return (2, 4, 3);
      case PT_345:
        return (3, 5, 3);
      case PT_12:
        return (1, 2, 2);
      case PT_23:
        return (2, 3, 2);
      case PT_34:
        return (3, 4, 2);
      case PT_45:
        return (4, 5, 2);
      case PT_1:
        return (1, 1, 1);
      case PT_2:
        return (2, 2, 1);
      case PT_3:
        return (3, 3, 1);
      case PT_4:
        return (4, 4, 1);
      case PT_5:
        return (5, 5, 1);
      default: 
        return null;
    }
  }
  
  String screenPTFromColumnsLR(int column){
    return singles.firstWhere((pt){
      final pos = columnPosFromScreenPT(pt)!;
      return column >= pos.$1 && column <= pos.$2;
    });
  }

  static String? screenPTColumnsLR(int fromStartLR, int columns){
    switch(fromStartLR){
      case 1:
        return switch(columns){
          5=>PT_12345,
          4=>PT_1234,
          3=>PT_123,
          2=>PT_12,
          1=>PT_1,
          _=>null
        };
      case 2:
        return switch(columns){
          4=>PT_2345,
          3=>PT_234,
          2=>PT_23,
          1=>PT_2,
          _=>null
        };
      case 3:
        return switch(columns){
          3=>PT_345,
          2=>PT_34,
          1=>PT_3,
          _=>null
        };
      case 4:
        return switch(columns){
          2=>PT_45,
          1=>PT_4,
          _=>null
        };
      case 5:
        return switch(columns){
          1=>PT_5,
          _=>null
        };
      default: 
        return null;
    }
  }

  static String? screenPTColumnsRL(int fromStartRL, int columns){
    switch(fromStartRL){
      case 5:
        return switch(columns){
          5=>PT_12345,
          4=>PT_2345,
          3=>PT_345,
          2=>PT_45,
          1=>PT_5,
          _=>null
        };
      case 4:
        return switch(columns){
          4=>PT_1234,
          3=>PT_234,
          2=>PT_34,
          1=>PT_4,
          _=>null
        };
      case 3:
        return switch(columns){
          3=>PT_123,
          2=>PT_23,
          1=>PT_3,
          _=>null
        };
      case 2:
        return switch(columns){
          2=>PT_12,
          1=>PT_2,
          _=>null
        };
      case 1:
        return switch(columns){
          1=>PT_1,
          _=>null
        };
      default: 
        return null;
    }
  }

  static List<String>? genScreenPTColumnsLR(List<int> columnsLR, int maxColumn){
    if(columnsLR.length > maxColumn || columnsLR.fold<int>(0, (total, added)=>total+added) > maxColumn ) return null;
    var fromStart = 1, index = 0;
    List<String> list = [];
    while(fromStart <= maxColumn){
      var willFillColumns = index < columnsLR.length ?  columnsLR[index] : 1;
      var willAdded = screenPTColumnsLR(fromStart, willFillColumns);
      if(willAdded != null){
        list.add(willAdded);
        index ++;
        fromStart += willFillColumns;
      }else{
        return null;
      }
    }
    return list;
  }

  static List<String>? genScreenPTColumnsRL(List<int> columnsRL, int maxColumn){
    if(columnsRL.length > maxColumn || columnsRL.fold<int>(0, (total, added)=>total+added) > maxColumn ) return null;
    var fromStart = maxColumn, index = 0;
    List<String> list = [];
    while(fromStart > 0){
      var willFillColumns = index < columnsRL.length ?  columnsRL[index] : 1;
      var willAdded = screenPTColumnsRL(fromStart, willFillColumns);
      if(willAdded != null){
        list.add(willAdded);
        index ++;
        fromStart -= willFillColumns;
      }else{
        return null;
      }
    }
    return list.reversed.toList();
  }

  String? genContextPTColumnsLR(List<int> columnsLR){
    return genScreenPTColumnsLR(columnsLR, column)?.join(',');
  }

  String? genContextPTColumnsRL(List<int> columnsRL){
    return genScreenPTColumnsRL(columnsRL, column)?.join(',');
  }
  
  final List<VoidCallback> _measuredCbs = [];

  void produceMeasuredCb(VoidCallback measuredCb){
    _measuredCbs.add(measuredCb);
  }
  
  VoidCallback? get consumeMeasuredCb => _measuredCbs.isEmpty ? null : (){
    while(_measuredCbs.isNotEmpty){
      _measuredCbs.removeLast()();
    }
  };

  /// 根据当前 singlePT 获得 - 的分割比例，用于绘制拼屏网格线(物理拼缝，不包含在grid中)
  List<double> Function(Size size)? columnSplits(String singlePT){
    if(singlePT == PT_FULLSCREEN && column <= 5) singlePT = screenPTColumnsLR(1, column) ?? singlePT;
    if(singlePT.contains('cell') || !singlePT.contains('-')) return null;
    final divides = singlePT.split('-').length;
    if(tailColumnExpandAvailable){
      final double columnAspectRatio = singleAspectRatioSize!.aspectRatio / row; 
      if(tailColumnExpand == TailColumnExpand.left && singlePT.contains(PT_1)){
        return (Size size)=>List.generate(divides - 1, (index)=>size.height * columnAspectRatio * (index + 1)).reversed.toList();
      }else
      if(tailColumnExpand == TailColumnExpand.right && singlePT.contains(column.toString())){
        final double columnAspectRatio = singleAspectRatioSize!.aspectRatio / row; 
        return (Size size)=>List.generate(divides - 1, (index)=>size.height * columnAspectRatio * (index + 1));
      }
    } else {
      return (Size size)=>List.generate(divides - 1, (index)=>size.width * (index + 1) / divides);
    }
    return null;
  }
}