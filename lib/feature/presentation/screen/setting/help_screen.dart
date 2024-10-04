
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/presentation/screen/setting/widget/icon_setting.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help", style: Style.title,),
      ),
      body: SafeArea(
        child: ListView(
          children: [
          ],
        ),
      ),
    );
  }
}
