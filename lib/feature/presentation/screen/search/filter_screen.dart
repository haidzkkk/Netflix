import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/blocs/search/search_bloc.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/blocs/setting/setting_cubit.dart';
import 'package:spotify/feature/blocs/setting/setting_state.dart';
import 'package:spotify/feature/presentation/screen/search/category_widget.dart';
import 'package:spotify/feature/presentation/screen/search/search_screen.dart';
import 'package:spotify/feature/presentation/screen/search/widget/search_text_field.dart';
import '../../../commons/utility/style_util.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin{

  late SearchBloc searchViewModel = context.read<SearchBloc>();

  @override
  void initState() {
    searchViewModel.initScreen(
      tabController: TabController(
          length: searchViewModel.categories.length,
          vsync: this,
          initialIndex: searchViewModel.state.currentPageTab
      )
    );

    searchViewModel.tabController.addListener((){
      searchViewModel.pageTabIndexSearch(searchViewModel.tabController.index);
    });
    super.initState();
  }

  @override
  void dispose() {
    searchViewModel.disposeScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Scaffold(
        endDrawerEnableOpenDragGesture: false,
        endDrawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.4,
          child: BlocConsumer<SettingCubit, SettingState>(
            listenWhen: (previous, current) => previous.favouriteCategories != current.favouriteCategories,
            listener: (context, state){
              searchViewModel.tabController.dispose();
              searchViewModel.initScreen(
                  tabController: TabController(
                      length: searchViewModel.categories.length,
                      vsync: this,
                      initialIndex: searchViewModel.state.currentPageTab
                  )
              );
            },
            buildWhen: (previous, current) => previous.favouriteCategories != current.favouriteCategories,
            builder: (context, state) {
              return BlocBuilder<SearchBloc, SearchState>(
                buildWhen: (previous, current) => previous.currentPageTab != current.currentPageTab,
                builder: (context, state) {
                  var categories = searchViewModel.categories;
                  return ListView.separated(
                    itemCount: categories.length,
                    itemBuilder: (context, index){
                      var category = categories[index];
                      var selected = index == state.currentPageTab;
                      return ListTile(
                        selected: selected,
                        selectedColor: Colors.black.withOpacity(0.6),
                        selectedTileColor: Colors.white,
                        title: Text(category.name,
                          textAlign: TextAlign.start,
                          style: Style.title2.copyWith(
                            color: selected ? Colors.red : null,
                            shadows: selected ? [ const Shadow(color: Colors.red, blurRadius: 10)] : []
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        visualDensity: const VisualDensity(horizontal: -4),
                        onTap: (){
                          searchViewModel.pageTabIndexSearch(index);
                        },
                      );
                    },
                  separatorBuilder: (BuildContext context, int index) => const Divider(height: 1,),
                );
              },
                      );
            }
          ),
        ),
        body: Column(
          children: [
            SearchTextField(
              onTap: (){
                context.to(const SearchScreen());
              },
              height: 20.h,
              onlyRead: true,
              prefixIcon: const Icon(Icons.search, color: Colors.white,),
              suffixIcon: Builder(
                  builder: (context) {
                    return IconButton(
                        visualDensity: const VisualDensity(horizontal: -4),
                        onPressed: (){
                          Scaffold.of(context).openEndDrawer();
                        },
                        icon: const Icon(Icons.filter_list_rounded, color: Colors.white)
                    );
                  }
              ),
            ),
            BlocBuilder<SettingCubit, SettingState>(
              buildWhen: (previous, current) => previous.favouriteCategories != current.favouriteCategories,
              builder: (context, state) {
                return TabBar(
                    controller: searchViewModel.tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorPadding: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    dividerHeight: 0,
                    // indicatorColor: ColorResources.getPrimaryColor(),
                    // labelColor: ColorResources.getPrimaryColor(),
                    tabs: searchViewModel.categories.map((tab) => Tab(
                      child: Text(tab.name),
                    ),).toList()
                );
              }
            ),
            Expanded(
              child: BlocBuilder<SettingCubit, SettingState>(
               buildWhen: (previous, current) => previous.favouriteCategories != current.favouriteCategories,
               builder: (context, state) {
                  return TabBarView(
                      controller: searchViewModel.tabController,
                      children: searchViewModel.categories.map(
                              (tab) => CategoryWidget(categoryMovie: tab,)).toList()
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
