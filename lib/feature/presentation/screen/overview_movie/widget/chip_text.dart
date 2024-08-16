
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChipText extends StatelessWidget {
  const ChipText({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(2),
      decoration: BoxDecoration(
          borderRadius: const BorderRadiusDirectional.all(Radius.circular(3)),
          border: Border.all(
            width: 1,
            color: Colors.white,
          )
      ),
      child: child,
    );
  }
}
