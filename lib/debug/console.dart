import 'package:flutter/foundation.dart';

class VConsole with vConsole{
  static vConsole singleton = VConsole();
}

mixin vConsole {
  bool vConsoleFlag = true;
  String _vConsoleLog = '';

  console(Object object){
    if(vConsoleFlag){
      _vConsoleLog += '$object\n';
      if(this is! VConsole){
        VConsole.singleton.console(object);
      }
    }else{
      if (kDebugMode) {
        print(object);
      }
    }
  }

  void consoleClear(){
    _vConsoleLog = '';
  }

  @override
  String toString() {
    if(vConsoleFlag){
      return _vConsoleLog;
    }else {
      return super.toString();
    }
  }
}
