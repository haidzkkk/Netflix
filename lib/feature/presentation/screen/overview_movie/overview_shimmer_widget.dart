import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/widget/shimmer_widget.dart';

class OverviewShimmerWidget extends StatelessWidget {
  const OverviewShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100.h,
            width: double.infinity,
            child: Stack(
              alignment: AlignmentDirectional.topEnd,
              children: [
                ShimmerWidget(height: 100.h, width: double.infinity),
                Positioned(
                  top: MediaQuery.of(context).viewPadding.top + 8.h,
                  child: IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: Icon(FontAwesomeIcons.solidCircleXmark, color: Colors.white.withOpacity(0.7), size: 25.sp,)
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(height: 14.h, width: 200.w),
                const SizedBox(height: 5,),
                ShimmerWidget(height: 7.h, width: 250.w),
                const SizedBox(height: 10,),
                ShimmerWidget(height: 20.h, width: double.infinity),
                const SizedBox(height: 5,),
                ShimmerWidget(height: 20.h, width: double.infinity),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: ShimmerWidget(
                            height: 20.h,
                            width: 20.h
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ShimmerWidget(
                            height: 20.h,
                            width: 20.h
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ShimmerWidget(
                            height: 20.h,
                            width: 20.h
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                ShimmerWidget(height: 7.h, width: 100.w),
                const SizedBox(height: 5,),
                ShimmerWidget(height: 7.h, width: double.infinity),
                const SizedBox(height: 5,),
                ShimmerWidget(height: 7.h, width: 200.w),
                const SizedBox(height: 5,),
                ShimmerWidget(height: 100.h, width: double.infinity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
