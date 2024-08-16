import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/presentation/screen/home_screen/home_screen.dart';
import 'package:spotify/feature/presentation/screen/main/widget/item_bottom_bar.dart';
import 'package:spotify/feature/presentation/screen/widget/badge_widget.dart';
import '../../blocs/home/home_bloc.dart';
import '../../blocs/home/home_event.dart';
import '../../blocs/home/home_state.dart';
import '../search/filter_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  late final homeViewModel = context.read<HomeBloc>();

  List<Widget> screens = [
    const HomeScreen(),
    const FilterScreen(),
    const SizedBox(),
    const SizedBox(),
    const SizedBox(),
  ];

  @override
  void initState() {
    homeViewModel.add(GetAllCategoryMovie());
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
      // body: BlocBuilder<HomeBloc, HomeState>(
      //   builder: (context, state) {
      //     return IndexedStack(
      //       index: state.currentPageIndex,
      //       children: screens,
      //     );
      //   },
      // ),
      body: PageView(
        controller: homeViewModel.pageController,
        children: screens,
      ),
      bottomNavigationBar: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return BottomNavigationBar(
            enableFeedback: true,
            type: BottomNavigationBarType.fixed,
            iconSize: 18,
            currentIndex: state.currentPageIndex,
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
                label: "History",
                badgeCount: 12,
              ),
              ItemBottomBar.withChildBadge(
                icon: const Icon(FontAwesomeIcons.download),
                label: "Download",
                badgeCount: 6,
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

}
