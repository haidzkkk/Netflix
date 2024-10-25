import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/utility/color_resource.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/presentation/blocs/download/download_cubit.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_cubit.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_state.dart';
import 'package:spotify/feature/presentation/screen/setting/auth_screen.dart';
import 'package:spotify/feature/presentation/screen/setting/help_screen.dart';
import 'package:spotify/feature/presentation/screen/setting/extension_screen.dart';
import 'package:spotify/feature/presentation/screen/setting/notification_screen.dart';
import 'package:spotify/feature/presentation/screen/setting/sync_screen.dart';
import 'package:spotify/feature/presentation/screen/setting/widget_provider_screen.dart';
import 'package:spotify/feature/presentation/screen/widget/image_widget.dart';
import 'package:spotify/feature/presentation/screen/widget/overlay_widget.dart';
import 'package:spotify/feature/presentation/screen/setting/widget/icon_setting.dart';
import 'package:spotify/feature/presentation/screen/setting/widget/icon_share.dart';
import 'package:spotify/gen/assets.gen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'language_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> with AutomaticKeepAliveClientMixin{
  late SettingCubit viewModel = context.read<SettingCubit>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16,),
            BlocBuilder<SettingCubit, SettingState>(
              buildWhen: (previous, current) => previous.currentAccount != current.currentAccount,
              builder: (context, state) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(width: 16,),

                      state.currentAccount != null
                      ? ImageWidget(
                        url: state.currentAccount?.photoUrl ?? "https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg",
                        width: 100,
                        height: 100,
                        borderRadius: 100,
                      ) : Container(
                        width: 100,
                        height: 100,
                        padding: const EdgeInsetsDirectional.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadiusDirectional.all(Radius.circular(100))
                        ),
                        child: Assets.img.googleLogo.image(),
                      ),
                      const SizedBox(width: 16,),
                      state.currentAccount != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(state.currentAccount?.displayName ?? "", style: Style.title,),
                              Text(state.currentAccount?.email ?? "", style: Style.body,),
                            ],
                          )
                       : GestureDetector(
                          onTap: (){
                            viewModel.signingGoogle();
                          },
                         child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Chưa đăng nhập", style: Style.title2,),
                              Text("Đăng nhập", style: Style.body.copyWith(color: Colors.grey),),
                            ],
                          ),
                       ),
                      const Spacer(),
                      if(state.currentAccount != null)
                        GestureDetector(
                          onTap: (){
                            viewModel.logoutGoogle();
                          },
                          child: Text("Đăng xuất", style: Style.body.copyWith(color: Colors.grey),)
                        ),
                      const SizedBox(width: 16,),
                    ],
                  );
                }
            ),
            const SizedBox(height: 16,),
            Container(
              color: ColorResources.secondaryColor,
              width: double.infinity,
              padding: const EdgeInsetsDirectional.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 25.sp,),
                      const SizedBox(width: 10,),
                      Text("Tell friend about Netflix", style: Style.title,),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Text("Stream movies in HD, enjoy multiple languages, and explore curated collections to find your next favorite film. Download Netflix today and bring the world of cinema to your fingertips!", style: Style.body,),
                  const SizedBox(height: 10,),
                  Text("Term & Conditions", style: Style.body.copyWith(decoration: TextDecoration.underline, color: Colors.grey),),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 60,
                          alignment: Alignment.center,
                          color: ColorResources.primaryColor,
                          padding: const EdgeInsetsDirectional.all(8),
                          child: Text(AppConstants.appShare,
                            style: Style.title2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){
                          Clipboard.setData(const ClipboardData(text: AppConstants.appShare));
                          showToast("Đã copy link");
                        },
                        child: Container(
                          height: 60,
                          alignment: Alignment.center,
                          color: ColorResources.primaryColorRevert,
                          padding: const EdgeInsetsDirectional.all(8),
                          child: Text("Copy Link",
                            style: Style.title2.copyWith(
                                color: ColorResources.primaryColor,
                                fontWeight: FontWeight.bold
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconShare(
                          height: 50,
                          width: 50,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsetsDirectional.all(6),
                          icon: Assets.img.googleLogo.image(fit: BoxFit.fill),
                          onTap: (){
                            launchUrl(Uri.parse("https://github.com/haidzkkk/netflix"));
                          }
                      ),
                      const SizedBox(width: 10),
                      IconShare(
                          height: 50,
                          width: 50,
                          backgroundColor: Colors.white,
                          icon: Assets.img.facebookLogo.image(fit: BoxFit.fill),
                          onTap: (){
                            launchUrl(Uri.parse("https://www.facebook.com/"));
                          }
                      ),
                      const SizedBox(width: 10),
                      IconShare(
                          height: 50,
                          width: 50,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsetsDirectional.all(3),
                          icon: Assets.img.githubLogo.image(),
                          onTap: (){
                            launchUrl(Uri.parse("https://github.com/haidzkkk/netflix"));
                          }
                      ),
                      const SizedBox(width: 10),
                      IconShare(
                          padding: const EdgeInsets.only(top: 5),
                          icon: Column(
                            children: [
                              const Icon(FontAwesomeIcons.paperPlane, color: ColorResources.primaryColorRevert,),
                              Text("Share", style: Style.body.copyWith(color: ColorResources.primaryColorRevert),)
                            ],
                          ),
                          onTap: (){
                            Share.share(AppConstants.appShare);
                          }
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16,),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconSetting(
                    backgroundColor: ColorResources.secondaryColor,
                    trailing: Icon(Icons.keyboard_arrow_right, size: 25.sp,),
                    leading: Icons.tv_sharp,
                    label: "Tiện ích",
                    onTap: (){
                      context.toWithCupertino(const ExtensionScreen());
                    }
                  ),
                  IconSetting(
                    backgroundColor: ColorResources.secondaryColor,
                    trailing: Icon(Icons.keyboard_arrow_right, size: 25.sp,),
                    leading: FontAwesomeIcons.bell,
                    label: "Thông báo",
                    onTap: (){
                      context.toWithCupertino(const NotificationScreen());
                    }
                  ),
                  IconSetting(
                    backgroundColor: ColorResources.secondaryColor,
                    trailing: Icon(Icons.keyboard_arrow_right, size: 25.sp,),
                    leading: FontAwesomeIcons.earthAmericas,
                    label: "Ngôn ngữ",
                    onTap: (){
                      context.toWithCupertino(const LanguageScreen());
                    }
                  ),
                  IconSetting(
                    backgroundColor: ColorResources.secondaryColor,
                    trailing: Icon(Icons.keyboard_arrow_right, size: 25.sp,),
                    leading: FontAwesomeIcons.arrowsRotate,
                    label: "Đồng bộ",
                    onTap: (){
                      context.toWithCupertino(const SyncScreen());
                    }
                  ),
                  IconSetting(
                    backgroundColor: ColorResources.secondaryColor,
                    trailing: Icon(Icons.keyboard_arrow_right, size: 25.sp,),
                    leading: FontAwesomeIcons.key,
                    label: "Bảo mật",
                    onTap: (){
                      context.toWithCupertino(const AuthScreen());
                    }
                  ),
                  IconSetting(
                    backgroundColor: ColorResources.secondaryColor,
                    trailing: Icon(Icons.keyboard_arrow_right, size: 25.sp,),
                    leading: Icons.view_agenda_outlined,
                    label: "Thêm vào nền",
                    onTap: (){
                      context.toWithCupertino(const WidgetProviderScreen());
                    }
                  ),
                  IconSetting(
                      backgroundColor: ColorResources.secondaryColor,
                      label: "Giúp đỡ",
                      leading: Icons.help,
                      trailing: OverlayWidget(
                        overlay: Container(
                          width: 300,
                          height: 300,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadiusDirectional.all(Radius.circular(8))
                          ),
                          child: Assets.img.instagramLogo.image(),
                        ),
                        child: const Icon(Icons.slideshow),
                      ),
                      onTap: (){
                        context.toWithCupertino(const HelpScreen());
                      }
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16,),
            Text("Version:\t 1.0.0", style: Style.body, textAlign: TextAlign.center,),
            Text("Copyright by Netflix", style: Style.body, textAlign: TextAlign.center,),
            const SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

}
