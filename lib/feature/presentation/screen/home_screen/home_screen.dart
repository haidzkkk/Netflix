import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/presentation/screen/home_screen/header_widget.dart';
import 'package:spotify/feature/presentation/screen/home_screen/slide_widget.dart';
import 'package:spotify/feature/presentation/screen/home_screen/widget/movie_item.dart';
import 'package:spotify/feature/presentation/screen/home_screen/widget/title_widget.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/overview_screen.dart';
import '../../../data/models/category_movie.dart';
import '../../../data/models/response/movie.dart';
import '../../blocs/home/home_bloc.dart';
import '../../blocs/home/home_event.dart';
import '../../blocs/home/home_state.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../blocs/search/search_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin{

  late final homeViewModel = context.read<HomeBloc>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async{
        for (var category in CategoryMovie.values) {
          homeViewModel.add(GetCategoryMovie(category));
        }
      },
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) => previous.movies[CategoryMovie.movieNew] != current.movies[CategoryMovie.movieNew],
              builder: (context, state) {
                return HeaderWidget(movie: state.movies[CategoryMovie.movieNew]?.firstOrNull,);
              }
            ),
            const SizedBox(height: 10,),
            TitleWidget(
                title: "Previews",
                onTap: (){

                }
            ),
            SizedBox(
              height: 100,
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) => previous.movies[CategoryMovie.listTvShow] != current.movies[CategoryMovie.listTvShow],
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.movies[CategoryMovie.listTvShow]?.length ?? 0,
                      itemBuilder: (context, index) {
                        var item = state.movies[CategoryMovie.listTvShow]![index];
                        return Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle
                            ),
                            child: CachedNetworkImage(imageUrl: item.getThumbUrl, width: 90, height: 90, fit: BoxFit.cover,));
                      },
                      separatorBuilder: (context, index) => const SizedBox(width: 10,),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10,),
            TitleWidget(
                title: "Trending now",
                onTap: (){

                }
            ),
            SizedBox(
              height: 180.w,
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) => previous.movies[CategoryMovie.movieNew] != current.movies[CategoryMovie.movieNew],
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.movies[CategoryMovie.movieNew]?.length ?? 0,
                      itemBuilder: (context, index) {
                      var item = state.movies[CategoryMovie.movieNew]![index];
                      return MovieItem(
                          movie: item,
                          onTap: (){
                            context.showDraggableBottomSheet(
                                builder: (context, controller){
                                  return OverViewScreen(
                                    movie: item.toMovieInfo(),
                                    draggableScrollController: controller,
                                  );
                                }
                            );
                          }
                      );
                    },
                      separatorBuilder: (context, index) => const SizedBox(width: 10,),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10,),
            TitleWidget(
              title: "Phim hay nhất",
              onTap: (){

              }
            ),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) => previous.movies[CategoryMovie.listEmotional] != current.movies[CategoryMovie.listEmotional],
              builder: (context, state) {
                return SlideWidget(
                  movies: state.movies[CategoryMovie.listEmotional] ?? [],
                  onTap: (Movie movie){
                    context.showDraggableBottomSheet(
                        builder: (context, controller){
                          return OverViewScreen(
                            movie: movie.toMovieInfo(),
                            draggableScrollController: controller,
                          );
                        }
                    );
                  }
                );
              },
            ),
            ...CategoryMovie.valuesCategory
                .map((category){
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10,),
                  TitleWidget(
                      title: category.name,
                      onTap: (){
                        homeViewModel.add(PageIndexHomeEvent(1));
                        context.read<SearchBloc>().pageTabCategorySearch(category);
                      }
                  ),
                  SizedBox(
                    height: 180.w,
                    child: BlocBuilder<HomeBloc, HomeState>(
                      buildWhen: (previous, current) => previous.movies[category] != current.movies[category],
                      builder: (context, state) {
                        var items = state.movies[category] ?? [];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              var item = items[index];
                              return MovieItem(
                                  movie: item,
                                  onTap: (){
                                    context.showDraggableBottomSheet(
                                        builder: (context, controller){
                                          return OverViewScreen(
                                            movie: item.toMovieInfo(),
                                            draggableScrollController: controller,
                                          );
                                        }
                                    );
                                  }
                              );
                            },
                            separatorBuilder: (context, index) => const SizedBox(width: 10,),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
