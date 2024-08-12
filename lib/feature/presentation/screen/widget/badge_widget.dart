
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum BadgeType{
  dot, count
}

class BadgeWidget extends StatelessWidget {
  const BadgeWidget({super.key,
    this.child,
    this.count,
    this.widthBadge,
    this.heightBadge,
    this.type,
    this.size,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  final Widget? child;
  final int? count;
  final double? widthBadge;
  final double? heightBadge;

  final BadgeType? type;
  final double? size;

  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  @override
  Widget build(BuildContext context) {
    if(child != null){
      return Stack(
        alignment: Alignment.center,
        children: [
          child!,
          Positioned(
              top: top ?? (bottom == null ? 0 : null),
              right: right ?? (left == null ? 0 : null),
              bottom: bottom,
              left: left,
              child: badgesCountWidget(count)
          )
        ],
      );
    }
    return badgesCountWidget(count);
  }

  Widget badgesCountWidget(int? count){
    if(count == null || count <= 0) return const SizedBox();

    double size = this.size ?? 20;
    double fontSize = size * 0.6;

    String countString = count >= 100 ? 99.toString() : count.toString();
    return Container(
        height: size,
        width: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadiusDirectional.all(Radius.circular(100)),
        ),
        child: type != BadgeType.dot
            ? Text(countString, maxLines: 1, style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),)
            : null
    );
  }
}
