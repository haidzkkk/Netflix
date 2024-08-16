
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChipBanner extends StatelessWidget {
  const ChipBanner({super.key, required this.child, required this.colors});
  final Widget child;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(2),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors
          ),
          borderRadius: const BorderRadiusDirectional.all(Radius.circular(3)),

      ),
      child: child,
    );
  }
}
