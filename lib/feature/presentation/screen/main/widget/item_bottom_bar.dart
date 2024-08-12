
import 'package:flutter/cupertino.dart';

import '../../widget/badge_widget.dart';

class ItemBottomBar extends BottomNavigationBarItem{

  ItemBottomBar({required super.icon, super.label});

  factory ItemBottomBar.withChildBadge({
    required String label,
    required Widget icon,
    int? badgeCount,
}){
    return ItemBottomBar(
      icon: SizedBox(
        width: 40,
        child: BadgeWidget(
            count: badgeCount,
            size: 14,
            child: icon
        ),
      ),
      label: label,
    );
  }
}