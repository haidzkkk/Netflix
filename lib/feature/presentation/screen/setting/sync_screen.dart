
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/date_converter.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/presentation/blocs/download/download_cubit.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_cubit.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_state.dart';
import 'package:spotify/feature/presentation/screen/setting/widget/icon_setting.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../data/models/status.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  late SettingCubit viewModel = context.read<SettingCubit>();

  @override
  void initState() {
    viewModel.getCurrentDriveFileMovieFavourite();
    super.initState();
  }

  @override
  void dispose() {
    viewModel.cleanStateSyncFileMovieFavourite();
    super.dispose();
  }

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
                Text("Phim yêu thích", style: Style.body,),
                IconSetting(
                  margin: EdgeInsetsDirectional.zero,
                  leading: Icons.cloud_upload_outlined,
                  label: "Tải lên đám mây",
                  onTap: () async{
                    viewModel.uploadBackupData();
                  },
                  trailing: BlocBuilder<SettingCubit, SettingState>(
                    buildWhen: (previous, current) => previous.favouriteFileDrive.status != current.favouriteFileDrive.status,
                    builder: (context, state) {
                      var favouriteFileDriveStatus = state.favouriteFileDrive;
                      return favouriteFileDriveStatus.status == StatusEnum.loading
                        ? const CupertinoActivityIndicator()
                        : Text(DateConverter.analyzeDateTime(favouriteFileDriveStatus.data?.modifiedTime));
                    },
                  ),
                ),
                IconSetting(
                  margin: EdgeInsetsDirectional.zero,
                  leading: Icons.cloud_download_outlined,
                  label: "Đồng bộ đám mây",
                  onTap: () async{
                    viewModel.syncDriveFileMovieFavourite();
                  },
                  trailing: BlocBuilder<SettingCubit, SettingState>(
                    // buildWhen: (previous, current) => previous.syncingFavouriteDriveFile != current.syncingFavouriteDriveFile,
                    builder: (context, state) {
                      switch(state.syncingFavouriteDriveFile){
                        case StatusEnum.loading: {
                          return const CupertinoActivityIndicator();
                        }
                        case StatusEnum.successfully: {
                          return const Icon(Icons.check, color: Colors.green,);
                        }
                        case StatusEnum.failed  : {
                          return const Icon(Icons.close, color: Colors.red,);
                        }
                        default: {
                          return const SizedBox();
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16,),
                Text("Bộ nhớ trong", style: Style.body,),
                IconSetting(
                  margin: EdgeInsetsDirectional.zero,
                  leading: Icons.downloading,
                  label: "Đồng bộ tải xuống",
                  onTap: () async{
                    context.read<DownloadCubit>().syncMovieDownloading();
                  },
                ),
              ],
            ),
          ),
        )
    );
  }
}
