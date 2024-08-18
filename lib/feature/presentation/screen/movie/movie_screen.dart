
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chewie/chewie.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/widget/chip_banner.dart';
import 'package:video_player/video_player.dart';

import '../../../commons/utility/style_util.dart';
import '../../../data/models/status.dart';
import '../../blocs/movie/movie_bloc.dart';
import '../home_screen/widget/action_button.dart';
import '../overview_movie/overview_shimmer_widget.dart';
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

  String? previousUrl;
  @override
  void initState() {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(''));
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      aspectRatio: 16/9
    );

    viewModel.stream.listen((state){
      final newUrl = state.currentEpisode?.linkM3u8 ?? '';
      if (newUrl.isNotEmpty && newUrl != previousUrl) {
        previousUrl = newUrl;

        printData("ok đã chạy controller");
        if (videoPlayerController.value.isInitialized) {
          videoPlayerController.dispose();
          chewieController.dispose();
        }


        videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(newUrl));
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: true,
          aspectRatio: 16 / 9,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((duration){
      viewModel.add(ChangeEpisodeMovieEvent(episode: viewModel.state.movie.data?.episodes?.firstOrNull?.episode?.firstOrNull));
    });
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    viewModel.add(ChangeEpisodeMovieEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              FutureBuilder(
                  future: viewModel.state.movie.data?.getColor(),
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
                    if(state.movie.status == StatusEnum.initial
                        || state.movie.status == StatusEnum.loading
                            && state.movie.data == null
                    ){
                      return const OverviewShimmerWidget();
                    }else if(state.movie.status == StatusEnum.failed){
                      Future(() {
                        context.showSnackBar("${state.movie.message}");
                      });
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16/9,
                          child: Chewie(
                            controller: chewieController,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10,),
                              Text(state.movie.data?.name ?? "",
                                style: Style.title.copyWith(fontSize: 20.sp),
                              ),
                              const SizedBox(height: 5,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Wrap(
                                        children: [
                                          if(state.movie.data?.time != null)
                                            Text(state.movie.data?.time ?? "", style: Style.body,),
                                          if(state.movie.data?.time != null)
                                            ...[
                                              const SizedBox(width: 5,),
                                              ChipText(
                                                  child: Text(
                                                      "${state.movie.data?.episodeCurrent}",
                                                      style: Style.body.copyWith(fontSize: 10.sp)
                                                  )
                                              ),
                                            ],
                                          if(state.movie.data?.time != null)
                                            ...[
                                              const SizedBox(width: 5,),
                                              ChipText(
                                                  child: Text("${state.movie.data?.quality}",
                                                      style: Style.body.copyWith(fontSize: 10.sp)
                                                  )
                                              ),
                                            ],
                                          if(state.movie.data?.year != null)
                                            ...[
                                              const SizedBox(width: 10,),
                                              Text("${state.movie.data?.year}",
                                                style: Style.body,
                                              ),
                                            ],
                                          if(state.movie.data?.lang != null)
                                            ...[
                                              const SizedBox(width: 5,),
                                              ChipText(
                                                  child: Text(
                                                      "${state.movie.data?.lang}",
                                                      style: Style.body.copyWith(fontSize: 10.sp)
                                                  )
                                              ),
                                            ],
                                        ]
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  Text("${state.movie.data?.view?.format() ?? 0} views",
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
                              if((state.movie.data?.episodes?.firstOrNull?.episode?.length ?? 0) > 1)
                                ...[

                                  const SizedBox(height: 15,),
                                  Wrap(
                                    children: state.movie.data?.episodes?.firstOrNull?.episode?.map((episode){
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
                                      imageUrl: state.movie.data?.getPosterUrl ?? "",
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
                                              TextSpan(text: state.movie.data?.category?.map((category) => category.name).toList().join(", ") ?? "",
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
                                              TextSpan(text: state.movie.data?.country?.map((country) => country.name).toList().join(", ") ?? "",
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
                                              TextSpan(text: state.movie.data?.actor?.join(", ") ?? "",
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
                                              TextSpan(text: state.movie.data?.director?.join(", ") ?? "",
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
                              if(state.movie.data?.content != null)
                                ...[
                                  const Text("Mô tả"),
                                  ReadMoreText(
                                    "${state.movie.data?.content ?? ""}  ",
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
      ),
    );
  }
}
