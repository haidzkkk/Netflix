
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/data/models/status.dart';
import 'package:spotify/feature/presentation/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/screen/widget/custom_better_player.dart';

class PictureInPictureMovieWidget extends StatelessWidget {
  const PictureInPictureMovieWidget({super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    MovieBloc viewModel = context.read<MovieBloc>();
    return BlocConsumer<MovieBloc, MovieState>(
        listenWhen: (previous, current) => previous.isPlayerWindow != current.isPlayerWindow,
        listener: (context, state){

          /// when movie collapse
          if(!state.isExpandWatchMovie && state.isPlayerWindow == true){
            viewModel.add(ChangeExpandedMovieEvent(isExpand: true));
          }

          /// when view overview movie
          if(state.movie.status != StatusEnum.initial && state.isPlayerWindow == true){
            Navigator.pop(context);
          }

          /// off snackBar when it show
          if(state.isPlayerWindow == true){
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }

          /// switch control player
          if(state.isPlayerWindow == true){
            viewModel.betterPlayerController?.setControlsEnabled(false);
          }else{
            viewModel.betterPlayerController?.setControlsEnabled(true);
          }
        },
        buildWhen: (previous, current) => previous.isPlayerWindow != current.isPlayerWindow,
        builder: (context, state) {
          if(state.isPlayerWindow == true){
            return AspectRatio(
              aspectRatio: 16/9,
              child: viewModel.betterPlayerController != null
                  ? CustomBetterPlayer(controller: viewModel.betterPlayerController!,)
                  : const SizedBox(),
            );
          }

          return child;
        }
    );
  }
}
