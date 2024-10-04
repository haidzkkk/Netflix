
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';

class IconSetting extends StatelessWidget {
  const IconSetting({
    super.key,
    required this.leading,
    required this.label,
    required this.onTap,
    this.trailing,
    this.backgroundColor,
    this.margin,
    this.padding,
  });

  final IconData leading;
  final Widget? trailing;
  final String label;
  final Color? backgroundColor;
  final Function() onTap;
  final EdgeInsetsDirectional? margin;
  final EdgeInsetsDirectional? padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsetsDirectional.symmetric(vertical: 8),
        padding: padding ?? const EdgeInsetsDirectional.all(16),
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadiusDirectional.all(Radius.circular(8))
        ),
        child: Row(
          children: [
            Icon(leading, size: 20.sp,),
            const SizedBox(width: 30,),
            Text(label, style: Style.title2.copyWith(fontWeight: FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis,),
            const Spacer(),
            if(trailing != null) trailing!
          ],
        ),
      ),
    );
  }
}
