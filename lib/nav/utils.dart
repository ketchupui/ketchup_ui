import 'dart:math';
import '../model/screen/screen.dart';

List<int> availableColumns(List<int> available, int maxColumn, [int minColumn = 1]){
  assert(available.isNotEmpty);
  return available.where((a)=>a <= maxColumn && a >= minColumn).toList() ..sort((a, b)=>b.compareTo(a));
}

int? nextColumnLess(List<int> available, int nowColumn, int maxColumn){
  return availableColumns(available, min(nowColumn, maxColumn) - 1).firstOrNull;
}

int? nextColumnMore(List<int> available, int nowColumn, int maxColumn){
  return availableColumns(available, maxColumn, nowColumn + 1).lastOrNull;
}

List<(ScreenPT,T)> mergeScreenPT<T>(List<String> pts, String contextPT, List<T> list){
  return list.indexed.map<(ScreenPT,T)>((indexed)=>((pts[indexed.$1], contextPT), indexed.$2)).toList();
  // return pts.indexed.map((indexed)=>((indexed.$2, contextPT), list[indexed.$1])).toList();
}