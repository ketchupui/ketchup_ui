import 'package:collection/collection.dart';
import '../debug/console.dart';
import 'utils.dart';
 
typedef Navigatable<T> = (int, int, T);
typedef NavigatableList<T> = List<Navigatable<T>>;
typedef NavCtntPair<T> = (NavigatableList<T>, NavigatableList<T>);
typedef SinglenNavigatableAvbCols = List<int>;
typedef AvailabeColPattern = List<int>;

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

abstract class NavigatorCore<T extends MultiColumns> with vConsole {

  int get contentPageClass;
  
  int get screenColumn;

  /// 非连续内容扩展算法 https://immvpc32u2.feishu.cn/docx/SlLddeDrJoCW9ox4igYcPNSTnSd?from=from_copylink
  /// 6月22日改为可伸展可折叠(新增折叠)，可返回 null 表示不可伸缩
  NavCtntPair<T>? expandCollapse(NavCtntPair<T> currentPages, int givenScreenColumn){
    NavigatableList<T> navigates = currentPages.$1;
    NavigatableList<T> contents = currentPages.$2;
    // var current = [...navigates, ...contents ];
    // var currentColumnsNum = current.fold<int>(0, (count, item)=>count + item.$2);

    List<SinglenNavigatableAvbCols> navigatesAvbCols = avbColsList(navigates); 
    List<SinglenNavigatableAvbCols> contentsAvbCols = avbColsList(contents);
    //// 没有任何扩展性 返回原值
    if(navigatesAvbCols.isEmpty && contentsAvbCols.isEmpty) return currentPages;
    // var expandColumnsNum = screenColumn - currentColumnsNum;

    /// 内容从新到旧
    /// [3,2,1][4,2][3,1] 变成 [3,4,3][3,4,1][3,2,3][3,2,1][2,4,3][2,4,1]...
    List<AvailabeColPattern> recursiveCombine(List<SinglenNavigatableAvbCols> r){
      assert(r.isNotEmpty);
      if(r.length == 1) {
        /// 拆包最后一个 SingleAvbCol
        return r.single.map<AvailabeColPattern>((int col)=> [ col ] ).toList();
      } else if(r.length > 1){
        /// 拆包第一个 SingleAvbCol
        SinglenNavigatableAvbCols first = r.first;
        List<AvailabeColPattern> rest = recursiveCombine(r..removeAt(0));
        return first.expand<AvailabeColPattern>((int putF)=> rest.map<AvailabeColPattern>((AvailabeColPattern restPtn)=>[ putF, ...restPtn ])).toList();
      } else {
        return [<int>[]];
      }
    }

    AvailabeColPattern? target = recursiveCombine([ ...contentsAvbCols, ...navigatesAvbCols.reversed ]).firstWhereOrNull((AvailabeColPattern test){
      return test.sum <= givenScreenColumn;
    });
    if(target == null) return null;

    var navColumns = target.sublist(contentsAvbCols.length).reversed.toList();
    var ctnColumns = target.sublist(0, contentsAvbCols.length);

    return (navigates.mapIndexed((i, nav)=>(nav.$1, navColumns[i].toInt(), nav.$3)).toList(), 
            contents.mapIndexed((i, ctn)=>(ctn.$1, ctnColumns[i].toInt(), ctn.$3)).toList());
  }
  
  List<SinglenNavigatableAvbCols> avbColsList(NavigatableList<T> nav) => nav.map((ctn)=>availableColumns(ctn.$3.availableColumns, ctn.$1, ctn.$2)).toList();

  String expandString(NavCtntPair<T> currentPages) => expandCollapse(currentPages, screenColumn).toString();

  (NavCtntPair<T>, NavigatableList<T>) shiftExpand(NavCtntPair<T> currentPages, Navigatable<T> insertPage){
    var shiftPair = shift(currentPages, insertPage);
    return (expandCollapse(shiftPair.$1, screenColumn)!, shiftPair.$2);
  }

  String shiftExpandString(NavCtntPair<T> currentPages, Navigatable<T> insertPage)=>shiftExpand(currentPages, insertPage).$1.toString();

  (NavCtntPair<T>, NavigatableList<T>) shift(NavCtntPair<T> currentPages, Navigatable<T> insertPage){
    var navigates = currentPages.$1;
    var contents = currentPages.$2;
    var insertPageClass = insertPage.$1;
    var newColumnNumber = insertPage.$2;
    var isContentPage = insertPage.$1 <= contentPageClass;
    NavigatableList<T> removeList = [];
    var newpageInsertStartIndex = !isContentPage ?  navigates.indexWhere((page)=>insertPageClass >= page.$1) : -1;

    // List<int, int, T?> mapDecline(List<int, int, T?> willMap, ){
    //   return willMap.map((item){
    //       if(willFoldColumnNumber > 0){
    //         willFoldColumnNumber --;
    //         return (item.$1, item.$2 - 1, item.$3);
    //       } else {
    //         return item;
    //       }
    //     }).toList();
    // }
    
    //// https://immvpc32u2.feishu.cn/docx/R427dV9WbonppxxMv1xc1Jt4n8c#share-HA0odkwJsoOSmYxTx0ZcK4MfnLf
    //// 剔除算法
    if(newpageInsertStartIndex != -1){
      removeList.addAll(navigates.getRange(newpageInsertStartIndex, navigates.length));
      navigates.removeRange(newpageInsertStartIndex, navigates.length);
    }

    var current = [...navigates, ...contents ];
    int currentColumnsNum = current.fold<int>(0, (count, item)=>count + item.$2);
    /// 逻辑最小和逻辑最大不一定可用
    // int foldedColumnsNum = current.length;
    // int expandColumnsNum = current.fold(0, (count, item)=>count + item.$1);
    int foldedColumnsNum = current.fold<int>(0, (count, item)=>count + (availableColumns(item.$3.availableColumns, item.$1).lastOrNull ?? item.$2));
    
    // int minExpandNum = current.map((item){
    //   var next = nextColumnLess(item.$3.availableColumns, item.$2 + 1, item.$1);
    //   return next != null ? next - item.$2 : -1;
    // }).where((i)=>i > 0).sorted((a, b)=>b.compareTo(a)).lastOrNull ?? 0;
    // bool canExpand = minExpandNum > 0;
    // int expandMinColumnsNum = currentColumnsNum + minExpandNum;
    // int expandMaxColumnsNum = current.fold<int>(0, (count, item)=>count + (availableColumns(item.$3.availableColumns, item.$1).firstOrNull ?? item.$2));
    
    /// 
    if(newColumnNumber + foldedColumnsNum >= screenColumn){
      var count = newColumnNumber + foldedColumnsNum - screenColumn;
      if(count > 0){
        var popIndex = contents.length - count;
        /// 执行退栈
        removeList.addAll(contents.getRange(popIndex, contents.length));
        contents.removeRange(popIndex, contents.length);
      }
      /// 执行最大折叠
      // navigates = navigates.map((willFold)=>(willFold.$1, 1, willFold.$3)).toList();
      // contents = contents.map((willFold)=>(willFold.$1, 1, willFold.$3)).toList();
      navigates = navigates.map((willFold)=>(willFold.$1, availableColumns(willFold.$3.availableColumns, willFold.$1).last, willFold.$3)).toList();
      contents = contents.map((willFold)=>(willFold.$1, availableColumns(willFold.$3.availableColumns, willFold.$1).last, willFold.$3)).toList();
    }else
    if(newColumnNumber + currentColumnsNum > screenColumn){
      /// 执行折叠算法-决定折叠谁 叠多少(必然有没折叠的)
      var willFoldColumnNumber = newColumnNumber + currentColumnsNum - screenColumn;
      /// 先将导航栈按照从大到小折叠，再将内容栈从旧到新折叠(逐一折叠：一次折一列(不一定是一列但最少是一列))
      while(willFoldColumnNumber > 0){
        navigates = navigates.map((nv){
          var next = nextColumnLess(nv.$3.availableColumns, nv.$2, nv.$1);
          if(willFoldColumnNumber > 0 && next != null){
          // if(willFoldColumnNumber > 0 && nv.$2 > 1){
            // willFoldColumnNumber --;
            // return (nv.$1, nv.$2 - 1, nv.$3);
            willFoldColumnNumber -= nv.$2 - next;
            return (nv.$1, next, nv.$3);
          } else {
            return nv;
          }
        }).toList();
        if(willFoldColumnNumber > 0){
          contents = contents.reversed.map((ct){
            var next = nextColumnLess(ct.$3.availableColumns, ct.$2, ct.$1);
            if(willFoldColumnNumber > 0 && next != null){
            // if(willFoldColumnNumber > 0 && ct.$2 > 1){
              // willFoldColumnNumber --;
              // return (ct.$1, ct.$2 - 1, ct.$3);
              willFoldColumnNumber -= ct.$2 - next;
              return (ct.$1, next, ct.$3);
            } else {
              return ct;
            }
          }).toList().reversed.toList();
        }
      }
    }
    // else
    // /// 扩展算法有个前提： 最小扩展 > 0 最小扩展栏目数 <= screenColumn 
    // if(newColumnNumber + currentColumnsNum < screenColumn && canExpand && expandMinColumnsNum <= screenColumn){
    //   /// 内容扩展算法(同时受到 可以展开的最大值 和 屏幕最大值两个限制)
    //   var willExpandColumnNumber = min(screenColumn - newColumnNumber - currentColumnsNum, expandMaxColumnsNum - currentColumnsNum);
    //   /// 先将内容栈按照从新到旧扩展，再从导航栈按照从小到大扩展
    //   while(willExpandColumnNumber > 0){
    //     contents = contents.map((ct){
    //       if(willExpandColumnNumber > 0 && ct.$2 <= ct.$1){
    //         willExpandColumnNumber --;
    //         return (ct.$1, ct.$2 + 1, ct.$3);
    //       } else {
    //         return ct;
    //       }
    //     }).toList();
    //     if(willExpandColumnNumber > 0){
    //       navigates = navigates.reversed.map((nv){
    //         if(willExpandColumnNumber > 0 && nv.$2 <= nv.$1){
    //           willExpandColumnNumber --;
    //           return (nv.$1, nv.$2 + 1, nv.$3);
    //         } else {
    //           return nv;
    //         }
    //       }).toList().reversed.toList();
    //     }
    //   }
    // }
    /// 插入元素
    if(isContentPage){
      return ((navigates, contents ..insert(0, insertPage)), removeList);
    }else
    if(newpageInsertStartIndex != -1){
      return ((navigates ..insert(newpageInsertStartIndex, insertPage), contents), removeList);
    }else{
      return ((navigates ..add(insertPage), contents), removeList);
    }
  }
  
  String shiftString(NavCtntPair<T> currentPages, Navigatable<T> insertPage) => shift(currentPages, insertPage).$1.toString();

}

class NavigatorCoreTester<T extends MultiColumns> extends NavigatorCore<T>{

  NavigatorCoreTester({required this.contentPageClass, required this.screenColumn});

  @override
  int contentPageClass;

  @override
  int screenColumn;
}
