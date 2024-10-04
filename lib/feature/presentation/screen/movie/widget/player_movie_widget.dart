

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/color_resource.dart';
import 'package:spotify/feature/commons/utility/pageutil.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/presentation/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/screen/widget/custom_better_player.dart';
import 'package:spotify/feature/presentation/screen/widget/process_indicator/custom_progress_bar.dart';

class PlayerMovieWidget extends StatefulWidget {
  const PlayerMovieWidget({
    super.key,
    required this.heightBottomNav,
    required this.heightMovieCollapse,
    required this.actionDispose,
    required this.heightProcess,
  });

  final double heightBottomNav;
  final double heightMovieCollapse;
  final double heightProcess;
  final Function() actionDispose;

  @override
  State<PlayerMovieWidget> createState() => _PlayerMovieWidgetState();
}

class _PlayerMovieWidgetState extends State<PlayerMovieWidget> {
  late MovieBloc viewModel = context.read<MovieBloc>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<MovieBloc, MovieState>(
            buildWhen: (previous, current) => previous.isExpandWatchMovie != current.isExpandWatchMovie
              || previous.isPlay != current.isPlay,
            builder: (context, state){
              viewModel.betterPlayerController?.setControlsEnabled(state.isExpandWatchMovie ? true : false);
              return GestureDetector(
                onTap: state.isExpandWatchMovie ? null : (){
                  viewModel.add(ChangeExpandedMovieEvent(isExpand: true));
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    AnimatedContainer(
                      height: state.isExpandWatchMovie ? PageUtil.screenWidth / 16 * 9 : widget.heightMovieCollapse,
                      width: state.isExpandWatchMovie ? PageUtil.screenWidth : widget.heightMovieCollapse / 9 * 21,
                      duration: const Duration(milliseconds: 200),
                      child: AspectRatio(
                        aspectRatio: state.isExpandWatchMovie ? 16/9 : 21/9,
                        child: viewModel.betterPlayerController != null
                          ? CustomBetterPlayer(controller: viewModel.betterPlayerController!,)
                          : const SizedBox(),
                      ),
                    ),
                    if(!state.isExpandWatchMovie)
                      Expanded(
                        child: Row(
                          children: [
                            const Spacer(flex: 1,),
                            Expanded(
                              flex: 13,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(state.currentMovie?.name ?? "", style: Style.title2, maxLines: 1, overflow: TextOverflow.ellipsis,),
                                  Text(state.currentEpisode?.name ?? "", style: Style.body, maxLines: 1, overflow: TextOverflow.ellipsis,),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: IconButton(
                                  onPressed: (){
                                    if(viewModel.betterPlayerController?.isPlaying() == true){
                                      viewModel.betterPlayerController?.pause();
                                    }else{
                                      viewModel.betterPlayerController?.play();
                                    }
                                  },
                                  icon: Icon(state.isPlay == true
                                      ? Icons.pause
                                      : Icons.play_arrow_rounded,
                                    size: 25.sp,
                                  )
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: IconButton(
                                  onPressed: () => widget.actionDispose(),
                                  icon: Icon(Icons.clear, size: 25.sp,)
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              );
            }
        ),
        Stack(
          children: [
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
                    duration: const Duration(milliseconds: 500),
                    opacity: state.visibleControlsPlayer ? 0 : 1,
                    child: LinearProgressIndicator(
                      minHeight: widget.heightProcess,
                      color: viewModel.state.currentMovie?.color,
                      backgroundColor: ColorResources.secondaryColor,
                      value: process,
                    ),
                  );
                }
            ),
            Positioned.fill(
              child: BlocBuilder<MovieBloc, MovieState>(
                builder: (context, state){
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: state.visibleControlsPlayer ? 1 : 0,
                    child: SizedBox(
                      width: double.infinity,
                      child: CustomProgressBar(
                        indicatorSize: 20,
                        controller: viewModel.progressController,
                        untouchedColor: ColorResources.secondaryColor,
                        primaryColor: viewModel.state.currentMovie?.color ?? ColorResources.primaryColor,
                        onMoved: (value) {
                          viewModel.betterPlayerController?.seekTo(Duration(seconds: ((state.totalTimeEpisode ?? 0).toDouble() * value).toInt()));
                        },
                        onTap: (value) {
                          viewModel.betterPlayerController?.seekTo(Duration(seconds: ((state.totalTimeEpisode ?? 0).toDouble() * value).toInt()));
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ],
    );
  }
}
