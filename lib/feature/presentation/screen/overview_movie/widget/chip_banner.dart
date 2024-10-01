
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChipBanner extends StatelessWidget {
  const ChipBanner({super.key, required this.child, required this.colors, this.margin, this.padding});
  final Widget child;
  final List<Color> colors;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    bool isSingleColor = colors.length <= 1;
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsetsDirectional.all(2),
      decoration: BoxDecoration(
          color: isSingleColor ? colors.firstOrNull : null,
          gradient: !isSingleColor ? LinearGradient(
            colors: colors
          ) : null,
          borderRadius: const BorderRadiusDirectional.all(Radius.circular(3)),

      ),
      child: child,
    );
  }
}
