import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/widget/shimmer_widget.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    required this.url,
    this.fit,
    this.width,
    this.height,
  });

  final String? url;
  final BoxFit? fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if(url?.isNotEmpty != true) return const SizedBox(child: Center(child: Icon(Icons.error_outline),),);
    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, s) => const ShimmerWidget(width: 0, height: 0),
      errorWidget: (context, s, o) => const SizedBox(child: Center(child: Icon(Icons.error_outline),),),
    );
  }
}
