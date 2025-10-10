import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ketchup_ui/animation.dart';

void main() {
  
  group('GroupedAnimationManager 单例模式测试', () {
    tearDown(() {
      // 确保每个测试后重置单例
      GroupedAnimationManager.resetInstance();
    });

    testWidgets('应该返回同一个单例实例', (WidgetTester tester) async {
      final instance1 = GroupedAnimationManager.instance;
      final instance2 = GroupedAnimationManager.instance;

      expect(instance1, same(instance2));
    });

    testWidgets('createInstance 应该创建并返回单例', (WidgetTester tester) async {
      bool callbackCalled = false;

      final instance = GroupedAnimationManager.createInstance(
        onAllCompleted: () {
          callbackCalled = true;
        },
      );

      expect(instance, isNotNull);
      expect(GroupedAnimationManager.isInitialized, isTrue);
      expect(instance, same(GroupedAnimationManager.instance));
    });

    testWidgets('resetInstance 应该重置单例', (WidgetTester tester) async {
      final instance1 = GroupedAnimationManager.instance;
      instance1.createGroup('test');

      GroupedAnimationManager.resetInstance();
      final instance2 = GroupedAnimationManager.instance;

      expect(instance2.groupCount, 0);
    });

    testWidgets('disposeInstance 应该清理单例', (WidgetTester tester) async {
      final manager = GroupedAnimationManager.instance;
      final controller = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 100),
      );
      manager.addController('dispose_test', controller);

      GroupedAnimationManager.disposeInstance();

      expect(GroupedAnimationManager.isInitialized, isFalse);
    });
  });

  group('分组管理 API 测试', () {
    late List<AnimationController> controllers;
    late GroupedAnimationManager manager;

    setUp(() {
      manager = GroupedAnimationManager(); // 使用非单例避免干扰
      controllers = [];
    });

    tearDown(() {
      // 先 dispose 管理器，再 dispose 控制器
      manager.dispose();
      for (final controller in controllers) {
        try{
          controller.dispose();
        }catch(e){};
      }
    });

    // 辅助方法：创建并记录控制器
    AnimationController _createController(WidgetTester tester, Duration duration) {
      final controller = AnimationController(
        vsync: tester,
        duration: duration,
      );
      controllers.add(controller);
      return controller;
    }

    testWidgets('createGroup 应该创建新分组', (WidgetTester tester) async {
      manager.createGroup('test_group');

      expect(manager.hasGroup('test_group'), isTrue);
      expect(manager.groupCount, 1);
    });

    testWidgets('addController 应该自动创建不存在的分组', (WidgetTester tester) async {
      final controller1 = _createController(tester, const Duration(milliseconds: 100));
      
      manager.addController('auto_group', controller1);

      expect(manager.hasGroup('auto_group'), isTrue);
      expect(manager.hasController('auto_group', controller1), isTrue);
    });

    testWidgets('addController 不应该重复添加同一个控制器', (WidgetTester tester) async {
      final controller1 = _createController(tester, const Duration(milliseconds: 100));
      
      manager.addController('test', controller1);
      manager.addController('test', controller1);

      expect(manager.getGroupControllerCount('test'), 1);
    });

    testWidgets('removeController 应该从分组中移除控制器', (WidgetTester tester) async {
      final controller1 = _createController(tester, const Duration(milliseconds: 100));
      final controller2 = _createController(tester, const Duration(milliseconds: 200));
      
      manager.addControllers('remove_test', [controller1, controller2]);

      manager.removeController('remove_test', controller1);

      expect(manager.getGroupControllerCount('remove_test'), 1);
      expect(manager.hasController('remove_test', controller1), isFalse);
      expect(manager.hasController('remove_test', controller2), isTrue);
    });

    testWidgets('removeGroup 应该移除整个分组', (WidgetTester tester) async {
      final controller1 = _createController(tester, const Duration(milliseconds: 100));
      final controller2 = _createController(tester, const Duration(milliseconds: 200));
      
      manager.addControllers('group_to_remove', [controller1, controller2]);

      manager.removeGroup('group_to_remove');

      expect(manager.hasGroup('group_to_remove'), isFalse);
    });
  });

  // group('播放控制 API 测试', () {
  //   late List<AnimationController> controllers;
  //   late GroupedAnimationManager manager;

  //   setUp(() {
  //     manager = GroupedAnimationManager();
  //     controllers = [];
  //   });

  //   tearDown(() {
  //     manager.dispose();
  //     for (final controller in controllers) {
  //       controller.dispose();
  //     }
  //   });

  //   AnimationController _createController(WidgetTester tester, Duration duration) {
  //     final controller = AnimationController(
  //       vsync: tester,
  //       duration: duration,
  //     );
  //     controllers.add(controller);
  //     return controller;
  //   }

  //   testWidgets('playGroup 应该开始播放指定分组', (WidgetTester tester) async {
  //     final controller1 = _createController(tester, const Duration(milliseconds: 100));
  //     final controller2 = _createController(tester, const Duration(milliseconds: 100));
      
  //     manager.addControllers('play_test', [controller1, controller2]);

  //     manager.playGroup('play_test');

  //     // 只检查动画是否开始播放，不检查是否完成
  //     expect(controller1.status, AnimationStatus.forward);
  //     expect(controller2.status, AnimationStatus.forward);
  //   });

  //   testWidgets('playGroup 应该支持自定义时长', (WidgetTester tester) async {
  //     final controller1 = _createController(tester, const Duration(milliseconds: 500));
      
  //     manager.addController('duration_test', controller1);

  //     final customDuration = const Duration(milliseconds: 200);
  //     manager.playGroup('duration_test', duration: customDuration);

  //     expect(controller1.duration, customDuration);
  //     expect(controller1.status, AnimationStatus.forward);
  //   });

  //   testWidgets('playAll 应该开始播放所有分组', (WidgetTester tester) async {
  //     final controller1 = _createController(tester, const Duration(milliseconds: 100));
  //     final controller2 = _createController(tester, const Duration(milliseconds: 100));
      
  //     manager.addController('group1', controller1);
  //     manager.addController('group2', controller2);

  //     manager.playAll();

  //     expect(controller1.status, AnimationStatus.forward);
  //     expect(controller2.status, AnimationStatus.forward);
  //   });

  //   testWidgets('stopGroup 应该停止指定分组', (WidgetTester tester) async {
  //     final controller1 = _createController(tester, const Duration(milliseconds: 1000));
      
  //     manager.addController('stop_test', controller1);

  //     controller1.forward();
  //     await tester.pump(const Duration(milliseconds: 100));
      
  //     manager.stopGroup('stop_test');

  //     expect(controller1.status, AnimationStatus.forward);
  //     expect(controller1.isAnimating, isFalse);
  //   });

  //   testWidgets('resetGroup 应该重置指定分组', (WidgetTester tester) async {
  //     final controller1 = _createController(tester, const Duration(milliseconds: 100));
      
  //     manager.addController('reset_test', controller1);

  //     // 手动设置值到完成状态，不依赖动画
  //     controller1.value = 1.0;
      
  //     manager.resetGroup('reset_test');

  //     expect(controller1.value, 0.0);
  //     expect(controller1.status, AnimationStatus.dismissed);
  //   });

  //   testWidgets('播放时应该重置完成状态', (WidgetTester tester) async {
  //     final controller1 = _createController(tester, const Duration(milliseconds: 100));
      
  //     manager.addController('status_test', controller1);

  //     // 先模拟完成状态
  //     controller1.value = 1.0;
  //     // 手动触发状态监听器
  //     for (final listener in controller1.statusListeners) {
  //       listener(AnimationStatus.completed);
  //     }
  //     expect(manager.isGroupCompleted('status_test'), isTrue);

  //     // 再次播放应该重置状态
  //     manager.playGroup('status_test');
  //     expect(manager.isGroupCompleted('status_test'), isFalse);
  //   });

  // });

  group('回调功能测试', () {
    late List<AnimationController> controllers;
    late GroupedAnimationManager manager;

    setUp(() {
      manager = GroupedAnimationManager();
      controllers = [];
    });

    tearDown(() {
      manager.dispose();
      for (final controller in controllers) {
        try{
          controller.dispose();
        }catch(e){}
      }
    });

    AnimationController _createController(WidgetTester tester, Duration duration) {
      final controller = AnimationController(
        vsync: tester,
        duration: duration,
      );
      controllers.add(controller);
      return controller;
    }

    testWidgets('分组完成回调应该正确触发', (WidgetTester tester) async {
      bool groupCompleted = false;
      final controller1 = _createController(tester, const Duration(milliseconds: 10));
      final controller2 = _createController(tester, const Duration(milliseconds: 10));

      manager.createGroup('callback_group', onGroupMembersCompleted: () {
        groupCompleted = true;
      });
      manager.addControllers('callback_group', [controller1, controller2]);

      manager.playGroup('callback_group');
      
      // 等待动画完成
      await tester.pumpAndSettle();

      expect(groupCompleted, isTrue);
      expect(manager.isGroupCompleted('callback_group'), isTrue);
    });

    testWidgets('全局完成回调应该正确触发', (WidgetTester tester) async {
      bool allCompleted = false;
      final controller1 = _createController(tester, const Duration(milliseconds: 10));
      final controller2 = _createController(tester, const Duration(milliseconds: 10));
      
      final managerWithCallback = GroupedAnimationManager(
        onAllCompleted: () {
          allCompleted = true;
        },
      );

      managerWithCallback.addController('group1', controller1);
      managerWithCallback.addController('group2', controller2);

      managerWithCallback.playAll();
      
      // 等待动画完成
      await tester.pumpAndSettle();

      expect(allCompleted, isTrue);
      expect(managerWithCallback.areAllGroupsCompleted, isTrue);

      managerWithCallback.dispose();
    });

    testWidgets('只有所有分组完成时才触发全局回调', (WidgetTester tester) async {
      int callbackCount = 0;
      final controller1 = _createController(tester, const Duration(milliseconds: 10));
      final controller2 = _createController(tester, const Duration(milliseconds: 10));
      
      final managerWithCallback = GroupedAnimationManager(
        onAllCompleted: () {
          callbackCount++;
        },
      );

      managerWithCallback.addController('group1', controller1);
      managerWithCallback.addController('group2', controller2);

      // 只完成第一个分组
      managerWithCallback.playGroup('group1');
      await tester.pumpAndSettle();

      expect(callbackCount, 0);
      expect(managerWithCallback.areAllGroupsCompleted, isFalse);

      // 完成第二个分组
      managerWithCallback.playGroup('group2');
      await tester.pumpAndSettle();

      expect(callbackCount, 1);
      expect(managerWithCallback.areAllGroupsCompleted, isTrue);

      managerWithCallback.dispose();
    });

    // 暂时跳过空分组测试，等修复代码后再启用
    testWidgets('空分组应该立即触发完成回调', (WidgetTester tester) async {
      bool emptyGroupCompleted = false;
      
      manager.createGroup('empty_group', onGroupMembersCompleted: () {
        emptyGroupCompleted = true;
      });
    
      expect(emptyGroupCompleted, isTrue);
      expect(manager.isGroupCompleted('empty_group'), isTrue);
    });
  });


  group('查询 API 测试', () {
  late List<AnimationController> controllers;
  late GroupedAnimationManager manager;

  setUp(() {
    manager = GroupedAnimationManager();
    controllers = [];
  });

  tearDown(() {
    manager.dispose();
    for (final controller in controllers) {
      try{
        controller.dispose();
      }catch(e){};
    }
  });

  AnimationController _createController(WidgetTester tester, Duration duration) {
    final controller = AnimationController(
      vsync: tester,
      duration: duration,
    );
    controllers.add(controller);
    return controller;
  }

  testWidgets('getControllers 应该返回分组控制器列表', (WidgetTester tester) async {
    final controller1 = _createController(tester, const Duration(milliseconds: 100));
    final controller2 = _createController(tester, const Duration(milliseconds: 200));
    
    manager.addControllers('query_test', [controller1, controller2]);

    final controllers = manager.getControllers('query_test');

    expect(controllers, hasLength(2));
    expect(controllers, contains(controller1));
    expect(controllers, contains(controller2));
  });

  testWidgets('getGroupValues 应该返回分组动画值列表', (WidgetTester tester) async {
    final controller1 = _createController(tester, const Duration(milliseconds: 100));
    final controller2 = _createController(tester, const Duration(milliseconds: 200));
    
    manager.addControllers('values_test', [controller1, controller2]);

    controller1.value = 0.5;
    controller2.value = 0.8;

    final values = manager.getGroupValues('values_test');

    expect(values, hasLength(2));
    expect(values[0], 0.5);
    expect(values[1], 0.8);
  });

  testWidgets('findControllerGroups 应该找到控制器所在的所有分组', (WidgetTester tester) async {
    final controller1 = _createController(tester, const Duration(milliseconds: 100));
    
    manager.addController('group1', controller1);
    manager.addController('group2', controller1); // 同一个控制器在多个分组

    final groups = manager.findControllerGroups(controller1);

    expect(groups, hasLength(2));
    expect(groups, contains('group1'));
    expect(groups, contains('group2'));
  });

  testWidgets('groupCompletionStatus 应该返回分组完成状态', (WidgetTester tester) async {
    final controller1 = _createController(tester, const Duration(milliseconds: 10));
    
    manager.addController('status_test', controller1);

    final statusBefore = manager.groupCompletionStatus['status_test'];
    manager.playGroup('status_test');
    await tester.pumpAndSettle();
    final statusAfter = manager.groupCompletionStatus['status_test'];

    expect(statusBefore, isFalse);
    expect(statusAfter, isTrue);
  });

  testWidgets('totalControllerCount 应该返回总控制器数量', (WidgetTester tester) async {
    final controller1 = _createController(tester, const Duration(milliseconds: 100));
    final controller2 = _createController(tester, const Duration(milliseconds: 200));
    
    manager.addController('group1', controller1);
    manager.addController('group2', controller2);

    expect(manager.totalControllerCount, 2);
  });

  testWidgets('getGroupControllerCount 应该返回分组控制器数量', (WidgetTester tester) async {
    final controller1 = _createController(tester, const Duration(milliseconds: 100));
    final controller2 = _createController(tester, const Duration(milliseconds: 200));
    
    manager.addControllers('count_test', [controller1, controller2]);

    expect(manager.getGroupControllerCount('count_test'), 2);
  });

  testWidgets('groupLabels 应该返回所有分组标签', (WidgetTester tester) async {
    manager.createGroup('group1');
    manager.createGroup('group2');
    manager.createGroup('group3');

    final labels = manager.groupLabels;

    expect(labels, hasLength(3));
    expect(labels, contains('group1'));
    expect(labels, contains('group2'));
    expect(labels, contains('group3'));
  });
});

  group('边界条件测试', () {
    late List<AnimationController> controllers;
    late GroupedAnimationManager manager;

    setUp(() {
      manager = GroupedAnimationManager();
      controllers = [];
    });

    tearDown(() {
      manager.dispose();
      for (final controller in controllers) {
        try{
          controller.dispose();
        }catch(e){};
      }
    });

    AnimationController _createController(WidgetTester tester, Duration duration) {
      final controller = AnimationController(
        vsync: tester,
        duration: duration,
      );
      controllers.add(controller);
      return controller;
    }

    testWidgets('空管理器应该返回正确的状态', (WidgetTester tester) async {
      expect(manager.groupCount, 0);
      expect(manager.totalControllerCount, 0);
      expect(manager.areAllGroupsCompleted, isFalse);
      expect(manager.groupLabels, isEmpty);
    });

    testWidgets('操作不存在的分组应该不会抛出异常', (WidgetTester tester) async {
      expect(() => manager.playGroup('nonexistent'), returnsNormally);
      expect(() => manager.reverseGroup('nonexistent'), returnsNormally);
      expect(() => manager.stopGroup('nonexistent'), returnsNormally);
      expect(() => manager.resetGroup('nonexistent'), returnsNormally);
      expect(() => manager.removeGroup('nonexistent'), returnsNormally);
      expect(() => manager.getControllers('nonexistent'), returnsNormally);
      expect(() => manager.getGroupValues('nonexistent'), returnsNormally);
    });

    testWidgets('空分组应该被视为完成状态', (WidgetTester tester) async {
      manager.createGroup('empty_group');

      expect(manager.isGroupCompleted('empty_group'), isTrue);
    });

    testWidgets('重置完成状态应该工作正常', (WidgetTester tester) async {
      final controller = _createController(tester, const Duration(milliseconds: 10));
      manager.addController('reset_test', controller);

      controller.forward();
      await tester.pumpAndSettle();
      expect(manager.isGroupCompleted('reset_test'), isTrue);

      manager.resetGroup('reset_test');
      expect(manager.isGroupCompleted('reset_test'), isFalse);
    });

    testWidgets('清空管理器应该重置所有状态', (WidgetTester tester) async {
      final controller = _createController(tester, const Duration(milliseconds: 100));
      manager.addController('clear_test', controller);

      manager.clear();

      expect(manager.groupCount, 0);
      expect(manager.totalControllerCount, 0);
      expect(manager.areAllGroupsCompleted, isFalse);
    });

    testWidgets('移动和复制控制器应该正常工作', (WidgetTester tester) async {
      final controller1 = _createController(tester, const Duration(milliseconds: 100));
      final controller2 = _createController(tester, const Duration(milliseconds: 200));
      
      manager.addController('source_group', controller1);
      manager.addController('source_group', controller2);

      // 测试移动
      manager.moveController(controller1, 'source_group', 'target_group');
      expect(manager.hasController('source_group', controller1), isFalse);
      expect(manager.hasController('target_group', controller1), isTrue);
      expect(manager.getGroupControllerCount('source_group'), 1);
      expect(manager.getGroupControllerCount('target_group'), 1);

      // 测试复制
      manager.copyController(controller2, 'target_group');
      expect(manager.hasController('source_group', controller2), isTrue);
      expect(manager.hasController('target_group', controller2), isTrue);
      expect(manager.getGroupControllerCount('source_group'), 1);
      expect(manager.getGroupControllerCount('target_group'), 2);
    });
  });

  group('时长修改测试', () {
    late List<AnimationController> controllers;
    late GroupedAnimationManager manager;

    setUp(() {
      manager = GroupedAnimationManager();
      controllers = [];
    });

    tearDown(() {
      manager.dispose();
      for (final controller in controllers) {
        try{
          controller.dispose();        
        }catch(e){}
      }
    });

    AnimationController _createController(WidgetTester tester, Duration duration) {
      final controller = AnimationController(
        vsync: tester,
        duration: duration,
      );
      controllers.add(controller);
      return controller;
    }

    testWidgets('播放时修改时长应该生效', (WidgetTester tester) async {
      final controller1 = _createController(tester, const Duration(milliseconds: 500));
      
      manager.addController('duration_test', controller1);

      final originalDuration = controller1.duration;
      final newDuration = const Duration(milliseconds: 200);

      // 先停止动画，再修改时长
      controller1.stop();
      manager.playGroup('duration_test', duration: newDuration);

      expect(controller1.duration, newDuration);
      expect(controller1.duration, isNot(originalDuration));
    });

    testWidgets('反向播放时修改时长应该生效', (WidgetTester tester) async {
      final controller1 = _createController(tester, const Duration(milliseconds: 500));
      
      manager.addController('reverse_duration_test', controller1);

      final newDuration = const Duration(milliseconds: 300);

      // 先停止动画，再修改时长
      controller1.stop();
      manager.reverseGroup('reverse_duration_test', duration: newDuration);

      expect(controller1.duration, newDuration);
    });

    testWidgets('playAll 应该支持统一修改所有控制器时长', (WidgetTester tester) async {
      final controller1 = _createController(tester, const Duration(milliseconds: 500));
      final controller2 = _createController(tester, const Duration(milliseconds: 200));
      
      manager.addController('group1', controller1);
      manager.addController('group2', controller2);

      // 先停止所有动画
      controller1.stop();
      controller2.stop();

      final newDuration = const Duration(milliseconds: 400);
      manager.playAll(duration: newDuration);

      expect(controller1.duration, newDuration);
      expect(controller2.duration, newDuration);
    });

    testWidgets('修改时长应该在动画开始前生效', (WidgetTester tester) async {
      final controller1 = _createController(tester, const Duration(milliseconds: 100));
      
      manager.addController('before_play_test', controller1);

      // 在播放前修改时长
      final newDuration = const Duration(milliseconds: 50);
      manager.playGroup('before_play_test', duration: newDuration);

      expect(controller1.duration, newDuration);
      
      // 等待动画完成
      await tester.pumpAndSettle();
      
      expect(controller1.status, AnimationStatus.completed);
    });
  });
}
