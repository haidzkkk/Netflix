
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../commons/utility/style_util.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    super.key,
    required this.title,
    this.onTap,
    this.padding,
  });

  final String title;
  final Function()? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(title,
                style: Style.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10,),
            if(onTap != null)
              const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.white,),
          ],
        ),
      ),
    );
  }
}
