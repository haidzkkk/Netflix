
import 'package:flutter/cupertino.dart';

class ContextService{
  GlobalKey<NavigatorState> globalKey = GlobalKey<NavigatorState>();
  BuildContext? get context => globalKey.currentContext;
}