
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/entity/episode_download.dart';
import 'package:spotify/feature/data/models/entity/movie_local.dart';
import 'package:spotify/feature/data/models/entity/movie_status_download.dart';
import 'package:spotify/feature/blocs/download/download_cubit.dart';
import 'package:spotify/feature/blocs/download/download_state.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/widget/chip_banner.dart';

class MovieDownloadManagerWidget extends StatefulWidget {
  const MovieDownloadManagerWidget({super.key, required this.movieLocal});

  final MovieLocal movieLocal;

  @override
  State<MovieDownloadManagerWidget> createState() => _MovieDownloadManagerWidgetState();
}

class _MovieDownloadManagerWidgetState extends State<MovieDownloadManagerWidget> {
  late DownloadCubit viewModel = context.read<DownloadCubit>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: (){
                    viewModel.selectDeleteEpisodeDownload({
                      for (var element in widget.movieLocal.episodesDownload?.values ?? [])
                        element as EpisodeDownload : true
                    },
                        refresh: true
                    );
                  },
                  child: Text("Chọn tất cả", style: Style.title2,)
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BlocBuilder<DownloadCubit, DownloadState>(
                      buildWhen: (previous, current) => previous.episodeDeleteSelect != current.episodeDeleteSelect,
                      builder: (context, state) {
                        List<EpisodeDownload> episodeErrorCancel = state.episodeDeleteSelect.values.where((EpisodeDownload e){
                          return e.status == StatusDownload.LOADING || e.status == StatusDownload.INITIALIZATION;
                        }).toList();
                        bool isSelect = episodeErrorCancel.isNotEmpty;
                        if(!isSelect) return const SizedBox();

                        return TextButton(
                          onPressed: isSelect ? (){
                            Future.wait([
                              for (var value in episodeErrorCancel)
                                viewModel.stopDownloadEpisode(
                                    movie: widget.movieLocal.toMovieInfo(),
                                    episode: value.toEpisode()
                                )
                            ]).then((values){
                              viewModel.selectDeleteEpisodeDownload({}, refresh: true);
                            });
                          } : null,
                          child: Text("Hủy tải xuống", style: Style.title2.copyWith(color: isSelect ? Colors.red : Colors.grey, fontWeight: FontWeight.bold),),
                        );
                      }
                  ),
                  BlocBuilder<DownloadCubit, DownloadState>(
                      buildWhen: (previous, current) => previous.episodeDeleteSelect != current.episodeDeleteSelect,
                      builder: (context, state) {
                        List<EpisodeDownload> episodeErrorCancel = state.episodeDeleteSelect.values.where((EpisodeDownload e){
                          return e.status == StatusDownload.ERROR || e.status == StatusDownload.CANCEL;
                        }).toList();
                        bool isSelect = episodeErrorCancel.isNotEmpty;
                        if(!isSelect) return const SizedBox();

                        return TextButton(
                          onPressed: isSelect ? () async{
                            Future.wait([
                              for (var episode in episodeErrorCancel)
                                viewModel.startDownloadEpisode(
                                    movie: widget.movieLocal.toMovieInfo(),
                                    episode: episode.toEpisode()
                                )
                            ]).then((values){
                              viewModel.selectDeleteEpisodeDownload({}, refresh: true);
                            });
                          } : null,
                          child: Text("Tải lại", style: Style.title2.copyWith(color: isSelect ? Colors.red : Colors.grey, fontWeight: FontWeight.bold),),
                        );
                      }
                  ),
                  BlocBuilder<DownloadCubit, DownloadState>(
                      buildWhen: (previous, current) => previous.episodeDeleteSelect != current.episodeDeleteSelect,
                      builder: (context, state) {
                        bool isSelect = state.episodeDeleteSelect.isNotEmpty
                            || state.movies[state.getKeyMapEntryMovies(widget.movieLocal)]?.episodesDownload?.isEmpty == true;
                        return TextButton(
                          onPressed: isSelect ? () async{
                            viewModel.deleteMovieDownload(
                              movieDelete: widget.movieLocal,
                              episodes: state.episodeDeleteSelect.values.toList(),
                            ).then((value){
                              context.back();
                            });
                          } : null,
                          child: Text("Xóa", style: Style.title2.copyWith(color: isSelect ? Colors.red : Colors.grey, fontWeight: FontWeight.bold),),
                        );
                      }
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10,),
          BlocBuilder<DownloadCubit, DownloadState>(
              buildWhen: (previous, current) => previous.episodeDeleteSelect != current.episodeDeleteSelect
                  || previous.movies.hashCode != current.movies.hashCode,
              builder: (context, state) {
                return Wrap(
                  children: widget.movieLocal.episodesDownload?.values.map((episode){
                    bool isSelect = state.episodeDeleteSelect[episode.id] != null;

                    return GestureDetector(
                      onTap: (){
                        viewModel.selectDeleteEpisodeDownload({episode: !isSelect});
                      },
                      child: ChipBanner(
                        margin: const EdgeInsetsDirectional.all(4),
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
                        colors: [
                          isSelect ? Colors.red.withOpacity(0.5) : Colors.white12
                        ],
                        child: Text("${episode.name} ${episode.getStatus()}", style: Style.body,),
                      ),
                    );
                  }).toList() ?? [],
                );
              }
          ),
          const SizedBox(height: 10,),
        ],
      ),
    );
  }
}
