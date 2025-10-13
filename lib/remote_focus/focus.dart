// ignore_for_file: non_constant_identifier_names
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:ketchup_ui/mixin/listeners.dart';

enum NextFocusAction {
  left, right, up, down, enter
}

enum FindFocusPosition {
  father, topFather, children, brothers, prevLeft, nextRight
}

class FocusNode extends ChangeNotifier{
  final String name;
  FocusNode? father;
  FocusNode? left;
  FocusNode? right;
  FocusNode? up;
  FocusNode? down;
  FocusNode? enter;
  bool isFocused = false;
  FocusNode({required this.name, this.father});

  void onFocus(){
    notifyListeners();
  }

  void onBlur(){
    notifyListeners();
  }

  void focus(){
    isFocused = true;
    onFocus();
  }

  void blur(){
    isFocused = false;
    onBlur();
  }
  void reset(){
    left = null;
    right = null;
    up = null;
    down = null;
    enter = null;
  }
}

mixin FocusManager {
  static FocusManager? activeManager;
  void Function(VoidCallback, [String? d]) get focusUpdate;
  final FocusNode DEFAULT_FOCUS_NODE = FocusNode(name: 'default');
  final Map<String, FocusNode> focusNodeMap = {};
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

  FocusNode focusDefault({bool update = true}){
    _currentFocusNode = null;
    currentFocusNode.focus();
    if(update) focusUpdate((){});
    return currentFocusNode;
  }

  FocusNode focusTopFatherManager({bool update = true}){
    final topFatherManager = findFocusManager(FindFocusPosition.topFather)?.firstOrNull;
    currentFocusNode.blur();
    if(update) focusUpdate((){});
    return (activeManager = topFatherManager)!.focusDefault(update: update);  
  }

  FocusNode? focusEnter({bool update = true}){
    if(enterFocusNode != null){
      currentFocusNode.blur();
      enterFocusNode!.focus();
      if(update) focusUpdate((){});
      return _currentFocusNode = enterFocusNode;
    }
    return null;
  }
  
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

  FocusNode? focusLeft({bool update = true}){
    if(leftFocusNode != null){
      currentFocusNode.blur();
      leftFocusNode!.focus();
    }
    if(update) focusUpdate((){});
    return _currentFocusNode = leftFocusNode;
  }

  FocusNode? focusLeftAcrossManager({bool update = true}){
    final left = focusLeft(update: false);
    if(left == null){
      final prevLeftManager = findFocusManager(FindFocusPosition.prevLeft)?.firstOrNull;
      if(prevLeftManager != null){
        currentFocusNode.blur();
        if(update) focusUpdate((){});
        return (activeManager = prevLeftManager).focusDefault(update: update);
      }
    }
    if(update) focusUpdate((){});
    return left;
  }

  FocusNode? focusRight({bool update = true}){
    if(rightFocusNode != null){
      currentFocusNode.blur();
      rightFocusNode!.focus();
    }
    if(update) focusUpdate((){});
    return _currentFocusNode = rightFocusNode;
  }

  FocusNode? focusRightAcrossManager({bool update = true}){
    final right = focusRight(update: false);
    if(right == null){
      final nextRightManager = findFocusManager(FindFocusPosition.nextRight)?.firstOrNull;
      if(nextRightManager != null){
        currentFocusNode.blur();
        if(update) focusUpdate((){});
        return (activeManager = nextRightManager).focusDefault(update: update);
      }
    }
    if(update) focusUpdate((){});
    return right;
  }
  
  FocusNode? focusUp({bool update = true}){
    if(upFocusNode != null){
      currentFocusNode.blur();
      upFocusNode!.focus();
    }
    if(update) focusUpdate((){});
    return _currentFocusNode = upFocusNode;
  }

  FocusNode? focusUpAcrossManager({bool update = true}){
    final up = focusUp(update: false);
    if(up == null){
      final upFatherManager = findFocusManager(FindFocusPosition.father)?.firstOrNull;
      if(upFatherManager != null){
        currentFocusNode.blur();
        if(update) focusUpdate((){});
        return (activeManager = upFatherManager).focusDefault(update: update);
      }
    }
    if(update) focusUpdate((){});
    return up;
  }
  
  FocusNode? focusDown({bool update = true}){
    if(downFocusNode != null){
      currentFocusNode.blur();
      downFocusNode!.focus();
    }
    if(update) focusUpdate((){});
    return _currentFocusNode = downFocusNode;
  }

  FocusNode? focusDownAcrossManager({bool update = true}){
    final down = focusDown(update: false);
    if(down == null){
      final downChildrenManager = findFocusManager(FindFocusPosition.children)?.firstOrNull;
      if(downChildrenManager != null){
        currentFocusNode.blur();
        if(update) focusUpdate((){});
        return (activeManager = downChildrenManager).focusDefault(update: update);
      }
    }
    if(update) focusUpdate((){});
    return down;
  }
  
  FocusNode? focusBack({bool update = true}){
    if(backFocusNode != null){
      currentFocusNode.blur();
      backFocusNode!.focus();
    }
    if(update) focusUpdate((){});
    return _currentFocusNode = backFocusNode;
  }

  FocusNode? focusBackAcrossManager({bool update = true}){
    final back = focusBack(update: false);
    if(back == null){
      final fatherFocusManager = findFocusManager(FindFocusPosition.father)?.firstOrNull;
      if(fatherFocusManager != null){
        currentFocusNode.blur();
        if(update) focusUpdate((){});
        return (activeManager = fatherFocusManager).focusDefault(update: update);
      }
    }
    if(update) focusUpdate((){});
    return back;
  }
  
  bool isFocused([String? name]) => name != null && currentFocusNode.name == name && currentFocusNode.isFocused || (name == null && DEFAULT_FOCUS_NODE.isFocused);

  FocusNode focusEndSetDefaultNode(NextFocusAction? action, {void Function(FocusNode building, FocusNode dflt)? override}){
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
      case null:
    }
    override?.call(_buildingFocusNode, DEFAULT_FOCUS_NODE);
    __buildingFocusNode = null;
    return _buildingFocusNode;
  }

  FocusNode focusUpdateAddNode(NextFocusAction action, String focusName, {FocusNode? father, void Function(FocusNode building, FocusNode update)? override}){
    final updateAddNode = (focusNodeMap[focusName] ?? FocusNode(name: focusName, father: father))..reset();
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
    }
    override?.call(_buildingFocusNode, updateAddNode);
    focusNodeMap[focusName] = updateAddNode;
    return __buildingFocusNode = updateAddNode;
  }

  List<FocusManager>? findFocusManager(FindFocusPosition position);
}