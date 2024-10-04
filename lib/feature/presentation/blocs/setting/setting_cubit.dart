
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/data/models/category_movie.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';
import 'package:spotify/feature/data/repositories/setting_repo.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_state.dart';

class SettingCubit extends Cubit<SettingState>{
  SettingRepo repo;
  SettingCubit(this.repo): super(SettingState());

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
}