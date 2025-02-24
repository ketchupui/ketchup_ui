import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'model/screen.dart';
import 'model/grid.dart';
import 'ui/RightText.dart';
import 'utils.dart';
import 'painter/grid.dart';

enum RUNMODE { runtime, edit, debug }

typedef ResponsiveValueGroup = ({CATEGORY category, double fromExcludeSizeRatio, double toIncludeSizeRatio, RCPair rowColumn, Size? singleAspectRatio});
typedef HandsetValueGroup = ({RCPair rowColumn, Size? singleAspectRatio, RUNMODE mode, ScreenContext screen, GridContext? grid});
typedef ResponseAdaptiveCallback = HandsetValueGroup? Function({required ResponsiveValueGroup matched, required Size size});
typedef WidgetsBuilder = List<Widget>? Function(BuildContext context, String? singlePT, String? contextPT);

class KetchupUIResponsive extends StatefulWidget{
  final List<ResponsiveValueGroup> responses;
  final Key? ketchupKey;
  final HandsetValueGroup? init;
  final ResponseAdaptiveCallback? cb;
  final WidgetsBuilder? widgetsBuilder;
  const KetchupUIResponsive({super.key, this.widgetsBuilder, this.ketchupKey, required this.responses, this.cb, this.init});
  @override
  State<StatefulWidget> createState()=> _KetchupUIResponsiveState();
}

class _KetchupUIResponsiveState extends State<KetchupUIResponsive>{

  ResponsiveValueGroup? lastResponse;

  @override
  void initState() {
    super.initState();
    lastResponse = null;  
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
        print('layout-biggest:${constraints.biggest}');
        // print('layout-smallest:${constraints.smallest}');
        if(widget.responses.isNotEmpty){
          for(ResponsiveValueGroup group in widget.responses){
            if(group.fromExcludeSizeRatio < constraints.biggest.aspectRatio && constraints.biggest.aspectRatio <= group.toIncludeSizeRatio){
              if(lastResponse != group){
                lastResponse = group;
                var cbResult = widget.cb?.call(matched: group, size: constraints.biggest);
                return KetchupUISized(key: widget.ketchupKey,
                    widgetsBuilder: widget.widgetsBuilder,
                    rowColumn: cbResult?.rowColumn ?? widget.init?.rowColumn ?? group.rowColumn, 
                    singleAspectRatio: cbResult != null ? cbResult.singleAspectRatio : (widget.init != null ? widget.init!.singleAspectRatio : group.singleAspectRatio), 
                    size: constraints.biggest, 
                    mode: cbResult?.mode ?? widget.init?.mode ?? RUNMODE.debug, 
                    grid: cbResult?.grid ?? widget.init?.grid,
                    screen: cbResult?.screen ?? widget.init?.screen ?? ScreenContext.fromRVG(group));
              }
              break;
            }
          }
        }
        var init = widget.init;
        return init != null ? KetchupUISized(key: widget.ketchupKey, 
          widgetsBuilder: widget.widgetsBuilder,
          rowColumn: init.rowColumn, singleAspectRatio: init.singleAspectRatio, 
          size: constraints.biggest,mode: init.mode, screen: init.screen, grid: init.grid) : Container();
    });
    
  }
}

class KetchupUILayout extends StatelessWidget{

  final Size? singleAspectRatio;
  final RCPair rowColumn;
  final double gapspan;
  final RUNMODE mode;
  final ScreenContext screen;
  final GridContext? grid;
  final Key? statefulKey;
  final WidgetsBuilder? widgetsBuilder;
  const KetchupUILayout({super.key, this.statefulKey, this.widgetsBuilder,
    this.singleAspectRatio, this.gapspan = 0, 
    required this.screen, 
    this.grid,
    this.mode = RUNMODE.debug,
    required this.rowColumn });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((BuildContext context, BoxConstraints constraints){
        print('layout-biggest:${constraints.biggest}');
        // print('layout-smallest:${constraints.smallest}');
        return KetchupUISized(key: statefulKey,
          widgetsBuilder: widgetsBuilder,
          screen: screen,
          grid: grid,
          rowColumn: rowColumn, singleAspectRatio: singleAspectRatio, size: constraints.biggest, mode: mode);
      }));
  }
  
}

class KetchupUISized extends StatefulWidget{

  final Size? singleAspectRatio;
  final RCPair rowColumn;
  final Size size;
  final double gapspan;
  final RUNMODE mode;
  final ScreenContext screen;
  final GridContext? grid;
  final WidgetsBuilder? widgetsBuilder;
  const KetchupUISized({ super.key,
    required this.rowColumn, 
    required this.screen,
    required this.size, 
    this.widgetsBuilder, this.singleAspectRatio, 
    this.mode = RUNMODE.debug, this.gapspan = 0, this.grid });
  
  @override
  State<StatefulWidget> createState() => KetchupUIState();
}

class KetchupUIState extends State<KetchupUISized>{

  ScreenContext get screen => widget.screen;
  GridContext? get grid => widget.grid;

  Size? size;
  int renderTimes = 0;
  List<Widget> singleColumnChildren = [];
  Map<int, Map<String, Widget>> screenContextMapChild = {};
  Map<String, List<Widget>> screenContextDirectChildren = {};

  Widget fullscreenAspectRatioRow({required Widget child, required double? fullScreenAspectRatio}){
    return fullScreenAspectRatio != null ? SizedBox(
        height: double.infinity,
        child: AspectRatio(aspectRatio: fullScreenAspectRatio, child: child,)) : child; 
  }

  Widget outsideRowExpandedAspectRatio({required Widget child, int flex = 1, double? aspectRatio}){
    if(aspectRatio != null){
      return child;
    }else {
      /// 横向 Expanded
      return Expanded(
      flex: flex,
      child: child);
    }
  }
  
  Widget insideColumnExpandedAspectRatio({required Widget child, int flex = 1, double? aspectRatio}){ 
      if(aspectRatio != null){
        /// 纵向 Expanded
        return Expanded(
          flex: flex,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: child
        ));
      }else{
        /// 纵向 Expanded
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

  Widget editModeGridWrapping({required Widget child}){
    return grid != null && screen.mode != RUNMODE.runtime ? CustomPaint(foregroundPainter: GridPainter(context: grid! ), child: child,) : child;
  }

  Widget leafContainerWrapping({Key? key, Color? editModeColor, List<Widget>? children, required String leafName, Size? aspectRatio, String? extra, required BuildContext context}){
    print('widgetsBuilder:${widget.widgetsBuilder}');
    return editModeGridWrapping(child: Container(
            key: key,
            width: double.infinity,
            decoration: BoxDecoration(
              color: screen.mode == RUNMODE.edit ? editModeColor : null,
              border: screen.mode != RUNMODE.runtime && editModeColor != null ? Border.all(color: editModeColor) : null,
              // color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: []
                ..addAll(widget.widgetsBuilder?.call(context, extra ?? leafName, 
                  (screen.currentPattern ?? switch(screen.column){2=>PT_SINGLE_TWO,3=>PT_SINGLE_THREE,4=>PT_SINGLE_FOUR,5=>PT_SINGLE_FIVE,_=>PT_SINGLEALL}) ) ?? [])
                ..addAll(widget.mode == RUNMODE.edit ? [
                  AutoSizeText( extra ?? leafName , presetFontSizes: [160, 570], maxLines: 2, style:TextStyle(color: editModeColor?.darken(0.8))),
                  // Text(extra ?? leafName, style: TextStyle(color: editModeColor?.darken(0.8), fontSize: 570),)
                ]:[])
                // ..addAll(widget.mode == RUNMODE.edit && screen.gKeyMappedValues[leafName]?.$2 != null ? [
                //   Container(
                //     width: double.infinity,
                //     height: double.infinity,
                //     child: RepaintBoundary(
                //       child: CustomPaint(painter: GridPainter(context: grid ?? GridContext()), size: screen.gKeyMappedValues[leafName]!.$2!),
                //     )
                //   )
                // ]:[])
                ..addAll(
                  widget.mode != RUNMODE.runtime && screen.gKeyMappedValues.containsKey(leafName) ? 
                  [Column(
                    children: [
                      RightText(screen.gKeyMappedValues[leafName]!.$2.toString()),
                      aspectRatio != null ? 
                      RightText('aspectRadioSet ${aspectRatio.aspectRatio.toStringAsFixed(6)}(${aspectRatio.width} : ${aspectRatio.height})') : 
                      RightText('aspectRadioSet null'),
                      RightText('aspectRadioCal ${screen.gKeyMappedValues[leafName]!.$2!.aspectRatio.toStringAsFixed(6)}'),
                      RightText('= 9.0 : ${(9.0 / screen.gKeyMappedValues[leafName]!.$2!.aspectRatio).toStringAsFixed(2)} =16.0 : ${(16.0 / screen.gKeyMappedValues[leafName]!.$2!.aspectRatio).toStringAsFixed(2)}'),
                      RightText(screen.gKeyMappedValues[leafName]!.$3.toString()),
                      // RightText('size:${(core.gKeys[leafName]!.currentContext!.findRenderObject() as RenderBox).localToGlobal(Offset.zero).toString()}')
                    ],
                  )] :[])
            )));
  }

  List<Widget> createFromScreenContextPatterns({ required BuildContext context, required String screenContextPattern }){
    print('context render invoke(${++renderTimes})');
    var retList;
    if(screenContextPattern == PT_FULLSCREEN){
      retList = [outsideRowExpandedAspectRatio( aspectRatio: screen.fullscreenAspectRatioSize?.aspectRatio,
            child: Column(
              children:[insideColumnExpandedAspectRatio(
                aspectRatio: screen.fullscreenAspectRatioSize?.aspectRatio,
                child: leafContainerWrapping(
                  context: context,
                  key: screen.gKeys.putIfAbsent(screenContextPattern, ()=>GlobalKey<KetchupUIState>(debugLabel: screenContextPattern)),
                  aspectRatio: screen.fullscreenAspectRatioSize,
                  leafName: screenContextPattern, editModeColor: screen.contextScreenColorMap[screenContextPattern]))]))];
      testNeedMeasure();
      return retList;
    }

    retList = screenContextDirectChildren[screenContextPattern] = (){
      return screenContextPattern.split(',').map<Widget>((String screenPattern){
        if(screenPattern.startsWith('(')){
          var screencount = screenPattern.split('-').length;
          screenContextMapChild.putIfAbsent(screencount,()=>{});
          /// 计算约束
          var widgetSingleAspectRatio = widget.singleAspectRatio;
          Size? calculatedAspectRatio = widgetSingleAspectRatio != null ? 
            Size(widgetSingleAspectRatio.width * screencount /// 此处screencount 相当于widget.rowColumn.column
               , widgetSingleAspectRatio.height * widget.rowColumn.row) : null;
          return outsideRowExpandedAspectRatio( 
            flex: screencount,
            aspectRatio: calculatedAspectRatio?.aspectRatio,
            child: Column(
              children:[
                screenContextMapChild[screencount]![screenPattern] = (){
                  return insideColumnExpandedAspectRatio(
                    flex: screencount,
                    aspectRatio: calculatedAspectRatio?.aspectRatio,
                    child:  leafContainerWrapping(
                      context: context,
                      key: screen.gKeys.putIfAbsent(screenPattern, ()=>GlobalKey<KetchupUIState>(debugLabel: screenPattern)),
                      aspectRatio: calculatedAspectRatio,
                      leafName: screenPattern,
                      editModeColor: screen.contextScreenColorMap[screenPattern],
                  ));
                }()
              ]));
        }
        return singleColumnChildren[int.parse(screenPattern)-1];
      }).toList();
    }();
    testNeedMeasure();
    return retList;
    
  }

  List<Widget> createMultiRowSingleColumnChildren({required BuildContext context, required RCPair rowColumn, ScreenContext? core}){
    print('render invoke(${++renderTimes})');
    singleColumnChildren.clear();
    singleColumnChildren.addAll(
      List.generate(rowColumn.column, (int cIndex)=>
        outsideRowExpandedAspectRatio( aspectRatio: widget.singleAspectRatio?.aspectRatio,
          child: Column(
            children: List.generate(rowColumn.row, (int rIndex)=>insideColumnExpandedAspectRatio( aspectRatio: widget.singleAspectRatio?.aspectRatio,
              child: leafContainerWrapping(
                key: core?.gKeys.putIfAbsent('single-$cIndex-$rIndex', ()=>GlobalKey<KetchupUIState>(debugLabel: 'single-$cIndex-$rIndex')),
                context: context,
                leafName: 'single-$cIndex-$rIndex',
                extra: '${cIndex+1}',
                aspectRatio: widget.singleAspectRatio,
                editModeColor: Colors.primaries[(cIndex * rowColumn.row + rIndex) * 5 % 17].shade100,)
            )),
          )
        )
      )
    );

    testNeedMeasure();

    return singleColumnChildren;
  }
  
  void testNeedMeasure(){
    if(screen.isNeedMeasure || widget.size != size){
      size = widget.size;
      WidgetsBinding.instance.addPostFrameCallback((Duration dt){
          _updateGKeyValueRecords();
          setState((){});
      });
    }
  }

  /// 更新 GKey 测量信息
  void _updateGKeyValueRecords(){
    screen.gKeyMappedValues = screen.gKeys.map<String, GKeyValueRecord>((debugName, gKey)=>MapEntry(debugName, (
            gKey, gKey.currentContext?.size, (gKey.currentContext?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero))));
    screen.gKeyMappedValues.forEach((key, record)=>print('$key:${record.$2}:${record.$3}'));
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
  
  @override
  Widget build(BuildContext context) {
    // KetchupCore core = Provider.of<KetchupCore>(context);
    // print('----------offset:---------');
    // print((context.findRenderObject() as RenderBox).localToGlobal(Offset.zero));
    // return LayoutBuilder(
    //   builder: ((BuildContext context, BoxConstraints constraints){
    //     print('layout-biggest:${constraints.biggest}');
    //     print('layout-smallest:${constraints.smallest}');
    //     renderTimes = 0;
    //     isNeedUpdateFlag = true;
        return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: Colors.grey),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: []
                ..addAll(widget.mode == RUNMODE.edit ? [
                    SizedBox(height: 20),
                    Container(
                      alignment: Alignment(1, 0.5),
                      decoration: BoxDecoration(color: Colors.red),
                      child: Text('${widget.rowColumn.column}个横向排列的 ${widget.singleAspectRatio?.width ?? '-'}:${widget.singleAspectRatio?.height ?? '-'} 比例容器', 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                  ]:[])
                ..add(Expanded(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(color: Colors.blueGrey), 
                    child: fullscreenAspectRatioRow(
                      fullScreenAspectRatio: screen.fullscreenAspectRatioSize?.aspectRatio,
                      child: Row(
                        children: screen.currentPattern == null ? 
                          createMultiRowSingleColumnChildren(context: context, rowColumn: widget.rowColumn, core: screen) :
                          createFromScreenContextPatterns(context: context, screenContextPattern: screen.currentPattern!)
                    ))
                  )
                ))
                
          ));
      //   );}
      // ));
  }
  
  @override
  void initState() {
    super.initState();
    print('initState:$hashCode');
    renderTimes = 0;
    size = widget.size;
    
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose:$hashCode');
  }
}

