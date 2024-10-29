
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/utility/connect_util.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/api/kk_request/category_movie.dart';
import 'package:spotify/feature/data/repositories/google_repo.dart';
import 'package:spotify/feature/data/repositories/setting_repo.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_state.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import '../../../data/models/status.dart';

class SettingCubit extends Cubit<SettingState>{
  SettingRepo repo;
  GoogleRepo googleRepo;
  SettingCubit({required this.repo, required this.googleRepo}): super(SettingState()){
    getCurrentUser();
    listenStateConnectNetwork();
  }

  Future<void> syncSetting() async{

    bool? isWatchBackground = repo.getBoolData(SettingBoolEnum.watchBackground);
    bool? isAutoChangeEpisode = repo.getBoolData(SettingBoolEnum.autoChangeEpisode);
    bool? isSuggestEpisodeWatched = repo.getBoolData(SettingBoolEnum.suggestEpisodeWatched);
    bool? isShowNotifyWhenDownloadSuccess = repo.getBoolData(SettingBoolEnum.showNotifyWhenDownloadSuccess);
    List<CategoryMovie> favouriteCategories = repo.getListFavouriteCategory();

    emit(state.copyWith(
      isWatchBackground: isWatchBackground,
      isAutoChangeEpisode: isAutoChangeEpisode,
      isSuggestEpisodeWatched: isSuggestEpisodeWatched,
      isShowNotifyWhenDownloadSuccess: isShowNotifyWhenDownloadSuccess,
      favouriteCategories: favouriteCategories,
    ));

    getCurrentDriveFileMovieFavourite();
  }

  changeStateBool(bool enable, SettingBoolEnum stateType) async{
    bool isSuccess = await repo.setBoolData(stateType, enable);
    if(isSuccess){
      switch(stateType){
        case SettingBoolEnum.watchBackground: {
          emit(state.copyWith(
            isWatchBackground: enable,
          ));
          break;
        }
        case SettingBoolEnum.autoChangeEpisode:{
          emit(state.copyWith(
            isAutoChangeEpisode: enable,
          ));
          break;
        }
        case SettingBoolEnum.suggestEpisodeWatched:{
          emit(state.copyWith(
            isSuggestEpisodeWatched: enable,
          ));
          break;
        }
        case SettingBoolEnum.showNotifyWhenDownloadSuccess:{
          emit(state.copyWith(
            isShowNotifyWhenDownloadSuccess: enable,
          ));
          break;
        }
      }
    }
  }

  changeListCategory(List<CategoryMovie> categories) async{
    repo.setListFavouriteCategory(categories);
    emit(state.copyWith(
      favouriteCategories: List.of(categories),
    ));
  }


  getCurrentUser() async{
    var googleSignInAccount = await googleRepo.getCurrentUser();
    emit(state.copyWith(
      currentAccount: googleSignInAccount,
    ));
  }

  signingGoogle() async{
    GoogleSignInAccount? googleSignInAccount = await googleRepo.signIn();
    emit(state.copyWith(
      currentAccount: googleSignInAccount,
    ));
  }

  logoutGoogle() async{
    await googleRepo.logout();
    emit(state.copyWithAccountUser(
      currentAccount: null,
    ));
  }

  uploadBackupData() async{
    emit(state.copyWith(
      favouriteFileDrive: Status.loading(),
    ));
    await googleRepo.uploadToDrive(
        fileName: "moviesFavourite.json",
        jsonData: '{"ok": "1", "s": true}'
    );
    getCurrentDriveFileMovieFavourite();
  }

  getCurrentDriveFileMovieFavourite() async{
    emit(state.copyWith(
      favouriteFileDrive: Status.loading(),
    ));
    List<drive.File> files = await googleRepo.getListFile(fileName: "moviesFavourite.json");
    printData("${files.map((e) => e.name)}");
    emit(state.copyWith(
      favouriteFileDrive: Status.success(data: files.firstOrNull),
    ));
  }

  cleanStateSyncFileMovieFavourite() async{
    emit(state.copyWith(syncingFavouriteDriveFile: StatusEnum.initial,));
  }

  syncDriveFileMovieFavourite() async{
    emit(state.copyWith(syncingFavouriteDriveFile: StatusEnum.loading,));
    Map<String, dynamic>? mapJson = await googleRepo.getFileContent(fileId: state.favouriteFileDrive.data?.id ?? "");
    if(mapJson?.isNotEmpty != true) {
      emit(state.copyWith(syncingFavouriteDriveFile: StatusEnum.failed,));
      return;
    }
    emit(state.copyWith(syncingFavouriteDriveFile: StatusEnum.successfully,));
  }

  sendDataToAndroidWidgetProvider({required String categoryJson, required String movieJson}){
    const MethodChannel(AppConstants.methodChannelWidgetProvider)
        .invokeMethod(
        AppConstants.invokeMethodProvideMovie,
        {
          AppConstants.provideMovieCategory: categoryJson,
          AppConstants.provideMovieData: movieJson,
        }
    );
  }

  sendActionDragToAndroidWidgetProvider(){
    const MethodChannel(AppConstants.methodChannelWidgetProvider)
        .invokeMethod(AppConstants.invokeMethodDragWidget,);
  }

  late StreamSubscription streamSubscription;
  listenStateConnectNetwork(){
    streamSubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result){
      bool data = ConnectUtil.checkNetwork(result);
      if(state.isConnectNetwork != data){
        emit(state.copyWith(isConnectNetwork: data));
      }
    });

  }

  @override
  Future<void> close() {
    streamSubscription.cancel();
    return super.close();
  }
}