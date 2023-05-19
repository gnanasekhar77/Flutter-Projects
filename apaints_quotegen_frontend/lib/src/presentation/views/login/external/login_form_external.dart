import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/constants.dart';
import 'package:APaints_QGen/src/core/utils/edge_insets.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/core/utils/sized_boxes.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/auth_provider.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/authentication/authentication_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/categories/categories_bloc.dart';
import 'package:APaints_QGen/src/presentation/views/home/home_screen.dart';
import 'package:APaints_QGen/src/presentation/views/login/external/login_otp_view.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/elevated_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ExternalUserLoginForm extends StatefulWidget {
  final String? language;
  const ExternalUserLoginForm({Key? key, this.language}) : super(key: key);

  @override
  State<ExternalUserLoginForm> createState() => _ExternalUserLoginFormState();
}

class _ExternalUserLoginFormState extends State<ExternalUserLoginForm> {
  AuthProvider? loginProvide;
  late FocusNode passwordFocusNode;
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();

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

    final mobileNumberController = TextEditingController();
    final _formLoginKey = GlobalKey<FormState>();
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    final FocusNode unitCodeCtrlFocusNode = FocusNode();

    @override
    void initState() {
      super.initState();
    }

    @override
    void dispose() {
      mobileNumberController.dispose();

      super.dispose();
    }

    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      buildWhen: (previous, current) {
        return true;
      },
      builder: (context, state) {
        return Responsive(
          desktop: Form(
            key: _formLoginKey,
            child: Padding(
              padding: AsianPaintEdgeInsets.vertical_16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.allow(RegExp('[0-9]+')),
                    ],
                    enableInteractiveSelection: false,
                    cursorColor: AsianPaintColors.textFieldLabelColor,
                    controller: mobileNumberController,
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    AsianPaintColors.textFieldUnderLineColor)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: AsianPaintColors.textFieldUnderLineColor,
                        )),
                        filled: true,
                        focusColor: AsianPaintColors.textFieldUnderLineColor,
                        fillColor: AsianPaintColors.whiteColor,
                        border: const UnderlineInputBorder(),
                        labelText: AppLocalizations.of(context).mobile_number,
                        labelStyle: TextStyle(
                            fontFamily: AsianPaintsFonts.mulishMedium,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            color: AsianPaintColors.quantityColor)),
                  ),
                  const SizedBox(
                    height: 70,
                  ),
                  AsianPaintSizedBoxes.height_20,
                  Center(
                    child: SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => ExternalUserOTPScreen(
                          //             mobileNumber: mobileNumberController.text,
                          //           )),
                          // );
                          bloc.externalLogin(
                            mobileNumber: mobileNumberController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35.0)),
                            backgroundColor: AsianPaintColors.buttonColor,
                            shadowColor: AsianPaintColors.buttonBorderColor,
                            textStyle: TextStyle(
                                color: AsianPaintColors.resetPasswordLabelColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily)),
                        child: Text(
                          AppLocalizations.of(context).request_otp,
                          style: TextStyle(
                            fontFamily: AsianPaintsFonts.mulishRegular,
                            color: AsianPaintColors.whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AsianPaintSizedBoxes.height_15,
                ],
              ),
            ),
          ),
          tablet: const Scaffold(),
          mobile: Form(
            key: _formLoginKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: AsianPaintEdgeInsets.vertical_16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 380,
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: TextFormField(
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.allow(RegExp('[0-9]+')),
                        ],
                        enableInteractiveSelection: false,
                        validator: (value) {
                          // if (value!.length != 10) {
                          value!.isEmpty ? 'Please enter mobile number' : '';
                          // }
                        },
                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                        cursorColor: AsianPaintColors.textFieldLabelColor,
                        controller: mobileNumberController,
                        autofocus: true,
                        focusNode: unitCodeCtrlFocusNode,
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
                            labelText:
                                AppLocalizations.of(context).mobile_number,
                            labelStyle: TextStyle(
                                fontSize: 12,
                                fontFamily: AsianPaintsFonts.mulishRegular,
                                fontWeight: FontWeight.w400,
                                color: AsianPaintColors.textFieldLabelColor)),
                      ),
                    ),
                    AsianPaintSizedBoxes.height_20,
                    Center(
                      child: SizedBox(
                        height: 45,
                        width: 350,
                        child: APElevatedButton(
                          onPressed: () async {
                            // if (_formLoginKey.currentState!.validate()) {
                            if (mobileNumberController.text.length != 10) {
                              FlutterToastProvider().show(
                                  message: 'Please enter valid mobile number');
                            } else {
                              bloc.externalLogin(
                                mobileNumber: mobileNumberController.text,
                              );
                            }
                            // }
                            // final bloc = context.read<AuthenticationBloc>();
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (BuildContext context) {
                            //     return Provider<AuthenticationBloc>.value(
                            //       value: bloc,
                            //       child: const HomeScreen(),
                            //     );
                            //   }),
                            // );
                          },
                          label: state is AuthenticationLoginLoading
                              ? Center(
                                  child: SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                        color:
                                            AsianPaintColors.buttonTextColor),
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context).request_otp,
                                  style: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishBold,
                                    color: AsianPaintColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
      listener: (context, state) {
        if (state is FRAuthenticationAuthenticated) {
          _secureStorageProvider.saveMobileNumber(mobileNumberController.text);
          // Journey.isExist = true;
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(builder: (BuildContext context) {
              return ExternalUserOTPScreen(
                  mobileNumber: mobileNumberController.text);
            }),
          );
        }
      },
    );
  }
}
