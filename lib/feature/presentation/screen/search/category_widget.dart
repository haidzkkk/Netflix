
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/widget/shimmer_widget.dart';

import '../../../commons/utility/utils.dart';
import '../../../data/models/category_movie.dart';
import '../../../data/models/response/movie.dart';
import '../../blocs/search/search_bloc.dart';
import '../home_screen/widget/movie_item.dart';
import '../overview_movie/overview_screen.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key, required this.categoryMovie});

  final CategoryMovie categoryMovie;

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  late SearchBloc searchViewModel = context.read<SearchBloc>();
  ScrollController scrollController = ScrollController();


  @override
  void initState() {
    searchViewModel.fetchMoviesCategory(widget.categoryMovie, true);

    scrollController.addListener((){
      if(scrollController.offset >= (scrollController.position.maxScrollExtent - 80.h)){
        searchViewModel.fetchMoviesCategory(widget.categoryMovie);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
      child: Column(
        children: [
          const SizedBox(height: 1,),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                var items = state.searchMovies[widget.categoryMovie]?.data ?? [];

                var itemCount = 3;
                var heightItem = calculateHeightItemGirdView(context, 80.h, itemCount);

                return GridView.builder(
                  controller: scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: itemCount,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: heightItem
                  ),
                  itemCount: items.length + getItemCountShimmer(items.length, itemCount),
                  itemBuilder: (context, index){
                    if(index > items.length -1){
                      return const ShimmerWidget(width: 0, height: 0);
                    }

                    Movie item = items[index];
                    return MovieItem(
                      movie: item,
                      onTap: () {
                        context.showBottomSheet(
                            OverViewScreen(
                              movie: item.toMovieInfo(),
                            )
                        );
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  int getItemCountShimmer(int itemsLength, int columnCount){
    if(itemsLength == 0){
      return 12;
    }
    var oddItem = itemsLength % columnCount;
    var remainingItem = columnCount - oddItem;
    return remainingItem;
  }
}
