import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/data/models/db_local/movie_status_download.dart';
import 'package:spotify/feature/presentation/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/widget/chip_banner.dart';

class EpisodesMovieWidget extends StatefulWidget {
  const EpisodesMovieWidget({super.key});

  @override
  State<EpisodesMovieWidget> createState() => _EpisodesMovieWidgetState();
}

class _EpisodesMovieWidgetState extends State<EpisodesMovieWidget> {
  late MovieBloc viewModel = context.read<MovieBloc>();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieBloc, MovieState>(
      buildWhen: (previous, current) => previous.currentMovie != current.currentMovie
        || previous.currentEpisode != current.currentEpisode,
      builder: (context, state){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15,),
            Wrap(
              children: state.currentMovie?.episodes?.firstOrNull?.episode?.map((episode){
                String name = episode.name ?? "";
                String content = name.substring(name.indexOf(" ") + 1, name.length);

                bool isSelect = episode.slug == state.currentEpisode?.slug;
                bool watched = episode.episodeLocal != null;
                StatusDownload? downloaded = episode.episodesDownload?.status == StatusDownload.SUCCESS
                    ? StatusDownload(status: StatusDownload.SUCCESS)
                    : episode.episodesDownload?.status == StatusDownload.INITIALIZATION ||  episode.episodesDownload?.status == StatusDownload.LOADING
                    ? StatusDownload(status: StatusDownload.LOADING)
                    : null;

                return Container(
                  padding: const EdgeInsets.all(4),
                  child: GestureDetector(
                    onTap: (){
                      viewModel.add(ChangeEpisodeMovieEvent(episode: episode));
                    },
                    child: Stack(
                      children: [
                        ChipBanner(
                            colors: isSelect || watched
                                ? const [Colors.white12, Colors.white12]
                                : const [Colors.white38, Colors.white38],
                            child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                child: Text(content, style: Style.body.copyWith(
                                  color: isSelect ? Colors.red : null,
                                ),)
                            )
                        ),
                        if(downloaded != null)
                          Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(
                                downloaded.status == StatusDownload.SUCCESS ? Icons.download_rounded
                                : downloaded.status == StatusDownload.LOADING ? Icons.downloading
                                : Icons.error_outline,
                                size: 10.sp,
                              )
                          ),
                      ],
                    ),
                  ),
                );
              }).toList() ?? [],
            ),
            const SizedBox(height: 10,),
          ],
        );
      },
    );
  }

}
