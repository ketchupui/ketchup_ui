import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'utils.dart';
import 'model.dart';

enum RUNMODE { runtime, edit, debug }

typedef ResponsiveValueGroup = ({CATEGORY category, double fromExcludeSizeRatio, double toIncludeSizeRatio, RCPair rowColumn, Size? singleAspectRatio});
typedef HandsetValueGroup = ({RCPair rowColumn, Size? singleAspectRatio, RUNMODE mode, KetchupModel model});
typedef ResponseAdaptiveCallback = HandsetValueGroup? Function({required ResponsiveValueGroup matched, required Size size});

class KetchupUIResponsive extends StatefulWidget{
  final List<ResponsiveValueGroup> responses;
  final Key? ketchupKey;
  final HandsetValueGroup? init;
  final ResponseAdaptiveCallback? cb;
  const KetchupUIResponsive({super.key, this.ketchupKey, required this.responses, this.cb, this.init});
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
                    rowColumn: cbResult?.rowColumn ?? widget.init?.rowColumn ?? group.rowColumn, 
                    singleAspectRatio: cbResult != null ? cbResult.singleAspectRatio : (widget.init != null ? widget.init!.singleAspectRatio : group.singleAspectRatio), 
                    size: constraints.biggest, 
                    mode: cbResult?.mode ?? widget.init?.mode ?? RUNMODE.debug, 
                    model: cbResult?.model ?? widget.init?.model ?? KetchupModel.fromRVG(group));
              }
              break;
            }
          }
        }
        var init = widget.init;
        return init != null ? KetchupUISized(key: widget.ketchupKey, 
          rowColumn: init.rowColumn, singleAspectRatio: init.singleAspectRatio, 
          size: constraints.biggest,mode: init.mode, model: init.model) : Container();
    });
    
  }
}

class KetchupUILayout extends StatelessWidget{

  final Size? singleAspectRatio;
  final RCPair rowColumn;
  final double gapspan;
  final RUNMODE mode;
  final KetchupModel model;
  final Key? statefulKey;
  const KetchupUILayout({super.key, this.statefulKey, 
    this.singleAspectRatio, this.gapspan = 0, 
    required this.model, 
    this.mode = RUNMODE.debug,
    required this.rowColumn });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((BuildContext context, BoxConstraints constraints){
        print('layout-biggest:${constraints.biggest}');
        // print('layout-smallest:${constraints.smallest}');
        return KetchupUISized(key: statefulKey,
          model: model,
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
  final KetchupModel model;
  const KetchupUISized({ super.key, this.singleAspectRatio, required this.rowColumn, required this.size, this.mode = RUNMODE.debug, this.gapspan = 0, required this.model });
  
  @override
  State<StatefulWidget> createState() => KetchupUIState();
}

class KetchupUIState extends State<KetchupUISized>{

  KetchupModel get model => widget.model;
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

  Widget leafContainerWrapping({Key? key, Color? editModeColor, List<Widget>? children, required String leafName, Size? aspectRatio, String? extra}){
    return Container(
            key: key,
            width: double.infinity,
            decoration: BoxDecoration(
              color: model.mode == RUNMODE.edit ? editModeColor : null,
              border: model.mode != RUNMODE.runtime && editModeColor != null ? Border.all(color: editModeColor) : null,
              // color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: []
                ..addAll(widget.mode == RUNMODE.edit ? [
                  AutoSizeText( extra ?? leafName , presetFontSizes: [160, 570], maxLines: 2, style: TextStyle(color: editModeColor?.darkenColor())),
                  // Text(extra ?? leafName, style: TextStyle(color: editModeColor?.darken(0.8), fontSize: 570),)
                ]:[])
                ..addAll(
                  widget.mode != RUNMODE.runtime && model.gKeyMappedValues.containsKey(leafName) ? 
                  [Column(
                    children: [
                      Text(model.gKeyMappedValues[leafName]!.$2.toString()),
                      aspectRatio != null ? 
                      Text('aspectRadioSet ${aspectRatio.aspectRatio.toStringAsFixed(6)}(${aspectRatio.width} : ${aspectRatio.height})') : 
                      Text('aspectRadioSet null'),
                      Text('aspectRadioCal ${model.gKeyMappedValues[leafName]!.$2!.aspectRatio.toStringAsFixed(6)}'),
                      Text('= 9.0 : ${(9.0 / model.gKeyMappedValues[leafName]!.$2!.aspectRatio).toStringAsFixed(2)} =16.0 : ${(16.0 / model.gKeyMappedValues[leafName]!.$2!.aspectRatio).toStringAsFixed(2)}'),
                      Text(model.gKeyMappedValues[leafName]!.$3.toString()),
                      // Text('size:${(core.gKeys[leafName]!.currentContext!.findRenderObject() as RenderBox).localToGlobal(Offset.zero).toString()}')
                    ],
                  )] :[])
                ..addAll(children ?? [])
            ));
  }

  List<Widget> createFromScreenContextPatterns({ required String screenContextPattern }){
    print('context render invoke(${++renderTimes})');
    var retList;
    if(screenContextPattern == KetchupModel.PT_FULLSCREEN){
      retList = [outsideRowExpandedAspectRatio( aspectRatio: model.fullscreenAspectRatioSize?.aspectRatio,
            child: Column(
              children:[insideColumnExpandedAspectRatio(
                aspectRatio: model.fullscreenAspectRatioSize?.aspectRatio,
                child: leafContainerWrapping(
                  key: model.gKeys.putIfAbsent(screenContextPattern, ()=>GlobalKey<KetchupUIState>(debugLabel: screenContextPattern)),
                  aspectRatio: model.fullscreenAspectRatioSize,
                  leafName: screenContextPattern, editModeColor: model.contextScreenColorMap[screenContextPattern]))]))];
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
                      key: model.gKeys.putIfAbsent(screenPattern, ()=>GlobalKey<KetchupUIState>(debugLabel: screenPattern)),
                      aspectRatio: calculatedAspectRatio,
                      leafName: screenPattern,
                      editModeColor: model.contextScreenColorMap[screenPattern],
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

  List<Widget> createMultiRowSingleColumnChildren({required RCPair rowColumn, KetchupModel? core}){
    print('render invoke(${++renderTimes})');
    singleColumnChildren.clear();
    singleColumnChildren.addAll(
      List.generate(rowColumn.column, (int cIndex)=>
        outsideRowExpandedAspectRatio( aspectRatio: widget.singleAspectRatio?.aspectRatio,
          child: Column(
            children: List.generate(rowColumn.row, (int rIndex)=>insideColumnExpandedAspectRatio( aspectRatio: widget.singleAspectRatio?.aspectRatio,
              child: leafContainerWrapping(
                key: core?.gKeys.putIfAbsent('single-$cIndex-$rIndex', ()=>GlobalKey<KetchupUIState>(debugLabel: 'single-$cIndex-$rIndex')),
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
    if(model.isNeedMeasure || widget.size != size){
      size = widget.size;
      WidgetsBinding.instance.addPostFrameCallback((Duration dt){
          _updateGKeyValueRecords();
          setState((){});
      });
    }
  }

  /// 更新 GKey 测量信息
  void _updateGKeyValueRecords(){
    model.gKeyMappedValues = model.gKeys.map<String, GKeyValueRecord>((debugName, gKey)=>MapEntry(debugName, (
            gKey, gKey.currentContext?.size, (gKey.currentContext?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero))));
    model.gKeyMappedValues.forEach((key, record)=>print('$key:${record.$2}:${record.$3}'));
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
                      fullScreenAspectRatio: model.fullscreenAspectRatioSize?.aspectRatio,
                      child: Row(
                        children: model.currentPattern == null ? 
                          createMultiRowSingleColumnChildren(rowColumn: widget.rowColumn, core: model) :
                          createFromScreenContextPatterns(screenContextPattern: model.currentPattern!)
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

