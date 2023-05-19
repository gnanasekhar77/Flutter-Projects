//import 'package:asian_paints/lang_view.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/auth_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Background extends StatefulWidget {
  final Widget child;
  String? language;
  final String topImage, bottomImage, leftCenter, topRight, rightCenter;
  Background(
      {Key? key,
      required this.child,
      this.language,
      this.topImage = "assets/images/top_image.png",
      this.bottomImage = "assets/images/footer.png",
      this.leftCenter = "assets/images/left_center.png",
      this.topRight = "assets/images/top_right.png",
      this.rightCenter = "assets/images/right_center.png"})
      : super(key: key);

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  var selectedLanguage;
  AuthImpl? loginProvide;

  // Locale? locale;
  // bool isSelected(BuildContext context) =>
  //     locale == context.read<LocaleProvider>().locale;
  final _secureStorageProvider = null;

  @override
  void initState() {
    // loginProvide = Provider.of<AuthImpl>(context, listen: false);
    // getLang();
    // //selectedLanguage = Locale(Journey.appLanguage ?? "en");
    // Future.delayed(const Duration(seconds: 0), () {
    //   context.read<AuthImpl>().setLocale(selectedLanguage);
    // });

    super.initState();
  }

  Future<void> getLang() async {
    String? lang = await _secureStorageProvider.read(key: 'languageSelected');
    selectedLanguage = Locale(lang ?? "en");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                widget.topImage,
                width: 180,
              ),
            ),
            Positioned(
              top: 400,
              left: 0,
              child: Image.asset(
                widget.leftCenter,
                width: 50,
              ),
            ),
            Positioned(
              top: 150,
              right: 10,
              child: Image.asset(
                widget.topRight,
                width: 70,
              ),
            ),
            Positioned(
              top: 430,
              right: -20,
              child: Image.asset(
                widget.rightCenter,
                width: 50,
              ),
            ),
            SafeArea(
              child: widget.child,
            ),
            Positioned(
              top: 30,
              right: 0,
              child: SizedBox(
                width: 100,
                child: DropdownButtonFormField<Locale>(
                  value: selectedLanguage,
                  icon: const Visibility(
                      visible: false, child: Icon(Icons.arrow_downward)),
                  items: appLanguages.map((items) {
                    return DropdownMenuItem<Locale>(
                      value: items['locale'],
                      child: Text(
                        "${items['value']} ",
                        style: TextStyle(
                            color: AsianPaintColors.forgotPasswordTextColor,
                            fontSize: 10),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) async {
                    setState(() {
                      // context.read<AuthImpl>().setLocale(newValue);
                      // selectedLanguage = newValue!;
                    });
                    await _secureStorageProvider
                        .saveLanguage(selectedLanguage.toString());
                  },
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding:
                          const EdgeInsets.only(left: 17, bottom: 17, top: 17),
                      child: SvgPicture.asset(
                        "assets/images/language.svg",
                        height: 12,
                      ),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> appLanguages = [
    {"value": "عربي", "locale": const Locale("ar")},
    {"value": "English", "locale": const Locale("en")},
    {"value": "Bahasa", "locale": const Locale("id")}
  ];
}
