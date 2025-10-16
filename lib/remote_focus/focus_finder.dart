import 'package:ketchup_ui/ketchup_ui.dart';
import 'package:ketchup_ui/remote_focus/focus.dart';

mixin FocusFinder on FocusManager{
  
  FocusManager? get focusFather;

  FocusManager get focusTopFather {
    if(focusFather is FocusFinder){
      return (focusFather as FocusFinder).focusTopFather;
    }
    return this;
  }

  BasicNavigatorBuilder? get focusNav;

  @override
  List<FocusManager>? findFocusManager(FindFocusPosition position) {
    switch(position){
      case FindFocusPosition.topFather:
        return [focusTopFather];
      case FindFocusPosition.father:
        if(focusFather != null) return [focusFather!];
        return null;
      case FindFocusPosition.brothers:
        return focusFather?.findFocusManager(FindFocusPosition.children);
      case FindFocusPosition.focusedChild:
        final focused = focusNav?.focusedPageInfo?.$3.page;
        if(focused is FocusManager){
          return [focused!];
        }
        return null;
      case FindFocusPosition.children:
        return focusNav?.type<FocusManager>();
      case FindFocusPosition.nextRight:
        final brothers = focusFather?.findFocusManager(FindFocusPosition.children);
        if(brothers == null) return null;
        int index = brothers.indexOf(this);
        if(index + 1 < brothers.length){
          return [brothers.elementAt(index + 1)];
        }
        return null;
      case FindFocusPosition.prevLeft:
        final brothers = focusFather?.findFocusManager(FindFocusPosition.children);
        if(brothers == null) return null;
        int index = brothers.indexOf(this);
        if(index - 1 >= 0){
          return [brothers.elementAt(index - 1)];
        }
        return null;
    }
  }
}