
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spotify/feature/data/models/category_movie.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import '../../../data/models/status.dart';

class SettingState extends Equatable{
  final GoogleSignInAccount? currentAccount;
  final bool isWatchBackground;
  final bool isAutoChangeEpisode;
  final bool isSuggestEpisodeWatched;
  final List<CategoryMovie> favouriteCategories;
  final bool isShowNotifyWhenDownloadSuccess;
  final Status<drive.File> favouriteFileDrive;
  final StatusEnum syncingFavouriteDriveFile;

  SettingState({
    bool? isWatchBackground,
    bool? isAutoChangeEpisode,
    bool? isSuggestEpisodeWatched,
    List<CategoryMovie>? favouriteCategories,
    bool? isShowNotifyWhenDownloadSuccess,
    this.currentAccount,
    Status<drive.File>? favouriteFileDrive,
    StatusEnum? syncingFavouriteDriveFile,
  }):
        isWatchBackground = isWatchBackground ?? true,
        isAutoChangeEpisode = isAutoChangeEpisode ?? true,
        isSuggestEpisodeWatched = isSuggestEpisodeWatched ?? true,
        favouriteCategories = favouriteCategories ?? CategoryMovie.valueCategories,
        favouriteFileDrive = favouriteFileDrive ?? Status.initial(),
        isShowNotifyWhenDownloadSuccess = isShowNotifyWhenDownloadSuccess ?? true,
        syncingFavouriteDriveFile = syncingFavouriteDriveFile ?? StatusEnum.initial;

  SettingState copyWith({
    bool? isWatchBackground,
    bool? isAutoChangeEpisode,
    bool? isSuggestEpisodeWatched,
    List<CategoryMovie>? favouriteCategories,
    bool? isShowNotifyWhenDownloadSuccess,
    GoogleSignInAccount? currentAccount,
    Status<drive.File>? favouriteFileDrive,
    StatusEnum? syncingFavouriteDriveFile,
  }){
    return SettingState(
      isWatchBackground: isWatchBackground ?? this.isWatchBackground,
      isAutoChangeEpisode: isAutoChangeEpisode ?? this.isAutoChangeEpisode,
      isSuggestEpisodeWatched: isSuggestEpisodeWatched ?? this.isSuggestEpisodeWatched,
      favouriteCategories: favouriteCategories?.isNotEmpty == true ? favouriteCategories : this.favouriteCategories,
      isShowNotifyWhenDownloadSuccess: isShowNotifyWhenDownloadSuccess ?? this.isShowNotifyWhenDownloadSuccess,
      currentAccount: currentAccount ?? this.currentAccount,
      favouriteFileDrive: favouriteFileDrive ?? this.favouriteFileDrive,
      syncingFavouriteDriveFile: syncingFavouriteDriveFile ?? this.syncingFavouriteDriveFile,
    );
  }

  SettingState copyWithAccountUser({
    GoogleSignInAccount? currentAccount,
  }){
    return SettingState(
      isWatchBackground: isWatchBackground,
      isAutoChangeEpisode: isAutoChangeEpisode,
      isSuggestEpisodeWatched: isSuggestEpisodeWatched,
      favouriteCategories: favouriteCategories,
      isShowNotifyWhenDownloadSuccess: isShowNotifyWhenDownloadSuccess,
      favouriteFileDrive: favouriteFileDrive,
      syncingFavouriteDriveFile: syncingFavouriteDriveFile,
      currentAccount: currentAccount,
    );
  }


  @override
  List<Object?> get props => [
    currentAccount,
    isWatchBackground,
    isAutoChangeEpisode,
    isSuggestEpisodeWatched,
    favouriteCategories.hashCode,
    isShowNotifyWhenDownloadSuccess,
    favouriteFileDrive,
    syncingFavouriteDriveFile,
  ];

}