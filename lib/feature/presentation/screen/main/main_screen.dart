import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/data/models/category_movie.dart';
import 'package:spotify/feature/presentation/blocs/download/download_cubit.dart';
import 'package:spotify/feature/presentation/blocs/download/download_state.dart';
import 'package:spotify/feature/presentation/screen/download/download_screen.dart';
import 'package:spotify/feature/presentation/screen/home_screen/home_screen.dart';
import 'package:spotify/feature/presentation/screen/main/widget/item_bottom_bar.dart';
import 'package:spotify/feature/presentation/screen/movie/movie_screen.dart';
import 'package:spotify/feature/presentation/screen/watched/watched_screen.dart';
import '../../blocs/home/home_bloc.dart';
import '../../blocs/home/home_event.dart';
import '../../blocs/home/home_state.dart';
import '../../blocs/movie/movie_bloc.dart';
import '../search/filter_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  late final homeViewModel = context.read<HomeBloc>();
  late final movieViewModel = context.read<MovieBloc>();

  List<Widget> screens = [
    const HomeScreen(),
    const FilterScreen(),
    const WatchedScreen(),
    const DownloadScreen(),
    const SizedBox(),
  ];

  @override
  void initState() {
    for (var category in CategoryMovie.values) {
      homeViewModel.add(GetCategoryMovie(category));
    }
    super.initState();
  }

  @override
  void dispose() {
    homeViewModel.add(DisposeHomeEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: homeViewModel.pageController,
                    children: screens,
                  ),
                ),
                const SizedBox(height: 56,)
              ],
            ),
          ),
          Positioned.fill(
            child: BlocBuilder<MovieBloc, MovieState>(
              buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
              builder: (context, state) {
                if(state.currentMovie != null){
                  return const MovieScreen();
                }
                return const SizedBox();
              }
            ),
          ),
          BlocBuilder<MovieBloc, MovieState>(
            buildWhen: (previous, current) => previous.isExpandWatchMovie != current.isExpandWatchMovie,
            builder: (context, state) {
              bool isShowNav = !state.isExpandWatchMovie;
              return AnimatedPositioned(
                bottom: isShowNav ? 0 : -56,
                left: 0,
                right: 0,
                duration: const Duration(milliseconds: 300),
                child: BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (previous, current) => previous.currentPageIndex != current.currentPageIndex,
                  builder: (context, state) {
                    return BottomNavigationBar(
                      enableFeedback: true,
                      type: BottomNavigationBarType.fixed,
                      iconSize: 18,
                      currentIndex: state.currentPageIndex,
                      backgroundColor: Colors.black,
                      onTap: (value) => homeViewModel.add(PageIndexHomeEvent(value)),
                      selectedItemColor: Colors.white,
                      selectedLabelStyle: const TextStyle(color: Colors.white),
                      unselectedIconTheme: IconThemeData(color: Colors.white.withOpacity(0.3)),
                      unselectedLabelStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      items: [
                        ItemBottomBar.withChildBadge(
                          icon: const Icon(FontAwesomeIcons.house),
                          label: "Home",
                        ),
                        ItemBottomBar.withChildBadge(
                          icon: const Icon(FontAwesomeIcons.magnifyingGlass),
                          label: "Search",
                        ),
                        ItemBottomBar.withChildBadge(
                          icon: const Icon(FontAwesomeIcons.tv),
                          label: "Watched",
                        ),
                        ItemBottomBar.withChildBadge(
                          icon: BlocBuilder<DownloadCubit, DownloadState>(
                            buildWhen: (previous, current) => previous.moviesDownloading.length != current.moviesDownloading.length,
                            builder: (context, state) {
                              return ItemBottomBar.iconBadge(
                                  count: state.moviesDownloading.length,
                                  icon: const Icon(FontAwesomeIcons.download)
                              );
                            }
                          ),
                          label: "Download",
                        ),
                        ItemBottomBar.withChildBadge(
                          icon: const Icon(FontAwesomeIcons.bars),
                          label: "More",
                        ),
                      ],
                    );
                  },
                ),
              );
            }
          )
        ],
      ),
    );
  }

}
