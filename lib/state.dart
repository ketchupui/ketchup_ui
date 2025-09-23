// ignore_for_file: non_constant_identifier_names
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'debug.dart';
import 'model/model.dart';
import 'painter/grid.dart';
import 'painter/layer.dart';
import 'pxunit.dart';
import 'utils.dart';


typedef ResponsiveValueGroup = ({CATEGORY category, double fromExcludeSizeRatio, double toIncludeSizeRatio, RCPair rowColumn, Size? singleAspectRatio, TailColumnExpand tailColumnExpand});
typedef ScreenHandset = ({RCPair rowColumn, Size? singleAspectRatio, TailColumnExpand tailColumnExpand});
typedef HandsetValueGroup = ({ScreenContext screen, GridContext grid, LayerContext fgLayers, LayerContext bgLayers});
typedef ResponseAdaptiveCallback = HandsetValueGroup? Function({required ResponsiveValueGroup matched, required Size size});
typedef CaScreenWidgetsBuilderFilter<T> = T Function(BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT);
typedef ScreensBuilder = CaScreenWidgetsBuilderFilter<List<Widget>?>;
typedef WidgetsBuilder = List<Widget>? Function(BuildContext context);
ScreensBuilder BlankWidgetsBuilder = (BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT)=>null;

class KetchupUIResponsive extends StatefulWidget{
  final List<ResponsiveValueGroup> responses;
  final Key? statefulKey;
  final HandsetValueGroup init;
  final ResponseAdaptiveCallback? callbackBeforeRender;
  final ScreensBuilder? screensBuilder;
  final WidgetsBuilder? fullscreenBackgroundBuilder;
  final Decoration? bgDecoration;
  const KetchupUIResponsive({super.key, this.bgDecoration, this.screensBuilder, this.fullscreenBackgroundBuilder, this.statefulKey, required this.responses, this.callbackBeforeRender, required this.init});
  @override
  State<StatefulWidget> createState()=> _KetchupUIResponsiveState();
}

class _KetchupUIResponsiveState extends State<KetchupUIResponsive> with DebugUpdater{

  ResponsiveValueGroup? lastResponse;

  @override
  void initState() {
    super.initState();
    lastResponse = null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
        stateDebug('layout-biggest:${constraints.biggest}');
        // ketchupDebug('layout-smallest:${constraints.smallest}');
        if(widget.responses.isNotEmpty){
          for(ResponsiveValueGroup group in widget.responses){
            if(group.fromExcludeSizeRatio < constraints.biggest.aspectRatio && constraints.biggest.aspectRatio <= group.toIncludeSizeRatio){
              if(lastResponse != group){
                lastResponse = group;
                var cbResult = widget.callbackBeforeRender?.call(matched: group, size: constraints.biggest);
                return KetchupUISized(key: widget.statefulKey,
                    screensBuilder: widget.screensBuilder,
                    fullscreenBackgroundBuilder: widget.fullscreenBackgroundBuilder,
                    // rowColumn: cbResult?.rowColumn ?? widget.init.rowColumn, 
                    // singleAspectRatio: cbResult != null ? cbResult.singleAspectRatio : group.singleAspectRatio, 
                    // tailColumnExpand: cbResult?.tailColumnExpand ?? group.tailColumnExpand,
                    size: constraints.biggest, 
                    // mode: cbResult?.mode ?? widget.init.mode, 
                    screen: cbResult?.screen ?? widget.init.screen,
                    grid: cbResult?.grid ?? widget.init.grid,
                    fgLayers: cbResult?.fgLayers ?? widget.init.fgLayers,
                    bgLayers: cbResult?.bgLayers ?? widget.init.bgLayers,
                    bgDecoration: widget.bgDecoration,);
              }
              break;
            }
          }
        }
        var init = widget.init;
        return KetchupUISized(key: widget.statefulKey, 
          screensBuilder: widget.screensBuilder,
          fullscreenBackgroundBuilder: widget.fullscreenBackgroundBuilder,
          // rowColumn: init.rowColumn, 
          // singleAspectRatio: init.singleAspectRatio, 
          // tailColumnExpand: init.tailColumnExpand,
          // mode: init.mode, 
          size: constraints.biggest, 
          screen: init.screen, 
          grid: init.grid, 
          fgLayers: init.fgLayers, 
          bgLayers: init.bgLayers,
          bgDecoration: widget.bgDecoration,);
    });
    
  }
}

class KetchupUILayout extends StatelessWidget{

  // final Size? singleAspectRatio;
  // final RCPair rowColumn;
  // final TailColumnExpand tailColumnExpand;
  final double gapspan;
  // final RUNMODE mode;
  final ScreenContext screen;
  final GridContext grid;
  final LayerContext fgLayers;
  final LayerContext bgLayers;
  final Key? statefulKey;
  final ScreensBuilder? screensBuilder;
  final WidgetsBuilder? fullscreenBackgroundBuilder;
  final Decoration? bgDecoration;
  const KetchupUILayout({super.key, this.statefulKey, this.screensBuilder, this.fullscreenBackgroundBuilder,
    // this.singleAspectRatio, 
    this.gapspan = 0, 
    required this.screen,
    required this.grid,
    required this.fgLayers,
    required this.bgLayers,
    this.bgDecoration,
    // this.mode = RUNMODE.debug,
    // required this.rowColumn, 
    // this.tailColumnExpand = TailColumnExpand.none 
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((BuildContext context, BoxConstraints constraints){
        ketchupDebug('KetchupUILayouer-layout-biggest:${constraints.biggest}');
        // ketchupDebug('layout-smallest:${constraints.smallest}');
        return KetchupUISized(key: statefulKey,
          screensBuilder: screensBuilder,
          screen: screen,
          grid: grid,
          fgLayers: fgLayers,
          bgLayers: bgLayers,
          bgDecoration: bgDecoration,
          // rowColumn: rowColumn, 
          // singleAspectRatio: singleAspectRatio, 
          size: constraints.biggest, 
          // mode: mode, 
          // tailColumnExpand: tailColumnExpand,
        );
      }));
  }
  
}

class KetchupUISized extends StatefulWidget{

  // final Size? singleAspectRatio;
  // final RCPair rowColumn;
  // final TailColumnExpand tailColumnExpand;
  final Size size;
  final double gapspan;
  // final RUNMODE mode;
  final ScreenContext screen;
  final GridContext grid;
  final LayerContext bgLayers;
  final LayerContext fgLayers;
  final ScreensBuilder? screensBuilder;
  final WidgetsBuilder? fullscreenBackgroundBuilder;
  final Decoration? bgDecoration;
  const KetchupUISized({ super.key,
    // required this.rowColumn, 
    required this.screen,
    required this.size, 
    this.screensBuilder, 
    this.fullscreenBackgroundBuilder,
    // this.singleAspectRatio, 
    this.bgDecoration,
    // this.tailColumnExpand = TailColumnExpand.none,
    // this.mode = RUNMODE.debug, 
    this.gapspan = 0, required this.grid, required this.bgLayers,required this.fgLayers });
  
  @override
  State<StatefulWidget> createState() => KetchupUIState();
}

class KetchupUIState extends State<KetchupUISized> with DebugUpdater implements ContextAccessor {

  @override
  ScreenContext get screen => widget.screen;
  @override
  GridContext get grid => widget.grid;
  @override
  LayerContext get fgLayers => widget.fgLayers;
  @override
  LayerContext get bgLayers => widget.bgLayers;
  
  @override
  Size get size => widget.size;

  Size? get screenSingleAspectRatioSize => screen.singleAspectRatioSize;
  RCPair get screenRowColumn => screen.rowColumn;
  int get screenRow => screenRowColumn.row;
  int get screenColumn => screenRowColumn.column;
  TailColumnExpand get screenTailColumnExpand => screen.tailColumnExpand;

  int renderTimes = 0;

  /// 0.0.3 版本去掉缓存机制
  // List<Widget> singleColumnChildren = [];
  // Map<int, Map<String, Widget>> screenContextMapChild = {};
  // Map<String, List<Widget>> screenContextDirectChildren = {};

  Widget fullscreenAspectRatioRow({required Widget child, required double? fullScreenAspectRatio}){
    return fullScreenAspectRatio != null ? SizedBox(
        height: double.infinity,
        child: AspectRatio(aspectRatio: fullScreenAspectRatio, child: child,)) : child; 
  }

  Widget outsideRowExpandedAspectRatio({required Widget child, int flex = 1, double? aspectRatio}){
    if(aspectRatio != null){
      return child;
    }else {
      /// 横向 Expanded flex表示横向占比
      return Expanded(
      flex: flex,
      child: child);
    }
  }
  
  Widget insideColumnExpandedAspectRatio({required Widget child, int flex = 1, double? aspectRatio}){ 
      if(aspectRatio != null){
        /// 纵向 Expanded 用于 row > 1 时等比撑开
        return Expanded(
          flex: flex,
          /// aspectRatio 用于根据撑开的纵向高度计算横向占位（根据最大 height 计算 width）
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: child
        ));
      }else{
        /// 纵向 Expanded 用于 row > 1 时等比撑开
        return Expanded(
          flex: flex,
          child: child
        );
      }
  }

  // Widget? createScreenContextCombinedColumn({required int count, double? aspectRatio, required Color color }){
  //   if(aspectRatio != null){
  //     return Expanded(
  //       flex: count,
  //       child: AspectRatio(
  //         aspectRatio: aspectRatio * count
  //       ));
  //   }
  //   return Expanded(
  //     flex: count,
  //     child: null,);
  // }

  Widget editModeGridWrapping({required Widget child,required String singlePT}){
    return screen.mode != RUNMODE.runtime ? CustomPaint(foregroundPainter: 
      GridPainter(context: grid, 
        /// 纵向需要计算
        verExtra: screen.columnSplits(singlePT),
        /// 横向完全等分
        horExtra: screen.row > 1 ? (Size size)=>List.generate(screen.row - 1, (index)=>size.height * (index + 1) / screen.row ) : null
      ), child: child,) : child;
  }

  Widget leafContainerWrapping({Key? key, Color? editModeColor, List<Widget>? children, required String leafName, Size? literalAspectRatio, String? extra, required BuildContext context}){
    // ketchupDebug('widgetsBuilder:${widget.widgetsBuilder}');
    Size leafSize = screen.debug?.gKeyMappedValues[leafName]?.$2?.size ?? widget.size;
    return editModeGridWrapping(singlePT: leafName, child: Container(
            key: key,
            width: double.infinity,
            decoration: BoxDecoration(
              color: screen.mode == RUNMODE.edit ? editModeColor : null,
              border: screen.mode != RUNMODE.runtime && editModeColor != null ? Border.all(color: editModeColor) : null,
              // color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                ... (stateDebug(widget.screensBuilder?.call(
                    context, this,  (extra ?? leafName, screen.currentPattern))) ?? []),
                Text('                ${leafSize.width.toStringAsFixed(2)}x${leafSize.height.toStringAsFixed(2)}(${leafSize.aspectRatio.toStringAsFixed(4)})', style: TextStyle(fontSize: vmin(2)(widget.size), color: Colors.white, backgroundColor: Colors.black)),
                ...(screen.mode == RUNMODE.edit ? [
                  AutoSizeText( extra ?? leafName , presetFontSizes: [160, 570], maxLines: 2, style:TextStyle(color: editModeColor?.kDarken(0.8))),
                ]:[])]
                // ..addAll(
                //   widget.mode != RUNMODE.runtime && screen.gKeyMappedValues.containsKey(leafName) ? 
                //   [Column(
                //     children: [
                //       RightText(screen.gKeyMappedValues[leafName]!.$2.toString()),
                //       literalAspectRatio != null ? 
                //       RightText('aspectRadioSet ${literalAspectRatio.aspectRatio.toStringAsFixed(6)}(${literalAspectRatio.width} : ${literalAspectRatio.height})') : 
                //       RightText('aspectRadioSet null'),
                //       RightText('tailColumnExpand ${widget.tailColumnExpand}'),
                //       RightText('aspectRadioCal ${screen.gKeyMappedValues[leafName]!.$2!.aspectRatio.toStringAsFixed(6)}'),
                //       RightText('= 9.0 : ${(9.0 / screen.gKeyMappedValues[leafName]!.$2!.aspectRatio).toStringAsFixed(2)} =16.0 : ${(16.0 / screen.gKeyMappedValues[leafName]!.$2!.aspectRatio).toStringAsFixed(2)}'),
                //       RightText(screen.gKeyMappedValues[leafName]!.$3.toString()),
                //     ],
                //   )] :[])
            )));
  }

  List<Widget> createFromScreenContextPatterns({ required BuildContext context, required String screenContextPattern }){
    // ketchupDebug('context render invoke(${++renderTimes})');
    // testNeedMeasure();
    if(screenContextPattern == PT_FULLSCREEN){
      return [outsideRowExpandedAspectRatio( aspectRatio: screen.fullscreenAspectRatioSize?.aspectRatio,
            child: Column(
              children:[insideColumnExpandedAspectRatio(
                aspectRatio: screen.fullscreenAspectRatioSize?.aspectRatio,
                child: leafContainerWrapping(
                  context: context,
                  key: screen.debug?.gKeys.putIfAbsent(screenContextPattern, ()=>GlobalKey<KetchupUIState>(debugLabel: screenContextPattern)),
                  literalAspectRatio: screen.fullscreenAspectRatioSize,
                  leafName: screenContextPattern, editModeColor: screen.contextScreenColorMap[screenContextPattern]))]))];
    }else{
      return screenContextPattern.split(',').map<Widget>((String screenPattern){
        var columnCount = 1;
        if(screenPattern.startsWith('(')){
          columnCount = screenPattern.split('-').length;
        }  
        /// 计算约束(v0.0.3 新增尾屏比例)
        // var screenSingleAspectRatioSize = widget.screen.singleAspectRatioSize;
        final ratioSize = screenSingleAspectRatioSize;
        /// 没有设置单屏比例或者属于尾屏比例范畴 则flex自适配
        Size? calculatedAspectRatio = ratioSize == null || widget.screen.isTailInclude(screenPattern) ? null:  
        /// 不属于尾屏比例并设置了单屏比例则计算总屏幕比例
        Size(ratioSize.width * columnCount, /// 此处screencount 相当于widget.rowColumn.column
              ratioSize.height * screenRow);
        return outsideRowExpandedAspectRatio( 
            flex: columnCount,
            aspectRatio: calculatedAspectRatio?.aspectRatio,
            child: Column(
              children: [insideColumnExpandedAspectRatio(
                  flex: columnCount,
                  aspectRatio: calculatedAspectRatio?.aspectRatio,
                  child:  leafContainerWrapping(
                    context: context,
                    key: screen.debug?.gKeys.putIfAbsent(screenPattern, ()=>GlobalKey<KetchupUIState>(debugLabel: screenPattern)),
                    literalAspectRatio: calculatedAspectRatio,
                    leafName: screenPattern,
                    editModeColor: screen.contextScreenColorMap[screenPattern],
                  )///leaf
              )]///inside
            )
          );///outside
        }).toList();
      }
  }

  List<Widget> createSingleColumnCells({required BuildContext context, required RCPair rowColumn, ScreenContext? core}){
    // ketchupDebug('render invoke(${++renderTimes})');
    // testNeedMeasure();
    return List.generate(rowColumn.column, (int cIndex){
        var column = cIndex + 1;
        Size? calculatedAspectRatio = screenSingleAspectRatioSize == null || screen.isTailInclude('$column') ? null : screenSingleAspectRatioSize;
        return outsideRowExpandedAspectRatio( 
          aspectRatio: calculatedAspectRatio?.aspectRatio,
          child: Column(
            children: List.generate(rowColumn.row, (int rIndex){
              var row = rIndex + 1;
              var cellname = 'cell-$column-$row';
              return insideColumnExpandedAspectRatio( 
                aspectRatio: calculatedAspectRatio?.aspectRatio,
                child: leafContainerWrapping(
                  key: core?.debug?.gKeys.putIfAbsent(cellname, ()=>GlobalKey<KetchupUIState>(debugLabel: cellname)),
                  context: context,
                  leafName: cellname,
                  extra: '${cIndex+1}',
                  literalAspectRatio: screenSingleAspectRatioSize,
                  editModeColor: Colors.primaries[(cIndex * rowColumn.row + rIndex) * 5 % 17].shade100,)
              );
            }),
          ));
      });
  }
  
  bool get needUpdateMeasure => lastSize != size;
  void testNeedMeasure(){
    if((screen.debug?.isNeedMeasure ?? false) || needUpdateMeasure){
      lazyUpdate((){
        _updateGKeyValueRecords();
        lastSize = size;
      }, 'measured', screen.debug?.consumeMeasuredCb);
      
      // WidgetsBinding.instance.addPostFrameCallback((Duration dt){
      //   _updateGKeyValueRecords();
      //   lastSize = size;
      //   /// 用于显示 measure 后的数据
      //   setState((){});
      // });
    }
  }

  /// 更新 GKey 测量信息
  void _updateGKeyValueRecords(){
    assert(screen.debug != null);
    screen.debug!.gKeyMappedValues = screen.debug!.gKeys.map<String, GKeyValueRecord>((debugName, gKey){
      final renderBox = gKey.currentContext?.findRenderObject();
      if(renderBox != null){
        var rect = (renderBox as RenderBox).localToGlobal(Offset.zero) & renderBox.size;
        ketchupDebug('$debugName:$rect');
        return MapEntry(debugName, ( gKey, rect));
      }else {
        ketchupDebug('$debugName:null');
        return MapEntry(debugName, ( gKey, null));
      }});
  }
  // List<Widget> createSingleRowChildren({required int count, KetchupCore? core}){
  //   singleRowChildren.clear();
  //   singleRowChildren.addAll(
  //     List.generate(count, (int cIndex)=>childWrapper(
  //       Container(
  //         key: core?.gKeys.putIfAbsent('$cIndex', ()=>GlobalKey(debugLabel: '$cIndex')),
  //         decoration: BoxDecoration(
  //           color: Colors.primaries[(Colors.primaries.length * (cIndex) / count).floor()].shade100,
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         child: core?.gKeys.containsKey('$cIndex') ?? false ? Column(
  //             children: [
  //               Text('size:${core!.gKeys['$cIndex']!.currentContext!.size.toString()}'),
  //               Text('size:${(core.gKeys['$cIndex']!.currentContext!.findRenderObject() as RenderBox).localToGlobal(Offset.zero).toString()}')
  //             ],
  //           ): null ,
  //       )
  //     ))
  //   );
  //   return singleRowChildren;
  // }

  /// 确保所有语境都能收到回调
  Size? lastSize;

  void initContext(){
    screen.currentSize = size;
    grid.currentSize = size;
    fgLayers.currentSize = size;
    bgLayers.currentSize = size;
  }
  
  void setupContextListeners(){
    if(lastSize != size){
      screen.notifySizeChange(size, lastSize);
      grid.notifySizeChange(size, lastSize);
      fgLayers.notifySizeChange(size, lastSize);
      bgLayers.notifySizeChange(size, lastSize);
      double newRatio = size.aspectRatio;
      double? oldRatio = lastSize?.aspectRatio;
      if(oldRatio != newRatio){
        screen.notifyRatioChange(size, newRatio, oldRatio);
        grid.notifyRatioChange(size, newRatio, oldRatio);
        fgLayers.notifyRatioChange(size, newRatio, oldRatio);
        bgLayers.notifyRatioChange(size, newRatio, oldRatio);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // KetchupCore core = Provider.of<KetchupCore>(context);
    // ketchupDebug('----------offset:---------');
    // ketchupDebug((context.findRenderObject() as RenderBox).localToGlobal(Offset.zero));
    // return LayoutBuilder(
    //   builder: ((BuildContext context, BoxConstraints constraints){
    //     ketchupDebug('layout-biggest:${constraints.biggest}');
    //     ketchupDebug('layout-smallest:${constraints.smallest}');
    //     renderTimes = 0;
    //     isNeedUpdateFlag = true;
        stateDebug('update-build');
        setupContextListeners();
        return 
          // Container(
          //   width: double.infinity,
          //   height: double.infinity,
          //   decoration: BoxDecoration(color: Colors.grey),
          //   child: Column(
          //     // mainAxisAlignment: MainAxisAlignment.center,
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     crossAxisAlignment: CrossAxisAlignment.end,
          //     children: []
          //       ..addAll(widget.mode == RUNMODE.edit ? [
          //           SizedBox(height: 20),
          //           Container(
          //             alignment: Alignment(1, 0.5),
          //             decoration: BoxDecoration(color: Colors.red),
          //             child: Text('$screenColumn个横向排列的 ${screenSingleAspectRatioSize?.width ?? '-'}:${screenSingleAspectRatioSize?.height ?? '-'} 比例容器', 
          //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          //             ),
          //           ),
          //           SizedBox(height: 20),
          //         ]:[])
          //       ..add(Expanded(
          //         child: 
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: widget.bgDecoration ?? BoxDecoration(color: Colors.blueGrey), 
                    child: fullscreenAspectRatioRow(
                      fullScreenAspectRatio: screen.fullscreenAspectRatioSize?.aspectRatio,
                      child: 
                      /// 根据 CHATGPT 建议修改(高效动画版)
                        Stack(
                          children: [
                            ... (stateDebug(widget.fullscreenBackgroundBuilder?.call(
                            context)) ?? []),
                            CustomPaint(painter: LayerPainter(context: bgLayers, accessor: this), size: Size.infinite),
                            Positioned.fill(child: (){
                              testNeedMeasure();
                              return screen.singleCurrentPT != null ? 
                              leafContainerWrapping(leafName: screen.singleCurrentPT!, context: context) : 
                              Row(children: screen.currentPatternNullable == PT_CELL ? 
                                createSingleColumnCells(context: context, rowColumn: screenRowColumn, core: screen) :
                                createFromScreenContextPatterns(context: context, screenContextPattern: screen.currentPatternNullable!));
                            }()),
                            CustomPaint(painter: LayerPainter(context: fgLayers, accessor: this), size: Size.infinite),
                          ]
                        )
                        // CustomPaint(
                        //   painter: LayerPainter(context: bgLayers, accessor: this),
                        //   foregroundPainter: LayerPainter(context: fgLayers, accessor: this),
                        //   child: Row(children: screen.currentPatternNullable == PT_CELL ? 
                        //     createSingleColumnCells(context: context, rowColumn: widget.rowColumn, core: screen) :
                        //     createFromScreenContextPatterns(context: context, screenContextPattern: screen.currentPatternNullable!)
                        //   ),
                        // )
                      )
                //     )
                //   )
                // ))
          );
      //   );}
      // ));
  }
  
  
  
  @override
  void initState() {
    super.initState();
    ketchupDebug('KetchupUIState-initState:($hashCode)');
    renderTimes = 0;
    // setupContextListeners();
    initContext();
    // 会影响第一次监听的输入
    // lastSize = size;
    
  }

  @override
  void dispose() {
    super.dispose();
    ketchupDebug('dispose:$hashCode');
  }
  
  @override
  void lazyUpdate(VoidCallback c, [String? d, VoidCallback? afterUpdate]) {
    WidgetsBinding.instance.addPostFrameCallback((dt){
      debugUpdate(c, d);
      //// 实现 onMeasured 生命周期的关键
      if(afterUpdate != null){
        WidgetsBinding.instance.addPostFrameCallback((_)=>afterUpdate());
      }
    });
  }
  
  @override
  void Function(VoidCallback p1, [String? d]) get update => debugUpdate;
  

}

