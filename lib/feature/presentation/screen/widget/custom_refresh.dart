
import "package:flutter/cupertino.dart";
import "package:pull_to_refresh/pull_to_refresh.dart";

class CustomRefresh extends StatefulWidget {
  const CustomRefresh({
    super.key,
    this.keyState,
    required this.child,
    required this.controller,
    this.onLoad,
    required this.onRefresh, this.scrollController,
  });

  final PageStorageKey? keyState;
  final Widget child;
  final RefreshController controller;
  final ScrollController? scrollController;
  final Function()? onLoad;
  final RefreshCallback onRefresh;

  @override
  State<CustomRefresh> createState() => _CustomRefreshState();
}

class _CustomRefreshState extends State<CustomRefresh> {
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: SmartRefresher(
        enablePullUp: widget.onLoad != null,
        enablePullDown: true,
        scrollController: widget.scrollController,
        header: CustomHeader(
          builder: (context, mode){
            return Center(
                child: Container(
                    height: 25,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: const CupertinoActivityIndicator()
                )
            );
          },
        ),
        footer: CustomFooter(
          builder: (context, mode){
            Widget body;
            if(mode == LoadStatus.idle){
              return const SizedBox();
            }
            else if(mode == LoadStatus.loading){
              body = const CupertinoActivityIndicator();
            }
            else if(mode == LoadStatus.noMore){
              body = const Text("Không có phim nào",);
            }
            else {
              body = const SizedBox();
            }
            return Center(
                child: Container(
                    height: 25,
                    margin: const EdgeInsets.only(top: 20),
                    child: body
                )
            );
          },
        ),
        controller: widget.controller,
        onRefresh: ()async{
          await widget.onRefresh();
          widget.controller.refreshCompleted();
          widget.controller.loadComplete();
        },
        onLoading: widget.onLoad,
        child: widget.child,
      ),
    );
  }

}
