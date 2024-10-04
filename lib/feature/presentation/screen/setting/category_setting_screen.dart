
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/commons/utility/color_resource.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/data/models/category_movie.dart';
import 'package:spotify/feature/data/repositories/setting_repo.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_cubit.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_state.dart';
import 'package:spotify/feature/presentation/screen/setting/widget/icon_setting.dart';

class CategorySettingScreen extends StatefulWidget {
  const CategorySettingScreen({super.key});

  @override
  State<CategorySettingScreen> createState() => _CategorySettingScreenState();
}

class _CategorySettingScreenState extends State<CategorySettingScreen> {

  late var settingViewModel = context.read<SettingCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thể loại yêu thích", style: Style.title,),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          child: BlocBuilder<SettingCubit, SettingState>(
            buildWhen: (previous, current) => previous.favouriteCategories != current.favouriteCategories,
            builder: (context, state) {
              List<CategoryMovie> categories = state.favouriteCategories;
              return ReorderableListView(
                onReorder: (int oldIndex, int newIndex) {
                  if(oldIndex < newIndex){
                    newIndex -= 1;
                  }
                  var item = categories.removeAt(oldIndex);
                  categories.insert(newIndex, item);
                  settingViewModel.changeListCategory(categories);
                },
                children: categories.asMap().entries.map((category){
                  return Container(
                    key: ObjectKey(category.value.slug),
                    margin: const EdgeInsetsDirectional.all(8),
                    decoration: const BoxDecoration(
                        color: ColorResources.secondaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        )
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20,),
                        Text("${category.key + 1}", style: Style.title2),
                        const SizedBox(width: 20,),
                        Image.asset(category.value.getPathImage, width: 100, height: 100, fit: BoxFit.cover,),
                        const SizedBox(width: 20,),
                        Text(category.value.name, style: Style.title2,),
                        const Spacer(),
                        const Icon(FontAwesomeIcons.upDown),
                        const SizedBox(width: 20,),
                      ],
                    ),
                  );
                }).toList(),
              );
            }
          ),
        ),
      ),
    );
  }
}
