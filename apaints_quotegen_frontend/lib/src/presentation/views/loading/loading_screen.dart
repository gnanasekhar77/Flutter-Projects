import 'dart:io';

import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/presentation/views/login/external/login_view_external.dart';
import 'package:APaints_QGen/src/presentation/views/login/internal/login_view.dart';
import 'package:APaints_QGen/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:hovering/hovering.dart';

class LandingScreen extends StatefulWidget {
  static const routeName = Routes.LandingScreen;
  const LandingScreen({super.key});

  @override
  Splash createState() => Splash();
}

class Splash extends State<LandingScreen> {
  late int selectedButton = 0;
  int _exitCounter = 0;
  int _enterCounter = 0;

  Color textcolor = AsianPaintColors.userTypeTextColor;
  Color textcolor2 = AsianPaintColors.userTypeTextColor;

  void _incrementEnter(PointerEvent details) {
    setState(() {
      _enterCounter++;
    });
  }

  void _incrementExit(PointerEvent details) {
    setState(() {
      textcolor = AsianPaintColors.userTypeTextColor;
      _exitCounter++;
    });
  }

  void changecolour(PointerEvent details) {
    setState(() {
      textcolor = AsianPaintColors.whiteColor;
    });
  }

  void _incrementEnter2(PointerEvent details) {
    setState(() {
      _enterCounter++;
    });
  }

  void _incrementExit2(PointerEvent details) {
    setState(() {
      textcolor2 = AsianPaintColors.userTypeTextColor;
      _exitCounter++;
    });
  }

  void changecolour2(PointerEvent details) {
    setState(() {
      textcolor2 = AsianPaintColors.whiteColor;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;

    queryData = MediaQuery.of(context);
    // FocusManager.instance.primaryFocus?.unfocus();

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: WillPopScope(
          onWillPop: onWillPop,
          child: LayoutBuilder(builder: (layoutBuilderContext, constraints) {
            return Responsive(
              mobile: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/images/bg.svg',
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 1.6,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 15.0),
                      child: Text(
                        AppLocalizations.of(context).choose_your_account,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: AsianPaintsFonts.bathSansRegular,
                          color: AsianPaintColors.chooseYourAccountColor,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.elliptical(10.0, 10.0)),
                                color:
                                    AsianPaintColors.bottomTextUnSelectedColor),
                            margin: const EdgeInsets.all(10.0),
                            width: 160.0,
                            height: 160.0,
                            alignment: Alignment.topLeft,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  OptionRadio(
                                      text: '',
                                      index: 0,
                                      selectedButton: selectedButton,
                                      press: (val) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen()),
                                        );
                                        selectedButton = val;
                                        setState(() {});
                                      }),
                                  Center(
                                    child: SvgPicture.asset(
                                      'assets/images/external.svg',
                                      fit: BoxFit.contain,
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15.0),
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .internal_users,
                                        style: TextStyle(
                                          color: AsianPaintColors
                                              .userTypeTextColor,
                                          fontFamily:
                                              AsianPaintsFonts.bathSansRegular,
                                          fontSize: 13.0,
                                        ),
                                      ),
                                    ),
                                  )
                                ]),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ExternalUserLoginScreen()),
                            );
                          },
                          child: Container(
                            width: 160.0,
                            height: 160.0,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.elliptical(10.0, 10.0)),
                                color:
                                    AsianPaintColors.bottomTextUnSelectedColor),
                            margin: const EdgeInsets.all(10.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  OptionRadio(
                                      text: '',
                                      index: 1,
                                      selectedButton: selectedButton,
                                      press: (val) {
                                        selectedButton = val;
                                        setState(() {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ExternalUserLoginScreen()),
                                          );
                                          return activate();
                                        });
                                      }),
                                  // Icon(Icons.verified_user_outlined),
                                  Center(
                                    child: SvgPicture.asset(
                                      'assets/images/internal.svg',
                                      fit: BoxFit.fill,
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15.0),
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .external_users,
                                        style: TextStyle(
                                          color: AsianPaintColors
                                              .userTypeTextColor,
                                          fontFamily:
                                              AsianPaintsFonts.bathSansRegular,
                                          fontSize: 13.0,
                                        ),
                                      ),
                                    ),
                                  )
                                ]),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              tablet: const Scaffold(),
              desktop: Container(
                height: double.infinity,
                width: double.infinity,
                color: AsianPaintColors.appBackgroundColor,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        height: double.infinity,
                        //width:900,
                        child: Image.asset(
                          './assets/images/webviewlandingimage.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      Column(
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              padding:
                                  const EdgeInsets.only(top: 200, left: 150),
                              child: SvgPicture.asset(
                                'assets/images/bathsans_logo.svg',
                                height: 30,
                              )),
                          const SizedBox(
                            height: 40,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 130),
                            child: Text(
                              AppLocalizations.of(context).choose_your_account,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: AsianPaintsFonts.bathSansRegular,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          Container(
                            // hoverColor:
                            //          AsianPaintColors.resetPasswordLabelColor,
                            padding: const EdgeInsets.only(left: 145),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen()),
                                    );
                                  },
                                  child: MouseRegion(
                                    onEnter: _incrementEnter,
                                    onHover: changecolour,
                                    onExit: _incrementExit,
                                    child: HoverAnimatedContainer(
                                      hoverDecoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.elliptical(10.0, 10.0)),
                                        color: AsianPaintColors
                                            .resetPasswordLabelColor,
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.elliptical(10.0, 10.0)),
                                          color: AsianPaintColors.whiteColor),
                                      margin: const EdgeInsets.all(10.0),
                                      width: 170.0,
                                      height: 170.0,
                                      alignment: Alignment.topLeft,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            OptionRadiodt(
                                                textt: '',
                                                indexx: 0,
                                                selectedButtonn: selectedButton,
                                                pres: (val) {
                                                  // Navigator.push(
                                                  //     context,
                                                  //     MaterialPageRoute(
                                                  //         builder: (context) =>
                                                  //             const LoginScreen()),
                                                  //   );
                                                  setState(() {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const LoginScreen()),
                                                    );
                                                    selectedButton = val;
                                                    return activate();
                                                  });
                                                }),
                                            Container(
                                              height: 20,
                                            ),
                                            Center(
                                              child: SvgPicture.asset(
                                                'assets/images/external.svg',
                                                fit: BoxFit.contain,
                                                width: 60,
                                                height: 60,
                                                color: textcolor,
                                              ),
                                            ),
                                            Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15.0),
                                                child: Text(
                                                  AppLocalizations.of(context)
                                                      .internal_users,
                                                  style: TextStyle(
                                                    color:
                                                        textcolor, //AsianPaintColors
                                                    //     .userTypeTextColor,
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishBold,
                                                    fontSize: 10.0,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ]),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
                                MouseRegion(
                                  onEnter: _incrementEnter2,
                                  onHover: changecolour2,
                                  onExit: _incrementExit2,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ExternalUserLoginScreen()),
                                      );
                                    },
                                    child: HoverAnimatedContainer(
                                      width: 170.0,
                                      height: 170.0,
                                      hoverDecoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.elliptical(10.0, 10.0)),
                                        color: AsianPaintColors
                                            .resetPasswordLabelColor,
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.elliptical(10.0, 10.0)),
                                          color: AsianPaintColors.whiteColor),
                                      margin: const EdgeInsets.all(10.0),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            OptionRadiodt(
                                                textt: '',
                                                indexx: 1,
                                                selectedButtonn: selectedButton,
                                                pres: (val) {
                                                  setState(() {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const ExternalUserLoginScreen()),
                                                    );
                                                    selectedButton = val;
                                                    return activate();
                                                  });
                                                }),

                                            // Icon(Icons.verified_user_outlined),

                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Center(
                                              child: SvgPicture.asset(
                                                'assets/images/internal.svg',
                                                fit: BoxFit.fill,
                                                width: 60,
                                                height: 60,
                                                color: textcolor2,
                                              ),
                                            ),
                                            Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15.0),
                                                child: Text(
                                                  AppLocalizations.of(context)
                                                      .external_users,
                                                  style: TextStyle(
                                                    color: textcolor2,
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishBold,
                                                    fontSize: 10.0,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        )
        // Container(
        //   decoration: const BoxDecoration(color: Colors.white),
        //   child: Center(
        //     child: SvgPicture.asset('assets/images/bg.svg'),
        //   ),
        // ), //<- place where the image appears
        );
  }

  Future<bool> onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}

class OptionRadio extends StatefulWidget {
  final String text;
  final int index;
  final int selectedButton;
  final Function press;

  const OptionRadio({
    super.key,
    required this.text,
    required this.index,
    required this.selectedButton,
    required this.press,
  });

  @override
  OptionRadioPage createState() => OptionRadioPage();
}

class OptionRadioPage extends State<OptionRadio> {
  // QuestionController controllerCopy =QuestionController();

  int id = 1;

  // OptionRadioPage();

  @override
  void initState() {
    super.initState();
  }

  // int _selected;

  @override
  Widget build(BuildContext context) {
    int selectedButton;
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.white,
                  disabledColor: Colors.blue),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Radio(
                      /*Here the selectedButton which is null initially takes place of value after onChanged. Now, I need to clear the selected button when other button is clicked */
                      groupValue: widget.selectedButton,
                      value: widget.index,
                      activeColor: Colors.orange,
                      onChanged: (val) async {
                        debugPrint('Radio button is clicked onChanged $val');
                        setState(() {
                          widget.press(widget.index);
                        });
                      },
                      toggleable: false,
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}

class OptionRadiodt extends StatefulWidget {
  final String textt;
  final int indexx;
  final int selectedButtonn;
  final Function pres;

  const OptionRadiodt({
    super.key,
    required this.textt,
    required this.indexx,
    required this.selectedButtonn,
    required this.pres,
  });

  @override
  OptionRadioPage1 createState() => OptionRadioPage1();
}

class OptionRadioPage1 extends State<OptionRadiodt> {
  // QuestionController controllerCopy =QuestionController();

  int id = 1;

  // OptionRadioPage();

  @override
  void initState() {
    super.initState();
  }

  // int _selected;

  @override
  Widget build(BuildContext context) {
    int selectedButton;
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.black12,
                  disabledColor: Colors.black),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Radio(
                      //hoverColor: Colors.white,
                      /*Here the selectedButton which is null initially takes place of value after onChanged. Now, I need to clear the selected button when other button is clicked */
                      groupValue: widget.selectedButtonn,
                      value: widget.indexx,

                      activeColor: Colors.orange,

                      onChanged: (val) async {
                        debugPrint('Radio button is clicked onChanged $val');
                        setState(() {
                          widget.pres(widget.indexx);
                        });
                      },
                      toggleable: false,
                      // fillColor: Colors.green,
                      //focusColor: Colors.green,
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
