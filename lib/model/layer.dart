import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'accessor.dart';
import 'context.dart';

// ignore: constant_identifier_names
const DEFAULT_GROUP_NAME = 'default';
typedef PainterCall = void Function(Canvas canvas, Size size);

abstract class ContextPainterObject extends CustomPainter{
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
    if(oldDelegate is CPO) return oldDelegate.paintRect != paintRect ;
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

abstract class LayerContext extends BaseContext{
  List<CPO> get layers;
  NamedGroupCPOLayerContext get group => this as NamedGroupCPOLayerContext;
}

class SimpleLayerContext extends LayerContext{
  @override
  final List<CPO> layers;
  SimpleLayerContext({this.layers = const []});
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

class NamedGroupCPOLayerContext extends LayerContext{
  final Map<String,  List<CPOLayerValueRecord>> map;
  NamedGroupCPOLayerContext({this.map = const {}});

  List<CPOLayerValueRecord> get records => map.values.fold<List<CPOLayerValueRecord>>([], (combine, next)=>combine ..addAll(next));
  
  List<CPOLayerValueRecord> get ordered => records..sort((a, b) => a.$1 - b.$1);

  List<CPOLayerValueRecord> get reversed => records..sort((a, b) => b.$1 - a.$1);

  List<NamedGroupCPO> get named => ordered.fold<List<NamedGroupCPO>>([], (result, record)=>record.$2 != null ? [...result, record.$2!] : result);

  List<NamedGroupCPO> get reversedNamed => reversed.fold<List<NamedGroupCPO>>([], (result, record)=>record.$2 != null ? [...result, record.$2!] : result);
  
  @override
  List<CPO> get layers => named.map((named)=>named.cpoGetter()).toList();
  
  List<CPO> get reversedLayers => reversedNamed.map((named)=>named.cpoGetter()).toList();
  
  void updateCreateGroup(String groupName, int groupBaseWeight){
    assert(groupBaseWeight != -1);
    map.update(groupName, (exist)=>[(groupBaseWeight, null), ...exist.sublist(1)], ifAbsent: ()=>[(groupBaseWeight, null)]);
  }

  void clearCreateGroup(String groupName, int groupBaseWeight){
    assert(groupBaseWeight != -1);
    map.update(groupName, (_)=>[(groupBaseWeight, null)], ifAbsent: ()=>[(groupBaseWeight, null)]);
  }

  void updateAddGroupItem(String groupName, NamedGroupCPO ngCPO, [int weight = -1 ]){
    weightNGWrapped(NamedGroupCPO ngCPO){
      return weight != - 1 ? (weight, ngCPO) : (nextWeight(groupName), ngCPO);
    }
    map.update(groupName, (exist){
      int indexExist;
      if((indexExist = exist.indexWhere((test)=>test.$2?.name == ngCPO.name))!=-1){
        exist.fillRange(indexExist, indexExist + 1, weightNGWrapped(ngCPO));
      }else{
        exist.add(weightNGWrapped(ngCPO));
      }
      return exist;
    }, ifAbsent: ()=>[weightNGWrapped(ngCPO)]);
  }
  
  void updateAddDefaultItem(NamedGroupCPO ngCPO, [int weight = -1]){
    return updateAddGroupItem(DEFAULT_GROUP_NAME, ngCPO, weight);
  }

  bool addGroup(String groupName, NamedGroupCPO ngCPO, [int weight = -1 ]){
    bool containsKey;
    if(containsKey = map.containsKey(groupName)){
      if(weight != -1){
        map[groupName]!.add((weight, ngCPO));
      }else{
        map[groupName]!.add((nextWeight(groupName), ngCPO));
      }
    }else{
      clearCreateGroup(groupName, weight);
      map[groupName]!.add((weight, ngCPO));
    }
    return containsKey; 
  }

  bool addToDefault(NamedGroupCPO ngCPO){
    return addGroup(DEFAULT_GROUP_NAME, ngCPO);
  }

  int groupWeight(String groupName){
    return map.containsKey(groupName) && map[groupName]!.isNotEmpty ?  map[groupName]![0].$1 : -1;
  }

  int nextWeight(String groupName){
    assert(map.containsKey(groupName) && map[groupName]!.isNotEmpty);
    return map[groupName]!.last.$1 + 1;
  }
}