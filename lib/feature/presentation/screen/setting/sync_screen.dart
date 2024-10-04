
import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/presentation/screen/setting/widget/icon_setting.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Đồng bộ", style: Style.title,),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 32),
            child: ListView(
              children: [
                const SizedBox(height: 8,),
                Text("Đám mây", style: Style.body,),
                IconSetting(
                  margin: EdgeInsetsDirectional.zero,
                  leading: Icons.cloud_upload_outlined,
                  label: "Tải lên đám mây",
                  onTap: (){

                  },
                  // trailing: IconOverlay(
                  //   message: 'Lưu trữ dữ liệu của bạn lên cloud',
                  //   child: Icon(Icons.info_outline, size: 17.sp,),
                  // ),
                ),
                IconSetting(
                  margin: EdgeInsetsDirectional.zero,
                  leading: Icons.cloud_download_outlined,
                  label: "Đồng bộ đám mây",
                  onTap: (){

                  },
                  // trailing: IconOverlay(
                  //   widthOverlay: 100,
                  //   message: 'Kéo dữ liệu trên clound xuống đồng bộ với điện thoại của bạn',
                  //   child: Icon(Icons.info_outline, size: 17.sp,),
                  // ),
                ),
                const SizedBox(height: 16,),
                Text("Bộ nhớ trong", style: Style.body,),
                IconSetting(
                  margin: EdgeInsetsDirectional.zero,
                  leading: Icons.downloading,
                  label: "Đồng bộ tải xuống",
                  onTap: (){

                  },
                  // trailing: IconOverlay(
                  //   message: 'Đồng bộ tải xuống để dữ liệu chính xác nhất',
                  //   child: Icon(Icons.info_outline, size: 17.sp,),
                  // ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
