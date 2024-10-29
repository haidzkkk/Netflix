import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/data/models/entity/movie_status_download.dart';
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
              children: state.currentMovie?.servers?.firstOrNull?.episode?.map((episode){
                String name = episode.name ?? "";
                String content = name.substring(name.indexOf(" ") + 1, name.length);

                bool isSelect = episode.slug == state.currentEpisode?.slug;
                bool watched = episode.episodeLocal != null;
                IconData? iconDownload;
                switch(episode.episodesDownload?.status){
                  case StatusDownload.INITIALIZATION || StatusDownload.LOADING: {
                    iconDownload = Icons.downloading;
                    break;
                  }
                  case StatusDownload.SUCCESS: {
                    iconDownload = Icons.download_rounded;
                    break;
                  }
                  case StatusDownload.ERROR: {
                    iconDownload = Icons.error_outline;
                    break;
                  }
                }

                return Container(
                  padding: const EdgeInsets.all(4),
                  child: GestureDetector(
                    onTap: (){
                      if(state.currentEpisode?.slug != episode.slug){
                        viewModel.add(ChangeEpisodeMovieEvent(episode: episode));
                      }
                    },
                    child: Stack(
                      children: [
                        ChipBanner(
                            colors: isSelect || watched
                                ? const [Colors.white12]
                                : const [Colors.white38],
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                            child: Text(content, style: Style.body.copyWith(
                              color: isSelect ? Colors.red : null,
                            ),)
                        ),
                        if(iconDownload != null)
                          Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(iconDownload, size: 10.sp,)
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
