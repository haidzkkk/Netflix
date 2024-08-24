
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({
    super.key,
    this.height,
    this.title,
    this.focusNode,
    this.controller,
    this.onChange,
    this.onTap,
    this.onlyRead,
    this.prefixIcon,
    this.suffixIcon,
  });

  final double? height;
  final String? title;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Function(String value)? onChange;
  final Function()? onTap;
  final bool? onlyRead;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late TextEditingController textCtrl = widget.controller ?? TextEditingController();
  late FocusNode focusNode = widget.focusNode ?? FocusNode();

  @override
  void dispose() {
    if(widget.controller == null){
      textCtrl.dispose();
    }
    if(widget.focusNode == null){
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      alignment: Alignment.centerLeft,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
      child: TextFormField(
        onTap: (){
          if(widget.onTap != null) widget.onTap!();
        },
        focusNode: focusNode,
        controller: textCtrl,
        onEditingComplete: (){
          if(widget.onChange != null) widget.onChange!(textCtrl.text);
          focusNode.unfocus();
        },
        textInputAction: TextInputAction.search,
        cursorColor: Colors.white.withOpacity(0.5),
        cursorHeight: widget.height != null ?  (widget.height! / 2.1) : null,
        style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white
        ),
        readOnly: widget.onlyRead == true,
        decoration: InputDecoration(
            fillColor: Colors.black.withOpacity(0.7),
            filled: true,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            contentPadding: const EdgeInsets.only(left: 28, top: 0, bottom: 0),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(width: 0, color: Colors.transparent,),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(width: 0, color: Colors.transparent,),
            ),
            hintText: widget.title ?? "Tìm kiếm...",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7))),
      ),
    );
  }
}
