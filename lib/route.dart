import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'model.dart';
import 'state.dart';

typedef MatchGroup = (int weight, String? screenPT, String? contextPT);

class KetchupRoute extends GoRoute{
  List<MatchGroup>? screenContextMatches;
  KetchupRoute({required super.path, super.builder, super.pageBuilder, required this.screenContextMatches});
}

class KetchupResponsiveMatchRouteSetting extends StatefulWidget{
  final List<ResponsiveValueGroup>? responses;
  final Key? ketchupKey;
  final HandsetValueGroup? init;
  final ResponseAdaptiveCallback? cb;

  final List<RouteBase> routes;
  const KetchupResponsiveMatchRouteSetting({super.key, this.ketchupKey, required this.routes, this.responses, this.init, this.cb});

  @override
  State<StatefulWidget> createState()=> _KetchupResponsiveMatchRouteSettingState();
  
}

class _KetchupResponsiveMatchRouteSettingState extends State<KetchupResponsiveMatchRouteSetting>{
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KetchupUIResponsive(
          init: widget.init,
          ketchupKey: widget.ketchupKey,
          cb: widget.cb,
          responses: widget.responses ?? [
            (category: CATEGORY.mobile_gesture, fromExcludeSizeRatio: double.negativeInfinity, toIncludeSizeRatio: 9/19, rowColumn: (row: 1, column: 1), singleAspectRatio: null),
            (category: CATEGORY.mobile_gesture, fromExcludeSizeRatio: 9/19, toIncludeSizeRatio: 9/16, rowColumn: (row: 1, column: 1), singleAspectRatio: Size(9, 19)),
            (category: CATEGORY.mobile_gesture, fromExcludeSizeRatio: 9/16, toIncludeSizeRatio: 2 * 9/19, rowColumn: (row: 1, column: 1), singleAspectRatio : Size(9, 16)),
            (category: CATEGORY.mobile_gesture, fromExcludeSizeRatio: 2 * 9/19, toIncludeSizeRatio: 2 * 9/16, rowColumn: (row: 1, column: 2), singleAspectRatio: Size(9, 19)),
            (category: CATEGORY.tv_gamepad, fromExcludeSizeRatio: 2 * 9/16, toIncludeSizeRatio: 3 * 9/19, rowColumn: (row: 1, column: 2), singleAspectRatio: Size(9, 16)),
            (category: CATEGORY.mobile_gesture, fromExcludeSizeRatio: 3 * 9/19, toIncludeSizeRatio: 3 * 9/16, rowColumn: (row: 1, column: 3), singleAspectRatio: Size(9, 19)),
            (category: CATEGORY.tv_gamepad, fromExcludeSizeRatio: 3 * 9/16, toIncludeSizeRatio: 4 * 9/16, rowColumn: (row: 1, column: 3), singleAspectRatio: Size(9, 16)),
            (category: CATEGORY.tv_gamepad, fromExcludeSizeRatio: 4 * 9/16, toIncludeSizeRatio: 5 * 9/16, rowColumn: (row: 1, column: 4), singleAspectRatio: Size(9, 16)),
            (category: CATEGORY.tv_gamepad, fromExcludeSizeRatio: 5 * 9/16, toIncludeSizeRatio: 2 * 16 / 9, rowColumn: (row: 1, column: 5), singleAspectRatio: Size(9, 16)),
            (category: CATEGORY.pc_mousekeyboard, fromExcludeSizeRatio: 2 * 16 / 9, toIncludeSizeRatio: double.infinity, rowColumn: (row: 1, column: 2), singleAspectRatio: Size(16, 9)),
        ])
    );
  }

  @override
  void initState() {
    super.initState();
    
  }
  
}

class KetchupRoutesUI extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  
}