
import '../route.dart';

mixin RouteFinder {
  List<KetchupRoute> get routes;
  
  String? get currentRoute;
   
  (KetchupRoute, Map<String, String>)? _find(List<String> splits, {KetchupRoute? root, Map<String, String>? param, int level = 1}){
    var params = param ?? {};
    for(var route in (root?.routes ?? routes)){
      var count = route.separates.length;
      var nextIndex = count; /// 如果匹配默认截断数量
      /// match 规则
      if(splits.length >= count && route.separates.indexed.every((sep){
          switch(sep.$2.type){
            case PathType.root:
              return splits[sep.$1] == '';
            case PathType.static:
              return splits[sep.$1] == sep.$2.name;
            case PathType.dynamic:
              params[sep.$2.name!] = splits[sep.$1];
              return true;
            case PathType.wildcard:
              nextIndex = splits.length;
              params[sep.$2.name!] = splits.sublist(sep.$1).join('/');
              return true;
          }
        })){
          /// 终局
          if(nextIndex == splits.length){
            return (route, { ...params, '_level': level.toString(), '_matched': route.path, '_debug': '$level->${route.path}' } );
          }else
          /// 递归
          if(nextIndex >=0 && nextIndex < splits.length){
            var result = _find(splits.sublist(nextIndex), root: route, param: params, level: level + 1);
            if(result != null) return result;
          }
      }
    }
    return null;
  }
  
  (KetchupRoute, Map<String, String>)? find(String routeParams){
    int queryIndex = routeParams.indexOf('?');
    int hashIndex = routeParams.indexOf('#');
    String pathString = routeParams.substring(0, queryIndex != -1 ? queryIndex : (hashIndex != -1 ? hashIndex : routeParams.length));
    String queryString = queryIndex != -1 ? routeParams.substring(queryIndex + 1, hashIndex != -1 ? hashIndex : routeParams.length) : '';
    String hashString = hashIndex != -1 ? routeParams.substring(hashIndex + 1) : '';
    return _find( 
      pathString.split('/'), 
      param: { '_path': routeParams, '_hash': hashString, ...parseQuery(queryString) });
  }
}

class RouteFinderTester with RouteFinder{

  RouteFinderTester(this.routes);

  @override
  String? get currentRoute => '';

  @override
  List<KetchupRoute> routes;
    
}