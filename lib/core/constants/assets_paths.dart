class AssetsPath {
  static final AssetsPath _instance = AssetsPath._init();
  AssetsPath._init();

  factory AssetsPath() {
    return _instance;
  }

  // !SVG
  final String emptyMessageBoxSVG = 'assets/svg/images/empty_message_box.svg';
  final String errrorScreenSVG = 'assets/svg/images/error_screen.svg';
  final String successSVG = 'assets/svg/images/success.svg';
  final String failureSVG = 'assets/svg/images/failure.svg';
  final String forgotPasswordSVG = 'assets/svg/images/forgot_password.svg';
  final String loginScreenSVG = 'assets/svg/images/login_screen.svg';
  final String notFoundSearchSVG = 'assets/svg/images/not_found_search.svg';
  final String pageBackgroundHorizontalSVG = 'assets/svg/images/page_background_horizontal.svg';
  final String pageBackgroundVerticalSVG = 'assets/svg/images/page_background_vertical.svg';
  final String successSignUpSVG = 'assets/svg/images/success_sign_up.svg';
  final String logoSVG = 'assets/svg/images/logo.svg';
  final String googleSVG = 'assets/svg/google.svg';

  //! BOTTOM_NAV_BAR_SVG
  final String home = 'assets/svg/bottom_nav_bar/home.svg';
  final String message = 'assets/svg/bottom_nav_bar/message.svg';
  final String search = 'assets/svg/bottom_nav_bar/search.svg';
  final String profile = 'assets/svg/bottom_nav_bar/profile.svg';

  final String alertSnackBarSVG = 'assets/svg/snack_bar/alert_snack_bar.svg';
  final String successSnackBarSVG = 'assets/svg/snack_bar/success_snack_bar.svg';

  //! TEXT_FIELD_ICON_SVG
  final String emailTextField = 'assets/svg/text_field/email_text_field.svg';
  final String passwordTextField = 'assets/svg/text_field/password_text_field.svg';
}
