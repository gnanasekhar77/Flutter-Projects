import 'dart:io';

import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/auth_impl.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/authentication/authentication_bloc.dart';
import 'package:APaints_QGen/src/presentation/views/home/home_screen.dart';
import 'package:APaints_QGen/src/presentation/views/login/internal/login_form.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/elevated_button.dart';
import 'package:APaints_QGen/src/presentation/widgets/sidemenunav.dart';
import 'package:APaints_QGen/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = Routes.InternalLoginScreen;
  final String? language;

  const LoginScreen({Key? key, this.language}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthImpl? loginProvide;
  final _secureStorageProvider = null;
  bool _obscureText = true;
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

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
    //bool _obscureText = true;

    final bloc = context.read<AuthenticationBloc>();
    var formKey = GlobalKey<FormState>();

    // final userNameController = TextEditingController();
    // final passwordController = TextEditingController();
    final _formLoginKey = GlobalKey<FormState>();
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Responsive(
        mobile: Scaffold(
          backgroundColor: AsianPaintColors.whiteColor,
          resizeToAvoidBottomInset: true,
          body: LayoutBuilder(
            builder: (layoutBuilderContext, constraints) {
              return SingleChildScrollView(
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
                        // const Icon(Icons.abc),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 25.0, 8.0, 15.0),
                      child: Text(
                        AppLocalizations.of(context).internal_users_login,
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
                          child: LoginForm(language: 'English'),
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
        desktop: BlocConsumer<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AsianPaintColors.appBackgroundColor,
              resizeToAvoidBottomInset: false,
              body: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: LayoutBuilder(
                  builder: (layoutBuilderContext, constraints) {
                    return Row(
                      children: [
                        SizedBox(
                          height: double.infinity,
                          child: Image.asset(
                              './assets/images/webviewlandingimage.png'),
                        ),
                        Column(
                          children: [
                            Container(
                                padding:
                                    const EdgeInsets.only(top: 180, left: 190),
                                child: SvgPicture.asset(
                                  'assets/images/bathsans_logo.svg',
                                  height: 30,
                                )),
                            const SizedBox(
                              height: 25,
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 180),
                              child: Text(
                                AppLocalizations.of(context)
                                    .internal_users_login_web,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontFamily: AsianPaintsFonts.bathSansRegular,
                                  color: AsianPaintColors.textFieldLabelColor,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 180),
                              height: 70,
                              width: 500,
                              child: TextFormField(
                                enableInteractiveSelection: false,
                                controller: userNameController,
                                cursorColor:
                                    AsianPaintColors.textFieldLabelColor,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AsianPaintColors
                                                .textFieldUnderLineColor)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                      color: AsianPaintColors
                                          .textFieldUnderLineColor,
                                    )),
                                    filled: true,
                                    focusColor: AsianPaintColors
                                        .textFieldUnderLineColor,
                                    fillColor: AsianPaintColors.whiteColor,
                                    border: const UnderlineInputBorder(),
                                    labelText:
                                        AppLocalizations.of(context).user_id,
                                    labelStyle: TextStyle(
                                      fontFamily: AsianPaintsFonts.mulishMedium,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                      color: AsianPaintColors.quantityColor,
                                    )),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 180),
                              height: 70,
                              width: 500,
                              child: TextFormField(
                                enableInteractiveSelection: false,
                                obscureText: _obscureText,
                                controller: passwordController,
                                cursorColor:
                                    AsianPaintColors.textFieldLabelColor,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AsianPaintColors
                                              .textFieldUnderLineColor)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                    color: AsianPaintColors
                                        .textFieldUnderLineColor,
                                  )),
                                  filled: true,
                                  fillColor: AsianPaintColors.whiteColor,
                                  border: const UnderlineInputBorder(),
                                  labelText:
                                      AppLocalizations.of(context).password,
                                  focusColor:
                                      AsianPaintColors.textFieldUnderLineColor,
                                  labelStyle: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishMedium,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    color: AsianPaintColors.quantityColor,
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        //onTap: _togglePasswordVisibility,
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                    child: Icon(
                                      _obscureText
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 70,
                            ),
                            Container(
                              height: 40,
                              width: 510,
                              padding: const EdgeInsets.only(left: 180),
                              child: APElevatedButton(
                                onPressed: () async {
                                  // if (_formLoginKey.currentState.validate()) {
                                  bloc.login(
                                    userID: userNameController.text,
                                    password: passwordController.text,
                                    deviceToken: '',
                                  );
                                  // }
                                },
                                label: state is AuthenticationLoginLoading
                                    ? SizedBox(
                                        height: 15,
                                        width: 15,
                                        child: CircularProgressIndicator(
                                            color: AsianPaintColors
                                                .buttonTextColor),
                                      )
                                    : Text(
                                        AppLocalizations.of(context).login,
                                        style: TextStyle(
                                          fontFamily:
                                              AsianPaintsFonts.mulishBold,
                                          color: AsianPaintColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                // child: Text(
                                //   AppLocalizations.of(context).login,
                                //   style: TextStyle(
                                //     fontFamily: AsianPaintsFonts.mulishBold,
                                //     color: AsianPaintColors.buttonTextColor,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  },
                ),
              ),
            );
          },
          listener: (context, state) {
            if (state is AuthenticationAuthenticated) {
              // context.read<ConfigBloc>().fetchConfig();
              // Journey.loginType = 'Internal';
              // Navigator.pushAndRemoveUntil<void>(
              //   context,
              //   MaterialPageRoute<void>(
              //     builder: (BuildContext context) => const Sidemen(),
              //   ),
              //   (Route<dynamic> route) => false,
              // );
              bool kisWeb;
              try {
                if (Platform.isAndroid || Platform.isIOS) {
                  kisWeb = false;
                } else {
                  kisWeb = true;
                }
              } catch (e) {
                kisWeb = true;
              }

              if (userNameController.text.isNotEmpty) {
                if (!kisWeb) {
                  AuthenticationBloc authenticationBloc =
                      context.read<AuthenticationBloc>();
                  if ((authenticationBloc.userData?.userinfo?.isExist ?? '') ==
                      'no') {
                    logger('In No:::');
                    Journey.isExist = false;
                  } else {
                    logger('In Yes:::');
                    Journey.isExist = true;
                  }
                  Journey.skuResponseLists = [];
                  final secureStorageProvider =
                      getSingleton<SecureStorageProvider>();
                  secureStorageProvider
                      .saveQuoteToDisk(Journey.skuResponseLists);
                  secureStorageProvider.saveCartCount(0);
                  Navigator.pushAndRemoveUntil<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        Journey.loginType = 'Internal';

                        return const HomeScreen(loginType: 'Internal');
                      },
                    ),
                    (Route<dynamic> route) => false,
                  );
                } else {
                  AuthenticationBloc authenticationBloc =
                      context.read<AuthenticationBloc>();
                  if ((authenticationBloc.userData?.userinfo?.isExist ?? '') ==
                      'no') {
                    logger('In No:::');
                    Journey.isExist = false;
                  } else {
                    logger('In Yes:::');
                    Journey.isExist = true;
                  }
                  Journey.loginType = 'Internal';
                  Journey.email =
                      authenticationBloc.userData?.userinfo?.email ?? '';
                  Journey.username =
                      authenticationBloc.userData?.userinfo?.username ?? '';
                  Journey.loginType = 'Internal';
                  Journey.skuResponseLists = [];
                  final secureStorageProvider =
                      getSingleton<SecureStorageProvider>();
                  secureStorageProvider
                      .saveQuoteToDisk(Journey.skuResponseLists);
                  secureStorageProvider.saveCartCount(0);
                  Navigator.pushAndRemoveUntil<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const Sidemen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                }
              }
            }
          },
          buildWhen: (previous, current) {
            return true;
          },
        ),
        tablet: const Scaffold());
  }
}
