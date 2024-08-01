enum AuthType {
  login,
  register,
  forgot,
  otp,
  resetPassword,
}

enum AuthTagHero {
  faviconAuth,
  titleAuth,
  descriptionAuth,
  backButtonAuth,
  inputPhoneAuth,
  inputPasswordAuth,
  elevatedButtonAuth,
  forgotButtonAuth,
  dividerAuth,
  outlinedButtonContainerAuth,
  copyrightAuth,
}

class AuthSettingsModel {
  const AuthSettingsModel(
    this.title,
    this.description,
    this.elevatedButtonText,
    this.outlinedButtonDescription,
    this.outlinedButtonText,
  );

  final String title;
  final String description;
  final String elevatedButtonText;
  final String? outlinedButtonDescription;
  final String? outlinedButtonText;
}
