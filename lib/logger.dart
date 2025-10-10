import 'package:flutter/foundation.dart';

enum LogLevel { verbose, debug, info, warning, error, disabled }

enum LogCategory {
  /// basic
  state('STATE', LogLevel.debug),
  update('UPDATE', LogLevel.debug),
  build('BUILD', LogLevel.debug),
  layout('LAYOUT', LogLevel.debug),
  measure('MEASURE', LogLevel.debug),
  lifecycle('LIFECYCLE', LogLevel.debug),
  ui('UI', LogLevel.debug),
  
  /// context
  screen('SCREEN', LogLevel.debug),
  grid('GRID', LogLevel.debug),
  nav('NAV', LogLevel.debug),
  page('PAGE', LogLevel.debug),
  
  /// others
  network('NETWORK', LogLevel.debug),
  database('DB', LogLevel.debug),
  business('BIZ', LogLevel.info),
  analytics('ANALYTICS', LogLevel.warning),
  crash('CRASH', LogLevel.error),
  general('GENERAL', LogLevel.info),
  storage('STORAGE', LogLevel.debug),
  performance('PERF', LogLevel.info);


  final String name;
  final LogLevel defaultLevel;
  
  const LogCategory(this.name, this.defaultLevel);
}

class CategoryLogger {
  static final Map<LogCategory, LogLevel> _categoryLevels = {
    for (var category in LogCategory.values) 
      category: category.defaultLevel
  };
  
  static LogLevel _globalLevel = kReleaseMode ? LogLevel.warning : LogLevel.verbose;
  
  // 便捷的分类组
  static final List<LogCategory> _allCategories = LogCategory.values.toList();
  static final List<LogCategory> _uiCategories = [LogCategory.ui, LogCategory.business];
  static final List<LogCategory> _dataCategories = [LogCategory.network, LogCategory.database, LogCategory.storage];
  static final List<LogCategory> _debugCategories = [LogCategory.network, LogCategory.database, LogCategory.performance];
  static final List<LogCategory> _errorCategories = [LogCategory.crash, LogCategory.network, LogCategory.database];
  
  // 设置全局级别
  static set globalLevel(LogLevel level) => _globalLevel = level;
  
  // 设置多个分类的级别
  static void setCategoriesLevel(List<LogCategory> categories, LogLevel level) {
    for (final category in categories) {
      _categoryLevels[category] = level;
    }
  }
  
  // 启用/禁用多个分类
  static void enableCategories(List<LogCategory> categories, bool enabled) {
    for (final category in categories) {
      _categoryLevels[category] = enabled ? category.defaultLevel : LogLevel.disabled;
    }
  }

  // 启用/禁用多个分类
  static void enableCategoriesOrElse({ List<LogCategory>? enables, List<LogCategory>? disables }) {
    assert(enables != null || disables != null);
    if(enables != null){
      for (final category in _categoryLevels.entries) {
        if(enables.contains(category.key)){
          _categoryLevels[category.key] = category.key.defaultLevel;
        }else{
          _categoryLevels[category.key] = LogLevel.disabled;
        }
      }
    }else
    if(disables != null){
      for (final category in _categoryLevels.entries) {
        if(disables.contains(category.key)){
          _categoryLevels[category.key] = LogLevel.disabled;
        }else{
          _categoryLevels[category.key] = category.key.defaultLevel;
        }
      }
    }
  }
  
  // 检查是否应该输出日志
  static bool _shouldLog(LogCategory category, LogLevel level) {
    final categoryLevel = _categoryLevels[category]!;
    return level.index >= categoryLevel.index && level.index >= _globalLevel.index;
  }
  
  // 检查多个分类中是否有任何一个应该输出日志
  static bool _shouldLogAny(List<LogCategory> categories, LogLevel level) {
    for (final category in categories) {
      if (_shouldLog(category, level)) {
        return true;
      }
    }
    return false;
  }
  
  // 为多个分类输出日志
  static void v(List<LogCategory> categories, String message) {
    if (_shouldLogAny(categories, LogLevel.verbose)) {
      final categoryNames = categories.map((c) => c.name).join('|');
      debugPrint('💜 [V][$categoryNames] $message');
    }
  }
  
  static void d(List<LogCategory> categories, String message) {
    if (_shouldLogAny(categories, LogLevel.debug)) {
      final categoryNames = categories.map((c) => c.name).join('|');
      debugPrint('💚 [D][$categoryNames] $message');
    }
  }
  
  static void i(List<LogCategory> categories, String message) {
    if (_shouldLogAny(categories, LogLevel.info)) {
      final categoryNames = categories.map((c) => c.name).join('|');
      debugPrint('💙 [I][$categoryNames] $message');
    }
  }
  
  static void w(List<LogCategory> categories, String message, [dynamic error]) {
    if (_shouldLogAny(categories, LogLevel.warning)) {
      final categoryNames = categories.map((c) => c.name).join('|');
      debugPrint('💛 [W][$categoryNames] $message');
      if (error != null) debugPrint('      Details: $error');
    }
  }
  
  static void e(List<LogCategory> categories, String message, [dynamic error, StackTrace? stackTrace]) {
    if (_shouldLogAny(categories, LogLevel.error)) {
      final categoryNames = categories.map((c) => c.name).join('|');
      debugPrint('❤️ [E][$categoryNames] $message');
      if (error != null) debugPrint('      Error: $error');
      if (stackTrace != null) debugPrint('      Stack: $stackTrace');
    }
  }
  
  // 单个分类的便捷方法（向后兼容）
  static void vSingle(LogCategory category, String message) => v([category], message);
  static void dSingle(LogCategory category, String message) => d([category], message);
  static void iSingle(LogCategory category, String message) => i([category], message);
  static void wSingle(LogCategory category, String message, [dynamic error]) => w([category], message, error);
  static void eSingle(LogCategory category, String message, [dynamic error, StackTrace? stackTrace]) => e([category], message, error, stackTrace);
}