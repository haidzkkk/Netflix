import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/presentation/screen/home_screen/header_widget.dart';
import 'package:spotify/feature/presentation/screen/home_screen/slide_widget.dart';
import 'package:spotify/feature/presentation/screen/home_screen/widget/title_widget.dart';
import '../../blocs/home/home_bloc.dart';
import '../../blocs/home/home_state.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin{

  late final homeBloc = context.read<HomeBloc>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderWidget(),
          const SizedBox(height: 10,),
          TitleWidget(
              title: "Previews",
              onTap: (){

              }
          ),
          SizedBox(
            height: 100,
            child: BlocBuilder<HomeBloc, HomeState>(
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
                          child: CachedNetworkImage(imageUrl: item.getThumbUrl ?? "", width: 90, height: 90, fit: BoxFit.cover,));
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
            height: 140.w,
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.movies[CategoryMovie.movieNew]?.length ?? 0,
                    itemBuilder: (context, index) {
                      var item = state.movies[CategoryMovie.movieNew]![index];
                      return Image.network(item.getPosterUrl ?? "", width: 120.w, fit: BoxFit.cover,);
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
            builder: (context, state) {
              return SlideWidget(
                movies: state.movies[CategoryMovie.listEmotional] ?? [],
              );
            },
          ),
          const SizedBox(height: 10,),
          TitleWidget(
              title: "Phim lẻ",
              onTap: (){

              }
          ),
          SizedBox(
            height: 140.w,
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                var items = state.movies[CategoryMovie.listMovieSingle] ?? [];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      var item = items[index];
                      return Image.network(item.getPosterUrl, width: 120.w, fit: BoxFit.cover,);
                    },
                    separatorBuilder: (context, index) => const SizedBox(width: 10,),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10,),
          TitleWidget(
              title: "Phim hoạt hình",
              onTap: (){

              }
          ),
          SizedBox(
            height: 140.w,
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                var items = state.movies[CategoryMovie.listCartoon] ?? [];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      var item = items[index];
                      return Image.network(item.getPosterUrl, width: 120.w, fit: BoxFit.cover,);
                    },
                    separatorBuilder: (context, index) => const SizedBox(width: 10,),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10,),
          TitleWidget(
              title: "Tv show",
              onTap: (){

              }
          ),
          SizedBox(
            height: 140.w,
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                var items = state.movies[CategoryMovie.listTvShow] ?? [];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      var item = items[index];
                      return Image.network(item.getPosterUrl, width: 120.w, fit: BoxFit.cover,);
                    },
                    separatorBuilder: (context, index) => const SizedBox(width: 10,),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10,),
          TitleWidget(
              title: "Phim hành động",
              onTap: (){

              }
          ),
          SizedBox(
            height: 140.w,
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                var items = state.movies[CategoryMovie.listMovieAction] ?? [];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      var item = items[index];
                      return Image.network(item.getPosterUrl, width: 120.w, fit: BoxFit.cover,);
                    },
                    separatorBuilder: (context, index) => const SizedBox(width: 10,),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10,),
          TitleWidget(
              title: "Phim tình cảm",
              onTap: (){

              }
          ),
          SizedBox(
            height: 140.w,
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                var items = state.movies[CategoryMovie.listEmotional] ?? [];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      var item = items[index];
                      return Image.network(item.getPosterUrl, width: 120.w, fit: BoxFit.cover,);
                    },
                    separatorBuilder: (context, index) => const SizedBox(width: 10,),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
