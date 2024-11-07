
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/commons/utility/date_converter.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/entity/movie_local.dart';
import 'package:spotify/feature/blocs/watched/watched_cubit.dart';
import 'package:spotify/feature/presentation/screen/widget/image_widget.dart';

import '../../../../commons/utility/style_util.dart';
import '../../overview_movie/overview_screen.dart';

class WatchedItem extends StatefulWidget {
  const WatchedItem({super.key, required this.movieLocal, this.showDate, this.animation});

  final MovieLocal movieLocal;
  final bool? showDate;
  final Animation<double>? animation;

  @override
  State<WatchedItem> createState() => _WatchedItemState();
}

class _WatchedItemState extends State<WatchedItem> {

  Widget animationWidget({required Widget child}){
    if(widget.animation != null){
      return SizeTransition(
        sizeFactor: widget.animation!,
        child: child,
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {

    return animationWidget(
      child: Column(
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
              context.openOverviewScreen(widget.movieLocal.toMovieInfo());
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
                    child: ImageWidget(
                      url: widget.movieLocal.thumb,
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
                  PopupMenuButton(
                    offset: const Offset(-20, 50),
                    color: Colors.grey,
                    itemBuilder: (context){
                      return [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.delete_outline_outlined, color: Colors.black,),
                              SizedBox(width: 5,),
                              Text("Xóa", style: TextStyle(color: Colors.black),)
                            ],
                          ),
                          onTap: () {
                            context.read<WatchedCubit>().deleteMovieHistory(widget.movieLocal);
                          },
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.share, color: Colors.black,),
                              SizedBox(width: 5,),
                              Text("Chia sẻ", style: TextStyle(color: Colors.black),)
                            ],
                          ),
                          onTap: () {

                          },
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.black,),
                              SizedBox(width: 5,),
                              Text("Thông tin", style: TextStyle(color: Colors.black),)
                            ],
                          ),
                          onTap: () {

                          },
                        ),
                      ];
                    },
                    icon: Icon(Icons.more_vert, color: Colors.white, size: 20.sp,)
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
