
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_cubit.dart';
import 'package:spotify/feature/presentation/screen/setting/widget/icon_setting.dart';
import 'package:spotify/feature/presentation/screen/widget/overlay_widget.dart';

class WidgetProviderScreen extends StatefulWidget {
  const WidgetProviderScreen({super.key});

  @override
  State<WidgetProviderScreen> createState() => _WidgetProviderScreenState();
}

class _WidgetProviderScreenState extends State<WidgetProviderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm Widget vào nền", style: Style.title,),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            IconSetting(
              margin: const EdgeInsetsDirectional.symmetric(horizontal: 20),
              leading: FontAwesomeIcons.lock,
              label: "Danh sách yêu thích",
              onTap: (){
                context.read<SettingCubit>().sendActionDragToAndroidWidgetProvider();
              },
              trailing: OverlayWidget(
                overlay: Container(
                  width: 200,
                  height: 80,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  padding: const EdgeInsetsDirectional.all(10),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadiusDirectional.all(Radius.circular(8))
                  ),
                  child: const Text("Tiện ích giúp bạn biết được thông tin mới nhất về danh sách bạn yêu thích"),
                ),
                child: const Icon(Icons.help),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
