import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../mixin/listeners.dart';

abstract class BaseContext extends ChangeNotifier with SizeChangeNotifier, RatioChangeNotifier{
}
