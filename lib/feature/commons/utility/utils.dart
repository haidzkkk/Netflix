import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:palette_generator/palette_generator.dart';

void printData(String? context){
  if (kDebugMode) {
    print(context ?? "");
  }
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
  return null;
}