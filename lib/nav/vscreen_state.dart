import 'package:flutter/widgets.dart';
import 'package:ketchup_ui/ketchup_ui.dart';


abstract mixin class HasNavVirtualScreen {
  String get upperPT;
  VirtualScreenNavigatorBuilder get pageNav;
  ScreenContext get virtualScreen;
}

abstract class VScreenKetchupRoutePage extends KetchupRoutePage {

  ContextAccessor get ca;
  int get contentPageClass;
  String get upperPT;
  
  GlobalKey vscreenKey = GlobalKey();
  GlobalKey innerKetchupKey = GlobalKey();
  VScreenRoutePageState? get vscreenState => vscreenKey.currentState as VScreenRoutePageState?;
  KetchupUIState? get innerState => innerKetchupKey.currentState as KetchupUIState?;
  
  @override
  List<Widget>? columnBuild(BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT) {
    return [VScreenRoutePageStatefulWidget(key: vscreenKey, statefulKey: innerKetchupKey, page: this, ca: ca, contentPageClass: contentPageClass, upperPT: upperPT)];
  }
}

class VScreenRoutePageStatefulWidget extends StatefulWidget{
  
  String upperPT;
  ContextAccessor ca;
  KetchupRoutePage page;
  int contentPageClass;
  Map<String, String>? receiveData;
  Key? statefulKey;
  VScreenRoutePageStatefulWidget({super.key, this.statefulKey, required this.page, required this.ca, required this.contentPageClass, this.receiveData, required this.upperPT,});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => VScreenRoutePageState();
}

class VScreenRoutePageState<T extends VScreenRoutePageStatefulWidget> extends State<T> with DebugUpdater implements HasNavVirtualScreen{

  @override
  late VirtualScreenNavigatorBuilder pageNav;

  @override
  late ScreenContext virtualScreen;
  
  createVirtualScreenContext(){
    virtualScreen = widget.ca.screen.createVirtual(upperPT);
    pageNav = VirtualScreenNavigatorBuilder(screen: virtualScreen, contentPageClass: widget.contentPageClass, debugUpdater: this);
  }
  
  @override
  void initState() {
    super.initState();
    createVirtualScreenContext();
    widget.page.onCreate();
    widget.page.onReceive(widget.receiveData);
    widget.page.onResume();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    if(oldWidget.receiveData != widget.receiveData){
      widget.page.onReceive(widget.receiveData);
      widget.page.onResume();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    widget.page.onPause();
    widget.page.onDestroy();
  }
  
  @override
  Widget build(BuildContext context) {
    return KetchupUILayout(statefulKey: widget.statefulKey, screen: virtualScreen,
              screensBuilder: pageNav.screensBuilder,
              fullscreenBackgroundBuilder: (_)=>[widget.page.fullBuild(context)], grid: widget.ca.grid, bgLayers: widget.ca.bgLayers, fgLayers: widget.ca.fgLayers);
  }

  @override
  String get upperPT => widget.upperPT;

}

class VirtualScreenNavigatorBuilder extends BasicNavigatorBuilder{

  DebugUpdater debugUpdater;

  VirtualScreenNavigatorBuilder({required this.contentPageClass, required this.screen, required this.debugUpdater});

  @override
  Map<String, CachePage>? get cachePathPages => null;

  @override
  int contentPageClass;

  @override
  void lazyUpdate(VoidCallback c, [String? d, VoidCallback? afterUpdate]) {
    debugUpdater.debugLazyUpdate(c, d);
    if(afterUpdate != null){
      screen.debug?.produceMeasuredCb(afterUpdate);
    }
  }

  @override
  ScreenContext screen;
  
}
