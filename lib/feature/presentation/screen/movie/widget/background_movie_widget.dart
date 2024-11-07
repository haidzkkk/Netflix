
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/blocs/movie/movie_bloc.dart';

class BackgroundMovieWidget extends StatefulWidget {
  const BackgroundMovieWidget({super.key});

  @override
  State<BackgroundMovieWidget> createState() => _BackgroundMovieWidgetState();
}

class _BackgroundMovieWidgetState extends State<BackgroundMovieWidget> {
  late MovieBloc viewModel = context.read<MovieBloc>();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieBloc, MovieState>(
        buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
        builder: (context, state){
          if(viewModel.state.currentMovie?.color == null){
            return FutureBuilder(
                future: viewModel.state.currentMovie?.fetchColor(),
                builder: (context, snapShot) {
                  return widgetColor(snapShot.data);
                }
            );
          }
          return widgetColor(viewModel.state.currentMovie?.color);
        }
    );
  }

  Widget widgetColor(Color? color){
    return Container(
      height: 700,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: const Alignment(1, 1),
              colors: [
                Colors.transparent,
                color?.withOpacity(0.5) ?? Colors.transparent,
              ]
          )
      ),
    );
  }
}
