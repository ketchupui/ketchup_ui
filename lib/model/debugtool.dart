import 'package:flutter/widgets.dart';
import 'package:ketchup_ui/model/context.dart';

enum RUNMODE { runtime, edit, debug }
typedef GKeyValueRecord = (GlobalKey, Rect?);

class DebugToolContext extends BaseContext {
  
  /// 运行模式
  RUNMODE mode;
  /// 初始化 Key
  Map<String, GlobalKey> gKeys = {};
  /// 跟测量相关
  Map<String, GKeyValueRecord> gKeyMappedValues = {};

  DebugToolContext({required this.mode});
  
  bool get isNeedMeasure => gKeyMappedValues.isEmpty;
  bool get measured => gKeyMappedValues.isNotEmpty;

  // final List<VoidCallback> _measuredCbs = [];
  // void produceMeasuredCb(VoidCallback measuredCb){
  //   _measuredCbs.add(measuredCb);
  // }
  // VoidCallback? get consumeMeasuredCb => _measuredCbs.isEmpty ? null : (){
  //   while(_measuredCbs.isNotEmpty){
  //     _measuredCbs.removeLast()();
  //   }
  // };
}