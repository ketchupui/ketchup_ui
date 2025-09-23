import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class DebugUpdate {
  void debugUpdate(VoidCallback callback, [String? debugInfo]);
  void debugLazyUpdate(VoidCallback callback, [String? debugInfo]);
}

mixin DebugUpdater<T extends StatefulWidget> on State<T> implements DebugUpdate{
  String? _debugInfo;
  String get defaultDebuggerName => 'ketchup-ui-state';
  
  P stateDebug<P>(P object){
    if(kDebugMode){
      _debugInfo != null ? print('$defaultDebuggerName($_debugInfo):$object') : print('$defaultDebuggerName:$object');
    }
    return object;
  }

  @override
  void debugUpdate(VoidCallback callback, [String? debugInfo]){ 
    _debugInfo = debugInfo;
    setState(callback);
  }

  @override
  void debugLazyUpdate(VoidCallback callback, [String? debugInfo]){
    /// 安全调用 update 并进行 debug 计数
    WidgetsBinding.instance.addPostFrameCallback((Duration dt){
      debugUpdate(callback, debugInfo);
    });
  }
}