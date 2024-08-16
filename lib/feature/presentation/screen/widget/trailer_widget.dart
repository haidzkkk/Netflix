import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TrailerWidget extends StatefulWidget {
  const TrailerWidget({super.key, required this.thumbnail, required this.trailerUrl, this.onTap});

  final String trailerUrl;
  final String thumbnail;
  final Function? onTap;

  @override
  State<TrailerWidget> createState() => _TrailerWidgetState();
}

class _TrailerWidgetState extends State<TrailerWidget> {

  bool isPlay = false;

  late YoutubePlayerController trailerVideoYTCtrl;

  @override
  void initState() {
    trailerVideoYTCtrl = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(widget.trailerUrl) ?? "",
        flags: const YoutubePlayerFlags(
            autoPlay: true,
            loop: true,
            hideControls: true,
            mute: true,
            forceHD: true,
            disableDragSeek: true,
            enableCaption: false,
            useHybridComposition: true,
            showLiveFullscreenButton: false
        )
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TrailerWidget oldWidget) {
    String oldTrailerID = YoutubePlayer.convertUrlToId(oldWidget.trailerUrl) ?? "";
    String newTrailerID = YoutubePlayer.convertUrlToId(widget.trailerUrl) ?? "";
    if(newTrailerID != oldTrailerID && newTrailerID.isNotEmpty){
      trailerVideoYTCtrl.load(newTrailerID);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    trailerVideoYTCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        trailerVideoYTCtrl.dispose();
        if(widget.onTap != null) widget.onTap!();
      },
      child: IgnorePointer(
        ignoring: true,
        child: widget.trailerUrl.isNotEmpty
            ? YoutubePlayerBuilder(
          player: YoutubePlayer(
            onReady: (){

            },
            controller: trailerVideoYTCtrl,
            thumbnail: thumbnail(),
          ),
          builder: (context, player){
            return player;
          },
        )
            : thumbnail(),
      ),
    );
  }

  Widget thumbnail(){
    return widget.thumbnail.isNotEmpty
        ? CachedNetworkImage(imageUrl: widget.thumbnail, fit: BoxFit.cover,)
        : const Center(child: CupertinoActivityIndicator(),);
  }



///
// initVideo(String url){
//   if(url.isEmpty) return;
//   chewieController?.pause();
//   trailerVideoCtrl?.pause();
//   chewieController?.dispose();
//   trailerVideoCtrl?.dispose();
//
//   trailerVideoCtrl = VideoPlayerController.networkUrl(Uri.parse(url));
//
//   trailerVideoCtrl?.initialize().then((_){
//     setState(() {});
//   });
//
//   chewieController = ChewieController(
//     videoPlayerController: trailerVideoCtrl!,
//     autoPlay: true,
//     looping: true,
//   );
// }

///
// return chewieController != null
// ? SizedBox.expand(
// child: FittedBox(
// fit: BoxFit.cover,
// child: SizedBox(
// width: trailerVideoCtrl!.value.size.width,
// height: trailerVideoCtrl!.value.size.height,
// child: Chewie(controller: chewieController!),
// ),
// ),
// )
//     : widget.thumbnail.isNotEmpty
// ? Image.network(widget.thumbnail, fit: BoxFit.cover,)
//     : const Center(child: CupertinoActivityIndicator(),);
}
