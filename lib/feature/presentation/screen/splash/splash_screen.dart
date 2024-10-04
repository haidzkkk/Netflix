
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/presentation/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/blocs/search/search_bloc.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_cubit.dart';
import 'package:spotify/feature/presentation/screen/main/main_screen.dart';
import 'package:spotify/gen/assets.gen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{

  @override
  void initState() {
    context.read<MovieBloc>().initSettingCubit();
    context.read<SearchBloc>().initSettingCubit();
    context.read<SettingCubit>().syncSetting().then((value){
      Future.delayed(const Duration(milliseconds: 1500), (){
        context.replace(const MainScreen());
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Assets.img.iconNetflix.image(width: 200.sp, height: 200.sp)
            );
          },
        ),
      ),
    );
  }
}
