import 'dart:async';

class Debouncer {
  final Duration defaultDelay = const Duration(milliseconds: 100);
  Timer? _timer;

  // Debouncer({this.delay = const Duration(milliseconds: 100)});

  void call(void Function() action, [Duration? delay]) {
    _timer?.cancel(); // 取消前一个等待
    _timer = Timer(delay ?? defaultDelay, action); // 启动新的等待
  }

  void dispose() {
    _timer?.cancel();
  }
}