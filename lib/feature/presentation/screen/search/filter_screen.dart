import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/presentation/screen/search/category_widget.dart';
import 'package:spotify/feature/presentation/screen/search/search_screen.dart';
import '../../../commons/utility/style_util.dart';
import '../../blocs/search/search_bloc.dart';

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
          length: searchViewModel.tabCategories.length,
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
          child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            var categories = searchViewModel.tabCategories;
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
        ),
        ),
        body: Column(
          children: [
            GestureDetector(
              onTap: (){
                context.to(const SearchScreen());
              },
              child: Container(
                alignment: Alignment.centerLeft,
                height: 20.h,
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                margin: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: const BorderRadiusDirectional.all(Radius.circular(15))
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 5,),
                    const Text("Tìm kiếm..."),
                    const Spacer(),
                    Builder(
                      builder: (context) {
                        return IconButton(
                            visualDensity: const VisualDensity(horizontal: -4),
                            onPressed: (){
                              Scaffold.of(context).openEndDrawer();
                              // Scaffold.of(context).openDrawer();
                            },
                            icon: const Icon(Icons.filter_list_rounded)
                        );
                      }
                    )
                  ],
                ),
              ),
            ),
            TabBar(
                controller: searchViewModel.tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorPadding: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                dividerHeight: 0,
                // indicatorColor: ColorResources.getPrimaryColor(),
                // labelColor: ColorResources.getPrimaryColor(),
                tabs: searchViewModel.tabCategories.map((tab) => Tab(
                  child: Text(tab.name),
                ),).toList()
            ),
            Expanded(
              child: TabBarView(
                  controller: searchViewModel.tabController,
                  children: searchViewModel.tabCategories.map(
                          (tab) => CategoryWidget(categoryMovie: tab,)).toList()
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
