import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/category_movie.dart';
import 'package:spotify/feature/presentation/blocs/home/home_bloc.dart';
import 'package:spotify/feature/presentation/blocs/home/home_event.dart';
import 'package:spotify/feature/presentation/screen/search/widget/search_text_field.dart';
import 'package:spotify/feature/presentation/screen/widget/custom_refresh.dart';
import '../../../data/models/response/movie.dart';
import '../../../data/models/status.dart';
import '../../blocs/search/search_bloc.dart';
import '../home_screen/widget/movie_item.dart';
import '../home_screen/widget/title_widget.dart';
import '../overview_movie/overview_screen.dart';
import '../overview_movie/widget/shimmer_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin{

  late SearchBloc searchViewModel;

  FocusNode searchNode = FocusNode();
  TextEditingController searchTextCtrl = TextEditingController();
  RefreshController refreshController = RefreshController();

  @override
  void initState() {
    searchViewModel = context.read<SearchBloc>();
    searchNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    searchViewModel.clearCategory(CategoryMovie.search);
    searchNode.dispose();
    refreshController.dispose();
    searchTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    visualDensity: const VisualDensity(horizontal: -4),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: SearchTextField(
                      height: 20.h,
                      focusNode: searchNode,
                      controller: searchTextCtrl,
                      onChange: (value){
                        searchViewModel.fetchTextSearchMovies(searchTextCtrl.text);
                        searchNode.unfocus();
                      },
                      prefixIcon: GestureDetector(
                          onTap: (){
                            searchNode.unfocus();
                          },
                          child: const Icon(Icons.search, color: Colors.white,)),
                      suffixIcon: GestureDetector(
                          onTap: (){
                            searchTextCtrl.text = "";
                            searchViewModel.fetchTextSearchMovies(searchTextCtrl.text);
                          },
                          child: Icon(Icons.clear, color: Colors.white.withOpacity(0.8))
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CustomRefresh(
                  controller: refreshController,
                  onRefresh: () async{
                    await searchViewModel.fetchTextSearchMovies(searchTextCtrl.text);
                    searchNode.unfocus();
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const TitleWidget(title: "Kết quả tìm kiếm", padding: EdgeInsetsDirectional.symmetric(vertical: 4),),
                        Builder(
                          builder: (context) {
                            var itemCount = 3;
                            var heightItem = calculateHeightItemGirdView(context, 100.h, itemCount);
                            var category = CategoryMovie.search;

                            return BlocBuilder<SearchBloc, SearchState>(
                              buildWhen: (previous, current) => previous.searchMovies[category] != current.searchMovies[category],
                              builder: (context, state) {
                                StatusEnum? status = state.searchMovies[category]?.status;
                                var items = state.searchMovies[category]?.data ?? [];

                                if((status == StatusEnum.successfully || status == StatusEnum.failed)
                                    && items.isEmpty){
                                  return const Text("Không tìm thấy dữ liệu");
                                }

                                bool isLoadingWhenEmpty = status == StatusEnum.loading && items.isEmpty;

                                return GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: itemCount,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                      childAspectRatio: heightItem
                                  ),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: isLoadingWhenEmpty ? 3 : items.length,
                                  itemBuilder: (context, index){
                                    if(isLoadingWhenEmpty){
                                      return const ShimmerWidget(width: 0, height: 0);
                                    }

                                    Movie item = items[index];
                                    return Column(
                                      children: [
                                        Flexible(
                                          flex: 8,
                                          child: MovieItem(
                                            movie: item,
                                            onTap: () {
                                              context.showDraggableBottomSheet(
                                                builder: (context, controller){
                                                  return OverViewScreen(
                                                    movie: item.toMovieInfo(),
                                                    draggableScrollController: controller,
                                                  );
                                                }
                                              );
                                            },
                                          ),
                                        ),
                                        Flexible(
                                          flex: 2,
                                          child: Text(item.name ?? "", maxLines: 2, overflow: TextOverflow.ellipsis,),
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }
                        ),
                        const SizedBox(height: 10,),
                        Builder(
                          builder: (context) {
                            var itemCount = 3;
                            var heightItem = calculateHeightItemGirdView(context, 100.h, itemCount);
                            var category = CategoryMovie.valueCategories.first;

                            return Column(
                              children: [
                                TitleWidget(
                                  title: "${category.name} mới nhất",
                                  padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
                                  onTap: (){
                                    context.read<HomeBloc>().add(ChangePageIndexHomeEvent(1));
                                    searchViewModel.pageTabCategorySearch(category);
                                    context.back();
                                  },
                                ),
                                BlocBuilder<SearchBloc, SearchState>(
                                  buildWhen: (previous, current) => previous.searchMovies[category] != current.searchMovies[category],
                                  builder: (context, state) {
                                    StatusEnum? status = state.searchMovies[category]?.status;
                                    var items = state.searchMovies[category]?.data ?? [];

                                    if(status == StatusEnum.successfully && items.isEmpty){
                                      return const Text("Không có dữ liệu");
                                    }

                                    return GridView.builder(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: itemCount,
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 10,
                                          childAspectRatio: heightItem
                                      ),
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: status == StatusEnum.loading ? 12 : (items.length > 51 ? 51 : items.length),
                                      itemBuilder: (context, index){
                                        if(status == StatusEnum.loading){
                                          return const ShimmerWidget(width: 0, height: 0);
                                        }

                                        Movie item = items[index];
                                        return Column(
                                          children: [
                                            Flexible(
                                              flex: 8,
                                              child: MovieItem(
                                                movie: item,
                                                onTap: () {
                                                  context.showDraggableBottomSheet(
                                                      builder: (context, controller){
                                                        return OverViewScreen(
                                                          movie: item.toMovieInfo(),
                                                          draggableScrollController: controller,
                                                        );
                                                      }
                                                  );
                                                },
                                              ),
                                            ),
                                            Flexible(
                                              flex: 2,
                                              child: Text(item.name ?? "", maxLines: 2, overflow: TextOverflow.ellipsis,),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
