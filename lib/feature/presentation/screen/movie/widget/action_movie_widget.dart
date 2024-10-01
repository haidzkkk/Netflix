import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/presentation/blocs/download/download_cubit.dart';
import 'package:spotify/feature/presentation/blocs/home/home_bloc.dart';
import 'package:spotify/feature/presentation/blocs/home/home_event.dart';
import 'package:spotify/feature/presentation/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/screen/home_screen/widget/action_button.dart';

class ActionMovieWidget extends StatefulWidget {
  const ActionMovieWidget({super.key});


  @override
  State<ActionMovieWidget> createState() => _ActionMovieWidgetState();
}

class _ActionMovieWidgetState extends State<ActionMovieWidget> {
  late MovieBloc viewModel = context.read<MovieBloc>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ActionButton(
            title: Text("My List", style: TextStyle(fontSize: 16.sp),),
            icon: Icon(FontAwesomeIcons.plus, size: 27.sp,),
            onTap: (){

            },
          ),
        ),
        Expanded(
          child: ActionButton(
            title: Text("Download", style: TextStyle(fontSize: 16.sp),),
            icon: Icon(FontAwesomeIcons.download, size: 27.sp,),
            onTap: () async{
              handleDownloadEpisode(context);
            },
          ),
        ),
        Expanded(
          child: ActionButton(
            title: Text("Share", style: TextStyle(fontSize: 16.sp),),
            icon: Icon(FontAwesomeIcons.paperPlane, size: 27.sp,),
            onTap: (){
            },
          ),
        ),
      ],
    );
  }

  void handleDownloadEpisode(BuildContext context){
    context.read<DownloadCubit>().startDownloadEpisode(
        movie: viewModel.state.currentMovie!,
        episode: viewModel.state.currentEpisode!
    ).then((value){
      if(!value.key){
        context.showSnackBar(value.value);
        return;
      }

      context.showSnackBarWidget(
          child: Row(
            children: [
              Expanded(child: Text("Đang tải tập phim", style: Style.body.copyWith(color: Colors.white),)),
              const SizedBox(width: 10,),
              GestureDetector(
                onTap: (){
                  viewModel.add(ChangeExpandedMovieEvent(isExpand: false));
                  context.read<HomeBloc>().add(ChangePageIndexHomeEvent(3));
                },
                child: Text("Xem",
                    style: Style.title2.copyWith(color: Colors.white)
                ),
              ),
            ],
          ),
          seconds: 3,
      );
    });
  }
}
