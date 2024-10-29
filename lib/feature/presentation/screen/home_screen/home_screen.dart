import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/movie_info.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_cubit.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_state.dart';
import 'package:spotify/feature/presentation/screen/home_screen/header_widget.dart';
import 'package:spotify/feature/presentation/screen/home_screen/slide_widget.dart';
import 'package:spotify/feature/presentation/screen/home_screen/widget/movie_item.dart';
import 'package:spotify/feature/presentation/screen/home_screen/widget/title_widget.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/overview_screen.dart';
import 'package:spotify/feature/presentation/screen/widget/image_widget.dart';
import '../../../data/api/kk_request/category_movie.dart';
import '../../blocs/home/home_bloc.dart';
import '../../blocs/home/home_event.dart';
import '../../blocs/home/home_state.dart';

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
        homeViewModel.add(GetAllCategoryMovie());
      },
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<SettingCubit, SettingState>(
              buildWhen: (previous, current) => previous.favouriteCategories != current.favouriteCategories,
              builder: (context, state) {
                var category = state.favouriteCategories.firstOrNull ?? CategoryMovie.listCartoon;
                return BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (previous, current) => previous.movies[category] != current.movies[category],
                  builder: (context, state) {
                    return HeaderWidget(movie: state.movies[category]?.firstOrNull,);
                  }
                );
              }
            ),
            const TitleWidget(
                title: "Previews",
            ),
            SizedBox(
              height: 100,
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
                        return Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle
                            ),
                            child: ImageWidget(
                              url: item.thumbUrl,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            )
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(width: 10,),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10,),
            BlocBuilder<SettingCubit, SettingState>(
              buildWhen: (previous, current) => previous.favouriteCategories != current.favouriteCategories,
              builder: (context, state) {
                var category = state.favouriteCategories.firstOrNull ?? CategoryMovie.listEmotional;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TitleWidget(
                        title: category.name,
                        onTap: (){
                          homeViewModel.add(ChangePageIndexHomeEvent(1));
                          context.read<SearchBloc>().pageTabCategorySearch(category);
                        }
                    ),
                    BlocBuilder<HomeBloc, HomeState>(
                      buildWhen: (previous, current) => previous.movies[category] != current.movies[category],
                      builder: (context, state) {
                        return SlideWidget(
                          movies: state.movies[category] ?? [],
                          onTap: (MovieInfo movie){
                            context.openOverviewScreen(movie);
                          }
                        );
                      },
                    ),
                  ],
                );
              }
            ),
            BlocBuilder<SettingCubit, SettingState>(
              buildWhen: (previous, current) => previous.favouriteCategories != current.favouriteCategories,
              builder: (context, state) {
                List<CategoryMovie> categories = List.from(state.favouriteCategories)..removeAt(0);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: categories.map((category){
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10,),
                      TitleWidget(
                          title: category.name,
                          onTap: (){
                            homeViewModel.add(ChangePageIndexHomeEvent(1));
                            context.read<SearchBloc>().pageTabCategorySearch(category);
                          }
                      ),
                      SizedBox(
                        height: 180.w,
                        child: BlocBuilder<HomeBloc, HomeState>(
                          buildWhen: (previous, current) => previous.movies[category] != current.movies[category],
                          builder: (context, state) {
                            List<MovieInfo> items = state.movies[category] ?? [];
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
                                        context.openOverviewScreen(item);
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
                }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
