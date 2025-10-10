import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:ketchup_ui/animation.dart';
import 'package:ketchup_ui/nav/vscreen_state.dart';
import 'package:ketchup_ui/utils.dart';
import '../model/model.dart';
import '../model/screen/page_manager.dart';
import '../route.dart';
import '../state.dart';
import 'core.dart';
import 'route_finder.dart';
import 'utils.dart';

class PageCache with MultiColumns{
  ScreenPT? screenPT;
  final String? onCreatePath;
  final FocusRoutePage page;
  PageCache({required this.page, this.onCreatePath, this.screenPT });

  // bool get isBlank => page == null;
  // factory CachePage.blank()=>CachePage();
  factory PageCache.pathPage(String onCreatePath, FocusRoutePage page)=>PageCache(onCreatePath: onCreatePath, page: page);
  factory PageCache.nopathPage(FocusRoutePage page)=>PageCache(page: page);
  factory PageCache.changePT(PageCache cache, ScreenPT screenPT)=>PageCache(screenPT: screenPT, onCreatePath: cache.onCreatePath, page: cache.page);
  
  @override
  List<int> get availableColumns => page.availableColumns;
  
}

typedef PageClassColumnsCache = (int pageClass, int columns, PageCache?);

// typedef Navigatable<T> = (int, int, T);
// typedef NavigatableList<T> = List<Navigatable<T>>;
// typedef NavCtntPair<T> = (NavigatableList<T>, NavigatableList<T>);

typedef BuiltPageTest<T> = bool Function(T);
typedef BuiltPageTestBuilder<T> = BuiltPageTest<T> Function(String);

// typedef SingleAvbCol = List<int>;
// typedef ExpandAvbPtns = List<double>;

class IndexedIntentPage{
  final int column;
  final FocusRoutePage page;
  final Map<String, String>? recieveParams;
  const IndexedIntentPage(this.column, this.page, [this.recieveParams]);
}

abstract class Expandable{
  //// Expand 类动作 影响页面布局(onScreenChanged) 部分影响生命周期
  void expandRightStep();
  void expandLeftStep();
  void expandRightFull();
  void expandLeftFull();
  void expandFullscreen();
}

abstract class HistoryCacheInterface {
  bool get canGoBack;
  void back();
  bool get canGoForward;
  void forward();
}

abstract class BasicNavigatorBuilder extends NavigatorCore<PageCache>{

  BasicNavigatorBuilder({NavCtntPair<PageCache>? initPair}) : __currentPair = initPair ?? ([],[]);

  ScreenContext get screen;
  Map<String, PageCache>? get cachePathPages;

  @override
  int get screenColumn => screen.column;

  NavCtntPair<PageCache> __currentPair;
  NavCtntPair<PageCache> get currentPair => __currentPair;
  NavigatableList<PageCache> get currentNavPairList => [ ...__currentPair.$1, ...__currentPair.$2 ];
  List<PageCache> get currentCachePages => currentNavPairList.map((cache)=>cache.$3).toList();

  // Map<String, ScreenContext>? get currentVScreenMap {
  //   final ret = {};
  //   for(var cache in currentCachePages){
  //     if(cache.page is VScreenKetchupRoutePage){
  //       final cachePage = cache.page as VScreenKetchupRoutePage;
  //       if(cachePage.virtualScreen != null){
  //         ret.putIfAbsent(cachePage.vscreenState., ifAbsent)
  //       }
  //     }
  //   }
  //   return currentCachePages.where((cache)=>cache.page is VScreenKetchupRoutePage && cache.page).map<MapEntry>((VScreenKetchupRoutePage page)=>MapEntry(page.));
  // }

  List<int> get currentColumnsLR => currentNavPairList.map((cache)=>cache.$2).toList();
  String? get currentContextPT => screen.genContextPTColumnsLR(currentColumnsLR);
  List<String>? get currentScreenPTs => ScreenContext.genScreenPTColumnsLR(currentColumnsLR, 1, screen.column);

  void onColumnsChange(int screenColumn){
    adjustScreenColumnChangeWait();
  }
  
  void onMeasured(){
    navDebug('#$hashCode-nav.onMeasured');
    for (var cache in currentCachePages) {
      cache.page?.onMeasured(screen);
    }
  }

  void navUpdate(VoidCallback c, [String? d]);
  // void measureUpdate(VoidCallback c, [String? d, VoidCallback? afterUpdate]);

  void adjustScreenColumnChangeWait({ String? debugInfo, AnimationController? animCtrl })=>adjustScreenColumnChange(debugInfo: debugInfo, animCtrl: animCtrl, callUpdate: false);

  /// 适应屏幕栏目数调整{
  void adjustScreenColumnChange({ String? debugInfo, AnimationController? animCtrl, bool callUpdate = true,}){
    __currentPair = expandCollapse(__currentPair, screenColumn)!;
    _pageReceivedWillChangePT(null, debugInfo, animCtrl, callUpdate);
  }

  void currentPagesUnload(){
    for (var cache in currentCachePages) {
      cache.page?.onPause();
      cache.page?.onDestroy();
    }
  }

  void indexedGotoPagesWait({ List<IndexedIntentPage> intentsLR = const [], List<IndexedIntentPage> intentsRL = const [], AnimationController? animCtrl}) => indexedGotoPages(animCtrl: animCtrl, intentsLR: intentsLR, intentsRL: intentsRL, callUpdate: false);
  
  void indexedGotoPages({
    List<IndexedIntentPage> intentsLR = const [],
    List<IndexedIntentPage> intentsRL = const [],
    AnimationController? animCtrl, bool callUpdate = true}){
    currentPagesUnload();
    /// 忽略 contentPageClass
    final navList = intentsLR.mapIndexed<Navigatable<PageCache>>((index, intent)=>(screenColumn - index, intent.column,PageCache.nopathPage(intent.page..onReceive(intent.recieveParams)))).toList();
    /// 页面等级全部 = contentPageClass
    final ctnList = intentsRL.mapIndexed<Navigatable<PageCache>>((index, intent)=>(contentPageClass, intent.column,PageCache.nopathPage(intent.page..onReceive(intent.recieveParams)))).toList().reversed.toList();
    __currentPair = expandCollapse((navList, ctnList), screenColumn)!;
    for(final cache in currentCachePages){
      cache.page!.onCreate();
    }
    _pageReceivedWillChangePT(null, 'indexedIntents', animCtrl, callUpdate);
  }

  void directGotoPageWait(int pageClass, int targetColumn, FocusRoutePage page, {Map<String, String>? receiveParams, String? debugInfo, AnimationController? animCtrl, bool autoExpand = true}){
    _pageReadyWillReceive(null, page, null, receiveParams, pageClass, targetColumn, false, debugInfo: debugInfo, animCtrl: animCtrl, callUpdate: false, expand: autoExpand);
  }
  
  void directGotoPage(int pageClass, int targetColumn, FocusRoutePage page, {Map<String, String>? receiveParams, String? debugInfo, AnimationController? animCtrl, bool autoExpand = true}){
    _pageReadyWillReceive(null, page, null, receiveParams, pageClass, targetColumn, false, debugInfo: debugInfo, animCtrl: animCtrl, expand: autoExpand);
  }

  void removePagesWait(List<FocusRoutePage> pages,{AnimationController? animCtrl}){
    removePages(pages, animCtrl: animCtrl, callUpdate: false);
  }

  void removePages(List<FocusRoutePage> pages, {AnimationController? animCtrl, bool callUpdate = true}){
    for(final page in pages){
      __currentPair.$1.removeWhere((cached){
        if(cached.$3.page == page){
          cached.$3.page?.onPause();
          cached.$3.page?.onDestroy();
          return true;
        }
        return false;
      });
      __currentPair.$2.removeWhere((cached){
        if(cached.$3.page == page){
          cached.$3.page?.onPause();
          cached.$3.page?.onDestroy();
          return true;
        }
        return false;
      });
    }
    __currentPair = expandCollapse(__currentPair, screenColumn)!;
    _pageReceivedWillChangePT(null, 'removePagesWait', animCtrl, callUpdate);
    
  }
  
  void _pageReadyWillReceive(PageCache? cachePage, FocusRoutePage page, String? path, Map<String, String>? receiveParams, int pageClass, int targetColumn, bool shouldCallResume, { String? debugInfo, AnimationController? animCtrl, bool callUpdate = true, bool expand = true }){
    page.onReceive(receiveParams);
    /// NavigatorPage 和 NavigatorPageWidget 是两个类
    print('param:$receiveParams');
    print('pageClass:$pageClass');
    print('availableColumns:${(page as MultiColumns).availableColumns}');
    if(expand){
      targetColumn = availableColumns((page as MultiColumns).availableColumns, pageClass).first;
    }
  
    var willReplacePair = (expand ?  shiftExpand : shift).call(__currentPair, (pageClass, targetColumn, cachePage ?? PageCache.nopathPage(page)));
    for (var rElement in willReplacePair.$2) {
      rElement.$3.page?.onPause();
      rElement.$3.screenPT = null;
      final onCreatePath = rElement.$3.onCreatePath;
      if(onCreatePath != null){
        cachePathPages?.update(onCreatePath, (already){
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
    /// 6月22日 拆出第三段 willChangePT
    _pageReceivedWillChangePT(path, debugInfo, animCtrl, callUpdate);
  }

  List<(ScreenPT, Navigatable<PageCache>)> get screenPTCachePageList => mergeScreenPT<Navigatable<PageCache>>(currentScreenPTs!, currentContextPT!, currentNavPairList);
  
  void _pageScreenPTChangeDo(void Function(ScreenPT?, ScreenPT, PageCache) it){
    for (var item in screenPTCachePageList) {
      final oldScreenPT = item.$2.$3.screenPT;
      final newScreenPT = item.$1;
      if(oldScreenPT.toString() != newScreenPT.toString()) it(oldScreenPT, newScreenPT, item.$2.$3);
    }
  }

  void _pageReceivedWillChangePT([ String? path, String? debugInfo, AnimationController? animCtrl, bool callUpdate = true]){

    void endCall(){
      screen.currentPatternNullable = currentContextPT;
      if(callUpdate) untilUpdate(debugInfo: debugInfo, path: path);
    }
    
    _pageScreenPTChangeDo((ScreenPT? oldPT, ScreenPT newPT, PageCache cache){
      cache.page?.onScreenWillChange(newPT);
    });
    
    /// 此处插入 vscreenMap
    if(animCtrl != null){
      _pageScreenPTChangeDo((ScreenPT? oldPT, ScreenPT newPT, PageCache cache){
        final anim = cache.page?.willPlayAnimated(fromPT: oldPT, toPT: newPT, animCtrl: animCtrl);
        if(anim != null){
          GroupedAnimationManager.instance.addController('navigator', anim, onGroupMembersCompleted: () {
            endCall();
            GroupedAnimationManager.instance.dispose();
          },);
        }
      });
      /// 统一播放
      GroupedAnimationManager.instance.playGroup('navigator', duration: Duration(seconds: 2));
      // if(GroupedAnimationManager.instance.hasGroup('navigator')){
      //   GroupedAnimationManager.instance..onAllCompleted = (){
      //     endCall();
      //     GroupedAnimationManager.instance.dispose();
      //   }..playGroup('navigator', duration: Duration(seconds: 2));
      // }
    }

    final Map<String, VScreenFocusPageManager> vscreenMap = {};
    _pageScreenPTChangeDo((ScreenPT? oldPT, ScreenPT newPT, PageCache cache){
      if(cache.page is VScreenKetchupRoutePage){
        final cachePage = cache.page as VScreenKetchupRoutePage;
        if(cachePage.virtualScreen != null){
          vscreenMap.update(newPT.$1, (_) => cachePage.virtualScreen as VScreenFocusPageManager, ifAbsent: () => cachePage.virtualScreen as VScreenFocusPageManager,);
        }
      }
    });
    screen.currentPatternVirtualMap = vscreenMap;

    /// 之后不能再调此函数
    _pageScreenPTChangeDo((ScreenPT? oldPT, ScreenPT newPT, PageCache cache){
      cache.screenPT = newPT;
    });
    
    if(animCtrl == null) endCall();

  }

  // void _pageReceivedWillChangePT([ String? path, String? debugInfo, AnimationController? animCtrl, bool callUpdate = true]){
    
  //   endCall(){
  //     screen.currentPatternNullable = currentContextPT;
  //     if(callUpdate) untilUpdate(debugInfo: debugInfo, path: path);
  //   }

  //   List<AnimationStatusListener> listeners = [];
    
  //   AnimationStatusListener addListener(AnimationStatusListener listener){
  //     listeners.add(listener);
  //     return listener;
  //   }

  //   AnimationStatusListener removeFirst(){
  //     return listeners.removeAt(0);
  //   }

  //   for (var item in screenPTCachePageList) {
  //     final oldScreenPT = item.$2.$3.screenPT;
  //     final newScreenPT = item.$1;
  //     final page = item.$2.$3.page;
  //     if(oldScreenPT.toString() != newScreenPT.toString()){
        
  //       page?.onScreenWillChange(item.$1);

  //       item.$2.$3.screenPT = item.$1;
        
  //       /// 5月26日 新增-页面跳转动画 Hook 第一个结束动画就触发 onMeasured
  //       if(animCtrl != null && page != null){
  //         final anim = page.willPlayAnimated(fromPT: oldScreenPT, toPT: item.$1, animCtrl: animCtrl);
  //         anim
  //           ..duration = Duration(milliseconds: 1300)
  //           ..addStatusListener(addListener((AnimationStatus status){
  //             if(status.isCompleted){
  //               animCtrl.removeStatusListener(removeFirst());
  //               if(listeners.isEmpty){
  //                 endCall();
  //               }
  //             }
  //           }))
  //           ..forward();
  //       }
  //     }
  //   }

  //   if(listeners.isEmpty){
  //     endCall();
  //   }
  // }

  void untilUpdate({String? debugInfo, String? path, VoidCallback? afterMeasured}){
    navUpdate((){
      if(afterMeasured != null){
        WidgetsBinding.instance.addPostFrameCallback((_){
          afterMeasured();
        });
      }
    },'${debugInfo ?? 'untilUpdate'}=${path ?? 'nopath'}');
  }

  
  
  ColumnsBuilder get columnsBuilder => (BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT){
    if(currentScreenPTs != null){
      for(var cScreenPT in currentScreenPTs!.indexed){
        if((cScreenPT.$2, currentContextPT).toString() == screenPT.toString() && cScreenPT.$1 < currentCachePages.length){
          return currentCachePages[cScreenPT.$1].page?.columnsBuild(context, ctxAccessor, screenPT);
        }
      }
      return null;
    }else{
      return null;
    }
  };

  List<T> type<T>([bool includeCache = false]){
    return currentCachePages.map((cache)=>cache.page).whereType<T>().toList();
  }
}

abstract class RouteHistoryNavigatorBuilder extends BasicNavigatorBuilder with RouteFinder implements ContextAccessor{

  //// 历史记录
  final List<String> __historyRoutes = [];
  //// 前进记录
  final List<String> __forwardRoutes = [];

  /// (二级)缓存页面 (path->route->page)
  /// 有数据 表示查询过
  final Map<String, (KetchupRoute, Map<String, String>)> __cachePathRoutes = {};
  /// 有数据表示可以使用 cachePage
  /// 没有数据可能有页面正在展示，需要从 KetchupRoute 重新创建一个 CachePage(相同页面多个Tab页，页面克隆)
  final Map<String, PageCache> __cachePathPages = {};
  @override
  Map<String, PageCache>? get cachePathPages => __cachePathPages;

  // NavCtntPair<CachePage> __currentPair = ([],[]);

  /// 6月22日，加强交互性，修改栏目数之前判断是否合法
  bool canCollapse(int screenColumn){
    assert(screenColumn >0 && screenColumn <= this.screenColumn);
    return expandCollapse(__currentPair, screenColumn) != null;
  }

  // void adjustScreenColumnChangeWait()=>adjustScreenColumnChange(callUpdate: false);

  /// 适应屏幕栏目数调整{
  // void adjustScreenColumnChange({ String? debugInfo, AnimationController? animCtrl, bool callUpdate = true,}){
  //   __currentPair = expandCollapse(__currentPair, screenColumn)!;
  //   _pageReceivedWillChangePT(null, debugInfo, animCtrl, callUpdate);
  // }

  // void currentPagesUnload(){
  //   for (var cache in currentCachePages) {
  //     cache.page?.onPause();
  //     cache.page?.onDestroy();
  //   }
  // }

  void cachePagesUnload(){
    for (var cache in __cachePathPages.values) {
      cache.page?.onDestroy();
    }
  }

  void clear(){
      __historyRoutes.clear();
      __forwardRoutes.clear();
      cachePagesUnload();
      __cachePathPages.clear();
      __cachePathRoutes.clear();
      currentPagesUnload();
      __currentPair.$2.clear();
      __currentPair.$1.clear();
  }

  // NavigatableList<CachePage> get currentNavPairList => [ ...__currentPair.$1, ...__currentPair.$2 ];

  @override
  String? currentRoute;


  // List<CachePage> get currentCachePages => currentNavPairList.map((cache)=>cache.$3).toList();

  // List<int> get currentColumnsLR => currentNavPairList.map((cache)=>cache.$2).toList();

  // /// 9月17日 依赖 screen

  // String? get currentContextPT => screen.genContextPTColumnsLR(currentColumnsLR);

  // List<String>? get currentScreenPTs => ScreenContext.genScreenPTColumnsLR(currentColumnsLR, screen.column);

  Iterable<P> findBuiltPages<P>({BuiltPageTest<P>? test, bool includeCache = true}){
    Iterable<P> res = (<PageCache>[]..addAll(currentCachePages) ..addAll(includeCache ? __cachePathPages.values : []))
    .map<FocusRoutePage?>((cache)=>cache.page)
    .whereType<P>();
    if(test != null){
      return res.where(test);
    } else {
      return res;
    }
  }

  /// 重要函数(查找当前或者内存页面)
  P? findBuiltPage<P>(BuiltPageTest<P?> test, {bool includeCache = true}){
    return (<PageCache>[]..addAll(currentCachePages) ..addAll(includeCache ? __cachePathPages.values : []))
    .map<FocusRoutePage?>((cache)=>cache.page)
    .whereType<P?>()
    .firstWhere(test, orElse: () => null,);
  }

  // List<CachePage> get currentCachePages => [ ...__currentPair.$1, ...__currentPair.$2 ].map((cache)=>cache.$3).toList();

  @override
  List<T> type<T>([bool includeCache = false]){
    return (currentCachePages ..addAll(includeCache ? __cachePathPages.values : [])).map((cache)=>cache.page).whereType<T>().toList();
  }

  // void go(String route){
  // }

  void animPushWait(String route, AnimationController animCtrl)=>animPush(route, animCtrl, false);
  void animPush(String route, AnimationController animCtrl, [bool callUpdate = true]) => push(route, animCtrl, callUpdate);
  void pushWait(String route) => push(route, null, false);
  void push(String route, [AnimationController? animCtrl, bool callUpdate = true]){
    if(currentRoute != null){
      __historyRoutes.add(currentRoute!);
    }
    __forwardRoutes.clear();
    _innerGoNoHistory(currentRoute = route, 'nav.push', animCtrl, callUpdate);
  }

  void animPopWait(String route, AnimationController animCtrl)=>animPop(route, animCtrl, false);
  void animPop(String route, AnimationController animCtrl, [bool callUpdate = true]) => pop(route, animCtrl, callUpdate);
  void popWait(String route) => pop(route, null, false);
  void pop(String route, [AnimationController? animCtrl, bool callUpdate = true]){
    var removed = __currentPair.$1.firstWhereOrNull((cache) => cache.$3.onCreatePath == route);
    if(removed == null){
      if((removed = __currentPair.$2.firstWhereOrNull((cache) => cache.$3.onCreatePath == route)) == null){
        return;
      }else{
        __currentPair.$2.remove(removed);
      }
    }else{
      __currentPair.$1.remove(removed);
    }
    removed!.$3.page?.onPause();
    removed.$3.page?.onDestroy();
    _pageReceivedWillChangePT(route, 'pop', animCtrl, callUpdate);
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
  void _innerGoNoHistory(String path, [ String? debugInfo, AnimationController? animCtrl, bool callUpdate = true]){
    var routeParam = __cachePathRoutes[path] ?? find(path);
    if(routeParam != null){
      __cachePathRoutes[path] = routeParam;
      KetchupRoute route = routeParam.$1;
      Map<String,String> param = routeParam.$2;
      int pageClass = screen.column - (int.tryParse(param['_level'] ?? '1') ?? 1) + 1;
      int targetColumn = pageClass;
      PageCache? cachePage = __cachePathPages.remove(path);
      bool isFromCache = cachePage != null;
      if(!isFromCache){
        cachePage = PageCache.pathPage(path, route.ketchupPageBuilder!());
      }
      _pageReadyWillReceive(cachePage,
        cachePage.page!, path, { ...param, '_pageClass': pageClass.toString(), '_fromCache': isFromCache.toString() }, pageClass, targetColumn, isFromCache, debugInfo: debugInfo, animCtrl: animCtrl, callUpdate: callUpdate);
    }
  }

  // @override
  // void indexedGotoPagesWait({ List<IndexedIntentPage> intentsLR = const [], List<IndexedIntentPage> intentsRL = const [], AnimationController? animCtrl}) => indexedGotoPages(animCtrl: animCtrl, intentsLR: intentsLR, intentsRL: intentsRL, callUpdate: false);
  
  // @override
  // void indexedGotoPages({
  //   List<IndexedIntentPage> intentsLR = const [],
  //   List<IndexedIntentPage> intentsRL = const [],
  //   AnimationController? animCtrl, bool callUpdate = true}){
  //   currentPagesUnload();
  //   /// 忽略 contentPageClass
  //   final navList = intentsLR.mapIndexed<Navigatable<CachePage>>((index, intent)=>(screenColumn - index, intent.column,CachePage.nopathPage(intent.page..onReceive(intent.recieveParams)))).toList();
  //   /// 页面等级全部 = contentPageClass
  //   final ctnList = intentsRL.mapIndexed<Navigatable<CachePage>>((index, intent)=>(contentPageClass, intent.column,CachePage.nopathPage(intent.page..onReceive(intent.recieveParams)))).toList().reversed.toList();
  //   __currentPair = expandCollapse((navList, ctnList), screenColumn)!;
  //   for(final cache in currentCachePages){
  //     cache.page!.onCreate();
  //   }
  //   pageReceivedWillChangePT(null, 'indexedIntents', animCtrl, callUpdate);
  // }

  // void _innerGoPageReadyWillReceive(CachePage? cachePage, KetchupRoutePage page, String? path, Map<String, String>? onRecieveParams, int pageClass, int targetColumn, bool shouldCallResume, [ String? debugInfo, AnimationController? animCtrl, bool callUpdate = true]){
  //   page.onReceive(onRecieveParams);
  //   /// NavigatorPage 和 NavigatorPageWidget 是两个类
  //   if(page is MultiColumns){
  //     print('param:$onRecieveParams');
  //     print('pageClass:$pageClass');
  //     print('availableColumns:${(page as MultiColumns).availableColumns}');
  //     targetColumn = availableColumns((page as MultiColumns).availableColumns, pageClass).first;
  //   }

  //   var willReplacePair = shiftExpand(__currentPair, (pageClass, targetColumn, cachePage ?? CachePage.nopathPage(page)));
  //   for (var rElement in willReplacePair.$2) {
  //     rElement.$3.page?.onPause();
  //     rElement.$3.screenPT = null;
  //     final onCreatePath = rElement.$3.onCreatePath;
  //     if(onCreatePath != null){
  //       __cachePathPages.update(onCreatePath, (already){
  //         already.page?.onDestroy();
  //         return rElement.$3;
  //       }, ifAbsent:()=>rElement.$3);
  //     }else{
  //       rElement.$3.page?.onDestroy();
  //     }
  //   }
  //   __currentPair = willReplacePair.$1;

  //   if(shouldCallResume){
  //     page.onResume();
  //   }else{
  //     page.onCreate();
  //   }
  //   /// 6月22日 拆出第三段 willChangePT
  //   pageReceivedWillChangePT(path, debugInfo, animCtrl, callUpdate);
  // }

  // void _innerMergeWillChangePT([ String? path, String? debugInfo, AnimationController? animCtrl, bool callUpdate = true]){
  //   var merged = mergeScreenPT<Navigatable<CachePage>>(currentScreenPTs!, currentContextPT!, currentNavPairList);

  //   endCall(){
  //     screen.currentPatternNullable = currentContextPT;
  //     if(callUpdate) untilUpdate(debugInfo: debugInfo, path: path);
  //   }

  //   List<AnimationStatusListener> listeners = [];
  //   AnimationStatusListener addListener(AnimationStatusListener listener){
  //     listeners.add(listener);
  //     return listener;
  //   }
  //   AnimationStatusListener removeFirst(){
  //     return listeners.removeAt(0);
  //   }
  //   for (var indexed in merged.indexed) {
  //     final oldScreenPT = indexed.$2.$2.$3.screenPT;
  //     if(oldScreenPT.toString() != indexed.$2.$1.toString()){
  //       indexed.$2.$2.$3.page?.onScreenWillChange(indexed.$2.$1);
  //       indexed.$2.$2.$3.screenPT = indexed.$2.$1;
        
  //       /// 5月26日 新增-页面跳转动画 Hook 第一个结束动画就触发 onMeasured
  //       if(animCtrl != null && indexed.$2.$2.$3.page != null){
  //         final anim = indexed.$2.$2.$3.page!.willPlayAnimated(fromPT: oldScreenPT, toPT: indexed.$2.$1, animCtrl: animCtrl);
  //         anim
  //           ..duration = Duration(milliseconds: 1300)
  //           ..addStatusListener(addListener((AnimationStatus status){
  //             if(status.isCompleted){
  //               animCtrl.removeStatusListener(removeFirst());
  //               if(listeners.isEmpty){
  //                 endCall();
  //               }
  //             }
  //           }))
  //           ..forward();
  //       }
  //     }
  //   }

  //   if(listeners.isEmpty){
  //     endCall();
  //   }
  // }

  // void untilUpdate({String? debugInfo, String? path, VoidCallback? allMeasured}){
  //   lazyUpdate((){
  //     },'${debugInfo ?? 'untilUpdate'}=${path ?? 'nopath'}', (){
  //       for (var cache in currentCachePages) {
  //         cache.page!.onMeasured(screen);
  //       }
  //       allMeasured?.call();
  //     });
  // }

  // void removePagesWait(List<KetchupRoutePage> pages,{AnimationController? animCtrl}){
  //   removePages(pages, animCtrl: animCtrl, callUpdate: false);
  // }

  // void removePages(List<KetchupRoutePage> pages, {AnimationController? animCtrl, bool callUpdate = true}){
  //   for(final page in pages){
  //     __currentPair.$1.removeWhere((cached){
  //       if(cached.$3.page == page){
  //         cached.$3.page?.onPause();
  //         cached.$3.page?.onDestroy();
  //         return true;
  //       }
  //       return false;
  //     });
  //     __currentPair.$2.removeWhere((cached){
  //       if(cached.$3.page == page){
  //         cached.$3.page?.onPause();
  //         cached.$3.page?.onDestroy();
  //         return true;
  //       }
  //       return false;
  //     });
  //   }
  //   __currentPair = expandCollapse(__currentPair, screenColumn)!;
  //   pageReceivedWillChangePT(null, 'removePagesWait', animCtrl, callUpdate);
    
  // }

  // void directGotoPageWait(int pageClass, int targetColumn, KetchupRoutePage page, {Map<String, String>? constructParams, String? debugInfo, AnimationController? animCtrl}){
  //   pageReadyWillReceive(null, page, null, constructParams, pageClass, targetColumn, false, debugInfo, animCtrl, false);
  // }
  
  // void directGotoPage(int pageClass, int targetColumn, KetchupRoutePage page, {Map<String, String>? constructParams, String? debugInfo, AnimationController? animCtrl}){
  //   pageReadyWillReceive(null, page, null, constructParams, pageClass, targetColumn, false, debugInfo, animCtrl);
  // }

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
    clear();
  }

  @override
  ColumnsBuilder get columnsBuilder => (BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT){
    if(currentScreenPTs != null){
      for(var cScreenPT in currentScreenPTs!.indexed){
        if((cScreenPT.$2, currentContextPT).toString() == screenPT.toString() && cScreenPT.$1 < currentCachePages.length){
          return currentCachePages[cScreenPT.$1].page?.columnsBuild(context, ctxAccessor, screenPT);
        }
      }
      return null;
    }else{
      return null;
    }
  };
  
}

class EmptyCaImplTester implements ContextAccessor{

  EmptyCaImplTester(this.screen);
  
  @override
  LayerContext get bgLayers => SimpleLayerContext();

  @override
  LayerContext get fgLayers => SimpleLayerContext();

  @override
  GridContext get grid => GridContext();

  @override
  ScreenContext screen;
  
  @override
  void Function(VoidCallback p1, [String? d]) get update => (VoidCallback p1, [String? d]){
  };
  
  @override
  Size get size => Size.zero;
  
}

class RouteHistoryNavigatorBuilderImpl extends RouteHistoryNavigatorBuilder{
  
  ContextAccessor ca;

  RouteHistoryNavigatorBuilderImpl({required this.ca, required this.contentPageClass, required this.routes });

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

  // @override
  // void measureUpdate(VoidCallback c, [String? d, VoidCallback? afterMeasured]) {
  //   return ca.measureUpdate(c, d, afterMeasured);
  // }
  
  @override
  void Function(VoidCallback p1, [String? d]) get update => ca.update;
  
  @override
  Size get size => ca.size;
  
  @override
  void navUpdate(VoidCallback c, [String? d]) => ca.update;

}

mixin HasNavMixin implements ContextAccessor{
  int get contentPageClass;
  List<KetchupRoute> get routes;
  RouteHistoryNavigatorBuilderImpl? _nav;
  RouteHistoryNavigatorBuilderImpl get nav => _nav ??= RouteHistoryNavigatorBuilderImpl(ca: this, contentPageClass: contentPageClass, routes: routes);
}