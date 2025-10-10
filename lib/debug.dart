import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:ketchup_ui/utils.dart' as utils;
// import 'package:ketchup_ui/ketchup_ui.dart';

abstract class DebugUpdate {
  void debugUpdate(VoidCallback callback, [String? debugInfo]);
  void debugLazyUpdate(VoidCallback callback, [String? debugInfo]);
}

// final ketchupUIStateLabel = 'ketchup-ui-state';

mixin DebugUpdater<T extends StatefulWidget> on State<T> implements DebugUpdate{
  String? _debugInfo;
  // String get defaultDebuggerName => ketchupUIStateLabel;
  
  P stateDebug<P>(P object){
    if(kDebugMode){
      final debugInfo = _debugInfo;
      debugInfo != null ? utils.stateDebug('${T.runtimeType}($debugInfo):$object') : utils.stateDebug('${T.runtimeType}:$object');
    }
    return object;
  }
  
  P measureUpdateDebug<P>(P object){
    if(kDebugMode){
      final debugInfo = _debugInfo;
      debugInfo != null ? utils.measureUpdateDebug('${T.runtimeType}($debugInfo):$object') : utils.measureUpdateDebug('${T.runtimeType}:$object');
    }
    return object;
  }

  P measureDebug<P>(P object){
    if(kDebugMode){
      final debugInfo = _debugInfo;
      debugInfo != null ? utils.measureDebug('${T.runtimeType}($debugInfo):$object') : utils.measureDebug('${T.runtimeType}:$object');
    }
    return object;
  }

  P buildDebug<P>(P object){
    if(kDebugMode){
      final debugInfo = _debugInfo;
      debugInfo != null ? utils.buildDebug('${T.runtimeType}($debugInfo):$object') : utils.buildDebug('${T.runtimeType}:$object');
    }
    return object;
  }

  P updateDebug<P>(P object){
    if(kDebugMode){
      final debugInfo = _debugInfo;
      debugInfo != null ? utils.updateDebug('${T.runtimeType}($debugInfo):$object') : utils.updateDebug('${T.runtimeType}:$object');
    }
    return object;
  }

  P updateBuildDebug<P>(P object){
    if(kDebugMode){
      final debugInfo = _debugInfo;
      debugInfo != null ? utils.updateBuildDebug('${T.runtimeType}($debugInfo):$object') : utils.updateBuildDebug('${T.runtimeType}:$object');
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
    _debugInfo = debugInfo;
    /// 安全调用 update 并进行 debug 计数
    WidgetsBinding.instance.addPostFrameCallback((Duration dt){
      debugUpdate(callback, debugInfo);
    });
  }
}