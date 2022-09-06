import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // ignore: sort_child_properties_last
      child: const Center(
        child: CircularProgressIndicator(
          color: ColorHelper.themeColor,
        ),
      ),
      color: Colors.white.withOpacity(0.8),
    );
  }
}
