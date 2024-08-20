
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chewie/chewie.dart';
import 'package:spotify/feature/commons/utility/pageutil.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/widget/chip_banner.dart';
import 'package:video_player/video_player.dart';

import '../../../commons/utility/style_util.dart';
import '../../blocs/movie/movie_bloc.dart';
import '../home_screen/widget/action_button.dart';
import '../overview_movie/widget/chip_text.dart';
import '../widget/read_more_widget.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {

  late MovieBloc viewModel = context.read<MovieBloc>();

  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;

  setChewieController(VideoPlayerController videoPlayerController) {
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      aspectRatio: 16 / 9,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: (){
              viewModel.add(ChangeEpisodeMovieEvent(episode: viewModel.state.currentMovie?.episodes?.firstOrNull?.episode?.firstOrNull));
            },
          ),
        );
      },
    );
  }

  final DraggableScrollableController _controller = DraggableScrollableController();
  String? previousUrl;
  @override
  void initState() {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(''));
    setChewieController(videoPlayerController);

    viewModel.stream.listen((state){
      final newUrl = state.currentEpisode?.linkM3u8 ?? '';
      if (newUrl.isNotEmpty && newUrl != previousUrl) {
        previousUrl = newUrl;

        if (videoPlayerController.value.isInitialized) {
          videoPlayerController.dispose();
          chewieController.dispose();
        }

        videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(newUrl));
        setChewieController(videoPlayerController);
      }
    });


    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    _controller.dispose();
    viewModel.add(CleanWatchMovieEvent());
    super.dispose();
  }

  double heightBottomNav = 56;
  double heightMovieCollapse = 56;

  late double maxSize = 1;
  late double minSize = (heightMovieCollapse + heightBottomNav) / PageUtil.screenHeight;

  @override
  Widget build(BuildContext context) {
    return BlocListener<MovieBloc, MovieState>(
        listenWhen: (previous, current) => current.isExpandWatchMovie && current.currentMovie != null,
        listener: (context, state){
          _controller.animateTo(
            maxSize,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            if (notification.extent > 0.5 && viewModel.state.isExpandWatchMovie == false) {
              viewModel.add(ChangeExpandedMovieEvent(isExpand: true));
            } else if (notification.extent < 0.5 && viewModel.state.isExpandWatchMovie) {
              viewModel.add(ChangeExpandedMovieEvent(isExpand: false));
            }
            return true;
          },
          child: DraggableScrollableSheet(
              controller: _controller,
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
                        FutureBuilder(
                            future: viewModel.state.currentMovie?.getColor(),
                            builder: (context, snapShot) {
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
                        ),
                        BlocBuilder<MovieBloc, MovieState>(
                            builder: (context, state){
                              chewieController = chewieController.copyWith(
                                showControls: state.isExpandWatchMovie ? true : false,
                              );
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
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
                                            child: Chewie(
                                              controller: chewieController,
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
                                                      if(chewieController.isPlaying){
                                                        chewieController.pause();
                                                      }else{
                                                        chewieController.play();
                                                      }
                                                    },
                                                    icon: const Icon(Icons.play_circle_outlined)
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: IconButton(
                                                    onPressed: (){
                                                      viewModel.add(CleanWatchMovieEvent());
                                                    },
                                                    icon: const Icon(Icons.clear)
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10,),
                                        Text(state.currentMovie?.name ?? "",
                                          style: Style.title.copyWith(fontSize: 20.sp),
                                        ),
                                        const SizedBox(height: 5,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Wrap(
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
                                              ),
                                            ),
                                            const SizedBox(width: 20,),
                                            Text("${state.currentMovie?.view?.format() ?? 0} views",
                                              style: Style.body.copyWith(color: Colors.green),
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
                                                onTap: (){

                                                },
                                              ),
                                            ),
                                            Expanded(
                                              child: ActionButton(
                                                title: const Text("Share"),
                                                icon: const Icon(FontAwesomeIcons.paperPlane),
                                                onTap: (){
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        if((state.currentMovie?.episodes?.firstOrNull?.episode?.length ?? 0) > 1)
                                          ...[

                                            const SizedBox(height: 15,),
                                            Wrap(
                                              children: state.currentMovie?.episodes?.firstOrNull?.episode?.map((episode){
                                                String name = episode.name ?? "";
                                                String content = name.substring(name.indexOf(" ") + 1, name.length);
                                                bool watched = false;
                                                bool isSelect = episode.slug == state.currentEpisode?.slug;
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
                                            ),
                                          ],
                                        const SizedBox(height: 15,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: CachedNetworkImage(
                                                  imageUrl: state.currentMovie?.getPosterUrl ?? "",
                                                  fit: BoxFit.cover,
                                                )
                                            ),
                                            const SizedBox(width: 8,),
                                            Expanded(
                                              flex: 3,
                                              child: Column(
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
                                              ),
                                            ),
                                          ],),
                                        const SizedBox(height: 5,),
                                        if(state.currentMovie?.content != null)
                                          ...[
                                            const Text("Mô tả"),
                                            ReadMoreText(
                                              "${state.currentMovie?.content ?? ""}  ",
                                              style: Style.body.copyWith(color: Colors.white.withOpacity(0.4)),
                                              trimLength: 250,
                                            ),
                                          ],
                                        const SizedBox(height: 20,),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
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
}
