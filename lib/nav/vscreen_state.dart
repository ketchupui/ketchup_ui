// ignore_for_file: must_be_immutable

import 'package:flutter/widgets.dart' hide FocusManager;
import 'package:ketchup_ui/ketchup_ui.dart';
import '../remote_focus/focus.dart';


abstract mixin class HasNavVirtualScreen {
  ScreenPT get screenPT;
  VirtualScreenNavigatorBuilder get pageNav;
  ScreenContext get virtualScreen;
  VScreenFocusRoutePage get page;
}

abstract class PaintRectInterface {
  Rect? get paintRect;
  ScreenPT? get screenPT;
  // ContextAccessor? get ctxAccessor;
}

abstract class PaintRectFocusRoutePage extends FocusRoutePage with MultiColumns, FocusManager implements PaintRectInterface {

  @override
  ScreenContext? get pageScreen;

  @override
  ScreenPT? screenPT;

  @override
  Rect? get paintRect => screenPT != null ? pageScreen?.paintRect(screenPT!.$1) : null;
  
  // @override
  // Rect? get paintRect => screen.currentSizeRect;

  @override
  @mustCallSuper
  void onScreenWillChange(ScreenPT willChangePT) {
    pageLifecycleDebug('PaintRectRoutePage#$hashCode-onScreenWillChange');
    screenPT = willChangePT;
  }

  @override
  @mustCallSuper
  void onMeasured(ScreenContext screen){
    pageLifecycleDebug('PaintRectRoutePage#$hashCode-onMeasured');
  }

  @override
  @mustCallSuper
  List<Widget>? columnsBuild(BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT) {
    pageBuildDebug('PaintRectRoutePage#$hashCode-columnsBuild');
    return [
      ... bgFullBuild(context) ?? [],
      ... fgFullBuild(context) ?? [],
    ];
  }

}

abstract class VScreenFocusRoutePage extends FocusRoutePage with MultiColumns, FocusManager implements PaintRectInterface{

  ContextAccessor get ca;
  int get contentPageClass;

  @override
  ScreenPT? screenPT;

  @override
  Rect? get paintRect => pageScreen?.currentSizeRect;

  @override
  ScreenContext? get pageScreen => _pageScreen;
  ScreenContext? _pageScreen;
  GlobalKey vscreenKey = GlobalKey();
  GlobalKey innerKetchupKey = GlobalKey();
  VScreenPageState? get vscreenState => vscreenKey.currentState as VScreenPageState?;
  KetchupUIState? get ketchupState => innerKetchupKey.currentState as KetchupUIState?;
  VirtualScreenNavigatorBuilder? get pageNav => vscreenState?.pageNav;
  void Function(VoidCallback fn, [String? d])? get pageUpdate => ketchupState?.update;

  @override
  @mustCallSuper
  void onMeasured(ScreenContext screen){
    pageLifecycleDebug('VScreenKetchupRoutePage#$hashCode-onMeasured');
  }
  
  ScreenParams? createVirtualScreenUseParams(ScreenPT screenPT);

  @override
  @mustCallSuper
  void onScreenWillChange(ScreenPT willChangePT) {
    pageLifecycleDebug('VScreenKetchupRoutePage#$hashCode-onScreenWillChange');
    screenPT = willChangePT;
    if(pageScreen != null) pageScreen!.dispose();
    _pageScreen = ca.screen.createVirtual(willChangePT.$1, createVirtualScreenUseParams(willChangePT));
    // pageNav?.adjustScreenColumnChangeWait();
  }

  @override
  @mustCallSuper
  List<Widget>? columnsBuild(BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT) {
    pageBuildDebug('VScreenKetchupRoutePage#$hashCode-columnsBuild');
    if(pageScreen == null) {
      return [
        ... bgFullBuild(context) ?? [],
        ... fgFullBuild(context) ?? [],
      ];
    }
    return [
      VScreenPageStatefulWidget(key: vscreenKey, virtualScreen: pageScreen!, statefulKey: innerKetchupKey, page: this, ca: ca, contentPageClass: contentPageClass, screenPT: screenPT)
    ];
  }

  @override
  void Function(VoidCallback, [String? d]) get focusUpdate => pageUpdate ?? ca.update;
  NavCtntPair<PageCache>? pageNavSavedData;
  
  @override
  @mustCallSuper
  void onPause() {
    pageLifecycleDebug('VScreenKetchupRoutePage#$hashCode-onPause');
  }

}

class VScreenPageStatefulWidget extends StatefulWidget{
  
  ScreenPT screenPT;
  ContextAccessor ca;
  ScreenContext virtualScreen; 
  VScreenFocusRoutePage page;
  int contentPageClass;
  Map<String, String>? receiveData;
  Key? statefulKey;
  VScreenPageStatefulWidget({super.key, this.statefulKey, required this.virtualScreen, required this.page, required this.ca, required this.contentPageClass, this.receiveData, required this.screenPT});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => VScreenPageState();
}

class VScreenPageState<T extends VScreenPageStatefulWidget> extends State<T> with DebugUpdater implements HasNavVirtualScreen{

  @override
  late VirtualScreenNavigatorBuilder pageNav;

  @override
  ScreenContext get virtualScreen => widget.virtualScreen;

  @override
  VScreenFocusRoutePage get page => widget.page;
  
  bool createPageNav(){
    final savedData = widget.page.pageNavSavedData;
    pageNav = VirtualScreenNavigatorBuilder(screen: virtualScreen, contentPageClass: widget.contentPageClass, debugUpdater: this, initPair: savedData);
    return savedData != null;
  }
  
  @override
  void initState() {
    super.initState();
    if(createPageNav()){
      page.onResume();
    }else{
      page..onCreate()
          ..onResume();
    }
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    if(oldWidget.screenPT != widget.screenPT){
      final oldSingle = oldWidget.screenPT.$1;
      final newSingle = widget.screenPT.$1;
      final oldColumns = ScreenContext.columnPosFromScreenPT(oldSingle)?.$3;
      final newColumns = ScreenContext.columnPosFromScreenPT(newSingle)?.$3;
      if(oldColumns != newColumns && newColumns != null){
        pageNav.onColumnsChange(newColumns);
      }
    }
    if(oldWidget.receiveData != widget.receiveData){
      page.onReceive(widget.receiveData);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        page.onResume();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    page..pageNavSavedData = pageNav.currentPair
        ..onPause();
  }
  
  @override
  Widget build(BuildContext context) {
    return KetchupUILayout(key: widget.statefulKey, screen: virtualScreen,
              bgFullBuilder: widget.page.bgFullBuild,
              bgLayers: widget.ca.bgLayers, 
              columnsBuilder: pageNav.columnsBuilder,
              fgFullBuilder: widget.page.fgFullBuild,
              fgLayers: widget.ca.fgLayers,
              measuredCb: pageNav.onMeasured,
              grid: widget.ca.grid, 
           );
  }
    
  @override
  ScreenPT get screenPT => widget.screenPT;

}

class VirtualScreenNavigatorBuilder extends BasicNavigatorBuilder{

  DebugUpdater debugUpdater;

  VirtualScreenNavigatorBuilder({required this.contentPageClass, required this.screen, required this.debugUpdater, super.initPair});

  @override
  Map<String, PageCache>? get cachePathPages => null;

  @override
  int contentPageClass;

  @override
  ScreenContext screen;
  
  @override
  void navUpdate(VoidCallback c, [String? d]) => debugUpdater.debugUpdate(c, d);
  
}
