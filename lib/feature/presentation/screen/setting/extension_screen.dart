
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/repositories/setting_repo.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_cubit.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_state.dart';
import 'package:spotify/feature/presentation/screen/setting/category_setting_screen.dart';
import 'package:spotify/feature/presentation/screen/setting/widget/icon_setting.dart';

class ExtensionScreen extends StatefulWidget {
  const ExtensionScreen({super.key});

  @override
  State<ExtensionScreen> createState() => _ExtensionScreenState();
}

class _ExtensionScreenState extends State<ExtensionScreen> {

  late var settingViewModel = context.read<SettingCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tiện ích", style: Style.title,),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          child: ListView(
            children: [
              const SizedBox(height: 16,),
              Text("Xem phim", style: Style.body,),
              IconSetting(
                margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
               leading: Icons.airplay,
               label: "Xem dưới nền",
               onTap: (){
                 settingViewModel.changeStateBool(
                    !settingViewModel.state.isWatchBackground,
                    SettingBoolEnum.watchBackground
                 );
               },
               trailing: BlocBuilder<SettingCubit, SettingState>(
                 buildWhen: (previous, current) => previous.isWatchBackground != current.isWatchBackground,
                   builder: (context, state) {
                   return Text(state.isWatchBackground ? "bật" : "tắt", style: Style.body,);
                 }
               ),
              ),
              const SizedBox(height: 8,),
              IconSetting(
                margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
               leading: FontAwesomeIcons.forward,
               label: "Tự động chuyển tập",
               onTap: (){
                 settingViewModel.changeStateBool(
                     !settingViewModel.state.isAutoChangeEpisode,
                     SettingBoolEnum.autoChangeEpisode
                 );
               },
                trailing: BlocBuilder<SettingCubit, SettingState>(
                    buildWhen: (previous, current) => previous.isAutoChangeEpisode != current.isAutoChangeEpisode,
                    builder: (context, state) {
                      return Text(state.isAutoChangeEpisode ? "bật" : "tắt", style: Style.body,);
                    }
                ),
              ),
              const SizedBox(height: 8,),
              IconSetting(
                margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
               leading: Icons.replay_circle_filled_sharp,
               label: "Gợi ý thời gian đã xem",
                onTap: (){
                  settingViewModel.changeStateBool(
                      !settingViewModel.state.isSuggestEpisodeWatched,
                      SettingBoolEnum.suggestEpisodeWatched
                  );
                },
                trailing: BlocBuilder<SettingCubit, SettingState>(
                    buildWhen: (previous, current) => previous.isSuggestEpisodeWatched != current.isSuggestEpisodeWatched,
                    builder: (context, state) {
                      return Text(state.isSuggestEpisodeWatched ? "bật" : "tắt", style: Style.body,);
                    }
                ),
              ),
              const SizedBox(height: 16,),
              Text("Thể loại phim", style: Style.body,),
              IconSetting(
                margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                leading: FontAwesomeIcons.layerGroup,
                label: "Thể loại yêu thích",
                onTap: (){
                  context.toWithCupertino(const CategorySettingScreen());
                },
                trailing: BlocBuilder<SettingCubit, SettingState>(
                    buildWhen: (previous, current) => previous.favouriteCategories != current.favouriteCategories,
                    builder: (context, state) {
                      return Text(state.favouriteCategories.firstOrNull?.name ?? "", style: Style.body,);
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
