// ignore_for_file: non_constant_identifier_names
enum NextFocusAction {
  left, right, up, down
}

class FocusNode {
  final String name;
  FocusNode? father;
  FocusNode? left;
  FocusNode? right;
  FocusNode? up;
  FocusNode? down;
  bool isFocused = false;
  FocusNode({required this.name, this.father});
  void onFocus(){}
  void onBlur(){}
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
  }
}

mixin FocusManager {
  final FocusNode DEFAULT_FOCUS_NODE = FocusNode(name: 'default');
  final Map<String, FocusNode> focusNodeMap = {};
  FocusNode? __innerSetFocusNode;
  FocusNode get _innerSetFocusNode => __innerSetFocusNode ?? DEFAULT_FOCUS_NODE;
  FocusNode? _currentFocusNode;
  FocusNode get currentFocusNode => _currentFocusNode ?? DEFAULT_FOCUS_NODE;
  FocusNode? get leftFocusNode => currentFocusNode.left;
  FocusNode? get rightFocusNode => currentFocusNode.right;
  FocusNode? get upFocusNode => currentFocusNode.up;
  FocusNode? get downFocusNode => currentFocusNode.down;

  FocusNode? focusLeft(){
    currentFocusNode.blur();
    (leftFocusNode ?? DEFAULT_FOCUS_NODE).focus();
    return _currentFocusNode = leftFocusNode;
  }
  FocusNode? focusRight(){
    currentFocusNode.blur();
    (rightFocusNode ?? DEFAULT_FOCUS_NODE).focus();
    return _currentFocusNode = rightFocusNode;
  }
  FocusNode? focusUp(){
    currentFocusNode.blur();
    (upFocusNode ?? DEFAULT_FOCUS_NODE).focus();
    return _currentFocusNode = upFocusNode;
  }
  FocusNode? focusDown(){
    currentFocusNode.blur();
    (downFocusNode ?? DEFAULT_FOCUS_NODE).focus();
    return _currentFocusNode = downFocusNode;
  }
  
  bool isFocused([String? name]) => name != null && currentFocusNode.name == name || (name == null && DEFAULT_FOCUS_NODE.isFocused);

  FocusNode endSetToDefault(NextFocusAction action){
    switch(action){
      case NextFocusAction.right:
        _innerSetFocusNode.right = DEFAULT_FOCUS_NODE;
        DEFAULT_FOCUS_NODE.left = _innerSetFocusNode;
        break;
      case NextFocusAction.left:
        _innerSetFocusNode.left = DEFAULT_FOCUS_NODE;
        DEFAULT_FOCUS_NODE.right = _innerSetFocusNode;
        break;
      case NextFocusAction.down:
        _innerSetFocusNode.down = DEFAULT_FOCUS_NODE;
        DEFAULT_FOCUS_NODE.up = _innerSetFocusNode;
        break;
      case NextFocusAction.up:
        _innerSetFocusNode.up = DEFAULT_FOCUS_NODE;
        DEFAULT_FOCUS_NODE.down = _innerSetFocusNode;
        break;
    }
    __innerSetFocusNode = null;
    return _innerSetFocusNode;
  }

  FocusNode updateAddFocus(NextFocusAction action, String focusName, {FocusNode? father}){
    final updateAddNode = (focusNodeMap[focusName] ?? FocusNode(name: focusName, father: father))..reset();
    switch(action){
      case NextFocusAction.right:
        _innerSetFocusNode.right = updateAddNode;
        updateAddNode.left = _innerSetFocusNode;
        break;
      case NextFocusAction.left:
        _innerSetFocusNode.left = updateAddNode;
        updateAddNode.right = _innerSetFocusNode;
        break;
      case NextFocusAction.down:
        _innerSetFocusNode.down = updateAddNode;
        updateAddNode.up = _innerSetFocusNode;
        break;
      case NextFocusAction.up:
        _innerSetFocusNode.up = updateAddNode;
        updateAddNode.down = _innerSetFocusNode;
        break;
    }
    focusNodeMap[focusName] = updateAddNode;
    return __innerSetFocusNode = updateAddNode;
  }
}