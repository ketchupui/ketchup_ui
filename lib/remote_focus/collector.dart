import 'dart:ui';
import '../model/accessor.dart';
import 'focus.dart';
import 'debouncer.dart';
import 'remote.dart';

/// 交互打点工具
mixin ResponsivePointCollector {
  final List<VoidCallback> _collectResponsivePointsList = [];
  final Map<String, VoidCallback> _collectResponsivePointsMap = {};

  VoidCallback? nameResponse(String name){
    if(_collectResponsivePointsMap.containsKey(name)) {
      return _collectResponsivePointsMap[name]!;
    } else {
      final index = int.tryParse(name);
      if(index != null && index < _collectResponsivePointsList.length){
        return _collectResponsivePointsList[index];
      }else {
        return null;
      }
    }
  }

  List<String> get collectResponsivePointNames => [ ..._collectResponsivePointsList.map<String>((p)=>''), ..._collectResponsivePointsMap.keys ];
  
  List<VoidCallback> get collectResponsivePoints => _collectResponsivePointsList ..addAll(_collectResponsivePointsMap.values);

  String? _tempName;
  VoidCallback? collectPoint(VoidCallback? callback, {String? name, VoidCallback? after, VoidCallback? before}){
    before?.call();
    if(callback != null){
      _tempName = name;
      if(name != null) {
        _collectResponsivePointsMap.putIfAbsent(name, ()=>callback);
      } else {
        _collectResponsivePointsList.add(callback);
      }
    }
    after?.call();
    return callback;
  }
  /// 給打点命名
  int get pointIndex => _collectResponsivePointsList.length;

  String pointWrappedText(String text, {bool enabled = true}){
    if(enabled){
      if(_tempName != null) {
        final ret = '【$_tempName】$text';
        _tempName = null;
        return ret;
      } 
      return '【选项$pointIndex】$text';
    }
    return text;
  }

  void collectClear(){
    _collectResponsivePointsList.clear();
    _collectResponsivePointsMap.clear();
  }
}

mixin SingleRemoteChannelRPC on ResponsivePointCollector implements RemoteChannel, ContextAccessorUpdate{

  String get channelName;

  Debouncer get debouncer;

  FocusManager get focusHandler;

  @override
  /// 把交互点包裹起来做一层远程调用
  VoidCallback collectPoint(VoidCallback? callback, {String? name, VoidCallback? after, VoidCallback? before}){
    super.collectPoint(callback, name: name, after: after, before: before);
    if(isRemoteEnabled){
      debouncer.call(
        /// 远程交互
        ()=>remoteChannelSend(channelName, collectResponsivePointNames, (name){
          switch(name){
            case 'left':
              if(focusHandler.leftFocusNode != null) focusHandler.focusLeft();
              update((){});
              break;
            case 'right':
              if(focusHandler.rightFocusNode != null) focusHandler.focusRight();
              update((){});
              break;
            case 'up':
              if(focusHandler.upFocusNode != null) focusHandler.focusUp();
              update((){});
              break;
            case 'down':
              if(focusHandler.downFocusNode != null) focusHandler.focusDown();
              update((){});
              break;
            case 'ok':
              final focusName = focusHandler.currentFocusNode.name;
              nameResponse(focusName)?.call();
              break;
            case 'menu':
            case 'config':
            case 'back':
            default:
              nameResponse(name.toString())?.call();
          }
          return true;
        }));
    }
    return (){
      callback?.call();
      if(isRemoteEnabled) {
        remoteChannelClose(channelName);
      }
    };
  }

  // @override
  // int? get pointIndex => collectResponsivePoints.length;
  
}