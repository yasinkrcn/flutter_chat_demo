import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/core/constants/color_constants.dart';
import 'package:flutter_chat_demo/core/utils/screen_size.dart';

class AppTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  double? height;

  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function()? onTap;
  final void Function(String)? onChanged;

  AppTextFormField._({
    Key? key,
    required this.hintText,
    this.controller,
    this.height,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
  }) : super(key: key);

  factory AppTextFormField.standart({
    required String hintText,
    TextEditingController? controller,
    prefixIcon,
    void Function(String)? onChanged,
  }) {
    return AppTextFormField._(
      controller: controller,
      hintText: hintText,
      prefixIcon: prefixIcon,
      onChanged: onChanged,
    );
  }

  factory AppTextFormField.obscure({
    required String hintText,
    Widget? suffixIcon,
    TextEditingController? controller,
    Widget? prefixIcon,
    void Function()? onTap,
  }) {
    return AppTextFormField._(
      controller: controller,
      hintText: hintText,
      prefixIcon: const Icon(
        Icons.lock,
        color: ColorHelper.secondaryColor,
      ),
      suffixIcon: const Icon(
        Icons.visibility,
        color: ColorHelper.secondaryColor,
      ),
      onTap: onTap,
    );
  }

  factory AppTextFormField.chat({
    required String hintText,
    Widget? suffixIcon,
    TextEditingController? controller,
    Widget? prefixIcon,
    void Function()? onTap,
    double? height,
  }) {
    return AppTextFormField._(
      controller: controller,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      height: 40,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenSize().getWidthPercent(.8),
      height: height,
      child: TextFormField(
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.bottom,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: ColorHelper.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
      ),
    );
  }
}
