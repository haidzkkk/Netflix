
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';

import '../../../../gen/assets.gen.dart';
import '../../blocs/home/home_bloc.dart';
import '../../blocs/home/home_state.dart';
import '../widget/trailer_widget.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450,
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
                  stops: const [0.1, 0.3, 0.4],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return TrailerWidget(
                    // url: "https://www.youtube.com/watch?v=_OKAwz2MsJs",
                    url: "",
                    thumbnail: state.movies[CategoryMovie.movieNew]?.firstOrNull?.getPosterUrl ?? "",
                  );
                },
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
            top: 40,
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
                const Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Tv shows", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      Text("Movie", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      Text("My list", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
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
                    iconAction(
                        icon: FontAwesomeIcons.plus,
                        title: "My list",
                        onTap: (){
                        }
                    ),
                    ElevatedButton(
                      onPressed: () {

                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.white.withOpacity(0.8)),
                        shape: WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.all(Radius.circular(10))))
                      ),
                      child: const Row(
                        children: [
                          Icon(FontAwesomeIcons.play, color: Colors.black,),
                          SizedBox(width: 5,),
                          Text("Play", style: TextStyle(color: Colors.black,),)
                        ],
                      ),
                    ),
                    iconAction(
                      icon: Icons.error_outline,
                      title: "Info",
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

  Widget iconAction({required String title, required IconData icon, required Function onTap}){
    return GestureDetector(
      onTap: onTap(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 30.w,),
          Text(title,),
        ],
      ),
    );
  }
}
