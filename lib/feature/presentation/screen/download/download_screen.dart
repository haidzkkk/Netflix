
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/presentation/blocs/download/download_cubit.dart';
import 'package:spotify/feature/presentation/blocs/download/download_state.dart';
import 'package:spotify/feature/presentation/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/screen/download/widget/movie_download_item.dart';
import 'package:spotify/feature/presentation/screen/search/widget/search_text_field.dart';
import 'package:spotify/feature/presentation/screen/widget/custom_refresh.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> with AutomaticKeepAliveClientMixin{

  late DownloadCubit viewModel = context.read<DownloadCubit>();
  late MovieBloc movieViewModel = context.read<MovieBloc>();
  ScrollController scrollController = ScrollController();
  RefreshController refreshController = RefreshController();

  @override
  void initState() {
    viewModel.getMoviesDownload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Scaffold(
        body: SafeArea(
        child: Column(
        children: [
            SearchTextField(
              height: 20.h,
              // focusNode: searchNode,
              // controller: searchTextCtrl,
              onChange: (value){
              },
              prefixIcon: GestureDetector(
                  onTap: (){
                  },
                  child: const Icon(Icons.search, color: Colors.white,)),
              suffixIcon: GestureDetector(
                  onTap: (){
                  },
                  child: Icon(Icons.clear, color: Colors.white.withOpacity(0.8))
              ),
            ),
          Expanded(
            child: CustomRefresh(
              controller: refreshController,
              scrollController: scrollController,
              onLoad: () async{
                refreshController.loadNoData();
              },
              onRefresh: () async{
                await viewModel.getMoviesDownload(isRefresh: true);
              },
                child: BlocBuilder<DownloadCubit, DownloadState>(
                  buildWhen: (previous, current) => previous.movies.hashCode != current.movies.hashCode,
                  builder: (context, state){
                    var items = state.movies.values.toList();

                    if(items.isEmpty){
                      return const Center(child: Text("Không có phim nào"));
                    }

                    return AnimatedList(
                      key: viewModel.keyListAnimation,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      initialItemCount: items.length,
                      itemBuilder: (context, index, animation){
                        var item = items[index];
                        return MovieDownloadItem(movieLocal: item,);
                      },
                    );
                  },
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
