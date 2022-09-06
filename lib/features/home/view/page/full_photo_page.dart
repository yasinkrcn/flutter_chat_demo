import '../../../../core/_core_exports.dart';

class FullPhotoPage extends StatelessWidget {
  final String? url;

  const FullPhotoPage({Key? key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Stack(
        children: [
          PhotoView(
            imageProvider: NetworkImage(url!),
          ),
          Positioned(
            top: 15,
            left: 15,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.black.withOpacity(.3),
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: ColorHelper.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
