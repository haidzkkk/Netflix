
import 'package:flutter/cupertino.dart';

import '../../widget/badge_widget.dart';

class ItemBottomBar extends BottomNavigationBarItem{

  ItemBottomBar({required super.icon, super.label});

  factory ItemBottomBar.withChildBadge({
    required String label,
    required Widget icon,
}){
    return ItemBottomBar(
      icon: icon,
      label: label,
    );
  }

  static Widget iconBadge({required int count, required Widget icon}){
    return SizedBox(
      width: 40,
      child: BadgeWidget(
          count: count,
          size: 14,
          child: icon
      ),
    );
  }
}