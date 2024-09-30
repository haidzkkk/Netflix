import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/file_util.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/data/models/file/file_movie_episode.dart';
import 'package:spotify/feature/presentation/blocs/download/download_cubit.dart';
import 'package:spotify/feature/presentation/blocs/download/download_state.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late DownloadCubit viewModel = context.read<DownloadCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("file"),
            FutureBuilder(
              future: viewModel.fileRepository.getAllMovieEpisode(),
              builder: (context, snapshot){
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index){
                    var movie = snapshot.data![index];

                    return Container(
                      padding: const EdgeInsetsDirectional.all(8),
                      margin: const EdgeInsetsDirectional.all(8),
                      color: Colors.brown,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(movie.movie.name,
                            style: Style.title2,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: movie.episode.length,
                            itemBuilder: (context, index){
                              var episode = movie.episode[index];
                              return Container(
                                padding: const EdgeInsetsDirectional.all(8),
                                margin: const EdgeInsetsDirectional.all(8),
                                color: Colors.brown,
                              child: Text("${episode.name}\n${episode.path}"
                              ),
                              );
                            },
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            Text("db"),
            BlocBuilder<DownloadCubit, DownloadState>(
              builder: (context, state){
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.movies.values.length,
                  itemBuilder: (context, index){
                    var movie = state.movies.values.toList()[index];

                    return Container(
                      padding: const EdgeInsetsDirectional.all(8),
                      margin: const EdgeInsetsDirectional.all(8),
                      color: Colors.brown,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${movie.slug}",
                            style: Style.title2,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: movie.episodesDownload?.values.length ?? 0,
                            itemBuilder: (context, index){
                              var episode = movie.episodesDownload!.values.toList()[index];
                              return Container(
                                padding: const EdgeInsetsDirectional.all(8),
                                margin: const EdgeInsetsDirectional.all(8),
                                color: Colors.brown,
                              child: Text("${episode.id}\n"
                                  "${episode.name}"
                                  "${episode.path}"
                                  "${episode.status}"
                              ),
                              );
                            },
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
