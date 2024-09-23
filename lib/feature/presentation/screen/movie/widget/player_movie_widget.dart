
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/pageutil.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/presentation/blocs/movie/movie_bloc.dart';

class PlayerMovieWidget extends StatefulWidget {
  const PlayerMovieWidget({
    super.key,
    required this.heightBottomNav,
    required this.heightMovieCollapse,
    required this.actionDispose
  });

  final double heightBottomNav;
  final double heightMovieCollapse;
  final Function() actionDispose;

  @override
  State<PlayerMovieWidget> createState() => _PlayerMovieWidgetState();
}

class _PlayerMovieWidgetState extends State<PlayerMovieWidget> {
  late MovieBloc viewModel = context.read<MovieBloc>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieBloc, MovieState>(
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
                      ? BetterPlayer(controller: viewModel.betterPlayerController!,)
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
    );
  }
}
