
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/utility/pageutil.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/db_local/episode_local.dart';
import 'package:spotify/feature/data/models/movie_detail/movie_info_response.dart';
import 'package:spotify/feature/presentation/blocs/download/download_cubit.dart';
import 'package:spotify/feature/presentation/blocs/home/home_bloc.dart';
import 'package:spotify/feature/presentation/blocs/home/home_event.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/widget/chip_banner.dart';

import '../../../commons/utility/style_util.dart';
import '../../blocs/movie/movie_bloc.dart';
import '../home_screen/widget/action_button.dart';
import '../overview_movie/widget/chip_text.dart';
import '../widget/read_more_widget.dart';
import 'package:better_player/better_player.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {

  late MovieBloc viewModel = context.read<MovieBloc>();
  final DraggableScrollableController _dragController = DraggableScrollableController();

  BetterPlayerController? _betterPlayerController;
  setVideoController(String url){
    _betterPlayerController?.dispose();
    BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      autoPlay: true,
      eventListener: _onPlayerEvent,
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network, url,
      useAsmsSubtitles: true
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration,);
    _betterPlayerController?.setupDataSource(dataSource);
  }

  _onPlayerEvent(BetterPlayerEvent event){

    /// get current time watch episode
    Duration? myProgress = event.parameters?['progress'];
    if(myProgress?.inSeconds != null){
      currentTime = myProgress!.inSeconds;
    }

    /// check when player play
    /// check time watched end show snackBar to watch continue
    if (event.betterPlayerEventType == BetterPlayerEventType.play
        && isPlayed == false) {
      isPlayed = true;
      int minSecond = 10;
      var currentEpisode = viewModel.state.currentEpisode;
      if(currentEpisode?.episodeLocal != null
          && (currentEpisode?.episodeLocal?.currentSecond ?? 0) > minSecond
      ){
        showSnackBarContinueEpisode(currentEpisode?.episodeLocal?.currentSecond ?? 0);
      }
    }
  }

  String? currentUrl;
  handleSelectEpisode(String newUrl){
    if (newUrl.isNotEmpty && newUrl != currentUrl) {
      var currentEpisode = viewModel.state.currentEpisode;
      saveEpisodePreviousToLocal();
      episodeWillSave = currentEpisode;
      isPlayed = false;
      currentUrl = newUrl;
      setVideoController(newUrl);
    }
  }

  StreamSubscription? listenViewModelSubscription;

  @override
  void initState() {
    setVideoController(viewModel.state.currentEpisode?.linkM3u8 ?? 'link_empty');
    listenViewModelSubscription = viewModel.stream.listen((state){
      handleSelectEpisode(state.currentEpisode?.linkM3u8 ?? '');
    });
    super.initState();
  }

  @override
  void dispose() {
    disposeScreen();
    super.dispose();
  }

  bool isDispose = false;
  disposeScreen(){
    if(isDispose) return;
    listenViewModelSubscription?.cancel();
    listenViewModelSubscription = null;
    _betterPlayerController?.dispose();
    _dragController.dispose();
    saveEpisodePreviousToLocal();
    viewModel.add(CleanWatchMovieEvent());
    isDispose = true;
  }

  int currentTime = 0;
  bool isPlayed = false;
  Episode? episodeWillSave;
  saveEpisodePreviousToLocal(){
    printData("save không ${episodeWillSave?.name}");
    if(episodeWillSave == null) return;

    var episodeLocal = EpisodeLocal.fromWhenWatched(
        movieID: viewModel.state.currentMovie?.sId ?? "",
        body: episodeWillSave!,
        currentSecond: currentTime,
        lastTime: DateTime.now().millisecondsSinceEpoch
    );
    episodeWillSave!.episodeLocal = episodeLocal;
    viewModel.add(SaveEpisodeMovieWatchedToLocalEvent(episode: episodeLocal));
  }

  Color? backgroundColor;

  double heightBottomNav = 56;
  double heightMovieCollapse = 56;
  late double maxSize = 1;
  late double minSize = (heightMovieCollapse + heightBottomNav) / PageUtil.screenHeight;


  @override
  Widget build(BuildContext context) {
    return BlocListener<MovieBloc, MovieState>(
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
                        BlocBuilder<MovieBloc, MovieState>(
                          buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
                          builder: (context, state){
                            return FutureBuilder(
                                future: viewModel.state.currentMovie?.getColor(),
                                builder: (context, snapShot) {
                                  backgroundColor = snapShot.data;
                                  return Container(
                                    height: 700,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: const Alignment(1, 1),
                                            colors: [
                                              Colors.transparent,
                                              snapShot.data?.withOpacity(0.5) ?? Colors.transparent,
                                            ]
                                        )
                                    ),
                                  );
                                }
                            );
                          }
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BlocBuilder<MovieBloc, MovieState>(
                              builder: (context, state){
                                _betterPlayerController?.setControlsEnabled(state.isExpandWatchMovie ? true : false);
                                return GestureDetector(
                                  onTap: state.isExpandWatchMovie ? null : (){
                                    viewModel.add(ChangeExpandedMovieEvent(isExpand: true));
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        height: state.isExpandWatchMovie ? PageUtil.screenWidth / 16 * 9 : heightMovieCollapse,
                                        width: state.isExpandWatchMovie ? PageUtil.screenWidth : heightMovieCollapse / 9 * 21,
                                        duration: const Duration(milliseconds: 200),
                                        child: AspectRatio(
                                          aspectRatio: state.isExpandWatchMovie ? 16/9 : 21/9,
                                          child: BetterPlayer(
                                            controller: _betterPlayerController!,
                                          ),
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
                                                    if(_betterPlayerController?.isPlaying() == true){
                                                      _betterPlayerController?.pause();
                                                    }else{
                                                      _betterPlayerController?.play();
                                                    }
                                                  },
                                                  icon: const Icon(Icons.play_circle_outlined)
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: IconButton(
                                                  onPressed: (){
                                                    disposeScreen();
                                                  },
                                                  icon: const Icon(Icons.clear)
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const SizedBox(height: 10,),
                                  BlocBuilder<MovieBloc, MovieState>(
                                    buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
                                    builder: (context, state){
                                      return Text(state.currentMovie?.name ?? "",
                                        style: Style.title.copyWith(fontSize: 20.sp),
                                      );
                                    }
                                  ),
                                  const SizedBox(height: 5,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: BlocBuilder<MovieBloc, MovieState>(
                                          buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
                                          builder: (context, state){
                                            return Wrap(
                                                children: [
                                                  if(state.currentMovie?.time != null)
                                                    Text(state.currentMovie?.time ?? "", style: Style.body,),
                                                  if(state.currentMovie?.time != null)
                                                    ...[
                                                      const SizedBox(width: 5,),
                                                      ChipText(
                                                          child: Text(
                                                              "${state.currentMovie?.episodeCurrent}",
                                                              style: Style.body.copyWith(fontSize: 10.sp)
                                                          )
                                                      ),
                                                    ],
                                                  if(state.currentMovie?.time != null)
                                                    ...[
                                                      const SizedBox(width: 5,),
                                                      ChipText(
                                                          child: Text("${state.currentMovie?.quality}",
                                                              style: Style.body.copyWith(fontSize: 10.sp)
                                                          )
                                                      ),
                                                    ],
                                                  if(state.currentMovie?.year != null)
                                                    ...[
                                                      const SizedBox(width: 10,),
                                                      Text("${state.currentMovie?.year}",
                                                        style: Style.body,
                                                      ),
                                                    ],
                                                  if(state.currentMovie?.lang != null)
                                                    ...[
                                                      const SizedBox(width: 5,),
                                                      ChipText(
                                                          child: Text(
                                                              "${state.currentMovie?.lang}",
                                                              style: Style.body.copyWith(fontSize: 10.sp)
                                                          )
                                                      ),
                                                    ],
                                                ]
                                            );
                                          }
                                        ),
                                      ),
                                      const SizedBox(width: 20,),
                                      BlocBuilder<MovieBloc, MovieState>(
                                        buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
                                        builder: (context, state){
                                          return Text("${state.currentMovie?.view?.format() ?? 0} views",
                                            style: Style.body.copyWith(color: Colors.green),
                                          );
                                        }
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10,),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ActionButton(
                                          title: const Text("My List"),
                                          icon: const Icon(FontAwesomeIcons.plus),
                                          onTap: (){

                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: ActionButton(
                                          title: const Text("Download"),
                                          icon: const Icon(FontAwesomeIcons.download),
                                          onTap: () async{
                                            handleDownloadEpisode();
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: ActionButton(
                                          title: const Text("Share"),
                                          icon: const Icon(FontAwesomeIcons.paperPlane),
                                          onTap: (){
                                            if(currentUrl?.isNotEmpty != true) {
                                              context.showSnackBar("Không tìm thấy url phim hiện tại");
                                            }else if(viewModel.state.currentMovie?.slug?.isNotEmpty != true
                                                || viewModel.state.currentEpisode?.slug?.isNotEmpty != true){
                                              context.showSnackBar("Không tìm tên, tập phim để lưu vào local");
                                            }
                                            context.read<DownloadCubit>()
                                                .stopDownloadEpisode(
                                                movie: viewModel.state.currentMovie!,
                                                episode: viewModel.state.currentEpisode!
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  BlocBuilder<MovieBloc, MovieState>(
                                    buildWhen: (previous, current) => previous.currentMovie != current.currentMovie || previous.currentEpisode != current.currentEpisode,
                                    builder: (context, state){
                                      if((state.currentMovie?.episodes?.firstOrNull?.episode?.length ?? 0) <= 1){
                                        return const SizedBox();
                                      }
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
                                              return Container(
                                                padding: const EdgeInsets.all(4),
                                                child: GestureDetector(
                                                  onTap: (){
                                                    viewModel.add(ChangeEpisodeMovieEvent(episode: episode));
                                                  },
                                                  child: ChipBanner(
                                                      colors: isSelect || watched
                                                          ? const [Colors.white12, Colors.white12]
                                                          : const [Colors.white38, Colors.white38],
                                                      child: Padding(
                                                          padding: const EdgeInsets.all(4),
                                                          child: Text(content, style: Style.body.copyWith(
                                                            color: isSelect ? Colors.red : null,
                                                          ),)
                                                      )
                                                  ),
                                                ),
                                              );
                                            }).toList() ?? [],
                                          )],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 15,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: BlocBuilder<MovieBloc, MovieState>(
                                            buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
                                            builder: (context, state){
                                              return CachedNetworkImage(
                                                imageUrl: state.currentMovie?.getPosterUrl ?? "",
                                                fit: BoxFit.cover,
                                              );
                                            }
                                          )
                                      ),
                                      const SizedBox(width: 8,),
                                      Expanded(
                                        flex: 3,
                                        child: BlocBuilder<MovieBloc, MovieState>(
                                          buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
                                          builder: (context, state){
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                      children: [
                                                        TextSpan(text: "Category: ",
                                                            style: Style.body.copyWith(fontWeight: FontWeight.w700)
                                                        ),
                                                        TextSpan(text: state.currentMovie?.category?.map((category) => category.name).toList().join(", ") ?? "",
                                                            style: Style.body
                                                        ),
                                                      ]
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                RichText(
                                                  text: TextSpan(
                                                      children: [
                                                        TextSpan(text: "Country: ",
                                                            style: Style.body.copyWith(fontWeight: FontWeight.w700)
                                                        ),
                                                        TextSpan(text: state.currentMovie?.country?.map((country) => country.name).toList().join(", ") ?? "",
                                                            style: Style.body
                                                        ),
                                                      ]
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                RichText(
                                                  text: TextSpan(
                                                      children: [
                                                        TextSpan(text: "Actor: ",
                                                            style: Style.body.copyWith(fontWeight: FontWeight.w700)
                                                        ),
                                                        TextSpan(text: state.currentMovie?.actor?.join(", ") ?? "",
                                                            style: Style.body
                                                        ),
                                                      ]
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                RichText(
                                                  text: TextSpan(
                                                      children: [
                                                        TextSpan(text: "Director: ",
                                                            style: Style.body.copyWith(fontWeight: FontWeight.w700)
                                                        ),
                                                        TextSpan(text: state.currentMovie?.director?.join(", ") ?? "",
                                                            style: Style.body
                                                        ),
                                                      ]
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        ),
                                      ),
                                    ],),
                                  const SizedBox(height: 5,),
                                  BlocBuilder<MovieBloc, MovieState>(
                                    buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
                                    builder: (context, state){
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("Mô tả"),
                                          ReadMoreText(
                                            "${state.currentMovie?.content ?? ""}  ",
                                            style: Style.body.copyWith(color: Colors.white.withOpacity(0.4)),
                                            trimLength: 250,
                                          )
                                        ],
                                      );
                                    }
                                  ),
                                  const SizedBox(height: 20,),
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
                _betterPlayerController?.seekTo(Duration(seconds: seconds));
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: Text("Xem",
                  style: Style.title2.copyWith(color: Colors.white)
              ),
            ),
          ],
        ),
        seconds: 5,
        backgroundColor: backgroundColor
    );
  }

  void handleDownloadEpisode() {
    context.read<DownloadCubit>().startDownloadEpisode(
        movie: viewModel.state.currentMovie!,
        episode: viewModel.state.currentEpisode!
    ).then((value){
      if(!value.key){
        context.showSnackBar(value.value);
        return;
      }

      context.showSnackBarWidget(
          child: Row(
            children: [
              Expanded(child: Text("Đang tải tập phim", style: Style.body.copyWith(color: Colors.white),)),
              const SizedBox(width: 10,),
              GestureDetector(
                onTap: (){
                  viewModel.add(ChangeExpandedMovieEvent(isExpand: false));
                  context.read<HomeBloc>().add(PageIndexHomeEvent(3));
                },
                child: Text("Xem",
                    style: Style.title2.copyWith(color: Colors.white)
                ),
              ),
            ],
          ),
          seconds: 5,
          backgroundColor: backgroundColor
      );
    });
  }

}