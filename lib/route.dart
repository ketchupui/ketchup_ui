
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'model/accessor.dart';
import 'model/screen.dart';
import 'state.dart';

// typedef WeightGetter = int Function(int columns, bool isNewPage, int newPageClass, [ScreenPT]);

typedef KetchupRoutePageBuilder = KetchupRoutePage Function();

abstract class PageLifeCycle{
  void onReceive(Map<String, String>? params);
  void onCreate();
  void onResume();
  void onScreenWillChange(ScreenPT willChangePT);
  AnimationController willPlayAnimated({required ScreenPT? from,required ScreenPT to});
  void onMeasured(ScreenContext screen);
  void onPause();
  void onDestroy();
}

/// 带有生命周期的页面
abstract mixin class KetchupRoutePage implements PageLifeCycle{
  void onStateInit(void Function(VoidCallback c, [String? d]) stateUpdater);
  List<Widget>? screenBuild(BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT);
  Widget build(BuildContext context);
  
  @override
  AnimationController willPlayAnimated({ScreenPT? from, required ScreenPT to, AnimationController? animCtr}) {
    // TODO: implement willPlayAnimated
    throw UnimplementedError();
  }
}

enum PathType { 
  root, dynamic, static, wildcard
}

class SepPath{
  final PathType type;
  bool get isRoot => type == PathType.root;
  bool get isDynamic => type == PathType.dynamic;
  bool get isWildcard => type == PathType.wildcard;
  final String? name;
  const SepPath(this.name, this.type);
}

List<SepPath> parsePath(String path){
  if(path.isEmpty) return [];
  // if(path == '/') return [SepPath(null, PathType.root)];
  return path.split('/').map((sep){
    if(sep.isEmpty) {
      return SepPath(null, PathType.root);
    } else if(sep.startsWith('*')) {
      return SepPath(sep.substring(1), PathType.wildcard);
    } else if(sep.startsWith(':')) {
      return SepPath(sep.substring(1), PathType.dynamic);
    } else {
      return SepPath(sep, PathType.static);
    }
  }).toList();
}

Map<String, String> parseQuery(String query){
  if(query.isEmpty) return {};
  return Map.fromEntries(query.split('&').map<MapEntry<String,String>>((kv){
    var kvPair = kv.split('=');
    return MapEntry(kvPair[0], kvPair.length > 1 ? kvPair[1] : '');
  }));
}

// ignore: must_be_immutable
class KetchupRoute extends GoRoute{
  // final List<WeightPattern>? screenContextMatches;  
  // String get pureRoute => (path.split('/') ..removeLast()).join('/');
  List<SepPath> get separates => parsePath(path);
  // bool get hasParams => !path.endsWith('/');

  final KetchupRoutePageBuilder? ketchupPageBuilder;

  @override
  List<KetchupRoute> get routes => super.routes.cast<KetchupRoute>();
  
  KetchupRoute({required super.path, this.ketchupPageBuilder, GoRouterWidgetBuilder? builder, super.pageBuilder, super.routes}): super(builder: builder ?? (context, state) => ketchupPageBuilder!().build(context),) ;
}

class KetchupResponsiveMatchRouteSetting extends StatefulWidget{
  final List<ResponsiveValueGroup>? responses;
  final Key? ketchupKey;
  final HandsetValueGroup init;
  final ResponseAdaptiveCallback? cb;

  final List<RouteBase> routes;
  final WidgetsBuilder? widgetsBuilder;

  const KetchupResponsiveMatchRouteSetting({super.key, this.widgetsBuilder, this.ketchupKey, required this.routes, this.responses,required this.init, this.cb});

  @override
  State<StatefulWidget> createState()=> _KetchupResponsiveMatchRouteSettingState();
  
}

class _KetchupResponsiveMatchRouteSettingState extends State<KetchupResponsiveMatchRouteSetting>{
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KetchupUIResponsive(
          widgetsBuilder: widget.widgetsBuilder,
          init: widget.init,
          ketchupKey: widget.ketchupKey,
          cb: widget.cb,
          responses: widget.responses ?? [
            (category: CATEGORY.mobile_gesture, fromExcludeSizeRatio: double.negativeInfinity, toIncludeSizeRatio: 9/19, rowColumn: (row: 1, column: 1), singleAspectRatio: null, tailColumnExpand: TailColumnExpand.none),
            (category: CATEGORY.mobile_gesture, fromExcludeSizeRatio: 9/19, toIncludeSizeRatio: 9/16, rowColumn: (row: 1, column: 1), singleAspectRatio: Size(9, 19), tailColumnExpand: TailColumnExpand.none),
            (category: CATEGORY.mobile_gesture, fromExcludeSizeRatio: 9/16, toIncludeSizeRatio: 2 * 9/19, rowColumn: (row: 1, column: 1), singleAspectRatio : Size(9, 16), tailColumnExpand: TailColumnExpand.none),
            (category: CATEGORY.mobile_gesture, fromExcludeSizeRatio: 2 * 9/19, toIncludeSizeRatio: 2 * 9/16, rowColumn: (row: 1, column: 2), singleAspectRatio: Size(9, 19), tailColumnExpand: TailColumnExpand.none),
            (category: CATEGORY.tv_gamepad, fromExcludeSizeRatio: 2 * 9/16, toIncludeSizeRatio: 3 * 9/19, rowColumn: (row: 1, column: 2), singleAspectRatio: Size(9, 16), tailColumnExpand: TailColumnExpand.none),
            (category: CATEGORY.mobile_gesture, fromExcludeSizeRatio: 3 * 9/19, toIncludeSizeRatio: 3 * 9/16, rowColumn: (row: 1, column: 3), singleAspectRatio: Size(9, 19), tailColumnExpand: TailColumnExpand.none),
            (category: CATEGORY.tv_gamepad, fromExcludeSizeRatio: 3 * 9/16, toIncludeSizeRatio: 4 * 9/16, rowColumn: (row: 1, column: 3), singleAspectRatio: Size(9, 16), tailColumnExpand: TailColumnExpand.none),
            (category: CATEGORY.tv_gamepad, fromExcludeSizeRatio: 4 * 9/16, toIncludeSizeRatio: 5 * 9/16, rowColumn: (row: 1, column: 4), singleAspectRatio: Size(9, 16), tailColumnExpand: TailColumnExpand.none),
            (category: CATEGORY.tv_gamepad, fromExcludeSizeRatio: 5 * 9/16, toIncludeSizeRatio: 2 * 16 / 9, rowColumn: (row: 1, column: 5), singleAspectRatio: Size(9, 16),tailColumnExpand: TailColumnExpand.none),
            (category: CATEGORY.pc_mousekeyboard, fromExcludeSizeRatio: 2 * 16 / 9, toIncludeSizeRatio: double.infinity, rowColumn: (row: 1, column: 2), singleAspectRatio: Size(16, 9),tailColumnExpand: TailColumnExpand.none),
        ])
    );
  }

  @override
  void initState() {
    super.initState();
    
  }
  
}