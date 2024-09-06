
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/date_converter.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';

import '../../../../commons/utility/style_util.dart';
import '../../overview_movie/overview_screen.dart';

class WatchedItem extends StatefulWidget {
  const WatchedItem({super.key, required this.movieLocal, this.showDate});

  final MovieLocal movieLocal;
  final bool? showDate;

  @override
  State<WatchedItem> createState() => _WatchedItemState();
}

class _WatchedItemState extends State<WatchedItem> {
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
                  child: CachedNetworkImage(
                    imageUrl: widget.movieLocal.thumb ?? "",
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.movieLocal.name ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Style.title2.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 5,),
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                        children: [
                          TextSpan(text: "Đã xem lúc - ", style: Style.body),
                          TextSpan(text: DateConverter.millisecondsSinceEpochHourString(widget.movieLocal.lastTime), style: Style.body.copyWith(fontSize: 12.sp)),
                        ]
                      ))
                    ],
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
          ),
        ),
      ],
    );
  }
}
