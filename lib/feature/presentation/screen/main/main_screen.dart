import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/commons/utility/connect_util.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/category_movie.dart';
import 'package:spotify/feature/presentation/blocs/download/download_cubit.dart';
import 'package:spotify/feature/presentation/blocs/download/download_state.dart';
import 'package:spotify/feature/presentation/screen/download/download_screen.dart';
import 'package:spotify/feature/presentation/screen/home_screen/home_screen.dart';
import 'package:spotify/feature/presentation/screen/main/widget/item_bottom_bar.dart';
import 'package:spotify/feature/presentation/screen/setting/more_screen.dart';
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

class _MainScreenState extends State<MainScreen>{
  int currentIndex = 0;

  late final homeViewModel = context.read<HomeBloc>();
  late final movieViewModel = context.read<MovieBloc>();
  late final downloadViewModel = context.read<DownloadCubit>();

  late StreamSubscription streamSubscription;

  List<Widget> screens = [
    const HomeScreen(),
    const FilterScreen(),
    const WatchedScreen(),
    const DownloadScreen(),
    const MoreScreen(),
  ];

  @override
  void initState() {
    for (var category in CategoryMovie.values) {
      homeViewModel.add(GetCategoryMovie(category));
    }
    listenNetworkState();

    downloadViewModel.checkAndSyncMovieDownloading();
    super.initState();
  }

  @override
  void dispose() {
    homeViewModel.add(DisposeHomeEvent());
    streamSubscription.cancel();
    ok?.cancel();
    ok = null;
    super.dispose();
  }

  Timer? ok;
  bool isDestroyApp = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if(movieViewModel.state.isExpandWatchMovie){
          movieViewModel.add(ChangeExpandedMovieEvent(isExpand: false));
          return;
        }else if(homeViewModel.state.currentPageIndex != 0){
          homeViewModel.add(ChangePageIndexHomeEvent(0));
          return;
        }

        if(isDestroyApp){
          SystemNavigator.pop();
        }else{
          isDestroyApp = true;
          showToast("Nhấn thêm lần nữa để thoát");
          ok = Timer(const Duration(milliseconds: 1000), (){
            isDestroyApp = false;
            ok?.cancel();
            ok = null;
          });
        }
    },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
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
                              iconSize: 18.sp,
                              currentIndex: state.currentPageIndex,
                              onTap: (value) => homeViewModel.add(ChangePageIndexHomeEvent(value)),
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
                                  icon: BlocConsumer<DownloadCubit, DownloadState>(
                                    listener: (context, state){
                                      movieViewModel.add(UpdateDownloadEpisodeMovieEvent(episodesDownload: state.moviesDownloading));
                                    },
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
                  ),
                ],
              ),
            ),
            BlocConsumer<HomeBloc, HomeState>(
              listenWhen: (previous, current) => previous.isConnect != current.isConnect,
              listener: (context, state){
                if(first && !state.isConnect){
                  homeViewModel.add(ChangePageIndexHomeEvent(3));
                }
                first = false;
              },
              buildWhen: (previous, current) => previous.isConnect != current.isConnect,
              builder: (context, state) {
                return Material(
                  color: state.isConnect ? Colors.teal : Colors.red,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: state.isConnect ? 0 : 20,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(state.isConnect ? "Đã kết nối mạng" : "Không kết nối mạng"),
                  ),
                );
              }
            )
          ],
        ),
      ),
    );
  }
  bool first = true;
  void listenNetworkState() {
    streamSubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result){
      bool data = ConnectUtil.checkNetwork(result);
      if(homeViewModel.state.isConnect != data){
        homeViewModel.add(ListenNetworkConnectHomeEvent(data));
      }
    });
  }


}
