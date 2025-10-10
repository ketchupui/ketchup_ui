import 'package:flutter/animation.dart';

/// 简化版分组动画管理器 - 直接管理 AnimationController
class GroupedAnimationManager {

  // 单例实例
  static GroupedAnimationManager? _instance;
  
  // 核心数据结构：分组标签 -> 控制器列表
  final Map<String, List<AnimationController>> _groups = {};
  
  // 回调函数
  VoidCallback? onAllCompleted;
  /// 只存放有数据时候的回调，无数据不回调
  final Map<String, VoidCallback> _groupCallbacks = {};
  
  // 状态跟踪
  final Map<String, bool> _groupCompletionStatus = {};
  final Map<AnimationController, bool> _controllerCompletionStatus = {};
  
  bool _hasTriggeredAllCompleted = false;

  /// 私有构造函数
  GroupedAnimationManager._internal({
    this.onAllCompleted,
  });

  /// 获取单例实例
  static GroupedAnimationManager get instance {
    _instance ??= GroupedAnimationManager._internal();
    return _instance!;
  }

  /// 创建新的管理器实例（非单例模式）
  factory GroupedAnimationManager({
    VoidCallback? onAllCompleted,
  }) {
    return GroupedAnimationManager._internal(onAllCompleted: onAllCompleted);
  }

  /// 创建带配置的单例实例
  static GroupedAnimationManager createInstance({
    VoidCallback? onAllCompleted,
  }) {
    _instance = GroupedAnimationManager._internal(onAllCompleted: onAllCompleted);
    return _instance!;
  }

  /// 重置单例实例
  static void resetInstance() {
    _instance?.clear();
    _instance = null;
  }

  /// 检查单例是否已初始化
  static bool get isInitialized => _instance != null;

  // ========== 分组管理 API ==========

  /// 创建新分组（如果分组已存在则不会重复创建）
  void createGroup(String label, {VoidCallback? onGroupMembersCompleted}) {
    if (!_groups.containsKey(label)) {
      _groups[label] = [];
      // 空分组应该立即被视为完成状态，但不触发回调
      _groupCompletionStatus[label] = true;
      if (onGroupMembersCompleted != null) {
        _groupCallbacks[label] = onGroupMembersCompleted;
        // 注意：空分组不立即触发回调，回调只在有内容且完成时触发
        // onGroupMembersCompleted();
      }
    }
  }

  /// 添加控制器到指定分组（自动创建不存在的分组）
  void addController(String label, AnimationController controller, {VoidCallback? onGroupMembersCompleted}) {
    // 确保分组存在
    createGroup(label, onGroupMembersCompleted: onGroupMembersCompleted);
    
    final group = _groups[label]!;
    if (!group.contains(controller)) {
      group.add(controller);
      _controllerCompletionStatus[controller] = false;
      
      // 修复：添加控制器后，如果分组从空变为非空，需要重置完成状态
      if (group.length == 1) { // 刚刚从空变成有1个控制器
        _groupCompletionStatus[label] = false;
      }
      
      controller.addStatusListener((status) {
        _handleControllerStatusChange(controller, label, status);
      });
    }
  }

  /// 批量添加控制器到分组
  void addControllers(String label, List<AnimationController> controllers, {VoidCallback? onGroupMembersCompleted}) {
    for (final controller in controllers) {
      addController(label, controller, onGroupMembersCompleted: onGroupMembersCompleted);
    }
  }

  /// 从分组中移除指定控制器
  void removeController(String label, AnimationController controller) {
    final group = _groups[label];
    if (group != null) {
      group.remove(controller);
      _controllerCompletionStatus.remove(controller);
      
      // 如果分组为空，检查是否需要触发完成回调
      if (group.isEmpty) {
        _checkGroupCompletion(label);
      }
      _checkAllCompleted();
    }
  }

  /// 移除指定分组的所有控制器
  void removeGroup(String label) {
    final group = _groups[label];
    if (group != null) {
      for (final controller in group) {
        _controllerCompletionStatus.remove(controller);
      }
      _groups.remove(label);
      _groupCompletionStatus.remove(label);
      _groupCallbacks.remove(label);
      _checkAllCompleted();
    }
  }

  /// 移动控制器到另一个分组
  void moveController(AnimationController controller, String fromLabel, String toLabel) {
    removeController(fromLabel, controller);
    addController(toLabel, controller);
  }

  /// 复制控制器到另一个分组（一个控制器可以在多个分组中）
  void copyController(AnimationController controller, String toLabel) {
    addController(toLabel, controller);
  }

  // ========== 播放控制 API ==========

  /// 播放指定分组的所有动画
  void playGroup(String label, {Duration? duration}) {
    final group = _groups[label];
    if (group != null) {
      _groupCompletionStatus[label] = false;
      for (final controller in group) {
        _controllerCompletionStatus[controller] = false;
        _playController(controller, duration: duration);
      }
    }
  }

  /// 播放所有分组的所有动画
  void playAll({Duration? duration}) {
    _hasTriggeredAllCompleted = false;
    
    for (final label in _groups.keys) {
      _groupCompletionStatus[label] = false;
      final group = _groups[label]!;
      for (final controller in group) {
        _controllerCompletionStatus[controller] = false;
        _playController(controller, duration: duration);
      }
    }
  }

  /// 反向播放指定分组的所有动画
  void reverseGroup(String label, {Duration? duration}) {
    final group = _groups[label];
    if (group != null) {
      _groupCompletionStatus[label] = false;
      for (final controller in group) {
        _reverseController(controller, duration: duration);
      }
    }
  }

  /// 反向播放所有动画
  void reverseAll({Duration? duration}) {
    for (final group in _groups.values) {
      for (final controller in group) {
        _reverseController(controller, duration: duration);
      }
    }
  }

  /// 播放单个控制器（内部方法）
  void _playController(AnimationController controller, {Duration? duration}) {
    if (duration != null) {
      // 直接修改 duration 属性，然后播放
      controller.duration = duration;
    }
    controller.forward();
  }

  /// 反向播放单个控制器（内部方法）
  void _reverseController(AnimationController controller, {Duration? duration}) {
    if (duration != null) {
      // 直接修改 duration 属性，然后反向播放
      controller.duration = duration;
    }
    controller.reverse();
  }

  /// 停止指定分组的所有动画
  void stopGroup(String label) {
    final group = _groups[label];
    if (group != null) {
      for (final controller in group) {
        controller.stop();
      }
    }
  }

  /// 停止所有动画
  void stopAll() {
    for (final group in _groups.values) {
      for (final controller in group) {
        controller.stop();
      }
    }
  }

  /// 重置指定分组的所有动画
  void resetGroup(String label) {
    final group = _groups[label];
    if (group != null) {
      _groupCompletionStatus[label] = false;
      for (final controller in group) {
        _controllerCompletionStatus[controller] = false;
        controller.reset();
      }
    }
  }

  /// 重置所有动画
  void resetAll() {
    _hasTriggeredAllCompleted = false;
    for (final label in _groups.keys) {
      _groupCompletionStatus[label] = false;
      final group = _groups[label]!;
      for (final controller in group) {
        _controllerCompletionStatus[controller] = false;
        controller.reset();
      }
    }
  }

  // ========== 查询 API ==========

  /// 获取指定分组的所有控制器
  List<AnimationController> getControllers(String label) {
    return _groups[label]?.toList() ?? [];
  }

  /// 获取指定分组的动画值列表
  List<double> getGroupValues(String label) {
    final group = _groups[label];
    return group?.map((c) => c.value).toList() ?? [];
  }

  /// 获取控制器所在的所有分组标签
  List<String> findControllerGroups(AnimationController controller) {
    return _groups.keys.where((label) {
      final group = _groups[label]!;
      return group.contains(controller);
    }).toList();
  }

  /// 检查分组是否存在
  bool hasGroup(String label) => _groups.containsKey(label);

  /// 检查控制器是否在指定分组中
  bool hasController(String label, AnimationController controller) {
    final group = _groups[label];
    return group?.contains(controller) ?? false;
  }

  /// 检查指定分组是否全部完成
  bool isGroupCompleted(String label) {
    return _groupCompletionStatus[label] == true;
  }

  /// 检查所有分组是否全部完成
  bool get areAllGroupsCompleted {
    if (_groups.isEmpty) return false;
    return _groups.keys.every((label) => _groupCompletionStatus[label] == true);
  }

  /// 获取分组完成状态
  Map<String, bool> get groupCompletionStatus => Map.unmodifiable(_groupCompletionStatus);

  /// 获取所有分组标签
  List<String> get groupLabels => _groups.keys.toList();

  /// 获取分组数量
  int get groupCount => _groups.length;

  /// 获取指定分组的控制器数量
  int getGroupControllerCount(String label) {
    return _groups[label]?.length ?? 0;
  }

  /// 获取总控制器数量
  int get totalControllerCount {
    int count = 0;
    for (final group in _groups.values) {
      count += group.length;
    }
    return count;
  }

  // ========== 内部方法 ==========

  /// 处理控制器状态变化
  void _handleControllerStatusChange(
    AnimationController controller, 
    String groupLabel, 
    AnimationStatus status
  ) {
    final bool isCompleted = (status == AnimationStatus.completed);
    final bool wasCompleted = _controllerCompletionStatus[controller] ?? false;
    
    if (isCompleted != wasCompleted) {
      _controllerCompletionStatus[controller] = isCompleted;
      _checkGroupCompletion(groupLabel);
      _checkAllCompleted();
    }
  }

  /// 检查指定分组是否完成
  void _checkGroupCompletion(String label) {
    final group = _groups[label];
    if (group == null) return;
    
    // 空分组视为完成
    if (group.isEmpty) {
      if (!(_groupCompletionStatus[label] ?? false)) {
        _groupCompletionStatus[label] = true;
        _groupCallbacks[label]?.call();
      }
      return;
    }
    
    final allControllersCompleted = group.every(
      (controller) => _controllerCompletionStatus[controller] == true
    );
    
    if (allControllersCompleted && !(_groupCompletionStatus[label] ?? false)) {
      _groupCompletionStatus[label] = true;
      _groupCallbacks[label]?.call();
    }
  }

  /// 检查所有分组是否完成
  void _checkAllCompleted() {
    if (_groups.isEmpty || _hasTriggeredAllCompleted) return;
    
    final allGroupsCompleted = _groups.keys.every(
      (label) => _groupCompletionStatus[label] == true
    );
    
    if (allGroupsCompleted) {
      _hasTriggeredAllCompleted = true;
      onAllCompleted?.call();
    }
  }

  // ========== 清理方法 ==========

  /// 清空所有分组和控制器
  void clear() {
    for (final group in _groups.values) {
      for (final controller in group) {
        _controllerCompletionStatus.remove(controller);
      }
    }
    _groups.clear();
    _groupCompletionStatus.clear();
    _groupCallbacks.clear();
    _hasTriggeredAllCompleted = false;
  }

  /// 销毁所有控制器
  void dispose() {
    for (final group in _groups.values) {
      for (final controller in group) {
        try{
          controller.dispose();
        }catch(e){}
      }
    }
    clear();
  }

  /// 销毁单例实例
  static void disposeInstance() {
    _instance?.dispose();
    _instance = null;
  }
}