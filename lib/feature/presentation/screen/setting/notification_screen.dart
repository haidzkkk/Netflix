
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/presentation/screen/setting/widget/icon_setting.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông báo", style: Style.title,),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16,),
            IconSetting(
              margin: const EdgeInsetsDirectional.symmetric(horizontal: 32),
              leading: FontAwesomeIcons.bellConcierge,
              label: "Thông khi tải thành công",
              onTap: (){

              },
              trailing: Text("tắt", style: Style.body,),
            ),
          ],
        ),
      ),
    );
  }
}
