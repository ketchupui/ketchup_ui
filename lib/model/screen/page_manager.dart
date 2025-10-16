
import 'dart:developer';

import 'package:ketchup_ui/model/debugtool.dart';
import 'package:ketchup_ui/model/screen/screen.dart';

mixin FocusPageManager on BaseScreenContext{
  /// 2025.8.31 新增 _currentFocus 仅在竖屏模式下使用表示展示当前单个屏幕语境(始终单栏)
  int _currentFocusIndex = -1;
  @override
  List<String> get singles;
  @override
  FocusPageMode get focusPageMode;
  @override
  set focusPageMode(FocusPageMode mode);

  String focusPageSingleRL([int? index]){
    focusPageMode = FocusPageMode.singleRL;
    final tempIndex = index ?? _currentFocusIndex;
    _currentFocusIndex = tempIndex >= 0 && tempIndex <= singles.length - 1 ? tempIndex : singles.length - 1;
    // gKeyMappedValues.clear();
    return focusPageCurrentPT!;
  }

  String focusPageSingleLR([int? index]){
    focusPageMode = FocusPageMode.singleLR;
    final tempIndex = index ?? _currentFocusIndex;
    _currentFocusIndex = tempIndex >= 0 && tempIndex <= singles.length - 1 ? tempIndex : 0;
    // gKeyMappedValues.clear();
    return focusPageCurrentPT!;
  }

  String? focusPageNext(){
    _currentFocusIndex = focusPageNextIndex;
    return focusPageCurrentPT;
  }

  String? focusPagePrev(){
    _currentFocusIndex = focusPagePrevIndex;
    return focusPageCurrentPT;
  }

  void focusPageMultiLR(){
    focusPageMode = FocusPageMode.multiLR;
    // gKeyMappedValues.clear();
  }
  
  String? get focusPageCurrentPT => focusPageMode != FocusPageMode.multiLR && _currentFocusIndex >=0 && _currentFocusIndex < singles.length ? singles[_currentFocusIndex] : null;
  int get focusPageNextIndex => switch(focusPageMode){
    FocusPageMode.singleRL => _currentFocusIndex - 1  >= 0 && _currentFocusIndex < singles.length ? _currentFocusIndex - 1 : -1,
    FocusPageMode.singleLR => _currentFocusIndex + 1 < singles.length ? _currentFocusIndex + 1 : -1,
    // FocusPageMode.multiLR => _currentFocusIndex + 1 < singles.length ? _currentFocusIndex + 1 : -1,
    FocusPageMode.multiLR => -1,
  };
  String? get focusPageNextPT => switch(focusPageMode){
    FocusPageMode.singleRL => _currentFocusIndex - 1  >= 0 && _currentFocusIndex < singles.length ? singles[_currentFocusIndex - 1] : null,
    FocusPageMode.singleLR => _currentFocusIndex + 1 < singles.length ? singles[_currentFocusIndex + 1] : null,
    // FocusPageMode.multiLR => _currentFocusIndex + 1 < singles.length ? singles[_currentFocusIndex + 1] : null,
    FocusPageMode.multiLR => null,
  };
  int get focusPagePrevIndex => switch(focusPageMode){
    FocusPageMode.singleRL => _currentFocusIndex + 1 < singles.length ? _currentFocusIndex + 1 : -1,
    FocusPageMode.singleLR => _currentFocusIndex - 1  >= 0 && _currentFocusIndex < singles.length ? _currentFocusIndex - 1 : -1,
    // FocusPageMode.multiLR => _currentFocusIndex - 1  >= 0 && _currentFocusIndex < singles.length ? _currentFocusIndex - 1 : -1,
    FocusPageMode.multiLR => -1,
  };
  String? get focusPagePrevPT => switch(focusPageMode){
    FocusPageMode.singleRL => _currentFocusIndex + 1 < singles.length ? singles[_currentFocusIndex + 1] : null,
    FocusPageMode.singleLR => _currentFocusIndex - 1  >= 0 && _currentFocusIndex < singles.length ? singles[_currentFocusIndex - 1] : null,
    // FocusPageMode.multiLR => _currentFocusIndex - 1  >= 0 && _currentFocusIndex < singles.length ? singles[_currentFocusIndex - 1] : null,
    FocusPageMode.multiLR => null,
  };

}

mixin VScreenFocusPageManager on FocusPageManager{

  @override
  set mode(RUNMODE runmode){
    super.mode = runmode;
    currentPatternVirtualMap?.values.forEach((vscreen)=>vscreen.mode = runmode);
  }
  Map<String, VScreenFocusPageManager>? _currentPatternVirtualMap;
  
  Map<String, VScreenFocusPageManager>? get currentPatternVirtualMap => _currentPatternVirtualMap;
  set currentPatternVirtualMap(Map<String, VScreenFocusPageManager>? map){
    // if(map?.isEmpty ?? true){
    //   debugger();
    // }
    _currentPatternVirtualMap = map;
  }
  
  VScreenFocusPageManager? findVirtualScreen(String singlePT){
    return currentPatternVirtualMap?[singlePT];
  }

  List<int> vscreenFocusPageSingleRL(){
    focusPageMode = FocusPageMode.singleRL;
    _currentFocusIndex = _currentFocusIndex >= 0 && _currentFocusIndex <= singles.length - 1 ? _currentFocusIndex : singles.length - 1;
    currentPatternVirtualMap?.values.forEach((vscreen)=>vscreen.vscreenFocusPageSingleRL());
    return vscreenFocusCurrentIndexList;
  }

  List<int> vscreenFocusPageSingleLR(){
    focusPageMode = FocusPageMode.singleLR;
    _currentFocusIndex = _currentFocusIndex >= 0 && _currentFocusIndex <= singles.length - 1 ? _currentFocusIndex : 0;
    currentPatternVirtualMap?.values.forEach((vscreen)=>vscreen.vscreenFocusPageSingleLR());
    return vscreenFocusCurrentIndexList;
  }

  List<String> _vscreenFocusPageRecursive(List<int> recursiveIndexes){
    _currentFocusIndex = recursiveIndexes.first;
    if(focusPageCurrentPT != null){
      final vscreen = findVirtualScreen(focusPageCurrentPT!);
      final secondMore = recursiveIndexes.sublist(1);
      if(vscreen != null && secondMore.isNotEmpty){
        return [focusPageCurrentPT!, ... vscreen._vscreenFocusPageRecursive(secondMore)];
      }
      return [focusPageCurrentPT!];
    }
    return [];
  }

  List<String> vscreenFocusPageCurrent() => _vscreenFocusPageRecursive(vscreenFocusCurrentIndexList);

  List<String> vscreenFocusPageNext(){
    final next = vscreenFocusNextIndexList;
    if(next.isEmpty) return [];
    return _vscreenFocusPageRecursive(next);
  }

  List<String> vscreenFocusPagePrev(){
    final prev = vscreenFocusPrevIndexList;
    if(prev.isEmpty) return [];
    return _vscreenFocusPageRecursive(prev);
  }

  void vscreenFocusPageMultiLR(){
    vscreenFocusPageModeRecursive(FocusPageMode.multiLR);
  }
  
  void vscreenFocusPageModeRecursive(FocusPageMode mode){
    focusPageMode = mode;
    currentPatternVirtualMap?.values.forEach((vscreen)=>vscreen.vscreenFocusPageModeRecursive(mode));
  }
  
  /// 参考 https://immvpc32u2.feishu.cn/docx/Bq2adq4zPo8fUSxqzzRckqb4nUP#share-MNrNdETyrokPo1xzW2lczDt8nUg
  List<int> get vscreenFocusPrevIndexList {
    final current = focusPageCurrentPT;
    if(current != null){
      final currentVScreen = findVirtualScreen(current);
      if(currentVScreen != null){
        final currentSinglePrevNode = currentVScreen.vscreenFocusPrevIndexList;
        if(currentSinglePrevNode.isNotEmpty){
          /// 1.如果翻页成功，则返回 [ 当前指针, ... 翻页递归指针数组 ]
          return [ _currentFocusIndex, ...currentSinglePrevNode ];
        }
      }
    }
    /// 2. 如果翻页失败，执行 3.叶子节点 操作
    /// 如果是 叶子节点，3. 检查翻页边界
    final prev = focusPagePrevPT;
    if(prev != null){
      final prevVScreen = findVirtualScreen(prev);
      if(prevVScreen != null){
        final currentSingleNode = prevVScreen.vscreenFocusCurrentIndexList;
        if(currentSingleNode.isNotEmpty){
          /// 4. 如果是树枝节点，基于当前节点递归向下执行当前页初始化(RL/LR),返回 [ 翻页指针, ...初始化递归指针数组 ]
          return [ focusPagePrevIndex, ...currentSingleNode ];
        }
      }
      /// 5. 如果是叶子节点，返回 [ 翻页指针 ]
      return [ focusPagePrevIndex ];
    }
    /// 6. 如果为空表示超越边界，返回 [ 空数组 ]
    return [];
  }

  List<int> get vscreenFocusNextIndexList {
    final current = focusPageCurrentPT;
    if(current != null){
      final currentVScreen = findVirtualScreen(current);
      if(currentVScreen != null){
        final currentSingleNextPT = currentVScreen.vscreenFocusNextIndexList;
        if(currentSingleNextPT.isNotEmpty){
          /// 1.如果翻页成功，则返回 [ 当前指针, ... 翻页递归指针数组 ]
          return [ _currentFocusIndex, ...currentSingleNextPT ];
        }
      }
    }
    /// 2. 如果翻页失败，执行 3.叶子节点 操作
    /// 如果是 叶子节点，3. 检查翻页边界
    final next = focusPageNextPT;
    if(next != null){
      final nextVScreen = findVirtualScreen(next);
      if(nextVScreen != null){
        final currentSingleNode = nextVScreen.vscreenFocusCurrentIndexList;
        if(currentSingleNode.isNotEmpty){
          /// 4. 如果是树枝节点，基于当前节点递归向下执行当前页初始化(RL/LR),返回 [ 翻页指针, ...初始化递归指针数组 ]
          return [ focusPageNextIndex, ...currentSingleNode ];
        }
      }
      /// 5. 如果是叶子节点，返回 [ 翻页指针 ]
      return [ focusPageNextIndex ];
    }
    /// 6. 如果为空表示超越边界，返回 [ 空数组 ]
    return [];
  }

  List<int> get vscreenFocusCurrentIndexList {
    final current = focusPageCurrentPT;
    if(current != null){
      final currentVScreen = findVirtualScreen(current);
      if(currentVScreen != null){
        final currentSingleNode = currentVScreen.vscreenFocusCurrentIndexList;
        /// 孩子节点有下一页
        if(currentSingleNode.isNotEmpty){
          return [ _currentFocusIndex, ...currentSingleNode ];
        }
      }
      return [ _currentFocusIndex ];
    }
    return [];
  }
}
