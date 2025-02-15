// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'state.dart';

enum CATEGORY { tv_gamepad, pc_mousekeyboard, mobile_gesture, all }

typedef GKeyValueRecord = (GlobalKey, Size?, Offset?);
typedef RCPair = ({int row, int column});

class KetchupModel extends ChangeNotifier{
  static const String PT_FULLSCREEN = 'fullscreen';
  static const Null PT_SINGLEALL = null;

  static const String PT_12 = '(1-2)';
  static const String PT_123 = '(1-2-3)';
  static const String PT_1234 = '(1-2-3-4)';
  static const String PT_23 = '(2-3)';
  static const String PT_234 = '(2-3-4)';
  static const String PT_2345 = '(2-3-4-5)';
  static const String PT_34 = '(3-4)';
  static const String PT_345 = '(3-4-5)';
  static const String PT_45 = '(4-5)';

  static const String PT_1 = '1';
  static const String PT_2 = '2';
  static const String PT_3 = '3';
  static const String PT_4 = '4';
  static const String PT_5 = '5';


  /// 五联屏语境
  static const String PT_12_3_4_5 ='$PT_12,$PT_3,$PT_4,$PT_5';
  static const String PT_1_23_4_5 ='$PT_1,$PT_23,$PT_4,$PT_5';
  static const String PT_1_2_34_5 ='$PT_1,$PT_2,$PT_34,$PT_5';
  static const String PT_12_34_5 ='$PT_12,$PT_34,$PT_5';
  static const String PT_1_2_3_45 ='$PT_1,$PT_2,$PT_3,$PT_45';
  static const String PT_12_3_45 ='$PT_12,$PT_3,$PT_45';
  static const String PT_1_23_45 ='$PT_1,$PT_23,$PT_45';

  static const String PT_123_4_5 ='$PT_123,$PT_4,$PT_5';
  static const String PT_123_45 ='$PT_123,$PT_45';
  static const String PT_1_234_5 ='$PT_1,$PT_234,$PT_5';
  static const String PT_1_2_345 ='$PT_1,$PT_2,$PT_345';
  static const String PT_12_345 ='$PT_12,$PT_345';
  
  static const String PT_1234_5 ='$PT_1234,$PT_5';
  static const String PT_1_2345 ='$PT_1,$PT_2345';
  
  /// 四联屏语境
  static const String PT_12_3_4 ='$PT_12,$PT_3,$PT_4';
  static const String PT_1_23_4 ='$PT_1,$PT_23,$PT_4';
  static const String PT_1_2_34 ='$PT_1,$PT_2,$PT_34';
  static const String PT_12_34 ='$PT_12,$PT_34';
  static const String PT_123_4 ='$PT_123,$PT_4';
  static const String PT_1_234 ='$PT_1,$PT_234';

  /// 三联屏语境
  static const String PT_12_3 ='$PT_12,$PT_3';
  static const String PT_1_23 ='$PT_1,$PT_23';
  
  KetchupModel({RUNMODE mode = RUNMODE.debug, Size? singleAspectRatioSize, required RCPair rowColumn }): 
  _mode = mode, _singleAspectRatioSize = singleAspectRatioSize, _rowColumn = rowColumn {
    /// 同时计算 fullscreenAspectRatioSize
    rowColumn = _rowColumn;
  }

  factory KetchupModel.fromRVG(ResponsiveValueGroup rvg) => KetchupModel( rowColumn: rvg.rowColumn , singleAspectRatioSize: rvg.singleAspectRatio );

  RUNMODE _mode;
  Size? _singleAspectRatioSize;
  Size? _fullscreenAspectRatioSize;
  RCPair _rowColumn;
  
  /// 初始化 Key
  Map<String, GlobalKey> gKeys = {};
  /// 跟测量相关
  Map<String, GKeyValueRecord> gKeyMappedValues = {};
  

  int get row => _rowColumn.row;
  int get column => _rowColumn.column;
  
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

  RCPair get rowColumn => _rowColumn;
  
  /// 更改模式不引起重新布局
  set mode(RUNMODE mode){
    _mode = mode;
    notifyListeners();
  }

  /// 更改屏幕比例导致
  /// 重新测量 gKeyMappedValues.clear();
  set singleAspectRatioSize(Size? size){
    _singleAspectRatioSize = size;
    _fullscreenAspectRatioSize = size != null ? Size(size.width * column, size.height * row) : null;
    gKeyMappedValues.clear();
    resetPattern();
  }

  Size? get fullscreenAspectRatioSize => _fullscreenAspectRatioSize;

  bool get isNeedMeasure => gKeyMappedValues.isEmpty; 

  Size? get singleAspectRatioSize => _singleAspectRatioSize; 

  RUNMODE get mode => _mode;
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

  set currentPattern(String? current){
    _lastPattern = _currentPattern;
    _currentPattern = current;
    if(_currentPattern != _lastPattern){
      gKeyMappedValues.clear();
    }
  } 

  void resetPattern(){
    _currentPattern = null;
    _lastPattern = null;
  }
  
  String? get currentPattern => _currentPattern;
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
        PT_SINGLEALL: PT_12_3_4_5, PT_12_3_4_5: PT_SINGLEALL, 
        PT_1_23_4_5: PT_123_4_5, PT_123_4_5: PT_1_23_4_5, 
        PT_1_2_34_5: PT_12_34_5, PT_12_34_5: PT_1_2_34_5,
        PT_1_2_3_45: PT_12_3_45, PT_12_3_45: PT_1_2_3_45,
        PT_1_234_5: PT_1234_5,PT_1234_5: PT_1_234_5,
        PT_1_23_45: PT_123_45, PT_123_45: PT_1_23_45,
        PT_1_2_345: PT_12_345, PT_12_345: PT_1_2_345,
        PT_1_2345: PT_FULLSCREEN, PT_FULLSCREEN: PT_1_2345
      },
      PT_23:{
        PT_SINGLEALL: PT_1_23_4_5, PT_1_23_4_5: PT_SINGLEALL, 
        PT_12_3_4_5: PT_123_4_5, PT_123_4_5: PT_12_3_4_5,
        PT_12_34_5: PT_1234_5, PT_1234_5: PT_12_34_5,
        PT_12_345: PT_FULLSCREEN, PT_FULLSCREEN: PT_12_345,
        PT_12_3_45: PT_123_45,PT_123_45: PT_12_3_45,
        PT_1_2_34_5: PT_1_234_5,PT_1_234_5: PT_1_2_34_5,
        PT_1_2_3_45: PT_1_23_45, PT_1_23_45: PT_1_2_3_45,
        PT_1_2_345: PT_1_2345, PT_1_2345: PT_1_2_345
      },
      PT_34:{
        PT_SINGLEALL: PT_1_2_34_5, PT_1_2_34_5: PT_SINGLEALL,
        PT_12_3_4_5: PT_12_34_5, PT_12_34_5: PT_12_3_4_5,        
        PT_123_4_5: PT_1234_5, PT_1234_5: PT_123_4_5,
        PT_123_45: PT_FULLSCREEN, PT_FULLSCREEN: PT_123_45,
        PT_12_3_45: PT_12_345, PT_12_345: PT_12_3_45,
        PT_1_23_4_5: PT_1_234_5, PT_1_234_5: PT_1_23_4_5,
        PT_1_23_45: PT_1_2345,PT_1_2345: PT_1_23_45,
        PT_1_2_3_45: PT_1_2_345, PT_1_2_345: PT_1_2_3_45,
      },
      PT_45:{
        PT_SINGLEALL: PT_1_2_3_45, PT_1_2_3_45: PT_SINGLEALL,
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
        PT_12_3_4: PT_SINGLEALL, PT_SINGLEALL: PT_12_3_4, 
        PT_1_23_4: PT_123_4, PT_123_4: PT_1_23_4,
        PT_1_2_34: PT_12_34, PT_12_34: PT_1_2_34,
        PT_1_234: PT_FULLSCREEN, PT_FULLSCREEN: PT_1_234,
      },
      PT_23:{
        PT_1_23_4: PT_SINGLEALL, PT_SINGLEALL: PT_1_23_4,
        PT_12_3_4: PT_123_4, PT_123_4: PT_12_3_4,
        PT_12_34: PT_FULLSCREEN, PT_FULLSCREEN: PT_12_34,
        PT_1_2_34: PT_1_234, PT_1_234: PT_1_2_34
      },
      PT_34:{
        PT_1_2_34: PT_SINGLEALL, PT_SINGLEALL: PT_1_2_34,
        PT_12_3_4: PT_12_34,PT_12_34: PT_12_3_4,
        PT_1_23_4: PT_1_234,PT_1_234: PT_1_23_4,
        PT_123_4: PT_FULLSCREEN, PT_FULLSCREEN: PT_123_4
      }
    },
    3:{
      PT_12:{
        PT_12_3: PT_SINGLEALL, PT_SINGLEALL:PT_12_3,
        PT_1_23: PT_FULLSCREEN, PT_FULLSCREEN: PT_1_23,
      },
      PT_23:{
        PT_1_23: PT_SINGLEALL, PT_SINGLEALL: PT_1_23,
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
}