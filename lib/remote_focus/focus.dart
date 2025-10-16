// ignore_for_file: non_constant_identifier_names
// import 'dart:developer';
// import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:ketchup_ui/ketchup_ui.dart';
// import 'package:ketchup_ui/logger.dart';
// import 'package:ketchup_ui/mixin/listeners.dart';

enum NextFocusAction {
  left, right, up, down, enter, back,
}

enum FindFocusPosition {
  father, topFather, children, focusedChild, brothers, prevLeft, nextRight
}

abstract class FocusEventListener {
  void onBlur(FocusNode target);
  void onFocus(FocusNode target);
}

class FocusNode extends ChangeNotifier implements FocusEventListener{
  final String name;
  FocusNode? father;
  FocusNode? left;
  FocusNode? right;
  FocusNode? up;
  FocusNode? down;
  FocusNode? enter;
  bool isFocused = false;
  FocusNode({required this.name, this.father});

  @override
  void onFocus(FocusNode target){
    focusDebug('$runtimeType#$hashCode-onFocus(${target.name})');
    notifyListeners();
  }

  @override
  void onBlur(FocusNode target){
    focusDebug('$runtimeType#$hashCode-onBlur(${target.name})');
    notifyListeners();
  }

  void focus(){
    isFocused = true;
    onFocus(this);
  }

  void blur(){
    isFocused = false;
    onBlur(this);
  }

  void reset(){
    left = null;
    right = null;
    up = null;
    down = null;
    enter = null;
  }
}

mixin FocusManager implements FocusEventListener{
  static FocusManager? activeManager;
  void Function(VoidCallback, [String? d]) get focusUpdate;
  final FocusNode DEFAULT_FOCUS_NODE = FocusNode(name: 'default');
  final Map<String, FocusNode> focusNodeReuseCacheMap = {};
  FocusNode? __buildingFocusNode;
  FocusNode get _buildingFocusNode => __buildingFocusNode ?? DEFAULT_FOCUS_NODE;
  FocusNode? _currentFocusNode;
  FocusNode get currentFocusNode => _currentFocusNode ?? DEFAULT_FOCUS_NODE;

  FocusNode? get enterFocusNode => currentFocusNode.enter;
  FocusNode? get leftFocusNode => currentFocusNode.left;
  FocusNode? get rightFocusNode => currentFocusNode.right;
  FocusNode? get upFocusNode => currentFocusNode.up;
  FocusNode? get downFocusNode => currentFocusNode.down;
  FocusNode? get backFocusNode => currentFocusNode.father;

  @override
  void onBlur(FocusNode target){
    focusDebug('$runtimeType#$hashCode-onBlur(${target.name}#${target.hashCode})');
  }
  
  @override
  void onFocus(FocusNode target){
    focusDebug('$runtimeType#$hashCode-onFocus(${target.name}#${target.hashCode})');
  }

  FocusNode focusDefault({bool update = true}){
    _currentFocusNode = null;
    currentFocusNode.focus();
    if(this != activeManager){
      onFocus(currentFocusNode);
    }
    if(update) focusUpdate((){});
    return currentFocusNode;
  }

  // FocusNode focusTopFatherManager({bool update = true}){
  //   final topFatherManager = findFocusManager(FindFocusPosition.topFather)!.first;
  //   currentFocusNode.blur();
  //   if(topFatherManager != this){
  //     onBlur(currentFocusNode);
  //   }
  //   if(update) focusUpdate((){});
  //   final newFocusNode = topFatherManager.focusDefault(update: update);
  //   activeManager = topFatherManager;
  //   return newFocusNode;
  // }

  // FocusNode? focusEnter({bool update = true}){
  //   if(enterFocusNode != null){
  //     currentFocusNode.blur();
  //     enterFocusNode!.focus();
  //     if(update) focusUpdate((){});
  //     return _currentFocusNode = enterFocusNode;
  //   }
  //   return null;
  // }
  
  // FocusNode? focusEnterAcrossManager({bool update = true}){
  //   final enter = focusEnter(update: false);
  //   if(enter == null){
  //     final enterChildrenManager = findFocusManager(FindFocusPosition.children)?.firstOrNull;
  //     if(enterChildrenManager != null){
  //       currentFocusNode.blur();
  //       if(update) focusUpdate((){});
  //       return (activeManager = enterChildrenManager).focusDefault(update: update);
  //     }
  //   }
  //   if(update) focusUpdate((){});
  //   return enter;
  // }

  // FocusNode? focusLeft({bool update = true}){
  //   if(leftFocusNode != null){
  //     currentFocusNode.blur();
  //     leftFocusNode!.focus();
  //   }
  //   if(update) focusUpdate((){});
  //   return _currentFocusNode = leftFocusNode;
  // }

  FocusNode? nextFocusNode(NextFocusAction action){
    return switch(action){
      NextFocusAction.down => downFocusNode,
      NextFocusAction.up => upFocusNode,
      NextFocusAction.left => leftFocusNode,
      NextFocusAction.right => rightFocusNode,
      NextFocusAction.enter => enterFocusNode,
      NextFocusAction.back => backFocusNode,
    };
  }

  FocusNode? focusNext({required NextFocusAction action, bool update = true}){
    final nextNode = nextFocusNode(action);
    if(nextNode != null){
      currentFocusNode.blur();
      nextNode.focus();
      if(update) focusUpdate((){});
      return _currentFocusNode = nextNode;
    }
    return null;
  }

  FocusNode? focusNextAcrossManager({NextFocusAction? action, List<FindFocusPosition>? positions, bool update = true}){
    assert(action != null || positions != null);
    final next = action != null ? focusNext(action: action, update: false) : null;
    if(next == null){
      final nextManager = switch(action){
        NextFocusAction.left => findFocusManager(FindFocusPosition.prevLeft)?.firstOrNull,
        NextFocusAction.right => findFocusManager(FindFocusPosition.nextRight)?.firstOrNull,
        NextFocusAction.up => findFocusManager(FindFocusPosition.father)?.firstOrNull,
        NextFocusAction.down => (findFocusManager(FindFocusPosition.focusedChild) ?? findFocusManager(FindFocusPosition.children))?.firstOrNull,
        NextFocusAction.back => findFocusManager(FindFocusPosition.father)?.firstOrNull,
        NextFocusAction.enter => null,
        _ => null
      } ?? (positions != null ? findFocusManagerByOrder(positions)?.firstOrNull : null);
      if(nextManager != null){
        currentFocusNode.blur();
        if(nextManager != this){
          onBlur(currentFocusNode);
        }
        if(update) focusUpdate((){});
        final newFocusNode = nextManager.focusDefault(update: update);
        activeManager = nextManager;
        return newFocusNode;
      }
    }
    if(update) focusUpdate((){});
    return next;
  }

  // FocusNode? focusLeftAcrossManager({bool update = true}){
  //   final left = focusLeft(update: false);
  //   if(left == null){
  //     final prevLeftManager = findFocusManager(FindFocusPosition.prevLeft)?.firstOrNull;
  //     if(prevLeftManager != null){
  //       currentFocusNode.blur();
  //       if(prevLeftManager != this){
  //         onBlur(currentFocusNode);
  //       }
  //       if(update) focusUpdate((){});
  //       final newFocusNode = prevLeftManager.focusDefault(update: update);
  //       activeManager = prevLeftManager;
  //       return newFocusNode;
  //     }
  //   }
  //   if(update) focusUpdate((){});
  //   return left;
  // }

  // FocusNode? focusRight({bool update = true}){
  //   if(rightFocusNode != null){
  //     currentFocusNode.blur();
  //     rightFocusNode!.focus();
  //   }
  //   if(update) focusUpdate((){});
  //   return _currentFocusNode = rightFocusNode;
  // }

  // FocusNode? focusRightAcrossManager({bool update = true}){
  //   final right = focusRight(update: false);
  //   if(right == null){
  //     final nextRightManager = findFocusManager(FindFocusPosition.nextRight)?.firstOrNull;
  //     if(nextRightManager != null){
  //       currentFocusNode.blur();
  //       if(nextRightManager != this){
  //         onBlur(currentFocusNode);
  //       }
  //       if(update) focusUpdate((){});
  //       final newFocusNode = nextRightManager.focusDefault(update: update);
  //       activeManager = nextRightManager;
  //       return newFocusNode;
  //     }
  //   }
  //   if(update) focusUpdate((){});
  //   return right;
  // }
  
  // FocusNode? focusUp({bool update = true}){
  //   if(upFocusNode != null){
  //     currentFocusNode.blur();
  //     upFocusNode!.focus();
  //   }
  //   if(update) focusUpdate((){});
  //   return _currentFocusNode = upFocusNode;
  // }

  // FocusNode? focusUpAcrossManager({bool update = true}){
  //   final up = focusUp(update: false);
  //   if(up == null){
  //     final upFatherManager = findFocusManager(FindFocusPosition.father)?.firstOrNull;
  //     if(upFatherManager != null){
  //       currentFocusNode.blur();
  //       if(upFatherManager != this){
  //         onBlur(currentFocusNode);
  //       }
  //       if(update) focusUpdate((){});
  //       final newFocusNode = upFatherManager.focusDefault(update: update);
  //       activeManager = upFatherManager;
  //       return newFocusNode;
  //     }
  //   }
  //   if(update) focusUpdate((){});
  //   return up;
  // }
  
  // FocusNode? focusDown({bool update = true}){
  //   if(downFocusNode != null){
  //     currentFocusNode.blur();
  //     downFocusNode!.focus();
  //   }
  //   if(update) focusUpdate((){});
  //   return _currentFocusNode = downFocusNode;
  // }

  // FocusNode? focusDownAcrossManager({bool update = true}){
  //   final down = focusDown(update: false);
  //   if(down == null){
  //     final downChildrenManager = (findFocusManager(FindFocusPosition.focusedChild) ?? findFocusManager(FindFocusPosition.children))?.firstOrNull;
  //     if(downChildrenManager != null){
  //       currentFocusNode.blur();
  //       if(downChildrenManager != this){
  //         onBlur(currentFocusNode);
  //       }
  //       if(update) focusUpdate((){});
  //       final newFocusNode = downChildrenManager.focusDefault(update: update);
  //       activeManager = downChildrenManager;
  //       return newFocusNode;
  //     }
  //   }
  //   if(update) focusUpdate((){});
  //   return down;
  // }
  
  // FocusNode? focusBack({bool update = true}){
  //   if(backFocusNode != null){
  //     currentFocusNode.blur();
  //     backFocusNode!.focus();
  //   }
  //   if(update) focusUpdate((){});
  //   return _currentFocusNode = backFocusNode;
  // }

  // FocusNode? focusBackAcrossManager({bool update = true}){
  //   final back = focusBack(update: false);
  //   if(back == null){
  //     final fatherFocusManager = findFocusManager(FindFocusPosition.father)?.firstOrNull;
  //     if(fatherFocusManager != null){
  //       currentFocusNode.blur();
  //       if(fatherFocusManager != this){
  //         onBlur(currentFocusNode);
  //       }
  //       if(update) focusUpdate((){});
  //       final newFocusNode = fatherFocusManager.focusDefault(update: update);
  //       activeManager = fatherFocusManager;
  //       return newFocusNode;
  //     }
  //   }
  //   if(update) focusUpdate((){});
  //   return back;
  // }
  
  bool isFocused([String? name]) => name != null && currentFocusNode.name == name && currentFocusNode.isFocused || (name == null && DEFAULT_FOCUS_NODE.isFocused);

  FocusNode buildingEnd2ndStepSetDefaultFocusNode(NextFocusAction? action, {void Function(FocusNode building, FocusNode dflt)? override}){
    switch(action){
      case NextFocusAction.right:
        _buildingFocusNode.right = DEFAULT_FOCUS_NODE;
        DEFAULT_FOCUS_NODE.left = _buildingFocusNode;
        break;
      case NextFocusAction.left:
        _buildingFocusNode.left = DEFAULT_FOCUS_NODE;
        DEFAULT_FOCUS_NODE.right = _buildingFocusNode;
        break;
      case NextFocusAction.down:
        _buildingFocusNode.down = DEFAULT_FOCUS_NODE;
        DEFAULT_FOCUS_NODE.up = _buildingFocusNode;
        break;
      case NextFocusAction.up:
        _buildingFocusNode.up = DEFAULT_FOCUS_NODE;
        DEFAULT_FOCUS_NODE.down = _buildingFocusNode;
        break;
      case NextFocusAction.enter:
        _buildingFocusNode.enter = DEFAULT_FOCUS_NODE;
        DEFAULT_FOCUS_NODE.father = _buildingFocusNode;
        break;
      case NextFocusAction.back:
        _buildingFocusNode.father = DEFAULT_FOCUS_NODE;
        DEFAULT_FOCUS_NODE.enter = _buildingFocusNode;
        break;
      case null:
    }
    override?.call(_buildingFocusNode, DEFAULT_FOCUS_NODE);
    __buildingFocusNode = null;
    return _buildingFocusNode;
  }

  FocusNode? __buildingHasFocusNode;
  /// 构建过程中原本聚焦的点位没有在build中调用时启动新点位(最后在build阶段创建的点位继承该焦点)
  void buildingEnd1stStepTestNeedResetFocus([FocusNode? buildingEndFocusNode]){
    /// 避免因为 build 导致焦点丢失
    if(__buildingHasFocusNode == null && currentFocusNode.isFocused && currentFocusNode != DEFAULT_FOCUS_NODE){
      // debugger();
      currentFocusNode.blur();
      (_currentFocusNode = buildingEndFocusNode ?? _buildingFocusNode).focus();
      WidgetsBinding.instance.addPostFrameCallback((_){
        focusUpdate((){});
      });
    }
    __buildingHasFocusNode = null;
  }

  FocusNode buildingUpdateAddFocusNode(NextFocusAction action, String focusName, {FocusNode? father, void Function(FocusNode building, FocusNode update)? override}){
    /// 聚焦节点重用问题
    final updateAddNode = (focusNodeReuseCacheMap[focusName] ?? FocusNode(name: focusName, father: father))..reset();
    /// 用于焦点重置
    if(updateAddNode.isFocused){
      __buildingHasFocusNode = updateAddNode;
    }
    switch(action){
      case NextFocusAction.right:
        _buildingFocusNode.right = updateAddNode;
        updateAddNode.left = _buildingFocusNode;
        break;
      case NextFocusAction.left:
        _buildingFocusNode.left = updateAddNode;
        updateAddNode.right = _buildingFocusNode;
        break;
      case NextFocusAction.down:
        _buildingFocusNode.down = updateAddNode;
        updateAddNode.up = _buildingFocusNode;
        break;
      case NextFocusAction.up:
        _buildingFocusNode.up = updateAddNode;
        updateAddNode.down = _buildingFocusNode;
        break;
      case NextFocusAction.enter:
        _buildingFocusNode.enter = updateAddNode;
        updateAddNode.father = _buildingFocusNode;
        break;
      case NextFocusAction.back:
        _buildingFocusNode.father = updateAddNode;
        updateAddNode.enter = _buildingFocusNode;
    }
    override?.call(_buildingFocusNode, updateAddNode);
    focusNodeReuseCacheMap[focusName] = updateAddNode;
    return __buildingFocusNode = updateAddNode;
  }

  List<FocusManager>? findFocusManager(FindFocusPosition position);

  List<FocusManager>? findFocusManagerByOrder(List<FindFocusPosition> positions){
    for(final position in positions){
      final findCurrentPosition = findFocusManager(position);
      if(findCurrentPosition?.isNotEmpty ?? false) return findCurrentPosition;
    }
    return null;
  }

  // FocusManager? singleFmFromChildren(List<FocusManager> children) => children.firstOrNull;

}