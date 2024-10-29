import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/color_resource.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/data/models/entity/movie_status_download.dart';
import 'package:spotify/feature/data/models/server_data.dart';
import 'package:spotify/feature/presentation/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/widget/chip_banner.dart';

class EpisodesMovieWidget extends StatefulWidget {
  const EpisodesMovieWidget({super.key});

  @override
  State<EpisodesMovieWidget> createState() => _EpisodesMovieWidgetState();
}

class _EpisodesMovieWidgetState extends State<EpisodesMovieWidget> {
  late MovieBloc viewModel = context.read<MovieBloc>();

  int serverIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieBloc, MovieState>(
      buildWhen: (previous, current) {
        if(previous.currentMovie != current.currentMovie){
          serverIndex = 0;
          return true;
        }
        if(previous.currentEpisode != current.currentEpisode) return true;
        return false;
      },
      builder: (context, state){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15,),
            Builder(
              builder: (context) {
                Map<int, ServerData> servers = {};

                List<ServerData> serverData =  state.currentMovie?.servers ?? [];
                for(int i = 0; i < serverData.length; i++){
                  servers[i] = serverData[i];
                }

                return Wrap(
                  children: servers.entries.map((entry){
                    bool isSelect = serverIndex == entry.key;

                    return GestureDetector(
                      onTap: (){
                        setState(() {
                          serverIndex = entry.key;
                        });
                      },
                      child: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
                          child: Text(entry.value.serverName ?? "server ${entry.key}",
                            style: Style.body.copyWith(
                              color: isSelect ? Colors.red : ColorResources.primaryColorRevert2,
                            ),
                          )
                      ),
                    );
                  }).toList(),
                );
              }
            ),
            Wrap(
              children: state.currentMovie?.servers?.isNotEmpty == true
                  ? state.currentMovie!.servers![serverIndex].episode!.map((episode){

                bool isSelect = episode.slug == state.currentEpisode?.slug;
                bool watched = episode.episodeWatched != null;
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
                            child: Text(episode.getName(), style: Style.body.copyWith(
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
              }).toList(): [],
            ),
            const SizedBox(height: 10,),
          ],
        );
      },
    );
  }

}
