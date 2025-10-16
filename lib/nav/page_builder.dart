
// ignore_for_file: must_be_immutable

import 'package:flutter/widgets.dart' hide FocusManager;

import '../debug/console.dart';
import '../remote_focus/focus.dart';
import '../model/accessor.dart';
import '../model/screen/screen.dart';
import '../route.dart';
import '../state.dart';
import 'core.dart';

class SimpleNavigatorPageBuilder extends NavigatorPage {

  final WidgetsBuilder? fgBuilder;
  final WidgetsBuilder? bgBuilder;
  final ColumnsBuilder? columnsBuilder;

  SimpleNavigatorPageBuilder({required this.availableColumns, required this.focusUpdate, this.bgBuilder, this.fgBuilder, this.columnsBuilder});

  factory SimpleNavigatorPageBuilder.maxPageLevel(int maxPageLevel, ColumnsBuilder columnsBuilder, {required void Function(VoidCallback p1, [String? d]) focusUpdate})=>SimpleNavigatorPageBuilder(availableColumns: List.generate(maxPageLevel, (col)=>col), columnsBuilder: columnsBuilder, focusUpdate: focusUpdate);
  
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
  List<Widget>? columnsBuild(BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT) {
    if(columnsBuilder != null){
      return columnsBuilder!.call(context, ctxAccessor, screenPT);
    }
    return [
      ... bgFullBuild(context) ?? [],
      ... fgFullBuild(context) ?? [],
    ];
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
  
  @override
  List<Widget>? bgFullBuild(BuildContext context) {
    return bgFullBuild(context);
  }
  
  @override
  List<Widget>? fgFullBuild(BuildContext context) {
    return fgFullBuild(context);
  }
  
  @override
  List<FocusManager>? findFocusManager(FindFocusPosition position) => null;
  
  @override
  void Function(VoidCallback p1, [String? d]) focusUpdate;

  @override
  ScreenContext? pageScreen;
  
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

abstract class NavPageWidget extends StatelessWidget with FocusRoutePage, FocusManager, MultiColumns implements PageLifeCycle{
  NavPageWidget({super.key});
}

abstract class NavigatorPage extends FocusRoutePage with MultiColumns, FocusManager{

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
  List<Widget>? columnsBuild(BuildContext context, ContextAccessor ctxAccessor, ScreenPT screenPT) {
    return [
      ... bgFullBuild(context) ?? [],
      ... fgFullBuild(context) ?? [],
    ];
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
  
  @override
  List<Widget>? bgFullBuild(BuildContext context) {
    return null;
  }
  
  @override
  List<Widget>? fgFullBuild(BuildContext context) {
    return null;
  }
  
  @override
  List<FocusManager>? findFocusManager(FindFocusPosition position) => null;
  
  @override
  void Function(VoidCallback p1, [String? d]) get focusUpdate => (VoidCallback p1, [String? d]){};

  @override
  ScreenContext? pageScreen;
  
}

extension MultiColumnsExt on String {
  SimpleMultiColumnsImp indexedCol(int col) => SimpleMultiColumnsImp.indexed(col, this);
  SimpleMultiColumnsImp bothendsCol(int col) => SimpleMultiColumnsImp.bothends(col, this);
  SimpleMultiColumnsImp evenCol(int col) => SimpleMultiColumnsImp.even(col, this);
  SimpleMultiColumnsImp oddsCol(int col) => SimpleMultiColumnsImp.odds(col, this);
}