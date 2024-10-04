
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key, required this.child, required this.overlay});

  final Widget child;
  final Container overlay;

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {

  final GlobalKey _key = GlobalKey();
  OverlayEntry? entry;
  int sessionId = 0;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (visibilityInfo) {
        bool isVisible = visibilityInfo.visibleFraction == 1;
        if(!isVisible){
          _disposeOverLay();
        }
      },
      child: TapRegion(
        onTapOutside: (tap) {
          _disposeOverLay();
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            _showOverlay(context);
          },
            child: Padding(
              padding: const EdgeInsetsDirectional.all(6),
                child: widget.child
            )
        ),
      ),
    );
  }

  void _disposeOverLay(){
    entry?.remove();
    entry = null;
  }

  void _showOverlay(context) async {
    if(entry != null){
      _disposeOverLay();
      return;
    }

    sessionId++;
    var overlaySessionId = sessionId;

    final box = _key.currentContext?.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);

    Offset positionOverLay = calculatePosition(offset);

    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: positionOverLay.dx,
        top: positionOverLay.dy,
        child: Material(
          child: widget.overlay,
        ),
      ),
    );
    Overlay.of(context).insert(entry!);
    await Future.delayed(const Duration(milliseconds: 5000), (){
      if(overlaySessionId == sessionId){
        _disposeOverLay();
      }
    });
  }

  Offset calculatePosition(Offset offset) {
    double widthOverlay = widget.overlay.constraints?.minWidth ?? 0;
    double heightOverlay = widget.overlay.constraints?.minHeight ?? 0;
    double heightScreen = MediaQuery.of(context).size.height;
    double widthScreen = MediaQuery.of(context).size.width;

    bool heightIsTopScreen = offset.dy < heightScreen / 2;
    bool? widthIsLeftScreen = offset.dx < widthScreen / 3 ? true
        : offset.dx > widthScreen / 3 * 2 ? false
        : null; /// null is center

    double dy = offset.dy + (heightIsTopScreen ? 50 : -heightOverlay);
    double dx = offset.dx + (widthIsLeftScreen == true ? 0
        : widthIsLeftScreen == false ? (widthOverlay * -1)
        : (-1 * widthOverlay / 2) + 25 );

    return Offset(dx, dy);
  }
}
