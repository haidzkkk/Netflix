import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/presentation/screen/home_screen/widget/action_button.dart';

import '../../../../gen/assets.gen.dart';
import '../../../commons/utility/style_util.dart';
import '../../../data/models/response/movie.dart';
import '../overview_movie/overview_screen.dart';
import '../widget/custom_bottom.dart';
import '../widget/trailer_widget.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key, required this.movie});

  final Movie? movie;

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250.h,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: [0.07.h, 0.3, 0.4],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: TrailerWidget(
                // url: "https://www.youtube.com/watch?v=_OKAwz2MsJs",
                trailerUrl: "",
                thumbnail: widget.movie?.getPosterUrl ?? "",
              ),
            ),
          ),
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.5, 0.8, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Container(
                color: Colors.black
              ),
            ),
          ),
          Positioned(
            top: 20.h,
            left: 0,
            right: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Assets.img.iconNetflix.image(width: 30, height: 30)
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Tv shows", style: Style.title2,),
                      Text("Movie", style: Style.title2,),
                      Text("My list", style: Style.title2,),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("#2 in Nigeria Today", style: TextStyle(fontSize: 18.sp),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                        icon: const Icon(FontAwesomeIcons.plus),
                        title: const Text("My list"),
                        onTap: (){

                        }
                    ),
                    CustomButton(
                      backgroundColor: Colors.white,
                      margin: EdgeInsets.zero,
                      height: 30,
                      wrapWidth: true,
                      borderRadius: 5,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.play, color: Colors.black,),
                          SizedBox(width: 5,),
                          Text("Play", style: TextStyle(color: Colors.black,),)
                        ],
                      ),
                      onPressed: (){
                        if(widget.movie != null){
                          context.showBottomSheet(OverViewScreen(movie: widget.movie!.toMovieInfo(),));
                        }else{
                          context.showSnackBar("Không tìm thấy phim");
                        }
                      },
                    ),
                    ActionButton(
                        icon: const Icon(Icons.error_outline),
                        title: const Text("Info"),
                        onTap: (){

                        }
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
