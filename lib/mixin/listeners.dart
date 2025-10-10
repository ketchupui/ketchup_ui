import 'package:flutter/material.dart';

typedef SizeChangeListener = void Function(Size newSize, Size? oldSize);

const DEFAULT_TAGNAME = 'default';

abstract class ChangeListenerNotifier<T>{
  final Map<String, List<T>> _changeListenerMap = {
    DEFAULT_TAGNAME: [],
  };

  bool contains(String tag){
    return _changeListenerMap.containsKey(tag);  
  }
  
  void addSizeChangeListener(T listener, {Size? initSize, String tag = DEFAULT_TAGNAME}){
    _changeListenerMap.putIfAbsent(tag, ()=>[]);
    _changeListenerMap[tag]!.add(listener);
    if(initSize != null){
      (listener as dynamic).call(initSize, null);
    }
  }

  bool removeSizeChangeListener(T listener, { String tag = DEFAULT_TAGNAME}){
    return contains(tag) && _changeListenerMap[tag]!.remove(listener);
  }

  void removeTag(String tag){
    _changeListenerMap.remove(tag);
  }

  List<T> get list => _changeListenerMap.values.fold<List<T>>([], (combineto, combined)=>combineto..addAll(combined));

}

mixin SizeChangeNotifier on Object{

  Rect? currentSizeRect;
  Size? get currentSize => currentSizeRect?.size;

  final Map<String, List<SizeChangeListener>> _sizeChangeListenerMap = {
    DEFAULT_TAGNAME: [],
  };

  bool containsSizeChangeListener(String tag){
    return _sizeChangeListenerMap.containsKey(tag);  
  }
  
  void addSizeChangeListener(SizeChangeListener listener, {Size? initSize, String tag = DEFAULT_TAGNAME}){
    _sizeChangeListenerMap.putIfAbsent(tag, ()=>[]);
    _sizeChangeListenerMap[tag]!.add(listener);
    if(initSize != null){
      listener(initSize, null);
    }
  }

  bool removeSizeChangeListener(SizeChangeListener listener, { String tag = DEFAULT_TAGNAME}){
    return containsSizeChangeListener(tag) && _sizeChangeListenerMap[tag]!.remove(listener);
  }

  void removeSizeChangeTag(String tag){
    _sizeChangeListenerMap.remove(tag);
  }

  List<SizeChangeListener> get sizeList => _sizeChangeListenerMap.values.fold<List<SizeChangeListener>>([], (combineto, combined)=>combineto..addAll(combined));
  
  void notifySizeChange(Rect newSize, Rect? oldSize){
    if(newSize.size != oldSize?.size){
      for (var listener in sizeList) {
        listener.call(newSize.size, oldSize?.size);
      }
    }
    currentSizeRect = newSize;
  }
}

typedef RatioChangeListener = void Function(Size size, double newRatio, double? oldRatio);

mixin RatioChangeNotifier on Object{

  double? currentRatio;
  final Map<String, List<RatioChangeListener>> _ratioChangeListenerMap = {
    DEFAULT_TAGNAME: [],
  };

  bool containsRatioChangeListener(String tag){
    return _ratioChangeListenerMap.containsKey(tag);  
  }
  
  void addRatioChangeListener(RatioChangeListener listener, {Size? initSize, String tag = DEFAULT_TAGNAME}){
    _ratioChangeListenerMap.putIfAbsent(tag, ()=>[]);
    _ratioChangeListenerMap[tag]!.add(listener);
    if(initSize != null){
      listener(initSize, initSize.aspectRatio, null);
    }
  }

  bool removeRatioChangeListener(RatioChangeListener listener, { String name = DEFAULT_TAGNAME}){
    return containsRatioChangeListener(name) && _ratioChangeListenerMap[name]!.remove(listener);
  }

  void removeRatioChangeTag(String tag){
    _ratioChangeListenerMap.remove(tag);
  }

  List<RatioChangeListener> get ratioList => _ratioChangeListenerMap.values.fold<List<RatioChangeListener>>([], (combineto, combined)=>combineto..addAll(combined));
    
  void notifyRatioChange(Size size, double newRatio, double? oldRatio){
    // if(ratioList.isEmpty) return;
    for (var listener in ratioList) {
      listener.call(size, newRatio, oldRatio);
    }
    currentRatio = newRatio;
  }
}

