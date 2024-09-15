
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/presentation/blocs/download/download_cubit.dart';
import 'package:spotify/feature/presentation/blocs/download/download_state.dart';
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
  ScrollController scrollController = ScrollController();
  RefreshController refreshController = RefreshController();

  @override
  void initState() {
    viewModel.getMovieDownload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      // body: FutureBuilder(
      //   future: FileUtil.getListMovieDownload(),
      //   builder: (context, snapshot){
      //     return ListView.builder(
      //       itemCount: snapshot.data?.length ?? 0,
      //       itemBuilder: (context, index){
      //         var item = snapshot.data![index];
      //
      //         return Container(
      //           padding: const EdgeInsetsDirectional.all(8),
      //           margin: const EdgeInsetsDirectional.all(8),
      //           color: Colors.brown,
      //           child: FutureBuilder(
      //               future: item.getSize(),
      //               builder: (context, snapshot){
      //               return Text("${item.getName()} ${bytesToMb(snapshot.data?.toDouble() ?? 0.0).toStringAsFixed(1)} MB");
      //             }
      //           ),
      //         );
      //       },
      //     );
      //   },
      // ),
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
                await viewModel.getMovieDownload(isRefresh: true);
              },
                child: BlocBuilder<DownloadCubit, DownloadState>(
                  buildWhen: (previous, current) => previous.movies.hashCode != current.movies.hashCode,
                  builder: (context, state){
                    print("build21321312");
                    var items = state.movies.values.toList();

                    if(items.isEmpty){
                      return const Center(child: Text("Không có phim nào"));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index){
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
