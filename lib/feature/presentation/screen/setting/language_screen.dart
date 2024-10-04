
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/color_resource.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final List<String> languages = [
    "Tiếng Anh",
    "Tiếng Việt",
    "Tiếng Pháp",
    "Tiếng Nhận",
    "Tiếng Hàn",
    "Tiếng Đức",
    "Tiếng Anh",
    "Tiếng Việt",
    "Tiếng Pháp",
    "Tiếng Nhận",
    "Tiếng Hàn",
    "Tiếng Đức",
    "Tiếng Anh",
    "Tiếng Việt",
    "Tiếng Pháp",
    "Tiếng Nhận",
    "Tiếng Hàn",
    "Tiếng Đức",
    "Tiếng Anh",
    "Tiếng Việt",
    "Tiếng Pháp",
    "Tiếng Nhận",
    "Tiếng Hàn",
    "Tiếng Đức",
    "Tiếng Anh",
    "Tiếng Việt",
    "Tiếng Pháp",
    "Tiếng Nhận",
    "Tiếng Hàn",
    "Tiếng Đức",
    "Tiếng Anh",
    "Tiếng Việt",
    "Tiếng Pháp",
    "Tiếng Nhận",
    "Tiếng Hàn",
    "Tiếng Đức",
    "Tiếng Anh",
    "Tiếng Việt",
    "Tiếng Pháp",
    "Tiếng Nhận",
    "Tiếng Hàn",
    "Tiếng Đức",
    "Tiếng Anh",
    "Tiếng Việt",
    "Tiếng Pháp",
    "Tiếng Nhận",
    "Tiếng Hàn",
    "Tiếng Đức",
    "Tiếng Anh",
    "Tiếng Việt",
    "Tiếng Pháp",
    "Tiếng Nhận",
    "Tiếng Hàn",
    "Tiếng Đức",
  ];

  @override
  Widget build(BuildContext context) {
    int indexSelect = Random().nextInt(languages.length - 1);
    return Scaffold(
      appBar: AppBar(
        title: Text("Ngôn ngữ", style: Style.title,),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView.separated(
            itemCount: languages.length,
            itemBuilder: (context, index){
              return itemLanguage(languages[index], indexSelect == index);
            },
            separatorBuilder: (context, index) => const Divider(height: 30, color: ColorResources.secondaryColor,),
          ),
        ),
      )
    );
  }

  Widget itemLanguage(String language, bool selected){
    return Row(
      children: [
        Text(language, style: Style.title2,),
        const Spacer(),
        if(selected)
          const Text("Đang chọn")
      ],
    );
  }
}
