import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../debug/console.dart';
import '../ketchup_ui.dart';
import 'page_builder.dart';
import 'utils.dart';

class CachePage with MultiColumns{
  ScreenPT? screenPT;
  final String? onCreatePath;
  // final KetchupRoute route;
  final KetchupRoutePage? page;
  CachePage({ this.page, this.onCreatePath, this.screenPT });

  bool get isBlank => page == null;
  factory CachePage.blank()=>CachePage();
  factory CachePage.pathPage(String onCreatePath, KetchupRoutePage page)=>CachePage(onCreatePath: onCreatePath, page: page);
  factory CachePage.nopathPage(KetchupRoutePage page)=>CachePage(page: page);
  factory CachePage.changePT(CachePage cache, ScreenPT screenPT)=>CachePage(screenPT: screenPT, onCreatePath: cache.onCreatePath, page: cache.page);
  
  @override
  List<int> get availableColumns => page is MultiColumns ? (page as MultiColumns).availableColumns : [1];
  
}

typedef PageClassCache = (int pageClass, int columns, CachePage?);




typedef NavPair<T> = (int, int, T);
typedef NavPairList<T> = List<NavPair<T>>;
typedef NavCtntPair<T> = (NavPairList<T>, NavPairList<T>);

typedef BuiltPageTest<T> = bool Function(T);
typedef BuiltPageTestBuilder<T> = BuiltPageTest<T> Function(String);

typedef SingleAvbCol = List<int>;
typedef ExpandAvbPtns = List<double>;

abstract class NavigatorCore<T extends MultiColumns> with vConsole {
  int get contentPageClass;
  int get screenColumn;

  /// 非连续内容扩展算法 https://immvpc32u2.feishu.cn/docx/SlLddeDrJoCW9ox4igYcPNSTnSd?from=from_copylink
  NavCtntPair<T> expand(NavCtntPair<T> currentPages){
    NavPairList<T> navigates = currentPages.$1;
    NavPairList<T> contents = currentPages.$2;
    // var current = [...navigates, ...contents ];
    // var currentColumnsNum = current.fold<int>(0, (count, item)=>count + item.$2);

    List<SingleAvbCol> navigatesExpandables = indexedExpAvbCols(navigates); 
    List<SingleAvbCol> contentsExpandables = indexedExpAvbCols(contents);
    //// 没有任何扩展性 返回原值
    if(navigatesExpandables.isEmpty && contentsExpandables.isEmpty) return currentPages;
    // var expandColumnsNum = screenColumn - currentColumnsNum;

    /// 内容从新到旧
    /// [3,2,1][4,2][3,1] 变成 [3,4,3][3,4,1][3,2,3][3,2,1][2,4,3][2,4,1]...
    List<ExpandAvbPtns> recursiveCombine(List<SingleAvbCol> r){
      assert(r.isNotEmpty);
      if(r.length == 1) {
        /// 拆包最后一个 SingleAvbCol
        return r.single.map<ExpandAvbPtns>((int col)=> [ col.toDouble() ] ).toList();
      } else if(r.length > 1){
        /// 拆包第一个 SingleAvbCol
        SingleAvbCol first = r.first;
        List<ExpandAvbPtns> rest = recursiveCombine(r..removeAt(0));
        return first.expand<ExpandAvbPtns>((int putF)=> rest.map<ExpandAvbPtns>((ExpandAvbPtns restPtn)=>[ putF.toDouble(), ...restPtn])).toList();
      } else {
        return [<double>[]];
      }
    }

    ExpandAvbPtns target = recursiveCombine([ ...contentsExpandables, ...navigatesExpandables.reversed ]).firstWhere((ExpandAvbPtns test){
      return test.sum <= screenColumn;
    });

    var navColumns = target.sublist(contentsExpandables.length).reversed.toList();
    var ctnColumns = target.sublist(0, contentsExpandables.length);

    return (navigates.mapIndexed((i, nav)=>(nav.$1, navColumns[i].toInt(), nav.$3)).toList(), 
            contents.mapIndexed((i, ctn)=>(ctn.$1, ctnColumns[i].toInt(), ctn.$3)).toList());
  }

  List<SingleAvbCol> indexedExpAvbCols(NavPairList<T> nav) => nav.map((ctn)=>availableColumns(ctn.$3.availableColumns, ctn.$1, ctn.$2)).toList();

  String expandString(NavCtntPair<T> currentPages) => expand(currentPages).toString();

  (NavCtntPair<T>, NavPairList<T>) shiftExpand(NavCtntPair<T> currentPages, NavPair<T> insertPage){
    var shiftPair = shift(currentPages, insertPage);
    return (expand(shiftPair.$1), shiftPair.$2);
  }

  String shiftExpandString(NavCtntPair<T> currentPages, NavPair<T> insertPage)=>shiftExpand(currentPages, insertPage).$1.toString();

  (NavCtntPair<T>, NavPairList<T>) shift(NavCtntPair<T> currentPages, NavPair<T> insertPage){
    var navigates = currentPages.$1;
    var contents = currentPages.$2;
    var insertPageClass = insertPage.$1;
    var newColumnNumber = insertPage.$2;
    var isContentPage = insertPage.$1 <= contentPageClass;
    NavPairList<T> removeList = [];
    var newpageInsertStartIndex = !isContentPage ?  navigates.indexWhere((page)=>insertPageClass >= page.$1) : -1;

    // List<int, int, T?> mapDecline(List<int, int, T?> willMap, ){
    //   return willMap.map((item){
    //       if(willFoldColumnNumber > 0){
    //         willFoldColumnNumber --;
    //         return (item.$1, item.$2 - 1, item.$3);
    //       } else {
    //         return item;
    //       }
    //     }).toList();
    // }
    
    //// https://immvpc32u2.feishu.cn/docx/R427dV9WbonppxxMv1xc1Jt4n8c#share-HA0odkwJsoOSmYxTx0ZcK4MfnLf
    //// 剔除算法
    if(newpageInsertStartIndex != -1){
      removeList.addAll(navigates.getRange(newpageInsertStartIndex, navigates.length));
      navigates.removeRange(newpageInsertStartIndex, navigates.length);
    }

    var current = [...navigates, ...contents ];
    int currentColumnsNum = current.fold<int>(0, (count, item)=>count + item.$2);
    /// 逻辑最小和逻辑最大不一定可用
    // int foldedColumnsNum = current.length;
    // int expandColumnsNum = current.fold(0, (count, item)=>count + item.$1);
    int foldedColumnsNum = current.fold<int>(0, (count, item)=>count + (availableColumns(item.$3.availableColumns, item.$1).lastOrNull ?? item.$2));
    
    // int minExpandNum = current.map((item){
    //   var next = nextColumnLess(item.$3.availableColumns, item.$2 + 1, item.$1);
    //   return next != null ? next - item.$2 : -1;
    // }).where((i)=>i > 0).sorted((a, b)=>b.compareTo(a)).lastOrNull ?? 0;
    // bool canExpand = minExpandNum > 0;
    // int expandMinColumnsNum = currentColumnsNum + minExpandNum;
    // int expandMaxColumnsNum = current.fold<int>(0, (count, item)=>count + (availableColumns(item.$3.availableColumns, item.$1).firstOrNull ?? item.$2));
    
    /// 
    if(newColumnNumber + foldedColumnsNum >= screenColumn){
      var count = newColumnNumber + foldedColumnsNum - screenColumn;
      if(count > 0){
        var popIndex = contents.length - count;
        /// 执行退栈
        removeList.addAll(contents.getRange(popIndex, contents.length));
        contents.removeRange(popIndex, contents.length);
      }
      /// 执行最大折叠
      // navigates = navigates.map((willFold)=>(willFold.$1, 1, willFold.$3)).toList();
      // contents = contents.map((willFold)=>(willFold.$1, 1, willFold.$3)).toList();
      navigates = navigates.map((willFold)=>(willFold.$1, availableColumns(willFold.$3.availableColumns, willFold.$1).last, willFold.$3)).toList();
      contents = contents.map((willFold)=>(willFold.$1, availableColumns(willFold.$3.availableColumns, willFold.$1).last, willFold.$3)).toList();
    }else
    if(newColumnNumber + currentColumnsNum > screenColumn){
      /// 执行折叠算法-决定折叠谁 叠多少(必然有没折叠的)
      var willFoldColumnNumber = newColumnNumber + currentColumnsNum - screenColumn;
      /// 先将导航栈按照从大到小折叠，再将内容栈从旧到新折叠(逐一折叠：一次折一列(不一定是一列但最少是一列))
      while(willFoldColumnNumber > 0){
        navigates = navigates.map((nv){
          var next = nextColumnLess(nv.$3.availableColumns, nv.$2, nv.$1);
          if(willFoldColumnNumber > 0 && next != null){
          // if(willFoldColumnNumber > 0 && nv.$2 > 1){
            // willFoldColumnNumber --;
            // return (nv.$1, nv.$2 - 1, nv.$3);
            willFoldColumnNumber -= nv.$2 - next;
            return (nv.$1, next, nv.$3);
          } else {
            return nv;
          }
        }).toList();
        if(willFoldColumnNumber > 0){
          contents = contents.reversed.map((ct){
            var next = nextColumnLess(ct.$3.availableColumns, ct.$2, ct.$1);
            if(willFoldColumnNumber > 0 && next != null){
            // if(willFoldColumnNumber > 0 && ct.$2 > 1){
              // willFoldColumnNumber --;
              // return (ct.$1, ct.$2 - 1, ct.$3);
              willFoldColumnNumber -= ct.$2 - next;
              return (ct.$1, next, ct.$3);
            } else {
              return ct;
            }
          }).toList().reversed.toList();
        }
      }
    }
    // else
    // /// 扩展算法有个前提： 最小扩展 > 0 最小扩展栏目数 <= screenColumn 
    // if(newColumnNumber + currentColumnsNum < screenColumn && canExpand && expandMinColumnsNum <= screenColumn){
    //   /// 内容扩展算法(同时受到 可以展开的最大值 和 屏幕最大值两个限制)
    //   var willExpandColumnNumber = min(screenColumn - newColumnNumber - currentColumnsNum, expandMaxColumnsNum - currentColumnsNum);
    //   /// 先将内容栈按照从新到旧扩展，再从导航栈按照从小到大扩展
    //   while(willExpandColumnNumber > 0){
    //     contents = contents.map((ct){
    //       if(willExpandColumnNumber > 0 && ct.$2 <= ct.$1){
    //         willExpandColumnNumber --;
    //         return (ct.$1, ct.$2 + 1, ct.$3);
    //       } else {
    //         return ct;
    //       }
    //     }).toList();
    //     if(willExpandColumnNumber > 0){
    //       navigates = navigates.reversed.map((nv){
    //         if(willExpandColumnNumber > 0 && nv.$2 <= nv.$1){
    //           willExpandColumnNumber --;
    //           return (nv.$1, nv.$2 + 1, nv.$3);
    //         } else {
    //           return nv;
    //         }
    //       }).toList().reversed.toList();
    //     }
    //   }
    // }
    /// 插入元素
    if(isContentPage){
      return ((navigates, contents ..insert(0, insertPage)), removeList);
    }else
    if(newpageInsertStartIndex != -1){
      return ((navigates ..insert(newpageInsertStartIndex, insertPage), contents), removeList);
    }else{
      return ((navigates ..add(insertPage), contents), removeList);
    }
  }
  
  String shiftString(NavCtntPair<T> currentPages, NavPair<T> insertPage) => shift(currentPages, insertPage).$1.toString();

  // @override
  // String toString([NavCtntPair<T>? pair]) {
  //   if(pair != null) return '${pair.$1.toString()},${pair.$2.toString()}';
  //   return super.toString();
  // }
}

class NavigatorCoreTester<T extends MultiColumns> extends NavigatorCore<T>{

  NavigatorCoreTester({required this.contentPageClass, required this.screenColumn});

  @override
  int contentPageClass;

  @override
  int screenColumn;
}

abstract class Expandable{
  //// Expand 类动作 影响页面布局(onScreenChanged) 部分影响生命周期
  void expandRightStep();
  void expandLeftStep();
  void expandRightFull();
  void expandLeftFull();
  void expandFullscreen();
}

mixin RouteFinder {
  List<KetchupRoute> get routes;
  
  String? get currentRoute;
   
  (KetchupRoute, Map<String, String>)? _find(List<String> splits, {KetchupRoute? root, Map<String, String>? param, int level = 1}){
    var params = param ?? {};
    for(var route in (root?.routes ?? routes)){
      var count = route.separates.length;
      var nextIndex = count; /// 如果匹配默认截断数量
      /// match 规则
      if(splits.length >= count && route.separates.indexed.every((sep){
          switch(sep.$2.type){
            case PathType.root:
              return splits[sep.$1] == '';
            case PathType.static:
              return splits[sep.$1] == sep.$2.name;
            case PathType.dynamic:
              params[sep.$2.name!] = splits[sep.$1];
              return true;
            case PathType.wildcard:
              nextIndex = splits.length;
              params[sep.$2.name!] = splits.sublist(sep.$1).join('/');
              return true;
          }
        })){
          /// 终局
          if(nextIndex == splits.length){
            return (route, { ...params, '_level': level.toString(), '_matched': route.path, '_debug': '$level->${route.path}' } );
          }else
          /// 递归
          if(nextIndex >=0 && nextIndex < splits.length){
            var result = _find(splits.sublist(nextIndex), root: route, param: params, level: level + 1);
            if(result != null) return result;
          }
      }
    }
    return null;
  }
  
  (KetchupRoute, Map<String, String>)? find(String routeParams){
    int queryIndex = routeParams.indexOf('?');
    int hashIndex = routeParams.indexOf('#');
    String pathString = routeParams.substring(0, queryIndex != -1 ? queryIndex : (hashIndex != -1 ? hashIndex : routeParams.length));
    String queryString = queryIndex != -1 ? routeParams.substring(queryIndex + 1, hashIndex != -1 ? hashIndex : routeParams.length) : '';
    String hashString = hashIndex != -1 ? routeParams.substring(hashIndex + 1) : '';
    return _find( 
      pathString.split('/'), 
      param: { '_path': routeParams, '_hash': hashString, ...parseQuery(queryString) });
  }
}

class RouteFinderTester with RouteFinder{

  RouteFinderTester(this.routes);

  @override
  String? get currentRoute => '';

  @override
  List<KetchupRoute> routes;
    
}

abstract class HistoryCachedNavigaterBuilder extends NavigatorCore<CachePage> with RouteFinder implements ContextAccessor{

  //// 历史记录
  List<String> __historyRoutes = [];
  
  //// 前进记录
  List<String> __forwardRoutes = [];

  /// (二级)缓存页面 (path->route->page)
  /// 有数据 表示查询过
  Map<String, (KetchupRoute, Map<String, String>)> __cachePathRoutes = {};
  /// 有数据表示可以使用 cachePage
  /// 没有数据可能有页面正在展示，需要从 KetchupRoute 重新创建一个 CachePage(相同页面多个Tab页，页面克隆)
  Map<String, CachePage> __cachePathPages = {};

  NavCtntPair<CachePage> __currentPair = ([],[]);

  void clear(){
      __historyRoutes.clear();
      __forwardRoutes.clear();
      __cachePathPages.clear();
      __cachePathRoutes.clear();
      __currentPair.$2.clear();
      __currentPair.$1.clear();
  }

  NavPairList<CachePage> get currentNavPairList => [ ...__currentPair.$1, ...__currentPair.$2 ];

  @override
  String? currentRoute;


  List<CachePage> get currentCachePages => currentNavPairList.map((cache)=>cache.$3).toList();

  List<int> get currentColumnsLR => currentNavPairList.map((cache)=>cache.$2).toList();

  String? get currentContextPT => screen.genContextPTColumnsLR(currentColumnsLR);

  List<String>? get currentScreenPTs => ScreenContext.genScreenPTColumnsLR(currentColumnsLR, screen.column);

  Iterable<P> findBuiltPages<P>({BuiltPageTest<P>? test, bool includeCache = true}){
    Iterable<P> res = (<CachePage>[]..addAll(currentCachePages) ..addAll(includeCache ? __cachePathPages.values : []))
    .map<KetchupRoutePage?>((cache)=>cache.page)
    .whereType<P>();
    if(test != null){
      return res.where(test);
    } else {
      return res;
    }
  }

  /// 重要函数(查找当前或者内存页面)
  P? findBuiltPage<P>(BuiltPageTest<P?> test, {bool includeCache = true}){
    return (<CachePage>[]..addAll(currentCachePages) ..addAll(includeCache ? __cachePathPages.values : []))
    .map<KetchupRoutePage?>((cache)=>cache.page)
    .whereType<P?>()
    .firstWhere(test, orElse: () => null,);
  }

  // List<CachePage> get currentCachePages => [ ...__currentPair.$1, ...__currentPair.$2 ].map((cache)=>cache.$3).toList();

  @override
  int get screenColumn => screen.column;

  List<T> type<T>([bool includeCache = false]){
    return (currentCachePages ..addAll(includeCache ? __cachePathPages.values : [])).map((cache)=>cache.page).whereType<T>().toList();
  }

  void go(String route){
  }

  void push(String route){
    if(currentRoute != null){
      __historyRoutes.add(currentRoute!);
    }
    __forwardRoutes.clear();
    _innerGoNoHistory(currentRoute = route, 'nav.push');
  }

  void animPush(String route, AnimationController animCtrl){
    if(currentRoute != null){
      __historyRoutes.add(currentRoute!);
    }
    __forwardRoutes.clear();
    _innerGoNoHistory(currentRoute = route, 'nav.animPush', animCtrl);
  }

  void replace(String route){
    __forwardRoutes.clear;
    _innerGoNoHistory(currentRoute = route, 'nav.replace');
  }

  /// 将指定页面扩展到最大
  void animateExpandMax(){
    
  }
  /// 情况1：主动，缓存没有,当前没有，新建并执行 onCreate(routeParams) - onResume() 
  /// 情况2：主动，缓存有，当前没有，由于 back 或者再次执行相同跳转，则从缓存中取出并执行 onResume()
  /// 情况3：主动，缓存没有，当前有，不需要换位置和扩张，什么也不做
  /// 情况4：主动，缓存没有，当前有，需要换位置或扩张，取出当前并执行 onScreenWillChange - onScreenChanged
  /// 情况5：被动，当前有，缓存没有，由于 back 或 go操作权重不够被挤入缓存，执行 onPause()
  /// 情况6：被动，当前有，权重不够或者处于权重策略需要换位置或收缩，取出当前并执行 onScreenWillChange - onScreenChanged
  /// 情况7：被动，当前没有，缓存有，由于缓存已满，被迫剔除缓存前 执行 onDestroy()
  /// 情况8：被动，当前有，缓存没有，由于 replace 操作对当前界面进行了删除，没有进入缓存和历史栈，执行 onPause() - onDestroy()
  void _innerGoNoHistory(String path, [String? debugInfo, AnimationController? animCtrl]){
    var routeParam = __cachePathRoutes[path] ?? find(path);
    if(routeParam != null){
      __cachePathRoutes[path] = routeParam;
      KetchupRoute route = routeParam.$1;
      Map<String,String> param = routeParam.$2;
      int pageClass = screen.column - (int.tryParse(param['_level'] ?? '1') ?? 1) + 1;
      int targetColumn = pageClass;
      CachePage? cachePage = __cachePathPages.remove(path);
      bool isFromCache = cachePage != null;
      if(!isFromCache){
        cachePage = CachePage.pathPage(path, route.ketchupPageBuilder!());
      }
      // cachePage.page?.onReceive({ ...param, '_pageClass': pageClass.toString(), '_fromCache': isFromCache.toString() });

      _innerGoPageReadyWillReceive(cachePage,
        cachePage.page!, path, { ...param, '_pageClass': pageClass.toString(), '_fromCache': isFromCache.toString() }, pageClass, targetColumn, isFromCache, debugInfo, animCtrl );
    }
  }

  void _innerGoPageReadyWillReceive(CachePage? cachePage, KetchupRoutePage page, String? path, Map<String, String>? onRecieveParams, int pageClass, int targetColumn, bool shouldCallResume, [String? debugInfo, AnimationController? animCtrl]){
    page.onReceive(onRecieveParams);
    /// NavigatorPage 和 NavigatorPageWidget 是两个类
    if(page is MultiColumns){
      print('param:$onRecieveParams');
      print('pageClass:$pageClass');
      print('availableColumns:${(page as MultiColumns).availableColumns}');
      targetColumn = availableColumns((page as MultiColumns).availableColumns, pageClass).first;
    }

    var willReplacePair = shiftExpand(__currentPair, (pageClass, targetColumn, cachePage ?? CachePage.nopathPage(page)));
    for (var rElement in willReplacePair.$2) {
      rElement.$3.page?.onPause();
      rElement.$3.screenPT = null;
      final onCreatePath = rElement.$3.onCreatePath;
      if(onCreatePath != null){
        __cachePathPages.update(onCreatePath, (already){
          already.page?.onDestroy();
          return rElement.$3;
        }, ifAbsent:()=>rElement.$3);
      }else{
        rElement.$3.page?.onDestroy();
      }
    }
    __currentPair = willReplacePair.$1;

    if(shouldCallResume){
      page.onResume();
    }else{
      page.onCreate();
    }

    var merged = mergeScreenPT<NavPair<CachePage>>(currentScreenPTs!, currentContextPT!, currentNavPairList);

    endCall(){
      lazyUpdate((){
        screen.currentPatternNullable = currentContextPT;
      },'$debugInfo=${path ?? 'nopath'}', (){
        for (var cache in currentCachePages) {
          cache.page!.onMeasured(screen);
        }
      });
    };

    List<AnimationStatusListener> listeners = [];
    AnimationStatusListener addListener(AnimationStatusListener listener){
      listeners.add(listener);
      return listener;
    }
    AnimationStatusListener removeFirst(){
      return listeners.removeAt(0);
    }
    for (var indexed in merged.indexed) {
      final oldScreenPT = indexed.$2.$2.$3.screenPT;
      if(oldScreenPT.toString() != indexed.$2.$1.toString()){
        indexed.$2.$2.$3.page?.onScreenWillChange(indexed.$2.$1);
        indexed.$2.$2.$3.screenPT = indexed.$2.$1;
        
        /// 5月26日 新增-页面跳转动画 Hook 第一个结束动画就触发 onMeasured
        if(animCtrl != null && indexed.$2.$2.$3.page != null){
          final anim = indexed.$2.$2.$3.page!.willPlayAnimated(fromPT: oldScreenPT, toPT: indexed.$2.$1, animCtrl: animCtrl);
          anim
            ..duration = Duration(milliseconds: 1300)
            ..addStatusListener(addListener((AnimationStatus status){
              if(status.isCompleted){
                animCtrl.removeStatusListener(removeFirst());
                if(listeners.isEmpty){
                  endCall();
                }
              }
            }))
            ..forward();
        }
      }
    }

    if(listeners.isEmpty){
      endCall();
    }
  }
  
  void nopathGo(int pageClass, int targetColumn, KetchupRoutePage page, {Map<String, String>? constructParams, String? debugInfo, AnimationController? animCtrl}){
    _innerGoPageReadyWillReceive(null, page, null, constructParams, pageClass, targetColumn, false, debugInfo, animCtrl);
    // page.onReceive(null);
    // if(page is MultiColumns){
    //     print('pageClass:$pageClass');
    //     print('availableColumns:${(page as MultiColumns).availableColumns}');
    //     targetColumn = availableColumns((page as MultiColumns).availableColumns, pageClass).first;
    //   }

    //   var willReplacePair = shiftExpand(__currentPair, (pageClass, targetColumn, CachePage.nopathPage(page)));
    //   for (var rElement in willReplacePair.$2) {
    //     rElement.$3.page?.onPause();
    //     rElement.$3.screenPT = null;
    //     __cachePathPages.update(rElement.$3.onCreatePath!, (already){
    //       already.page?.onDestroy();
    //       return rElement.$3;
    //     }, ifAbsent:()=>rElement.$3);
    //   }
    //   __currentPair = willReplacePair.$1;

    //   page.onCreate();

    //   var merged = mergeScreenPT<NavPair<CachePage>>(currentScreenPTs!, currentContextPT!, currentNavPairList);
    //   for (var indexed in merged.indexed) {
    //     if(indexed.$2.$2.$3.screenPT.toString() != indexed.$2.$1.toString()){
    //       indexed.$2.$2.$3.page?.onScreenWillChange(indexed.$2.$1);
    //       indexed.$2.$2.$3.screenPT = indexed.$2.$1;
    //     }
    //   }

    //   lazyUpdate((){
    //     screen.currentPatternNullable = currentContextPT;
    //   },'$debugInfo=nopath', (){
    //     for (var cache in currentCachePages) {
    //       cache.page!.onMeasured(screen);
    //     }
    //   });
  }
  // ignore: slash_for_doc_comments
  /**
   *  |-go(1) [] 1 []
      |-go(2) [1] 2 []
      |-go(3) [1,2] 3 []
      |-replace(4) [1,2] 4 []
      |-go(5) [1,2,4] 5 []
      |-go(6) [1,2,4,5] 6 []
      |-back() [1,2,4] 5 [6]
      |-back() [1,2] 4 [6,5]
        |-replace(7) [1,2] 7 []
        |-go(7) [1,2,4] 7 []
        |-forward() [1,2,4] 5 [6]
          |-forward() [1,2,4,5] 6 []
   */

  bool get canGoBack => __historyRoutes.isNotEmpty;
  void back(){
    if(canGoBack){
      var backRoute = __historyRoutes.removeLast();
      __forwardRoutes.add(currentRoute!);
      _innerGoNoHistory(currentRoute = backRoute);
    }
  }

  bool get canGoForward => __forwardRoutes.isNotEmpty;
  void forward(){
    if(canGoForward){
      var forwardRoute = __forwardRoutes.removeLast();
      __historyRoutes.add(currentRoute!);
      _innerGoNoHistory(currentRoute = forwardRoute);
    }
  }

  void onSizeChangeListener(Size newSize, Size? oldSize){
    WidgetsBinding.instance.addPostFrameCallback((Duration dt){
      WidgetsBinding.instance.addPostFrameCallback((Duration dt){
        for (var cache in currentCachePages) {
          cache.page?.onMeasured(screen);
        }
      });
    });
  }

  void initAfterScreenContext(){
    screen.addSizeChangeListener(onSizeChangeListener);
  }

  void dispose(){
    screen.removeSizeChangeListener(onSizeChangeListener);
  }

  WidgetsBuilder build(){
    return (BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT){
      if(currentScreenPTs != null){
        for(var cScreenPT in currentScreenPTs!.indexed){
          if((cScreenPT.$2, currentContextPT).toString() == screenPT.toString() && cScreenPT.$1 < currentCachePages.length){
            return currentCachePages[cScreenPT.$1].page?.screenBuild(context, ctxAccessor, screenPT);
          }
        }
        return null;
      }else{
        return null;
      }
    };
  }
  
}

class EmptyContextAccessorImp implements ContextAccessor{

  EmptyContextAccessorImp(this.screen);
  
  @override
  LayerContext get bgLayers => SimpleLayerContext();

  @override
  LayerContext get fgLayers => SimpleLayerContext();

  @override
  GridContext get grid => GridContext();

  @override
  ScreenContext screen;

  @override
  void lazyUpdate(VoidCallback c, [String? d, VoidCallback? updated]) {
    if(updated != null){
      updated();
    }
  }
  
  @override
  void Function(VoidCallback p1, [String? d]) get update => (VoidCallback p1, [String? d]){
  };
  
  @override
  Size get size => Size.zero;
  
}

class NavigaterBuilder extends HistoryCachedNavigaterBuilder{
  
  ContextAccessor ca;

  NavigaterBuilder({required this.ca, required this.contentPageClass, required this.routes });

  @override
  LayerContext get bgLayers => ca.bgLayers;

  @override
  int contentPageClass;

  @override
  LayerContext get fgLayers => ca.fgLayers;

  @override
  GridContext get grid => ca.grid;

  @override
  List<KetchupRoute> routes;

  @override
  ScreenContext get screen => ca.screen;

  @override
  void lazyUpdate(VoidCallback c, [String? d, VoidCallback? updated]) {
    return ca.lazyUpdate(c, d, updated);
  }
  
  @override
  void Function(VoidCallback p1, [String? d]) get update => ca.update;
  
  @override
  Size get size => ca.size;
  
}

mixin NavBuilder implements ContextAccessor{
  int get contentPageClass;
  List<KetchupRoute> get routes;
  NavigaterBuilder? _nav;
  NavigaterBuilder get nav => _nav ??= NavigaterBuilder(ca: this, contentPageClass: contentPageClass, routes: routes);
}