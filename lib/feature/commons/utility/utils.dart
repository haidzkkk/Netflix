import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';

void printData(String? content){
  if (kDebugMode) {
    print("==========> $content");
  }
}

double calculateHeightItemGirdView(BuildContext context, double height, int columnCount){
  double widgetItem = MediaQuery.of(context).size.width / columnCount;
  return widgetItem / height;
}

hasDomainUrl(String url){
  return url.contains("http://") || url.contains("https://");
}

Future<Color?> generateColorImageUrl(String url) async{
  String imageUrl = url;
  PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(NetworkImage(imageUrl));

  if(paletteGenerator.vibrantColor != null){
    return paletteGenerator.vibrantColor!.color;
  }else if(paletteGenerator.dominantColor != null){
    return paletteGenerator.dominantColor!.color;
  }else if(paletteGenerator.mutedColor != null){
    return paletteGenerator.mutedColor!.color;
  }
  return Colors.transparent;
}

extension NumExt on num {
  String format(){
    final NumberFormat formatter = NumberFormat('#,###');
    return formatter.format(this);
  }
}

extension BuildContextExt on BuildContext{
  void to(Widget screen){
    Navigator.push(this, MaterialPageRoute(builder: (context) => screen));
  }
  void back(){
    Navigator.pop(this);
  }
  void replace(Widget screen){
    Navigator.pushReplacement(this, MaterialPageRoute(builder: (context) => screen));
  }

  void showDraggableBottomSheet({
    required Widget Function(BuildContext context, ScrollController scrollController) builder
  }) async{
    bool bottomSheetOpen = true;
    await showModalBottomSheet(
        context: this,
        isScrollControlled: true,
        enableDrag: false,
        builder: (context){
          return NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                if (notification.extent <= 0.1 && bottomSheetOpen == true) {
                  context.back();
                  return true;
                }
                return false;
              },
              child: DraggableScrollableSheet(
                initialChildSize: 1,
                maxChildSize: 1,
                minChildSize: 0.0,
                snap: true,
                expand: false,
                builder: builder,
              )
          );
        }
    );
    bottomSheetOpen = false;
  }

  void showSnackBar(String content){
    var snackbar = SnackBar(
      content: Text(content, style: Style.body.copyWith(color: Colors.white),),
      backgroundColor: Colors.purple,
    );

    ScaffoldMessenger.of(this).showSnackBar(snackbar);
  }
}

extension IterableExt on Iterable{
  E? firstWhereOrNull<E>(bool Function(E element) check) {
    for (E element in this) {
      if (check(element)) return element;
    }
    return null;
  }
}
extension DateTimeExt on DateTime{
  bool isSameDay(DateTime? dateTime) {
    return year == dateTime?.year &&
        month == dateTime?.month &&
        day == dateTime?.day;
  }
}
