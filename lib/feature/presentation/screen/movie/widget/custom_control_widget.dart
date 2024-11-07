
import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/commons/utility/color_resource.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/screen/widget/process_indicator/custom_process.dart';

class CustomControlsWidget extends StatefulWidget {
  final BetterPlayerController controller;
  final Function(bool visbility)? onControlsVisibilityChanged;

  const CustomControlsWidget({
    super.key,
    required this.controller,
    this.onControlsVisibilityChanged,
  });

  @override
  CustomControlsWidgetState createState() => CustomControlsWidgetState();
}

class CustomControlsWidgetState extends State<CustomControlsWidget> {
  late MovieBloc viewModel = context.read<MovieBloc>();
  late Size sizeScreen = MediaQuery.of(context).size;

  bool controllerVisible = false;
  bool enableVolume = true;
  double speed = 1;
  bool isException = false;

  Timer? autoHideControl;

  handleControlVisible(){
    autoHideControl?.cancel();
    autoHideControl = null;
    if(controllerVisible && widget.controller.isPlaying()!){
      autoHideControl = Timer(const Duration(milliseconds: 4000), (){
        widget.controller.setControlsVisibility(false);
      });
    }
  }

  late StreamSubscription streamSubscription;

  @override
  void initState() {
    streamSubscription = widget.controller.controlsVisibilityStream.listen((isVisible){
      widget.controller.toggleControlsVisibility(isVisible);
      controllerVisible = isVisible;
      setState(() {});
      handleControlVisible();
    });
    widget.controller.addEventsListener(( event){
      if(event.betterPlayerEventType == BetterPlayerEventType.exception){
        isException = true;
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: controllerVisible ? Container(
                color: Colors.black.withOpacity(0.4),
              ) : const SizedBox(),
            ),
          ),
          Positioned.fill(
            bottom: 25,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: (){
                if(viewModel.state.isExpandWatchMovie == false) return;
                widget.controller.setControlsVisibility(!controllerVisible);
              },
              onDoubleTapDown: (details) async{
                if(!controllerVisible){
                  widget.controller.setControlsVisibility(!controllerVisible);
                }
                handleControlVisible();

                Duration rewindDuration;
                if(details.localPosition.dx < (sizeScreen.width / 2)){
                  Duration? videoDuration =
                  await widget.controller.videoPlayerController!.position;
                  rewindDuration = Duration(seconds: (videoDuration!.inSeconds - 20));
                  widget.controller.seekTo(rewindDuration);
                }else{
                  Duration? videoDuration =
                  await widget.controller.videoPlayerController!.position;
                  rewindDuration = Duration(seconds: (videoDuration!.inSeconds + 20));
                  widget.controller.seekTo(rewindDuration);
                }
              },
              child: const SizedBox(),
            ),
          ),
          if(!widget.controller.isFullScreen)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(top: 16, end: 12),
                child: iconAction(
                  padding: const EdgeInsetsDirectional.all(12),
                  icon: FontAwesomeIcons.chevronDown,
                  onTap: (){
                    context.read<MovieBloc>().add(ChangeExpandedMovieEvent(isExpand: false));
                  },
                ),
              ),
            ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: !controllerVisible ? const SizedBox() : Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BlocBuilder<MovieBloc, MovieState>(
                            buildWhen: (previous, current) => previous.totalTimeEpisode != current.totalTimeEpisode
                                || previous.currentTimeEpisode != current.currentTimeEpisode,
                            builder: (context, state){
                              return Text("${state.currentTimeEpisode?.secondsToMinute ?? "00:00"} / ${state.totalTimeEpisode?.secondsToMinute ?? "00:00"}");
                            }
                        ),
                        const Spacer(),
                        iconAction(
                          padding: const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 12),
                          icon: enableVolume ? Icons.volume_up_sharp : Icons.volume_off_sharp,
                          onTap: (){
                            handleControlVisible();
                            enableVolume = !enableVolume;
                            widget.controller.setVolume(enableVolume ? 1 : 0);
                            setState(() {});
                          },
                        ),
                        const SizedBox(width: 8,),
                        iconAction(
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
                          icon: Icons.speed,
                          onTap: (){
                            handleControlVisible();

                            speed = speed == 1 ? 2 : speed == 2 ? 0.5 : 1;
                            widget.controller.setSpeed(speed);
                            setState(() {});
                          },
                        ),
                        Text("$speed"),
                        const SizedBox(width: 16,),
                        iconAction(
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
                          icon: widget.controller.isFullScreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          onTap: () {
                            handleControlVisible();
                            setState(() {
                              if (widget.controller.isFullScreen) {
                                widget.controller.exitFullScreen();
                              } else {
                                widget.controller.enterFullScreen();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if(widget.controller.isFullScreen)
                      BlocBuilder<MovieBloc, MovieState>(
                        buildWhen: (previous, current) => previous.visibleControlsPlayer != current.visibleControlsPlayer
                            || previous.totalTimeEpisode != current.totalTimeEpisode
                            || previous.currentTimeEpisode != current.currentTimeEpisode,
                        builder: (context, state){
                          var process = (state.currentTimeEpisode ?? 0.0) /  (state.totalTimeEpisode ?? 0.0);
                          if(process.isNaN || process.isInfinite || process < 0 || process > 1){
                            process = 0;
                          }
                          return CustomProcessIndicator(
                            width: MediaQuery.of(context).size.width,
                            height: 5.sp,
                            indicatorSize: 10.sp,
                            color: viewModel.state.currentMovie?.color,
                            process: process,
                            enable: state.visibleControlsPlayer,
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            onMoved: (value) {
                              handleControlVisible();
                              viewModel.betterPlayerController?.seekTo(Duration(seconds: ((state.totalTimeEpisode ?? 0).toDouble() * value).toInt()));
                            },
                          );
                        },
                      )
                  ],
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: !controllerVisible ? const SizedBox() : Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  if(isException){
                    viewModel.add(ChangeEpisodeMovieEvent(episode: viewModel.state.currentEpisode));
                    return;
                  }else{
                    if (widget.controller.isPlaying()!) {
                      widget.controller.pause();
                    } else {
                      widget.controller.play();
                    }
                  }

                  setState(() { });
                  handleControlVisible();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: const BorderRadiusDirectional.all(Radius.circular(100)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10
                      )
                    ]
                  ),
                  padding: const EdgeInsetsDirectional.all(5),
                  child: Icon(isException ? Icons.error_outline
                      : widget.controller.isPlaying()!
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 35.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget iconAction({
    required IconData icon,
    required Function() onTap,
    EdgeInsetsGeometry? padding
  }){
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: !controllerVisible ? const SizedBox() : InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(8.0),
          child: Icon(icon, color: Colors.white, size: 25.sp,),
        ),
      ),
    );
  }
}
