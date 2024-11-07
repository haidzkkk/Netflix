
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/widget/chip_text.dart';

class InfoMovieWidget extends StatefulWidget {
  const InfoMovieWidget({super.key});

  @override
  State<InfoMovieWidget> createState() => _InfoMovieWidgetState();
}

class _InfoMovieWidgetState extends State<InfoMovieWidget> {
  late MovieBloc viewModel = context.read<MovieBloc>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<MovieBloc, MovieState>(
            buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
            builder: (context, state){
              return Text(state.currentMovie?.name ?? "",
                style: Style.title.copyWith(fontSize: 20.sp),
              );
            }
        ),
        const SizedBox(height: 10,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocBuilder<MovieBloc, MovieState>(
                  buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
                  builder: (context, state){
                    return Wrap(
                        children: [
                          if(state.currentMovie?.time != null)
                            Text(state.currentMovie?.time ?? "", style: Style.body,),
                          if(state.currentMovie?.time != null)
                            ...[
                              const SizedBox(width: 5,),
                              ChipText(
                                  child: Text(
                                      "${state.currentMovie?.episodeCurrent}",
                                      style: Style.body.copyWith(fontSize: 10.sp)
                                  )
                              ),
                            ],
                          if(state.currentMovie?.time != null)
                            ...[
                              const SizedBox(width: 5,),
                              ChipText(
                                  child: Text("${state.currentMovie?.quality}",
                                      style: Style.body.copyWith(fontSize: 10.sp)
                                  )
                              ),
                            ],
                          if(state.currentMovie?.year != null)
                            ...[
                              const SizedBox(width: 10,),
                              Text("${state.currentMovie?.year}",
                                style: Style.body,
                              ),
                            ],
                          if(state.currentMovie?.lang != null)
                            ...[
                              const SizedBox(width: 5,),
                              ChipText(
                                  child: Text(
                                      "${state.currentMovie?.lang}",
                                      style: Style.body.copyWith(fontSize: 10.sp)
                                  )
                              ),
                            ],
                        ]
                    );
                  }
              ),
            ),
            const SizedBox(width: 20,),
            BlocBuilder<MovieBloc, MovieState>(
                buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
                builder: (context, state){
                  return Text("${state.currentMovie?.view?.format() ?? 0} views",
                    style: Style.body.copyWith(color: Colors.green),
                  );
                }
            ),
          ],
        ),
        const SizedBox(height: 10,),
      ],
    );
  }
}
