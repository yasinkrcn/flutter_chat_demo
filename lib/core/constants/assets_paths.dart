class AssetsPath {
  static final AssetsPath _instance = AssetsPath._init();
  AssetsPath._init();

  factory AssetsPath() {
    return _instance;
  }

  // !SVG
  final String appIconSVG = 'assets/svg/message_icon.svg';

  // !PNG
  final String imageNotAvailable = 'assets/png/img_not_available.jpeg';
}
