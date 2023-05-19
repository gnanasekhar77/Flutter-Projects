import 'dart:async';
import 'dart:io';

import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/edge_insets.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/core/utils/sized_boxes.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/auth_provider.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/authentication/authentication_bloc.dart';
import 'package:APaints_QGen/src/presentation/views/home/home_screen.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/elevated_button.dart';
import 'package:APaints_QGen/src/presentation/widgets/sidemenunav.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginForm extends StatefulWidget {
  final String? language;
  const LoginForm({Key? key, this.language}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  AuthProvider? loginProvide;
  late FocusNode passwordFocusNode;
  bool _passwordVisible = false;

  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    passwordFocusNode = FocusNode();
    // listen to focus changes
    if (kIsWeb) {
      passwordFocusNode.addListener(() =>
          logger('focusNode updated: hasFocus: ${passwordFocusNode.hasFocus}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AuthenticationBloc>();
    // loginProvide = Provider.of<AuthProvider>(context, listen: true);
    var formKey = GlobalKey<FormState>();
    final _secureStorageProvider = getSingleton<SecureStorageProvider>();
    /* final RegExp emailRegex = RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
      */

    final _formLoginKey = GlobalKey<FormState>();
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    @override
    void initState() {
      _passwordVisible = false;
      passwordFocusNode = FocusNode();
      super.initState();
    }

    void setFocus() {
      FocusScope.of(context).requestFocus(passwordFocusNode);
    }

    @override
    void dispose() {
      userNameController.dispose();
      passwordController.dispose();
      super.dispose();
    }

    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationLoading) {
          SizedBox(
            height: displayHeight(context) * 0.65,
            width: displayWidth(context),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is AuthenticationAuthenticated) {
          // Journey.isExist = true;
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
              Journey.loginType = 'Internal';
              Journey.skuResponseLists = [];
              Journey.email =
                  authenticationBloc.userData?.userinfo?.email ?? '';
              Journey.username =
                  authenticationBloc.userData?.userinfo?.username ?? '';
              final secureStorageProvider =
                  getSingleton<SecureStorageProvider>();
              secureStorageProvider.saveQuoteToDisk(Journey.skuResponseLists);
              secureStorageProvider.saveCartCount(0);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    Journey.loginType = 'Internal';
                    return const HomeScreen(loginType: 'Internal');
                  },
                ),
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
              logger(
                  'Email: ${authenticationBloc.userData?.userinfo?.email ?? ''}');

              Journey.email =
                  authenticationBloc.userData?.userinfo?.email ?? '';
              Journey.username =
                  authenticationBloc.userData?.userinfo?.username ?? '';
              Journey.loginType = 'Internal';
              Journey.skuResponseLists = [];
              final secureStorageProvider =
                  getSingleton<SecureStorageProvider>();
              secureStorageProvider.saveQuoteToDisk(Journey.skuResponseLists);
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
      buildWhen: (context, state) {
        return true;
      },
      builder: (context, state) {
        return Responsive(
          desktop: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: AsianPaintEdgeInsets.vertical_16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: TextFormField(
                          enableInteractiveSelection: false,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          cursorColor: AsianPaintColors.textFieldLabelColor,
                          controller: userNameController,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AsianPaintColors
                                        .textFieldUnderLineColor)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: AsianPaintColors.textFieldUnderLineColor,
                            )),
                            filled: true,
                            focusColor:
                                AsianPaintColors.textFieldUnderLineColor,
                            fillColor: AsianPaintColors.textFieldBorderColor,
                            border: const UnderlineInputBorder(),
                            labelText: AppLocalizations.of(context).user_id,
                            labelStyle: TextStyle(
                                fontFamily: AsianPaintsFonts.mulishRegular,
                                fontWeight: FontWeight.w600,
                                color: AsianPaintColors.textFieldLabelColor),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter valid User ID";
                            }
                            return null;
                          }),
                    ),
                    AsianPaintSizedBoxes.height_5,
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: TextFormField(
                        enableInteractiveSelection: false,
                        keyboardType: TextInputType.text,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        focusNode: passwordFocusNode,
                        textInputAction: TextInputAction.done,
                        obscureText: !_passwordVisible,
                        controller: passwordController,
                        cursorColor: AsianPaintColors.textFieldLabelColor,
                        style: TextStyle(
                          color: AsianPaintColors.kPrimaryColor,
                        ),
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AsianPaintColors
                                      .textFieldUnderLineColor)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: AsianPaintColors.textFieldUnderLineColor,
                          )),
                          filled: true,
                          fillColor: AsianPaintColors.textFieldBorderColor,
                          border: const UnderlineInputBorder(),
                          labelText: AppLocalizations.of(context).password,
                          focusColor: AsianPaintColors.textFieldUnderLineColor,
                          labelStyle: TextStyle(
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              fontWeight: FontWeight.w600,
                              color: AsianPaintColors.textFieldLabelColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AsianPaintColors.textFieldLabelColor,
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(
                                () {
                                  _passwordVisible = !_passwordVisible;
                                },
                              );
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter valid password';
                          }
                          return null;
                        },
                      ),
                    ),
                    AsianPaintSizedBoxes.height_15,
                    Center(
                      child: SizedBox(
                        height: 45,
                        width: 350,
                        child: APElevatedButton(
                          onPressed: () {
                            if (_formLoginKey.currentState!.validate()) {
                              bloc.login(
                                userID: userNameController.text,
                                password: passwordController.text,
                                deviceToken: '',
                              );
                            }
                          },
                          label: state is AuthenticationLoginLoading
                              ? SizedBox(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                    color: AsianPaintColors.buttonTextColor,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context).login,
                                  style: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishBold,
                                    color: AsianPaintColors.buttonTextColor,
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
                    ),
                    AsianPaintSizedBoxes.height_15,
                  ],
                ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                        enableInteractiveSelection: false,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        cursorColor: AsianPaintColors.textFieldLabelColor,
                        controller: userNameController,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AsianPaintColors
                                      .textFieldUnderLineColor)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: AsianPaintColors.textFieldUnderLineColor,
                          )),
                          filled: true,
                          focusColor: AsianPaintColors.textFieldUnderLineColor,
                          fillColor: AsianPaintColors.textFieldBorderColor,
                          border: const UnderlineInputBorder(),
                          labelText: AppLocalizations.of(context).user_id,
                          labelStyle: TextStyle(
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: AsianPaintColors.textFieldLabelColor),
                        ),
                        validator: (value) {
                          // if (!emailRegex.hasMatch(value!)) {
                          if (value!.isEmpty) {
                            return 'Enter valid UserID';
                          }
                          return null;
                        }),
                    AsianPaintSizedBoxes.height_5,
                    TextFormField(
                      enableInteractiveSelection: false,
                      keyboardType: TextInputType.text,
                      controller: passwordController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      focusNode: passwordFocusNode,
                      textInputAction: TextInputAction.done,
                      obscureText: !_passwordVisible,
                      cursorColor: AsianPaintColors.textFieldLabelColor,
                      style: TextStyle(
                          color: AsianPaintColors.textFieldLabelColor),
                      decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AsianPaintColors
                                      .textFieldUnderLineColor)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: AsianPaintColors.textFieldUnderLineColor,
                          )),
                          filled: true,
                          fillColor: AsianPaintColors.textFieldBorderColor,
                          border: const UnderlineInputBorder(),
                          labelText: AppLocalizations.of(context).password,
                          focusColor: AsianPaintColors.textFieldUnderLineColor,
                          labelStyle: TextStyle(
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: AsianPaintColors.textFieldLabelColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AsianPaintColors.textFieldLabelColor,
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          )),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter valid password';
                        }
                        return null;
                      },
                    ),
                    AsianPaintSizedBoxes.height_15,
                    Center(
                      child: SizedBox(
                        height: 45,
                        width: 350,
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
                                      color: AsianPaintColors.buttonTextColor),
                                )
                              : Text(
                                  AppLocalizations.of(context).login,
                                  style: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishBold,
                                    color: AsianPaintColors.buttonTextColor,
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
                    ),
                    AsianPaintSizedBoxes.height_15,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void fixEdgePasswordRevealButton(FocusNode passwordFocusNode) {
    passwordFocusNode.unfocus();
    Future.microtask(() {
      passwordFocusNode.requestFocus();
      // js.context.callMethod("fixPasswordCss", []);
    });
  }
}
