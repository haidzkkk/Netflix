import 'package:flutter/material.dart';
class CustomButton extends StatelessWidget {
  final Function()? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? colorBoxShadow;
  final bool? enable;
  final bool? wrapWidth;
  final double? height;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor,
    this.colorBoxShadow,
    this.enable = true,
    this.width,
    this.height,
    this.wrapWidth,
    this.margin,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: margin ?? const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 5),
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
              padding: padding,
              backgroundColor: onPressed != null && enable == true ? backgroundColor : Colors.grey.shade400,
              fixedSize: wrapWidth == true ? Size.fromHeight(height ?? 48) : Size(width ?? MediaQuery.of(context).size.width, height ?? 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 10)
              )
          ),
          child: child
      ),
    );
  }
}
