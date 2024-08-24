
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';
import 'package:spotify/feature/data/repositories/local_db_repository.dart';
import 'package:spotify/feature/presentation/screen/watched/widget/watched_item.dart';

import '../../../di/InjectionContainer.dart';
import '../search/widget/search_text_field.dart';

class WatchedScreen extends StatefulWidget {
  const WatchedScreen({super.key});

  @override
  State<WatchedScreen> createState() => _WatchedScreenState();
}

class _WatchedScreenState extends State<WatchedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SearchTextField(
              height: 20.h,
              // focusNode: searchNode,
              // controller: searchTextCtrl,
              onChange: (value){
                // searchViewModel.fetchTextSearchMovies(searchTextCtrl.text);
                // searchNode.unfocus();
              },
              prefixIcon: GestureDetector(
                  onTap: (){
                    // searchNode.unfocus();
                  },
                  child: const Icon(Icons.search, color: Colors.white,)),
              suffixIcon: GestureDetector(
                  onTap: (){
                    // searchTextCtrl.text = "";
                    // searchViewModel.fetchTextSearchMovies(searchTextCtrl.text);
                  },
                  child: Icon(Icons.clear, color: Colors.white.withOpacity(0.8))
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async{
                  // setState(() {});
                },
                child: FutureBuilder(
                  future: sl<LocalDbRepository>().getAllMovieHistory(),
                  builder: (context, snapShot) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapShot.data?.length ?? 0,
                      itemBuilder: (context, index){
                        MovieLocal? previousItem = index == 0 ? MovieLocal.fromJson(snapShot.data![index]) : null;
                        var item = MovieLocal.fromJson(snapShot.data![index]);

                        var previousItemTime = DateTime.fromMillisecondsSinceEpoch(previousItem?.lastTime ?? 0);
                        var itemTime = DateTime.fromMillisecondsSinceEpoch(item.lastTime ?? 0);
                        var showDate = itemTime.day != previousItemTime.day;

                        return WatchedItem(movieLocal: item, showDate: showDate,);
                      },
                    );
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
