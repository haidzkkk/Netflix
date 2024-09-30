
import 'package:flutter/cupertino.dart';

abstract class ListAnimation<T>{
  late GlobalKey<AnimatedListState> keyListAnimation;

  insertAnimationList({
    required GlobalKey<AnimatedListState> keyList,
    required int fromIndex,
    required int toIndex,
  });

  removeAnimationList({
    required GlobalKey<AnimatedListState> keyList,
    int? removeWhere,
    T? data
  });
}