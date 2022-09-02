import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          color: ColorHelper.themeColor,
        ),
      ),
      color: Colors.white.withOpacity(0.8),
    );
  }
}
