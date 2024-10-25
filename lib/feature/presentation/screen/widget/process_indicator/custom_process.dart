
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/color_resource.dart';
import 'package:spotify/feature/presentation/screen/widget/process_indicator/progress_bar_view.dart';

class CustomProcessIndicator extends StatefulWidget {
  const CustomProcessIndicator({
    super.key,
    required this.height,
    required this.indicatorSize,
    required this.width,
    required this.process,
    this.color,
    required this.enable,
    this.onMoved,
    this.margin,
  });

  final double height;
  final double width;
  final double indicatorSize;
  final double process;
  final Color? color;
  final bool enable;
  final EdgeInsetsGeometry? margin;

  final ValueChanged? onMoved;

  @override
  State<CustomProcessIndicator> createState() => _CustomProcessIndicatorState();
}

class _CustomProcessIndicatorState extends State<CustomProcessIndicator> {

  late double process = widget.process;
  double widthChild = 0;
  bool isDragging = false;

  @override
  void didUpdateWidget(covariant CustomProcessIndicator oldWidget) {
    process = widget.process;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((value){
      widthChild = context.size?.width ?? 0;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanDown: _handleDragDown,
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: LinearProgressIndicator(
                minHeight: widget.height,
                color: widget.color,
                backgroundColor: ColorResources.primaryColorRevert2,
                value: process,
              ),
            ),
            Positioned(
              left: widthChild * process,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: widget.enable ? CustomPaint(
                  painter: ProgressBarView(
                    primaryColor: widget.color ?? ColorResources.secondaryColor,
                    indicatorSize: widget.indicatorSize * (isDragging ? 1.5 : 1),
                  ),
                ) : const SizedBox(),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _handleDragDown(DragDownDetails details) {
    isDragging = true;
    final progress = details.localPosition.dx / widthChild;
    if (progress >= 0 && progress <= 1) {
      widget.onMoved!(progress);
      process = progress;
      setState(() {});
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final progress = details.localPosition.dx / widthChild;
    if (progress >= 0 && progress <= 1) {
      widget.onMoved!(progress);
      process = progress;
      setState(() {});
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    isDragging = false;
    final progress = details.localPosition.dx / widthChild;
    if (progress >= 0 && progress <= 1) {
      widget.onMoved!(progress);
      process = progress;
      setState(() {});
    }
  }
}
