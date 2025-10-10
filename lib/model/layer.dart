// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'accessor.dart';
import 'context.dart';

// ignore: constant_identifier_names
const DEFAULT_GROUP_NAME = 'default';
typedef PainterCall = void Function(Canvas canvas, Size size);

abstract class ContextPainterObject extends CustomPainter with ChangeNotifier{

  ContextPainterObject({super.repaint});

  ContextAccessor? get ctxAccessor;
  Rect? get paintRect;
  PainterCall? _painterCall;
  
  @override
  void paint(Canvas canvas, Size size) {
    delegatePaint(canvas, size);
  }

  /// 该方法使得绘图方法只依赖一次 ctx 并缓存以来的计算数据，比如大小位置信息等。
  PainterCall? givePainterCall(ContextAccessor? ctxAccessor);
  
  /// 该方法使得绘图方法次次依赖实时的 ctx 数据，可能造成性能影响
  void paintContext(ContextAccessor? ctxAccessor, Canvas ctxCanvas, Size ctxSize);

  void delegatePaint(Canvas canvas, Size size){
    if((_painterCall ??= givePainterCall(ctxAccessor)) != null){
      _painterCall!.call(canvas, size);
    }else{
      paintContext(ctxAccessor, canvas, size);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // if(oldDelegate is CPO) return oldDelegate.paintRect != paintRect ;
    return true;
  }

  CustomPaint asBackground({Widget? child}){
    return CustomPaint(painter: this, child: child);
  }

  CustomPaint asForeground({Widget? child}){
    return CustomPaint(foregroundPainter: this, child: child);
  }
}

typedef CPO = ContextPainterObject;

class CPOWidget extends StatelessWidget{

  final CPO cpo;
  final Widget? child;
  final Size? size;
  const CPOWidget(this.cpo, {super.key, this.child, this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint( painter: cpo, size: size ?? cpo.paintRect?.size ?? Size.zero, child: child);
  }
    
}

abstract class ListLayerCommitInterface {

  @protected
  void _commitLayerAdded(CPO add);

  @protected
  void _commitLayersAdded(Iterable<CPO> adds);
  
  @protected
  bool _commitLayerRemoved(CPO remove);
  
  @protected
  bool _commitLayersRemoved(Iterable<CPO> removes);
  
  @protected
  void _commitLayersCleared([Iterable<CPO>? clears]);
}

abstract class NamedLayerCommitInterface {

  @protected
  //// 如果已经存在update则返回 true,不存在创建新的 返回 false
  bool _commitNamedLayerUpdateAdded(String named, [CPO? add]);

  @protected
  void _commitNamedLayerAdded(String named, CPO add);

  @protected
  void _commitNamedLayersAdded(String named, Iterable<CPO> adds);

  @protected
  void _commitNamedLayersGroupsAdded(Iterable<MapEntry<String, List<CPO>>> gadds);
  
  @protected
  bool _commitNamedLayerRemoved(String named, CPO remove);

  @protected
  bool _commitNamedLayerCanRemove(String named, CPO remove);
  
  @protected
  bool _commitNamedLayersRemoved(String named, Iterable<CPO> removes);
  
  @protected
  bool _commitNamedLayersCanRemove(String named, Iterable<CPO> removes);

  @protected
  bool _commitNamedLayersGroupsRemoved(Iterable<String> gremoves);
  
  @protected
  bool _commitNamedLayersGroupsCanRemove(Iterable<String> gremoves);

}

abstract class LayerContext extends BaseContext {
  List<CPO> get layers;
  ListLayerContext get list => this as ListLayerContext;
  NamedLayerContext get named => this as NamedLayerContext;
}

abstract class ListLayerContext extends LayerContext implements ListLayerCommitInterface{
  @override
  List<CPO> get layers;
  
  void notifyAddPainter(CPO painter) {
    _commitLayerAdded(painter);
    painter.addListener(_onSubPainterChanged);
    notifyListeners(); // 结构变动，也触发重绘
  }

  void notifyAddPainters(Iterable<CPO> painters) {
    _commitLayersAdded(painters);
    for (var painter in painters) {
      painter.addListener(_onSubPainterChanged);
    }
    notifyListeners(); // 结构变动，也触发重绘
  }

  void notifyRemovePainter(CPO painter) {
    if (_commitLayerRemoved(painter)) {
      painter.removeListener(_onSubPainterChanged);
      notifyListeners(); // 结构变动
    }
  }
  
  void notifyRemovePainters(Iterable<CPO> painters) {
    if (_commitLayersRemoved(painters)) {
      for (var painter in painters) {
        painter.removeListener(_onSubPainterChanged);
      }
      notifyListeners(); // 结构变动
    }
  }

  void _onSubPainterChanged() {
    notifyListeners(); // 转发 repaint
  }

  void notifyClear([Iterable<CPO>? clears]) {
    for (final p in clears ?? layers) {
      p.removeListener(_onSubPainterChanged);
    }
    _commitLayersCleared(clears);
    notifyListeners();
  }

}

abstract class NamedLayerContext extends ListLayerContext implements NamedLayerCommitInterface{

  Map<String, List<CPO>> get namedLayers;

  /// 非 notify 方式刷新(update方式刷新)
  void updateAddNamedPainter(String name, CPO painter){
    _commitNamedLayerUpdateAdded(name, painter);
  }

  void updateNamedClear(String name){
    _commitNamedLayerUpdateAdded(name);
  }
    
  void notifyAddNamedPainter(String name, CPO painter) {
    _commitNamedLayerAdded(name, painter);
    painter.addListener(_onSubPainterChanged);
    notifyListeners(); // 结构变动，也触发重绘
  }

  void notifyAddNamedPainters(String name, Iterable<CPO> painters) {
    _commitNamedLayersAdded(name, painters);
    for (var painter in painters) {
      painter.addListener(_onSubPainterChanged);
    }
    notifyListeners(); // 结构变动，也触发重绘
  }
  
  void notifyAddGroupNamedPainters(Iterable<MapEntry<String, List<CPO>>> gpainters) {
    _commitNamedLayersGroupsAdded(gpainters);
    for (var painter in gpainters) {
      for (var cpo in painter.value) {
        cpo.addListener(_onSubPainterChanged);
      }
    }
    notifyListeners(); // 结构变动，也触发重绘
  }

  void notifyRemoveNamedPainter(String named, CPO painter) {
    if (_commitNamedLayerRemoved(named, painter)) {
      painter.removeListener(_onSubPainterChanged);
      notifyListeners(); // 结构变动
    }
  }
  
  void notifyRemoveNamedPainters(String name, Iterable<CPO> painters) {
    if (_commitNamedLayersRemoved(name, painters)) {
      for (var painter in painters) {
        painter.removeListener(_onSubPainterChanged);
      }
      notifyListeners(); // 结构变动
    }
  }
  
  void notifyRemoveGroups(Iterable<String> gremoves) {
    if(_commitNamedLayersGroupsCanRemove(gremoves)){
      namedLayers.entries.where((filter)=>gremoves.contains(filter.key)).forEach((entry){
        for (var cpo in entry.value) {
          cpo.removeListener(_onSubPainterChanged);
        }
      });
      _commitNamedLayersGroupsRemoved(gremoves);
      notifyListeners(); // 结构变动
    }
  }

  @override
  void _onSubPainterChanged() {
    notifyListeners(); // 转发 repaint
  }

  void notifyGroupsClear([Iterable<String>? gclears]) {
    notifyRemoveGroups(gclears ?? namedLayers.keys);
  }


}

abstract mixin class ListLayerCommitImpl implements ListLayerCommitInterface{
  
  List<CPO> get simpleLayers;
  // set simpleLayers(List<CPO> value);
  
  @override
  void _commitLayerAdded(CPO add) {
    simpleLayers.add(add);
  }
  
  @override
  void _commitLayersCleared([Iterable<CPO>? clears]) {
    if(clears != null) {
      _commitLayersRemoved(clears);
    } else {
      simpleLayers.clear();
    }
  }
  
  @override
  bool _commitLayerRemoved(CPO remove) {
    return simpleLayers.remove(remove);
  }
  
  @override
  void _commitLayersAdded(Iterable<CPO> adds) {
    simpleLayers.addAll(adds);
  }
  
  @override
  bool _commitLayersRemoved(Iterable<CPO> removes) {
    return removes.every((remove)=>_commitLayerRemoved(remove));
  }
}

abstract mixin class NamdeLayersCommitImpl implements NamedLayerCommitInterface{

  Map<String, List<CPO>> get namedLayers;
  // set namedLayers(Map<String, List<CPO>> value);

  @override
  bool _commitNamedLayerUpdateAdded(String named, [CPO? add]) {
    var contains = namedLayers.containsKey(named);
    List<CPO> updated = add != null ? [add] : [];
    namedLayers.update(named, (list)=>updated, ifAbsent: () => updated,);
    return contains;
  }

  @override
  void _commitNamedLayerAdded(String named, CPO add) {
    namedLayers.update(named, (list)=>list..add(add), ifAbsent: () => [add],);
  }

  @override
  bool _commitNamedLayerCanRemove(String named, CPO remove) {
    return namedLayers.containsKey(named) && namedLayers[named]!.contains(remove);
  }

  @override
  bool _commitNamedLayerRemoved(String named, CPO remove) {
    if(_commitNamedLayerCanRemove(named, remove)){
      namedLayers.update(named, (list)=>list..remove(remove));
      return true;
    }
    return false;
  }

  @override
  void _commitNamedLayersAdded(String named, Iterable<CPO> adds) {
    namedLayers.update(named, (list)=>list..addAll(adds), ifAbsent: ()=>adds.toList());
  }

  @override
  void _commitNamedLayersGroupsAdded(Iterable<MapEntry<String,List<CPO>>> gadds) {
    namedLayers.addEntries(gadds);
  }

   @override
  bool _commitNamedLayersGroupsCanRemove(Iterable<String> gremoves) {
    return namedLayers.keys.toSet().containsAll(gremoves);
  }

  @override
  bool _commitNamedLayersGroupsRemoved(Iterable<String> gremoves) {
    if(_commitNamedLayersGroupsCanRemove(gremoves)){
      for (var removeKey in gremoves) {
        namedLayers.remove(removeKey);
      }
      return true;
    }
    return false;
  }

  @override
  bool _commitNamedLayersCanRemove(String named, Iterable<CPO> removes) {
    return namedLayers.containsKey(named) && namedLayers[named]!.toSet().containsAll(removes);
  }

  @override
  bool _commitNamedLayersRemoved(String named, Iterable<CPO> removes) {
    if(_commitNamedLayersCanRemove(named, removes)){
      namedLayers.update(named, (list)=>list..forEach((each)=>list.remove(each)));
      return true;
    }
    return false;
  }
  
}

class SimpleLayerContext extends ListLayerContext with ListLayerCommitImpl{

  @override
  List<CPO> layers;
  SimpleLayerContext({this.layers = const []});
  
  @override
  List<CPO> get simpleLayers => layers;
}

class SimpleNamedLayerContext extends NamedLayerContext with ListLayerCommitImpl, NamdeLayersCommitImpl{

  SimpleNamedLayerContext();

  @override
  List<CPO> get layers => namedLayers.values.fold([], (fold, add)=>fold..addAll(add));

  @override
  Map<String, List<CPO>> namedLayers = {};
  
  @override
  List<CPO> get simpleLayers => namedLayers.putIfAbsent('default-simple', ()=>[]);
  
}

typedef CPOLayerValueRecord = (int weight, NamedGroupCPO? value);
typedef CPOGetter = CPO Function();

class NamedGroupCPO{
  final String name;
  final bool isGroup;
  final CPO cpo;
  final CPOGetter cpoGetter;
  final String? father;
  const NamedGroupCPO({this.name = 'default', required this.cpo, required this.cpoGetter, this.father, this.isGroup = false});
  factory NamedGroupCPO.cpo({required String name, required CPO value, String? father})=>NamedGroupCPO(name: name, cpo: value, cpoGetter: ()=>value, father: father);
  factory NamedGroupCPO.getter({required String name, required CPOGetter value})=>NamedGroupCPO(name: name, cpo: value(), cpoGetter: value);
  factory NamedGroupCPO.copy({required NamedGroupCPO copy})=>NamedGroupCPO(name: copy.name, cpo: copy.cpo, cpoGetter: copy.cpoGetter, father: copy.father);
}


/// v0.1.0暂时不启用
// class NamedGroupCPOLayerContext extends LayerContext with ListLayerCommitImpl{
//   final Map<String,  List<CPOLayerValueRecord>> map;
//   NamedGroupCPOLayerContext({this.map = const {}});

//   List<CPOLayerValueRecord> get records => map.values.fold<List<CPOLayerValueRecord>>([], (combine, next)=>combine ..addAll(next));
  
//   List<CPOLayerValueRecord> get ordered => records..sort((a, b) => a.$1 - b.$1);

//   List<CPOLayerValueRecord> get reversed => records..sort((a, b) => b.$1 - a.$1);

//   List<NamedGroupCPO> get named => ordered.fold<List<NamedGroupCPO>>([], (result, record)=>record.$2 != null ? [...result, record.$2!] : result);

//   List<NamedGroupCPO> get reversedNamed => reversed.fold<List<NamedGroupCPO>>([], (result, record)=>record.$2 != null ? [...result, record.$2!] : result);
  
//   /// 同时使用 simple 和 named 两套机制方便过渡
//   @override
//   List<CPO> get layers => simpleLayers.isNotEmpty ? simpleLayers : named.map((named)=>named.cpoGetter()).toList();
  
//   List<CPO> get reversedLayers => reversedNamed.map((named)=>named.cpoGetter()).toList();
  
//   void updateCreateGroup(String groupName, int groupBaseWeight){
//     assert(groupBaseWeight != -1);
//     map.update(groupName, (exist)=>[(groupBaseWeight, null), ...exist.sublist(1)], ifAbsent: ()=>[(groupBaseWeight, null)]);
//   }

//   void clearCreateGroup(String groupName, int groupBaseWeight){
//     assert(groupBaseWeight != -1);
//     map.update(groupName, (_)=>[(groupBaseWeight, null)], ifAbsent: ()=>[(groupBaseWeight, null)]);
//   }

//   void updateAddGroupItem(String groupName, NamedGroupCPO ngCPO, [int weight = -1 ]){
//     weightNGWrapped(NamedGroupCPO ngCPO){
//       return weight != - 1 ? (weight, ngCPO) : (nextWeight(groupName), ngCPO);
//     }
//     map.update(groupName, (exist){
//       int indexExist;
//       if((indexExist = exist.indexWhere((test)=>test.$2?.name == ngCPO.name))!=-1){
//         exist.fillRange(indexExist, indexExist + 1, weightNGWrapped(ngCPO));
//       }else{
//         exist.add(weightNGWrapped(ngCPO));
//       }
//       return exist;
//     }, ifAbsent: ()=>[weightNGWrapped(ngCPO)]);
//   }
  
//   void updateAddDefaultItem(NamedGroupCPO ngCPO, [int weight = -1]){
//     return updateAddGroupItem(DEFAULT_GROUP_NAME, ngCPO, weight);
//   }

//   bool addGroup(String groupName, NamedGroupCPO ngCPO, [int weight = -1 ]){
//     bool containsKey;
//     if(containsKey = map.containsKey(groupName)){
//       if(weight != -1){
//         map[groupName]!.add((weight, ngCPO));
//       }else{
//         map[groupName]!.add((nextWeight(groupName), ngCPO));
//       }
//     }else{
//       clearCreateGroup(groupName, weight);
//       map[groupName]!.add((weight, ngCPO));
//     }
//     return containsKey; 
//   }

//   bool addToDefault(NamedGroupCPO ngCPO){
//     return addGroup(DEFAULT_GROUP_NAME, ngCPO);
//   }

//   int groupWeight(String groupName){
//     return map.containsKey(groupName) && map[groupName]!.isNotEmpty ?  map[groupName]![0].$1 : -1;
//   }

//   int nextWeight(String groupName){
//     assert(map.containsKey(groupName) && map[groupName]!.isNotEmpty);
//     return map[groupName]!.last.$1 + 1;
//   }
  
//   @override
//   List<CPO> simpleLayers = [];
  
// }