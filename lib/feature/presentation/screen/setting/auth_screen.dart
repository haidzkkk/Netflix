
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/presentation/screen/setting/widget/icon_setting.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bảo mật", style: Style.title,),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16,),
            IconSetting(
              margin: const EdgeInsetsDirectional.symmetric(horizontal: 32),
              leading: FontAwesomeIcons.lock,
              label: "Mật khẩu",
              onTap: (){

              },
              trailing: Text("tắt", style: Style.body,),
            ),
            const SizedBox(height: 8,),
            IconSetting(
              margin: const EdgeInsetsDirectional.symmetric(horizontal: 32),
              leading: FontAwesomeIcons.fingerprint,
              label: "Sinh chắc học",
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
