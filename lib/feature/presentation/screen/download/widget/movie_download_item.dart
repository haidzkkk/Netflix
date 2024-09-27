
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/date_converter.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/db_local/episode_download.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';
import 'package:spotify/feature/data/models/db_local/movie_status_download.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/widget/chip_text.dart';
import 'package:spotify/feature/presentation/screen/widget/image_widget.dart';

import '../../../../commons/utility/style_util.dart';
import '../../overview_movie/overview_screen.dart';

class MovieDownloadItem extends StatefulWidget {
  const MovieDownloadItem({super.key, required this.movieLocal, this.showDate});

  final MovieLocal movieLocal;
  final bool? showDate;

  @override
  State<MovieDownloadItem> createState() => _MovieDownloadItemState();
}

class _MovieDownloadItemState extends State<MovieDownloadItem> {
  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(widget.showDate == true)
          Text(
            DateConverter.dateStringToday(DateTime.fromMillisecondsSinceEpoch(widget.movieLocal.lastTime ?? 0)),
            style: Style.title2,
          ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            context.showDraggableBottomSheet(
                builder: (context, controller){
                  return OverViewScreen(
                    movie: widget.movieLocal.toMovieInfo(),
                    draggableScrollController: controller,
                  );
                }
            );
          },
          child: Container(
            margin: const EdgeInsetsDirectional.all(5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150.w,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadiusDirectional.all(Radius.circular(5)),
                  ),
                  child: Stack(
                    children: [
                      ImageWidget(
                        url: widget.movieLocal.poster ?? "",
                        fit: BoxFit.cover,
                      ),
                      Builder(
                        builder: (context) {
                          EpisodeDownload? item = widget.movieLocal.episodesDownload?.values.firstWhereOrNull((e) {
                            return e.status == StatusDownload.LOADING;
                          });

                          if(item == null) return const SizedBox();

                          return  Positioned.fill(child: Container(
                            color: Colors.white.withOpacity(0.5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.downloading, color: Colors.black),
                                Text('${item.executeProcess ?? 0}%', style: Style.body.copyWith(color: Colors.black),),
                              ],
                            ),
                          ));
                        }
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.movieLocal.name ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Style.title2.copyWith(color: Colors.white),
                            ),
                          ),
                          IconButton(
                              onPressed: (){

                              },
                              visualDensity: const VisualDensity(vertical: -4),
                              icon: Icon(Icons.more_vert, color: Colors.white, size: 20.sp,)
                          )
                        ],
                      ),
                      const SizedBox(height: 5,),
                      Builder(
                        builder: (context) {
                          var items = <Widget>[];
                          var listData = widget.movieLocal.episodesDownload?.values.toList() ?? [];
                          for(int i = 0; i < listData.length; i++){
                            var item = listData[i];
                            if(i > 10){
                              items.add(const Padding(
                                padding: EdgeInsetsDirectional.all(4),
                                child: ChipText(child: Text("\t\t...\t\t")),
                              ));
                              break;
                            }
                            var downloadStr = "";
                            if(item.executeProcess != null
                                && item.status == StatusDownload.LOADING
                                && item.executeProcess! < 100
                                && item.executeProcess! >= 0
                            ){
                              downloadStr = " (${item.executeProcess}%)";
                            }else if(item.executeProcess != null
                                && item.status == StatusDownload.INITIALIZATION
                            ){
                              downloadStr = " (đang trờ)";
                            }
                            items.add(Padding(
                              padding: const EdgeInsetsDirectional.all(4),
                              child: ChipText(child: Text("${item.name}$downloadStr")),
                            ));
                          }

                          return Wrap(
                            children: items,
                          );
                        }
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
