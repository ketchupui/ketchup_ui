import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef VoidRemoteCallback = void Function(dynamic);
typedef CloseRemoteCallback = bool Function(dynamic);

abstract class RemoteChannelObject {
   String get channel;
   dynamic get object;
   Map<String, dynamic> toJson();
}

mixin RemoteChannel {

  WebSocketChannel? get remoteChannel; 
  Map<String, VoidRemoteCallback> channelMap = {};

  bool get isPlayerConnected;
  bool get isChannelConnected;
  bool get isRemoteEnabled => isChannelConnected && isPlayerConnected;

  RemoteChannelObject unpackRCOFromJson(Map<String, dynamic> json);
  
  RemoteChannelObject packRCOIntoJson(String channel, dynamic object,);

  void remoteChannelListen(void Function(String) onInitData,{
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }){
    remoteChannel?.stream.listen((data){
      print('rawData:$data');
      final first = data[0];
      if(first == '{'){
        final rco = unpackRCOFromJson(jsonDecode(data));
        if(channelMap.containsKey(rco.channel)){
          channelMap[rco.channel]!(rco.object);
        }else {
          remoteBroadcastUnknownChannel(rco);
        }
      }else{
        onInitData(data);
      }
    }, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  void remoteBroadcastUnknownChannel(RemoteChannelObject data){
    print('remoteBroadcastUnknownChannel:$data');
  }
  
  void remoteChannelSend(String channel, dynamic object, CloseRemoteCallback callback){
    channelMap[channel] = (data){
      print('onChannelData:$channel:$data');
      if(callback(data)) channelMap.remove(channel);
    };
    remoteChannel?.sink.add(jsonEncode(packRCOIntoJson(channel, object)));
  }

  void remoteChannelClose(String channel){
    channelMap.remove(channel);
    // actor.remoteChannel?.sink.add(jsonEncode(RemoteChannelObject(channel, object: 'channelClose')));
  }
}