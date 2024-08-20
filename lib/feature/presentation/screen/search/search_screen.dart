import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/category_movie.dart';
import 'package:spotify/feature/presentation/blocs/home/home_bloc.dart';
import 'package:spotify/feature/presentation/blocs/home/home_event.dart';
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
          child: SingleChildScrollView(
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
                      child: Container(
                        height: 20.h,
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
                        child: TextField(
                          focusNode: searchNode,
                          controller: searchTextCtrl,
                          onEditingComplete: (){
                            searchViewModel.fetchTextSearchMovies(searchTextCtrl.text);
                            searchNode.unfocus();
                          },

                          textInputAction: TextInputAction.search,
                          cursorColor: Colors.white.withOpacity(0.5),
                          cursorHeight: 9.h,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white
                          ),
                          decoration: InputDecoration(
                              fillColor: Colors.black.withOpacity(0.7),
                              filled: true,
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
                              contentPadding: const EdgeInsets.only(left: 28, top: 0, bottom: 0),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(width: 0, color: Colors.transparent,),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(width: 0, color: Colors.transparent,),
                              ),
                              hintText: "Tìm kiếm...",
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7))),
                        ),
                      ),
                    ),
                  ],
                ),
                const TitleWidget(title: "Kết quả tìm kiếm", padding: EdgeInsetsDirectional.symmetric(vertical: 4),),
                BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    var itemCount = 3;
                    var heightItem = calculateHeightItemGirdView(context, 100.h, itemCount);
                    var category = CategoryMovie.search;

                    StatusEnum? status = state.searchMovies[category]?.status;
                    var items = state.searchMovies[category]?.data ?? [];

                    if(status == StatusEnum.successfully && items.isEmpty){
                      return const Text("Không tìm thấy dữ liệu");
                    }
                    if(status == StatusEnum.failed){
                      return Text(state.searchMovies[CategoryMovie.search]?.message ?? "Có lỗi sảy ra");
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
                      itemCount: status == StatusEnum.loading ? 12 : items.length,
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
                const SizedBox(height: 10,),
                Builder(
                  builder: (context) {
                    var itemCount = 3;
                    var heightItem = calculateHeightItemGirdView(context, 100.h, itemCount);
                    var category = CategoryMovie.movieNew;

                    return Column(
                      children: [
                        TitleWidget(
                          title: "Phim mới nhất",
                          padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
                          onTap: (){
                            context.read<HomeBloc>().add(PageIndexHomeEvent(1));
                            searchViewModel.pageTabCategorySearch(category);
                            context.back();
                          },
                        ),
                        BlocBuilder<SearchBloc, SearchState>(
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
                              itemCount: status == StatusEnum.loading ? 12 : items.length,
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
