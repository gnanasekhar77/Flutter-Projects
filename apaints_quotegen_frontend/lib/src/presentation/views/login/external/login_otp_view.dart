import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/auth_impl.dart';
import 'package:APaints_QGen/src/presentation/views/login/external/login_otp_form.dart';
import 'package:APaints_QGen/src/routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExternalUserOTPScreen extends StatefulWidget {
  static const routeName = Routes.OTPVerificationScreen;
  final String? language;
  final String? mobileNumber;
  const ExternalUserOTPScreen({Key? key, this.language, this.mobileNumber})
      : super(key: key);

  @override
  State<ExternalUserOTPScreen> createState() => _ExternalUserOTPScreenState();
}

class _ExternalUserOTPScreenState extends State<ExternalUserOTPScreen> {
  AuthImpl? loginProvide;
  final _secureStorageProvider = null;

  @override
  void initState() {
    // getLanguage();
    // loginProvide = Provider.of<AuthImpl>(context, listen: false);
    // selectedLanguage = widget.language.toString();
    // //selectedLanguage = Locale(loginProvide?.languageSelected ?? "en");
    // Future.delayed(const Duration(seconds: 0), () {
    //   context.read<LocaleProvider>().setLocale(selectedLanguage);
    // });
    super.initState();
  }

  Future<String?> getLanguage() async {
    String? lang = await _secureStorageProvider.read(key: 'languageSelected');
    logger("login_screen selected language $lang");
    return lang;
  }

  @override
  Widget build(BuildContext context) {
    final String? language;
    return Responsive(
      mobile: Scaffold(
        backgroundColor: AsianPaintColors.whiteColor,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (layoutBuilderContext, constraints) {
            return Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/images/login_bg.svg',
                      fit: BoxFit.fitWidth,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2.2,
                    ),
                    Positioned(
                        bottom: 320,
                        right:
                            330, //give the values according to your requirement
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop(context);
                          },
                          child: SizedBox(
                            height: 30,
                            width: 50,
                            child: SvgPicture.asset(
                              './assets/images/back2.svg',
                            ),
                          ), //const Icon(Icons.backspace),
                        )),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 25.0, 8.0, 15.0),
                  child: Text(
                    AppLocalizations.of(context).external_users_login,
                    style: TextStyle(
                      fontSize: 23.0,
                      fontFamily: AsianPaintsFonts.bathSansRegular,
                      color: AsianPaintColors.chooseYourAccountColor,
                    ),
                  ),
                ),
                Row(
                  children: const [
                    Spacer(),
                    Expanded(
                      flex: 8,
                      child: LoginOTPForm(language: 'English'),
                    ),
                    Spacer(),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      desktop: Scaffold(
        backgroundColor: AsianPaintColors.appBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (layoutBuilderContext, constraints) {
            return Row(
              children: [
                Container(
                  height: double.infinity,
                  child: Image.asset('./assets/images/webviewlandingimage.png'),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 180, left: 190),
                      child: SvgPicture.asset(
                                  'assets/images/bathsans_logo.svg',
                                  height: 30,
                                )
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 180),
                      child: Text(
                        AppLocalizations.of(context).external_users_login,
                        style: TextStyle(
                          fontSize: 27.0,
                          fontFamily: AsianPaintsFonts.bathSansRegular,
                          color: AsianPaintColors.textFieldLabelColor,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 180),
                      child: Text(
                        'Please enter OTP sent to your mobile number',
                        style: TextStyle(
                          fontFamily: AsianPaintsFonts.mulishRegular,
                          color: AsianPaintColors.projectUserNameColor,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    //const SizedBox(height:20),
                    Container(
                      padding: const EdgeInsets.only(left: 180),
                      height: 300,
                      width: 560,
                      child: Row(
                        children: const [
                          Spacer(),
                          Expanded(
                            flex: 8,
                            child: LoginOTPForm(language: 'English'),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      tablet: const Scaffold(),
    );
  }
}
