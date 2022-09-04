import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/core/utils/screen_size.dart';

class AppContainer extends StatelessWidget {
  final Widget child;
  final bool topPadding;
  final bool bottomPadding;
  const AppContainer({
    Key? key,
    required this.child,
    this.topPadding = false,
    this.bottomPadding = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(
          top: topPadding ? ScreenSize().topMargin : 0,
          bottom: bottomPadding ? ScreenSize().bottomMargin : 0,
        ),
        child: child,
      ),
    );
  }
}
