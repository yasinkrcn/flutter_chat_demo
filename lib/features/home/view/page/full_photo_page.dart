import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../../../core/constants/color_constants.dart';

class FullPhotoPage extends StatelessWidget {
  final String? url;

  const FullPhotoPage({Key? key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: ColorHelper.white,
          title: const Text(
            'Photo',
            style: TextStyle(color: ColorHelper.secondaryColor),
          ),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios,
              color: ColorHelper.secondaryColor,
            ),
          )),
      body: PhotoView(
        imageProvider: NetworkImage(url!),
      ),
    );
  }
}
