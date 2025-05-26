
import 'package:flutter/widgets.dart';
import '../debug/console.dart';
import '../ketchup_ui.dart';

class SimpleNavigatorPageBuilder extends NavigatorPage{

  final WidgetBuilder? builder;
  final WidgetsBuilder? widgetsBuilder;

  SimpleNavigatorPageBuilder({required this.availableColumns, this.builder, this.widgetsBuilder});

  factory SimpleNavigatorPageBuilder.maxPageLevel(int maxPageLevel, WidgetsBuilder widgetsBuilder)=>SimpleNavigatorPageBuilder(availableColumns: List.generate(maxPageLevel, (col)=>col), widgetsBuilder: widgetsBuilder);
  
  @override
  Widget build(BuildContext context) {
    return builder?.call(context) ?? Container();
  }

  @override
  void onDestroy() {
  }

  @override
  void onPause() {
  }

  @override
  void onScreenWillChange(ScreenPT willChangePT) {
  }

  @override
  void onStateInit(void Function(VoidCallback c, [String? d]) stateUpdater) {
  }
  
  @override
  List<Widget>? screenBuild(BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT) {
    if(widgetsBuilder != null){
      return widgetsBuilder!.call(context, ctxAccessor, screenPT);
    }
    return [build(context)];
  }
  
  @override
  List<int> availableColumns;
  
  @override
  int weight(int columns, int newPageLevel, bool isNewPage) {
    return newPageLevel;
  }
  
  @override
  void onCreate() {
  }
  
  @override
  void onMeasured(ScreenContext screen) {
  }
  
  @override
  void onResume() {
  }
  
  @override
  void onReceive(Map<String, String>? params) {
  }
  
}

abstract mixin class MultiColumns {
  List<int> get availableColumns;
  static List<int> indexed(int columns) => columns > 1 ? List.generate(columns, (c)=>c+1) : [1];
  static List<int> bothends(int columns) => columns > 1 ? [1, columns] : [1];
  static List<int> even(int columns) =>columns > 1 ? List.generate(columns, (c){
    if(c == 0 || c == columns -1 ) return c + 1;
    return (c + 1) % 2 == 0 ? c + 1 : -1;
  }).where((i)=>i != -1).toList() : [1];
  static List<int> odds(int columns) => columns > 1 ? List.generate(columns, (c){
    if(c == 0 || c == columns - 1) return c + 1;
    return (c + 1) % 2 == 0 ? -1 : c + 1;
  }).where((i)=>i != -1).toList() : [1];
  List<int> union(MultiColumns target) => availableColumns.toSet().union(target.availableColumns.toSet()).toList();
  List<int> difference(MultiColumns target) => [1, ...availableColumns.toSet().difference(target.availableColumns.toSet())];
  List<int> intersection(MultiColumns target) => availableColumns.toSet().intersection(target.availableColumns.toSet()).toList();
}

class SimpleMultiColumnsImp extends MultiColumns{
  
  // final int column;
  final String? debug;
  SimpleMultiColumnsImp(this.availableColumns, [this.debug]);
  factory SimpleMultiColumnsImp.indexed(int columns, [String? debug])=>SimpleMultiColumnsImp(MultiColumns.indexed(columns), debug);
  factory SimpleMultiColumnsImp.bothends(int columns, [String? debug])=>SimpleMultiColumnsImp(MultiColumns.bothends(columns), debug);
  factory SimpleMultiColumnsImp.even(int columns, [String? debug])=>SimpleMultiColumnsImp(MultiColumns.even(columns), debug);
  factory SimpleMultiColumnsImp.odds(int columns, [String? debug])=>SimpleMultiColumnsImp(MultiColumns.odds(columns), debug);

  SimpleMultiColumnsImp uni(SimpleMultiColumnsImp target) => SimpleMultiColumnsImp(union(target), debug);
  SimpleMultiColumnsImp dff(SimpleMultiColumnsImp target) => SimpleMultiColumnsImp(difference(target), debug);
  SimpleMultiColumnsImp itrsc(SimpleMultiColumnsImp target) => SimpleMultiColumnsImp(intersection(target), debug);
  
  @override
  final List<int> availableColumns;
  
  @override
  String toString() {
    return debug ?? super.toString();
  }
}

abstract class NavigatorPageWidget extends StatelessWidget with KetchupRoutePage, MultiColumns {}

abstract class NavigatorPage extends KetchupRoutePage with MultiColumns {

  /// 用于根据栏目数确定权值，不支持栏目数则返回 0
  /// 根据是否是新页面来进行新页面提权
  /// 根据是否是单页面和同级别页面确定收缩提权
  // int weight(int columns, int newPageLevel, bool isNewPage);
  
  /// 默认的屏幕权值模板
  /// https://immvpc32u2.feishu.cn/docx/NmMyd8g5ZoRXovxg2qscq36VnOe?from=from_copylink
  // int useWeightPattern(int column){
  //   return switch(column){
  //     1=>50000,
  //     2=>5000,
  //     3=>500,
  //     4=>50,
  //     5=>5,
  //     _=>1
  //   };
  // } 
}

const DEFAULT_NAME = 'test-page';
class TestableRoutePage extends NavigatorPage with vConsole{

  String name;
  TestableRoutePage([this.name = DEFAULT_NAME, this.availableColumns = const [1]]);
  factory TestableRoutePage.indexed(int columns, {String name = DEFAULT_NAME})=>TestableRoutePage(name, MultiColumns.indexed(columns));
  factory TestableRoutePage.bothends(int columns, {String name = DEFAULT_NAME})=>TestableRoutePage(name, MultiColumns.bothends(columns));
  factory TestableRoutePage.even(int columns, {String name = DEFAULT_NAME})=>TestableRoutePage(name, MultiColumns.even(columns));
  factory TestableRoutePage.odds(int columns, {String name = DEFAULT_NAME})=>TestableRoutePage(name, MultiColumns.odds(columns));
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void onCreate() {
    console('$name created');
  }

  @override
  void onDestroy() {
    console('$name destroyed');
  }

  @override
  void onPause() {
    console('$name pause');
  }

  @override
  void onScreenWillChange(ScreenPT willChangePT) {
    console('$name screenWillChange $willChangePT');
  }

  @override
  void onStateInit(void Function(VoidCallback c, [String? d]) stateUpdater) {
  }

  @override
  List<Widget>? screenBuild(BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT) {
    return [build(context)];
  }
  
  @override
  List<int> availableColumns;
  
  @override
  int weight(int columns, int newPageLevel, bool isNewPage) {
    return newPageLevel;
  }
  
  @override
  void onMeasured(ScreenContext screen) {
    console('$name measured');
  }
  
  @override
  void onResume() {
    console('$name resume');
  }
  
  @override
  void onReceive(Map<String, String>? params) {
  }
  
}

extension MultiColumnsExt on String {
  SimpleMultiColumnsImp indexedCol(int col) => SimpleMultiColumnsImp.indexed(col, this);
  SimpleMultiColumnsImp bothendsCol(int col) => SimpleMultiColumnsImp.bothends(col, this);
  SimpleMultiColumnsImp evenCol(int col) => SimpleMultiColumnsImp.even(col, this);
  SimpleMultiColumnsImp oddsCol(int col) => SimpleMultiColumnsImp.odds(col, this);
}