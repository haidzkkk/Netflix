
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/presentation/screen/widget/image_widget.dart';

import '../../../../data/models/response/movie.dart';
import '../../overview_movie/widget/chip_banner.dart';

class MovieItem extends StatelessWidget {
  const MovieItem({
    super.key,
    required this.movie,
    this.size,
    required this.onTap,
  });

  final Movie movie;
  final double? size;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size ?? 140.w,
        child: Stack(
          children: [
            Positioned.fill(
              child: ImageWidget(
                url: movie.getPosterUrl,
                fit: BoxFit.cover,
              ),
            ),
            if(movie.episodeCurrent != null)
              Positioned(
                left: 2,
                top: 2,
                child: ChipBanner(
                  colors: const [
                    Colors.brown,
                    Colors.redAccent,
                  ],
                  child: Text(movie.episodeCurrent!,
                    style: Style.body.copyWith(fontSize: 12.sp),
                  ),
                )
              ),
            if(movie.quality != null || movie.lang != null)
              Positioned(
                right: 2,
                bottom: 2,
                child: ChipBanner(
                  colors: const [
                    Colors.purple,
                    Colors.pink,
                  ],
                  child: Text("${movie.quality} ${movie.lang}",
                    style: Style.body.copyWith(fontSize: 12.sp),
                  ),
                )
              ),
          ],
        ),
      ),
    );
  }
}
