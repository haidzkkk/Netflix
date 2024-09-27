import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/movie_detail/movie_info.dart';
import 'package:spotify/feature/data/models/status.dart';
import 'package:spotify/feature/presentation/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/screen/home_screen/widget/action_button.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/overview_shimmer_widget.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/widget/chip_text.dart';
import 'package:spotify/feature/presentation/screen/widget/custom_bottom.dart';
import 'package:spotify/feature/presentation/screen/widget/image_widget.dart';
import 'package:spotify/feature/presentation/screen/widget/read_more_widget.dart';
import 'package:spotify/feature/presentation/screen/widget/trailer_widget.dart';

import '../../../commons/utility/style_util.dart';
import '../../../data/models/category_movie.dart';
import '../../../data/models/response/movie.dart';
import '../../blocs/home/home_bloc.dart';
import '../../blocs/home/home_state.dart';
import '../home_screen/widget/movie_item.dart';
import '../home_screen/widget/title_widget.dart';

class OverViewScreen extends StatefulWidget {
  const OverViewScreen({super.key, required this.movie, required this.draggableScrollController});

  final MovieInfo movie;
  final ScrollController draggableScrollController;

  @override
  State<OverViewScreen> createState() => _OverViewScreenState();
}

class _OverViewScreenState extends State<OverViewScreen>{
  
  late MovieBloc viewModel = context.read<MovieBloc>();
  @override
  void initState() {
    viewModel.add(GetInfoMovieEvent(movie: widget.movie));
    super.initState();
  }
  
  @override
  void dispose() {
    viewModel.add(CleanMovieEvent());
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.black,
    body: SingleChildScrollView(
      controller: widget.draggableScrollController,
      child: Stack(
        children: [
          FutureBuilder(
              future: widget.movie.fetchColor(),
              builder: (context, snapShot) {
                return TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                      begin: Colors.transparent,
                      end: snapShot.data?.withOpacity(0.5) ?? Colors.transparent
                  ),
                  duration: const Duration(milliseconds: 1000),
                  builder: (_, Color? color, __) {
                    return Container(
                      height: 700,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: const Alignment(1, 1),
                              colors: [
                                Colors.transparent,
                                color ?? Colors.transparent,
                              ]
                          )
                      ),
                    );
                  },
                );
              }
          ),
          BlocBuilder<MovieBloc, MovieState>(
            buildWhen: (previous, current) => current.movie.status == StatusEnum.failed,
            builder: (context, state2){
              if(state2.movie.status == StatusEnum.failed){
                Future(() {
                  context.showSnackBar("${state2.movie.message}");
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100.h,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: BlocBuilder<MovieBloc, MovieState>(
                            buildWhen: (previous, current) => previous.movie.data?.getThumbUrl != current.movie.data?.getThumbUrl,
                            builder: (context, state){
                              return TrailerWidget(
                                  thumbnail: state.movie.data?.getThumbUrl ?? "",
                                  // trailerUrl: state.movie.data?.trailerUrl ?? ""
                                  trailerUrl: "",
                              );
                            }
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).viewPadding.top + 8.h,
                          right: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: (){

                                },
                                child: Icon(FontAwesomeIcons.chromecast, color: Colors.black.withOpacity(0.7), size: 25.sp,)
                              ),
                              IconButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                icon: Icon(FontAwesomeIcons.solidCircleXmark, color: Colors.black.withOpacity(0.7), size: 25.sp,)
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
                        BlocBuilder<MovieBloc, MovieState>(
                          buildWhen: (previous, current) => previous.movie.data?.name != current.movie.data?.name,
                          builder: (context, state){
                            return Text(state.movie.data?.name ?? " _ _",
                              style: Style.title.copyWith(fontSize: 20.sp),
                            );
                          }
                        ),
                        BlocBuilder<MovieBloc, MovieState>(
                          buildWhen: (previous, current) => previous.movie.data != current.movie.data,
                          builder: (context, state){
                            return Row(
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
                            );
                          }
                        ),
                        const SizedBox(height: 10,),
                        CustomButton(
                          backgroundColor: Colors.white,
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          height: 30,
                          borderRadius: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded, color: Colors.black, size: 40.w,),
                              const SizedBox(width: 5,),
                              Text("Play", style: Style.title2.copyWith(color: Colors.black, fontSize: 20.sp),),
                            ],
                          ),
                          onPressed: (){
                            if(viewModel.state.movie.status == StatusEnum.successfully){
                              context.back();
                              viewModel.add(InitWatchMovieEvent(movie: viewModel.state.movie.data!));
                            }else{
                              context.showSnackBar("Không tìm thấy tập phim");
                            }
                          },
                        ),
                        CustomButton(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          height: 30,
                          borderRadius: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download, color: Colors.white, size: 30.w,),
                              const SizedBox(width: 5,),
                              Text("Download", style: Style.title2.copyWith(color: Colors.white, fontSize: 20.sp),),
                            ],
                          ),
                          onPressed: (){

                          },
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
                                title: const Text("Rate"),
                                icon: const Icon(FontAwesomeIcons.thumbsUp),
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
                        const SizedBox(height: 15,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: BlocBuilder<MovieBloc, MovieState>(
                                buildWhen: (previous, current) => previous.movie.data?.getPosterUrl != current.movie.data?.getPosterUrl,
                                builder: (context, state){
                                  if(state.movie.data?.getPosterUrl.isNotEmpty != true){
                                    return const SizedBox();
                                  }
                                  return ImageWidget(
                                    url: state.movie.data?.getPosterUrl ?? "",
                                    fit: BoxFit.cover,
                                  );
                                }
                              )
                            ),
                            const SizedBox(width: 8,),
                            BlocBuilder<MovieBloc, MovieState>(
                              buildWhen: (previous, current) => previous.movie.data != current.movie.data,
                              builder: (context, state){
                                return Expanded(
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
                                              TextSpan(text: state.movie.data?.category?.map((category) => category.name).toList().join(", ") ?? " _ _",
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
                                              TextSpan(text: state.movie.data?.country?.map((country) => country.name).toList().join(", ") ?? " _ _",
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
                                              TextSpan(text: state.movie.data?.actor?.join(", ") ?? " _ _",
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
                                              TextSpan(text: state.movie.data?.director?.join(", ") ?? " _ _",
                                                  style: Style.body
                                              ),
                                            ]
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            ),
                          ],),
                        BlocBuilder<MovieBloc, MovieState>(
                            buildWhen: (previous, current) => previous.movie.data != current.movie.data,
                            builder: (context, state){
                              if(state.movie.data?.content == null){
                                return const SizedBox(height: 5,);
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Mô tả"),
                                  ReadMoreText(
                                    "${state.movie.data?.content ?? " _ _"}  ",
                                    style: Style.body.copyWith(color: Colors.white.withOpacity(0.4)),
                                    trimLength: 250,
                                  ),
                                ],
                              );
                          }
                        ),
                        BlocBuilder<MovieBloc, MovieState>(
                          buildWhen: (previous, current) => previous.movie.data != current.movie.data,
                          builder: (context, state){
                            return BlocBuilder<HomeBloc, HomeState>(
                              builder: (context, homeState) {
                                return Column(
                                  children: state.movie.data?.category?.map((category){
                                    List<Movie>? movies = homeState.movies[CategoryMovie.getCategoryMovie(category.slug)];

                                    if(movies == null) return const SizedBox();
                                    return Column(
                                      children: [
                                        const SizedBox(height: 10,),
                                        TitleWidget(
                                            title: category.name ?? "",
                                            onTap: (){
                                            }
                                        ),
                                        SizedBox(
                                          height: 140.w,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: movies.length,
                                              itemBuilder: (context, index) {
                                                var item = movies[index];
                                                return MovieItem(
                                                    movie: item,
                                                    onTap: (){
                                                      viewModel.add(GetInfoMovieEvent(movie: item.toMovieInfo()));
                                                      widget.draggableScrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.bounceIn);
                                                    }
                                                );
                                              },
                                              separatorBuilder: (context, index) => const SizedBox(width: 10,),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList() ?? [],
                                );
                              },
                            );
                          }
                        ),
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


}
