
import 'package:flutter/cupertino.dart';

class IconShare extends StatelessWidget {
  const IconShare({super.key,
    required this.icon,
    this.height,
    this.width,
    this.backgroundColor,
    this.padding,
    this.onTap,
  });

  final Widget icon;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        padding: padding,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadiusDirectional.all(Radius.circular(10))
        ),
        margin: const EdgeInsetsDirectional.all(8),
        child: icon,
      ),
    );
  }
}
