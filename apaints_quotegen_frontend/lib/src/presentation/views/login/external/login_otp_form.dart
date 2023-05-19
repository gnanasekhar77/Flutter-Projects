import 'dart:io';

import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/edge_insets.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/auth_provider.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/authentication/authentication_bloc.dart';
import 'package:APaints_QGen/src/presentation/views/home/home_screen.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/elevated_button.dart';
import 'package:APaints_QGen/src/presentation/widgets/otp_input.dart';
import 'package:APaints_QGen/src/presentation/widgets/sidemenunav.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginOTPForm extends StatefulWidget {
  final String? language;
  const LoginOTPForm({Key? key, this.language}) : super(key: key);

  @override
  State<LoginOTPForm> createState() => _LoginOTPFormState();
}

class _LoginOTPFormState extends State<LoginOTPForm> {
  AuthProvider? loginProvide;
  late FocusNode passwordFocusNode;
  final secureStorageProvider = getSingleton<SecureStorageProvider>();
  late String mobileNum;

  @override
  void initState() {
    super.initState();
    passwordFocusNode = FocusNode();
    // listen to focus changes
    if (kIsWeb) {
      passwordFocusNode.addListener(() =>
          logger('focusNode updated: hasFocus: ${passwordFocusNode.hasFocus}'));
    }
  }

  void setFocus() {
    FocusScope.of(context).requestFocus(passwordFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AuthenticationBloc>();
    var formKey = GlobalKey<FormState>();
    final secureStorageProvider = getSingleton<SecureStorageProvider>();

    // 4 text editing controllers that associate with the 4 input fields
    final TextEditingController fieldOne = TextEditingController();
    final TextEditingController fieldTwo = TextEditingController();
    final TextEditingController fieldThree = TextEditingController();
    final TextEditingController fieldFour = TextEditingController();
    final TextEditingController fieldFive = TextEditingController();
    final TextEditingController fieldSix = TextEditingController();

    // This is the entered code
    // It will be displayed in a Text widget
    String? otp;

    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        return Responsive(
          desktop: Form(
            key: formKey,
            child: Padding(
              padding: AsianPaintEdgeInsets.vertical_16,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Implement 4 input fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OtpInput(fieldOne, true), // auto focus
                      OtpInput(fieldTwo, false),
                      OtpInput(fieldThree, false),
                      OtpInput(fieldFour, false),
                      OtpInput(fieldFive, false),
                      OtpInput(fieldSix, false),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                AppLocalizations.of(context).didnt_receive_otp,
                                style: TextStyle(
                                  color: AsianPaintColors.projectUserNameColor,
                                  fontFamily: AsianPaintsFonts.mulishSemiBold,
                                  fontSize: 10,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              String mobileNum =
                                  await secureStorageProvider.getMobileNumber();
                              bloc.externalLogin(
                                mobileNumber: mobileNum,
                              );
                              FlutterToastProvider().show(
                                  message:
                                      'OTP has been resent successfullyy!!');
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                AppLocalizations.of(context).resend_otp,
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color:
                                      AsianPaintColors.forgotPasswordTextColor,
                                  fontFamily: AsianPaintsFonts.mulishSemiBold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  Center(
                    child: SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            otp = fieldOne.text +
                                fieldTwo.text +
                                fieldThree.text +
                                fieldFour.text +
                                fieldFive.text +
                                fieldSix.text;
                          });
                          var mobileNum =
                              await secureStorageProvider.getMobileNumber();
                          logger(mobileNum);
                          bloc.validateOTP(
                            otp: otp,
                            phone: mobileNum,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                          backgroundColor:
                              AsianPaintColors.resetPasswordLabelColor,
                          shadowColor: AsianPaintColors.resetPasswordLabelColor,
                          textStyle: TextStyle(
                            color: AsianPaintColors.buttonTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: AsianPaintsFonts.mulishRegular,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context).login,
                          style: TextStyle(
                            fontFamily: AsianPaintsFonts.mulishBold,
                            color: AsianPaintColors.whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  // Display the entered OTP code
                  // Text(
                  //   otp ?? 'Please enter OTP',
                  //   style: const TextStyle(fontSize: 30),
                  // )
                ],
              ),
            ),
          ),
          tablet: const Scaffold(),
          mobile: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: AsianPaintEdgeInsets.vertical_16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Implement 4 input fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OtpInput(fieldOne, true), // auto focus
                        OtpInput(fieldTwo, false),
                        OtpInput(fieldThree, false),
                        OtpInput(fieldFour, false),
                        OtpInput(fieldFive, false),
                        OtpInput(fieldSix, false),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .didnt_receive_otp,
                                  style: TextStyle(
                                    color: AsianPaintColors.didntReceiveOtp,
                                    fontFamily: AsianPaintsFonts.mulishSemiBold,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                FlutterToastProvider().show(
                                    message:
                                        'OTP has been resent successfullyy!!');
                                String mobileNum = await secureStorageProvider
                                    .getMobileNumber();
                                bloc.externalLogin(
                                  mobileNumber: mobileNum,
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  AppLocalizations.of(context).resend_otp,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: AsianPaintColors.buttonTextColor,
                                    fontFamily: AsianPaintsFonts.mulishSemiBold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Center(
                      child: SizedBox(
                        height: 50,
                        width: 350,
                        child: APElevatedButton(
                          onPressed: () async {
                            // setState(() {
                            otp = fieldOne.text +
                                fieldTwo.text +
                                fieldThree.text +
                                fieldFour.text +
                                fieldFive.text +
                                fieldSix.text;
                            // });

                            String mobileNum =
                                await secureStorageProvider.getMobileNumber();
                            logger(mobileNum);
                            bloc.validateOTP(
                              otp: otp,
                              phone: mobileNum,
                            );
                          },
                          label: state is AuthenticationLoading
                              ? Center(
                                  child: SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                      color: AsianPaintColors.buttonTextColor,
                                    ),
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context).login,
                                  style: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishBold,
                                    color: AsianPaintColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      listener: (context, state) {
        if (state is AuthenticationInitial) {
          const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is AuthenticationLoading) {
          const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is AuthenticationOTPValidated) {
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
            secureStorageProvider.saveQuoteToDisk(Journey.skuResponseLists);
            secureStorageProvider.saveCartCount(0);
            if (Journey.isExist ?? true) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('Important!'),
                  content: const Text(
                      'You have been given authorized access to the Bathsense Quotation App for the sole purpose of creating quotations for Bathsense products.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              Journey.loginType = 'External';
                              return const HomeScreen(loginType: 'External');
                            },
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text('Ok'),
                    ),
                  ],
                ),
              );
              // FlutterToastProvider().show(message: '');
            } else {
              Navigator.pushAndRemoveUntil<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    Journey.loginType = 'External';
                    return const HomeScreen(loginType: 'External');
                  },
                ),
                (Route<dynamic> route) => false,
              );
            }
          } else {
            AuthenticationBloc authenticationBloc =
                context.read<AuthenticationBloc>();
            // Journey.isExist = false;

            if ((authenticationBloc.userData?.userinfo?.isExist ?? '') ==
                'no') {
              logger('In No:::');
              Journey.isExist = false;
            } else {
              logger('In Yes:::');
              Journey.isExist = true;
            }

            Journey.loginType = 'External';
            Journey.skuResponseLists = [];
            secureStorageProvider.saveQuoteToDisk(Journey.skuResponseLists);
            secureStorageProvider.saveCartCount(0);

            if (Journey.isExist ?? true) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('Important!'),
                  content: const Text(
                      'You have been given authorized access to the Bathsense Quotation App for the sole purpose of creating quotations for Bathsense products.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => const Sidemen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text('Ok'),
                    ),
                  ],
                ),
              );
              // FlutterToastProvider().show(message: '');
            } else {
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
    );
  }
}
