
import 'package:flutter/cupertino.dart';

abstract class ListAnimation{
  late GlobalKey<AnimatedListState> keyListAnimation;

  insertAnimationList({
    required GlobalKey<AnimatedListState> keyList,
    required int fromIndex,
    required int toIndex,
  });

  removeAnimationList({
    required GlobalKey<AnimatedListState> keyList,
    int? removeWhere,
  });
}