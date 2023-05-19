import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/auth_impl.dart';
import 'package:APaints_QGen/src/presentation/views/login/external/login_form_external.dart';
import 'package:APaints_QGen/src/routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExternalUserLoginScreen extends StatefulWidget {
  static const routeName = Routes.ExternalLoginScreen;
  final String? language;
  const ExternalUserLoginScreen({Key? key, this.language}) : super(key: key);

  @override
  State<ExternalUserLoginScreen> createState() =>
      _ExternalUserLoginScreenState();
}

class _ExternalUserLoginScreenState extends State<ExternalUserLoginScreen> {
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
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(
          builder: (layoutBuilderContext, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/images/login_bg.svg',
                        // fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 2,
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
                        fontSize: 20.0,
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
                        child: ExternalUserLoginForm(language: 'English'),
                      ),
                      Spacer(),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      desktop: Scaffold(
        backgroundColor: AsianPaintColors.appBackgroundColor,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: LayoutBuilder(
            builder: (layoutBuilderContext, constraints) {
              return Row(
                children: [
                  Container(
                    height: double.infinity,
                    child: Image.asset(
                      './assets/images/webviewlandingimage.png',
                      fit: BoxFit.fill,
                    ),
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
                          AppLocalizations.of(context).external_users_login_web,
                          style: TextStyle(
                            fontSize: 27.0,
                            fontFamily: AsianPaintsFonts.bathSansRegular,
                            color: AsianPaintColors.textFieldLabelColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 184),
                        child: Text(
                          'Please enter your mobile number to request OTP',
                          style: TextStyle(
                            fontFamily: AsianPaintsFonts.mulishRegular,
                            color: AsianPaintColors.projectUserNameColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 184),
                        height: 280,
                        width: 570,
                        child: Row(
                          children: const [
                            Spacer(),
                            Expanded(
                              flex: 8,
                              child: ExternalUserLoginForm(language: 'English'),
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
      ),
      tablet: const Scaffold(),
    );
  }
}
