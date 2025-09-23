
import 'package:flutter/widgets.dart';

import '../debug/console.dart';
import '../model/accessor.dart';
import '../model/screen.dart';
import '../route.dart';
import '../state.dart';
import 'core.dart';



class SimpleNavigatorPageBuilder extends NavigatorPage{

  final WidgetBuilder? builder;
  final ScreensBuilder? widgetsBuilder;

  SimpleNavigatorPageBuilder({required this.availableColumns, this.builder, this.widgetsBuilder});

  factory SimpleNavigatorPageBuilder.maxPageLevel(int maxPageLevel, ScreensBuilder widgetsBuilder)=>SimpleNavigatorPageBuilder(availableColumns: List.generate(maxPageLevel, (col)=>col), widgetsBuilder: widgetsBuilder);
  
  @override
  Widget fullBuild(BuildContext context) {
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
  List<Widget>? columnBuild(BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT) {
    if(widgetsBuilder != null){
      return widgetsBuilder!.call(context, ctxAccessor, screenPT);
    }
    return [fullBuild(context)];
  }
  
  @override
  List<int> availableColumns;
  
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

abstract class NavPageWidget extends StatelessWidget with KetchupRoutePage, MultiColumns implements PageLifeCycle{
  const NavPageWidget({super.key});
}

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
  Widget fullBuild(BuildContext context) {
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
  List<Widget>? columnBuild(BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT) {
    return [fullBuild(context)];
  }
  
  @override
  List<int> availableColumns;
  
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