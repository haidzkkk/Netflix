import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/pageutil.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/presentation/screen/movie/widget/player_movie_widget.dart';
import 'package:spotify/feature/presentation/screen/movie/widget/action_movie_widget.dart';
import 'package:spotify/feature/presentation/screen/movie/widget/background_movie_widget.dart';
import 'package:spotify/feature/presentation/screen/movie/widget/description_movie_widget.dart';
import 'package:spotify/feature/presentation/screen/movie/widget/episodes_movie_widget.dart';
import 'package:spotify/feature/presentation/screen/movie/widget/info_movie_widget.dart';
import '../../../commons/utility/style_util.dart';
import '../../blocs/movie/movie_bloc.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {

  late MovieBloc viewModel = context.read<MovieBloc>();
  final DraggableScrollableController _dragController = DraggableScrollableController();

  @override
  void dispose() {
    disposeScreen();
    super.dispose();
  }

  bool isDispose = false;
  disposeScreen(){
    if(isDispose) return;
    _dragController.dispose();
    viewModel.add(CleanWatchMovieEvent());
    isDispose = true;
  }

  double heightBottomNav = 56;
  double heightMovieCollapse = 56.w;
  double heightProcess = 1.5.h;
  late double maxSize = 1;
  late double minSize = (heightMovieCollapse + heightBottomNav + heightProcess) / PageUtil.screenHeight;

  @override
  Widget build(BuildContext context) {
    return BlocListener<MovieBloc, MovieState>(
      listenWhen: (previous, current) => previous.timeWatchedEpisode != current.timeWatchedEpisode
          && current.timeWatchedEpisode != null,
      listener: (context, state){
        showSnackBarContinueEpisode(state.timeWatchedEpisode!);
      },
      child: BlocListener<MovieBloc, MovieState>(
          listenWhen: (previous, current) => previous.isExpandWatchMovie != current.isExpandWatchMovie && current.currentMovie != null,
          listener: (context, state){
            _dragController.animateTo(
              state.isExpandWatchMovie ? maxSize : minSize,
              duration: viewModel.durationScroll,
              curve: Curves.easeInOut,
            );
          },
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if(viewModel.blockScrollListen) return true;
              if (notification.extent > 0.5 && viewModel.state.isExpandWatchMovie == false) {
                viewModel.add(ChangeExpandedMovieEvent(isExpand: true));
              } else if (notification.extent < 0.5 && viewModel.state.isExpandWatchMovie) {
                viewModel.add(ChangeExpandedMovieEvent(isExpand: false));
              }
              return true;
            },
            child: DraggableScrollableSheet(
                controller: _dragController,
                initialChildSize: maxSize,
                maxChildSize: maxSize,
                minChildSize: minSize,
                snap: true,
                expand: false,
                builder: (BuildContext context, ScrollController scrollController) {

                  return Scaffold(
                    body: SingleChildScrollView(
                      controller: scrollController,
                      child: Stack(
                        children: [
                          const BackgroundMovieWidget(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PlayerMovieWidget(
                                heightBottomNav: heightBottomNav,
                                heightMovieCollapse: heightMovieCollapse,
                                actionDispose: () => disposeScreen(),
                              ),
                              BlocBuilder<MovieBloc, MovieState>(
                                buildWhen: (previous, current) {
                                  if(previous.visibleControlsPlayer != current.visibleControlsPlayer){
                                    return true;
                                  }else if(current.visibleControlsPlayer == false
                                      && (previous.totalTimeEpisode != current.totalTimeEpisode
                                      || previous.currentTimeEpisode != current.currentTimeEpisode)){
                                    return true;
                                  }
                                  return false;
                                },
                                builder: (context, state){
                                  var process = (state.currentTimeEpisode ?? 0.0) /  (state.totalTimeEpisode ?? 0.0);
                                  if(process.isNaN || process.isInfinite || process < 0 || process > 1){
                                    process = 0;
                                  }
                                    return AnimatedOpacity(
                                      duration: state.visibleControlsPlayer ? const Duration(milliseconds: 50) : const Duration(milliseconds: 1000),
                                      opacity: state.visibleControlsPlayer ? 0 : 1,
                                      child: LinearProgressIndicator(
                                        minHeight: heightProcess,
                                        color: viewModel.state.currentMovie?.color,
                                        value: process,
                                      ),
                                    );
                                  }
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    InfoMovieWidget(),
                                    ActionMovieWidget(),
                                    EpisodesMovieWidget(),
                                    DescriptionMovieWidget(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
            ),
          )
      ),
    );
  }

  showSnackBarContinueEpisode(int seconds){
    var minuteSeconds = seconds / 60;
    var minute = minuteSeconds.truncate();
    var second = ((double.parse(minuteSeconds.toStringAsFixed(2)) - minute) * 60).toInt();

    context.showSnackBarWidget(
        child: Row(
          children: [
            Expanded(child: Text("Bạn đã xem đến $minute phút $second giây", style: Style.body.copyWith(color: Colors.white),)),
            const SizedBox(width: 10,),
            GestureDetector(
              onTap: (){
                viewModel.betterPlayerController?.seekTo(Duration(seconds: seconds));
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: Text("Xem",
                  style: Style.title2.copyWith(color: Colors.white)
              ),
            ),
          ],
        ),
        seconds: 5,
        backgroundColor: viewModel.state.currentMovie?.color
    );
  }
}