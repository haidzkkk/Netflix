
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../../data/models/response/movie.dart';

class SlideWidget extends StatefulWidget {
  const SlideWidget({super.key, required this.movies});
  final List<Movie> movies;

  @override
  State<SlideWidget> createState() => _SlideWidgetState();
}

class _SlideWidgetState extends State<SlideWidget> {

  late PageController pageController;

  int _currentPage = 0;
  late Timer _timer;

  @override
  void initState() {
    pageController = PageController(initialPage: _currentPage, viewportFraction: 0.8);
    _timer = Timer.periodic(const Duration(seconds: 20), (Timer timer) {
      if (_currentPage < widget.movies.length) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: (value){
          _currentPage = value;
        },
        clipBehavior: Clip.none,
        itemCount: widget.movies.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
              animation: pageController,
              builder: (context, child){
                double pageOffset = 0;
                if(pageController.position.haveDimensions){
                  pageOffset = pageController.page! - index;
                }

                return Container(
                  clipBehavior: Clip.hardEdge,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(5), top: Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(8, 20),
                            blurRadius: 24
                        )
                      ]
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          widget.movies[index].getPosterUrl,
                          width: double.infinity,
                          alignment: Alignment(-pageOffset.abs(), 0 ),
                          fit: BoxFit.fitWidth,
                          errorBuilder: (context, object, stackTrace){
                            return const Center(child: CircularProgressIndicator(),);
                          },
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 40,
                            color: Colors.black.withOpacity(0.8),
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(widget.movies[index].name ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14,),)
                                ),
                                const SizedBox(width: 5,),
                                const Text("Xem ngay", style: TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),)
                              ],
                            ),
                          )
                      )
                    ],
                  ),
                );
              }
          );
        },
      ),
    );
  }

}
