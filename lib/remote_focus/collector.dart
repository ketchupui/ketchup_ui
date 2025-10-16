import 'dart:ui';
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

mixin SingleRemoteChannelRPC on ResponsivePointCollector implements RemoteChannel{

  String get channelName;

  Debouncer get debouncer;

  FocusManager get focusHandler;

  @override
  /// 连接存在 但是不在 build 流程中 callback
  void remoteBroadcastUnknownChannel(RemoteChannelObject data){
    responseCallback(data.object);
  }

  void responseCallback(dynamic name){
    switch(name){
      case 'left':
        focusHandler.focusNextAcrossManager(action: NextFocusAction.left);
        break;
      case 'right':
        focusHandler.focusNextAcrossManager(action: NextFocusAction.right);
        break;
      case 'up':
        focusHandler.focusNextAcrossManager(action: NextFocusAction.up);
        break;
      case 'down':
        focusHandler.focusNextAcrossManager(action: NextFocusAction.down);
        break;
      case 'ok':
      case 'enter':
        if(focusHandler.focusNext(action: NextFocusAction.enter) == null){
          final focusName = focusHandler.currentFocusNode.name;
          if(focusHandler is ResponsivePointCollector){
            ///  需要保证 Collector 和 Focus 记录的 name 值一致
            (focusHandler as ResponsivePointCollector).nameResponse(focusName)?.call();
          }else{
            nameResponse(focusName)?.call();
          }
        }
        break;
      case 'menu':
      case 'config':
        focusHandler.focusNextAcrossManager(positions: [FindFocusPosition.topFather]);
        break;
      case 'back':
        final namedCb = focusHandler is ResponsivePointCollector ? (focusHandler as ResponsivePointCollector).nameResponse(name) : nameResponse(name);
        if(namedCb != null){
          namedCb.call();
        }else{
          focusHandler.focusNextAcrossManager(action: NextFocusAction.back);
        }
        break;
      default:
        nameResponse(name.toString())?.call();
    }
  }
  
  @override
  /// 把交互点包裹起来做一层远程调用
  VoidCallback collectPoint(VoidCallback? callback, {String? name, VoidCallback? after, VoidCallback? before}){
    super.collectPoint(callback, name: name, after: after, before: before);
    if(isRemoteEnabled){
      debouncer.call(
        /// 远程交互
        ()=>remoteChannelSend(channelName, collectResponsivePointNames, (name){
          responseCallback(name);
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