import 'dart:io';

import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/presentation/blocs/search/search_bloc.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/competiton_search/mobile/competition_search.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/my_projects.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/quick_quote.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/template_quote/template_quote_mobile.dart';
import 'package:APaints_QGen/src/presentation/views/loading/loading_screen.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/view_quote.dart';
import 'package:APaints_QGen/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:badges/badges.dart' as badges;
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = Routes.HomeScreen;
  final String? loginType;
  const HomeScreen({super.key, required this.loginType});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // GlobalKey<_HomeScreenState> key = GlobalKey();

  List<Widget> widgetOptions = [];

  bool? _showCartBadge;
  Color color = Colors.red;

  bool loadingStatus = false;
  String? userName = "";
  int? cartBadgeAmount;

  String? category;
  String? brand;
  String? range;
  List<SKUData>? skuData;
  String? token;
  int _selectedIndex = 0;

  final secureStorageProvider = getSingleton<SecureStorageProvider>();

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  Future<String?> getUsername() async {
    userName = await secureStorageProvider.read(key: 'username');
    cartBadgeAmount = await secureStorageProvider.getCartCount();
    logger("Cart Amount in init: $cartBadgeAmount");

    return userName;
  }

  onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loginType == 'Internal') {
      widgetOptions = <Widget>[
        const QuickQuote(),
        const TemplateQuote(),
        const CompetitionSearch(),
        MyProjects(
          myproject: true,
        )
      ];
    } else if (Journey.loginType == 'External') {
      widgetOptions = <Widget>[
        const QuickQuote(),
        const TemplateQuote(),
        MyProjects(
          myproject: true,
        )
      ];
    }
    logger("Login Type: ${widget.loginType}");
    logger('Email: ${Journey.email}');
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    Future<int> getCartCount() async {
      if ((Journey.token ?? '').isEmpty) {
        Journey.token = await secureStorageProvider.getToken();
        Journey.username = await secureStorageProvider.getUsername();
        Journey.email = await secureStorageProvider.getEmail();
        Journey.loginType = await secureStorageProvider.getLoginType();
        if (await secureStorageProvider.getIsExist() == 'true') {
          Journey.isExist = true;
        } else {
          Journey.isExist = false;
        }
      } else {
        secureStorageProvider.saveToken(Journey.token);
        secureStorageProvider.saveUsername(Journey.username);
        secureStorageProvider.saveEmail(Journey.email);
        secureStorageProvider.saveLoginType(Journey.loginType);

        secureStorageProvider.saveIsExist(Journey.isExist);
      }

      cartBadgeAmount = await secureStorageProvider.getCartCount();
      category = await secureStorageProvider.getCategory();
      brand = await secureStorageProvider.getBrand();
      range = await secureStorageProvider.getRange();
      skuData = await secureStorageProvider.getQuoteFromDisk();
      logger('Cart Count: $cartBadgeAmount');
      if (cartBadgeAmount != null) {
        _showCartBadge = cartBadgeAmount! > 0;
      }
      return cartBadgeAmount ?? 0;
    }

    Widget shoppingCartBadge(int cartBadgeAmount) {
      logger('Cart amount in quick quote: $cartBadgeAmount');
      return badges.Badge(
        position: badges.BadgePosition.topEnd(top: 0, end: 3),
        showBadge: _showCartBadge ?? false,
        badgeColor: color,
        badgeContent: Text(
          '$cartBadgeAmount',
          style: const TextStyle(color: Colors.white),
        ),
        child: IconButton(
            icon: SvgPicture.asset('assets/images/cart.svg'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewQuote(
                    catIndex: 0,
                    brandIndex: 0,
                    rangeIndex: 0,
                    category: category,
                    brand: brand,
                    range: range,
                    quantity: '',
                    skuResponseList: skuData,
                    fromFlip: false,
                  ),
                ),
              );
            }),
      );
    }

    return FutureBuilder(
      future: getCartCount(),
      builder: (context, snapshot) {
        return WillPopScope(
          onWillPop: onWillPopLogout,
          child: Responsive(
            mobile: Scaffold(
                key: scaffoldKey,
                appBar: AppBar(
                  centerTitle: false,
                  titleSpacing: 0,
                  title: SvgPicture.asset('assets/images/bathsans_logo.svg'),
                  leading: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 11, 5, 11),
                    child: GestureDetector(
                      onTap: () {
                        scaffoldKey.currentState!.openDrawer();
                      },
                      child: SvgPicture.asset(
                        'assets/images/navigation_menu.svg',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    shoppingCartBadge(snapshot.data ?? 1),
                    InkWell(
                      onTap: () {
                        showSearch(
                            context: context,
                            delegate: SearchList(
                                searchBloc:
                                    BlocProvider.of<SearchListBloc>(context)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(3, 8, 8, 8),
                        child: SvgPicture.asset('assets/images/search.svg'),
                      ),
                    ),
                  ],
                ),
                drawer: Drawer(
                  backgroundColor: AsianPaintColors.whiteColor,
                  child: ListView(
                    children: [
                      DrawerHeader(
                        decoration: BoxDecoration(
                          color: AsianPaintColors.kPrimaryColor,
                        ),
                        child: Container(
                          width: double.infinity,
                          color: AsianPaintColors.kPrimaryColor,
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: SvgPicture.asset(
                                      'assets/images/back.svg'),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Center(
                                child: CircleAvatar(
                                  foregroundColor:
                                      AsianPaintColors.buttonTextColor,
                                  radius: 30,
                                  backgroundImage: const AssetImage(
                                      'assets/images/user.png'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                Journey.username ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontFamily: AsianPaintsFonts.mulishRegular,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        tileColor: AsianPaintColors.whiteColor,
                        iconColor: AsianPaintColors.forgotPasswordTextColor,
                        leading: SvgPicture.asset('assets/images/web.svg'),
                        minLeadingWidth: 5,
                        title: Text(
                          'Website',
                          style: TextStyle(
                            fontFamily: AsianPaintsFonts.mulishRegular,
                            color: AsianPaintColors.kPrimaryColor,
                          ),
                        ),
                        onTap: () {
                          _launchSocialMediaAppIfInstalled(
                            url:
                                'https://bathsense.asianpaints.com/home.html', //Instagram
                          );
                          // Add Navigation logic here
                        },
                      ),
                      ListTile(
                        tileColor: AsianPaintColors.whiteColor,
                        iconColor: AsianPaintColors.forgotPasswordTextColor,
                        leading:
                            SvgPicture.asset('assets/images/instagram.svg'),
                        minLeadingWidth: 5,
                        title: Text(
                          'Instagram',
                          style: TextStyle(
                            fontFamily: AsianPaintsFonts.mulishRegular,
                            color: AsianPaintColors.kPrimaryColor,
                          ),
                        ),
                        onTap: () {
                          _launchSocialMediaAppIfInstalled(
                            url:
                                'https://www.instagram.com/bathsense.asianpaints/', //Instagram
                          );

                          // Add Navigation logic here
                        },
                      ),
                      ListTile(
                        tileColor: AsianPaintColors.whiteColor,
                        iconColor: AsianPaintColors.forgotPasswordTextColor,
                        leading: SvgPicture.asset('assets/images/facebook.svg'),
                        minLeadingWidth: 5,
                        title: Text(
                          'Facebook',
                          style: TextStyle(
                            fontFamily: AsianPaintsFonts.mulishRegular,
                            color: AsianPaintColors.kPrimaryColor,
                          ),
                        ),
                        onTap: () {
                          _launchSocialMediaAppIfInstalled(
                            url:
                                'https://www.facebook.com/asianpaints.bathsense', //Instagram
                          );

                          // Add Navigation logic here
                        },
                      ),
                      ListTile(
                        tileColor: AsianPaintColors.whiteColor,
                        iconColor: AsianPaintColors.forgotPasswordTextColor,
                        leading: SvgPicture.asset('assets/images/youtube.svg'),
                        minLeadingWidth: 5,
                        title: Text(
                          'Youtube',
                          style: TextStyle(
                            fontFamily: AsianPaintsFonts.mulishRegular,
                            color: AsianPaintColors.kPrimaryColor,
                          ),
                        ),
                        onTap: () {
                          _launchSocialMediaAppIfInstalled(
                            url:
                                'https://www.youtube.com/@bathsense.asianpaints', //Instagram
                          );

                          // Add Navigation logic here
                        },
                      ),
                      Divider(
                          thickness: 1, color: AsianPaintColors.quantityBorder),
                      ListTile(
                        tileColor: AsianPaintColors.whiteColor,
                        iconColor: AsianPaintColors.forgotPasswordTextColor,
                        leading: const Icon(Icons.login_outlined),
                        minLeadingWidth: 5,
                        title: Text(
                          AppLocalizations.of(context).logout,
                          style: TextStyle(
                            fontFamily: AsianPaintsFonts.mulishRegular,
                            color: AsianPaintColors.forgotPasswordTextColor,
                          ),
                        ),
                        onTap: () {
                          onWillPopLogout();

                          // Add Navigation logic here
                        },
                      ),
                      Divider(
                        thickness: 1,
                        color: AsianPaintColors.quantityBorder,
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: AsianPaintColors.kPrimaryColor,
                    primaryColor: AsianPaintColors.buttonTextColor,
                  ),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    // key: key,
                    currentIndex: _selectedIndex,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    selectedFontSize: 10,
                    unselectedFontSize: 10,
                    selectedLabelStyle: const TextStyle(fontSize: 0),
                    unselectedLabelStyle: const TextStyle(fontSize: 0),
                    backgroundColor: Colors.transparent,
                    selectedItemColor: AsianPaintColors.buttonTextColor,
                    unselectedItemColor: AsianPaintColors.whiteColor,
                    items: widget.loginType == 'Internal'
                        ? [
                            bottomNavigationBarItem(
                                SvgPicture.asset(
                                    'assets/images/quick_quote.svg'),
                                AppLocalizations.of(context).quick_quote),
                            bottomNavigationBarItem(
                                SvgPicture.asset(
                                    'assets/images/template_quote.svg'),
                                AppLocalizations.of(context).template_quote),
                            bottomNavigationBarItem(
                                SvgPicture.asset(
                                    'assets/images/competition_search.svg'),
                                AppLocalizations.of(context)
                                    .competition_search),
                            bottomNavigationBarItem(
                                SvgPicture.asset(
                                    'assets/images/my_projects.svg'),
                                AppLocalizations.of(context).my_projects),
                          ]
                        : [
                            bottomNavigationBarItem(
                                SvgPicture.asset(
                                    'assets/images/quick_quote.svg'),
                                AppLocalizations.of(context).quick_quote),
                            bottomNavigationBarItem(
                                SvgPicture.asset(
                                    'assets/images/template_quote.svg'),
                                AppLocalizations.of(context).template_quote),
                            bottomNavigationBarItem(
                                SvgPicture.asset(
                                    'assets/images/my_projects.svg'),
                                AppLocalizations.of(context).my_projects),
                          ],
                    onTap: (index) {
                      onTapped(index);
                    },
                  ),
                ),
                body: widgetOptions[_selectedIndex]),
            tablet: const Scaffold(),
            desktop: const Scaffold(),
          ),
        );
      },
    );
  }

  // Future<void> launchUrl(String url) async {
  //   final canLa = await canLaunch(url);
  //   if (kIsWeb) {
  //     if (canLa) {
  //       await launch(url);
  //     } else {
  //       throw "Could not launch $url";
  //     }
  //     return;
  //   }
  //   if (TargetPlatform.android) {
  //     if (url.startsWith("https://www.facebook.com/")) {
  //       final url2 = "fb://facewebmodal/f?href=$url";
  //       final intent2 = AndroidIntent(action: "action_view", data: url2);
  //       final canWork = await intent2.canResolveActivity();
  //       if (canWork) return intent2.launch();
  //     }
  //     final intent = AndroidIntent(action: "action_view", data: url);
  //     return intent.launch();
  //   } else {
  //     if (canLaunch) {
  //       await launch(url, forceSafariVC: false);
  //     } else {
  //       throw "Could not launch $url";
  //     }
  //   }
  // }

  Future<void> _launchSocialMediaAppIfInstalled({
    required String url,
  }) async {
    try {
      bool launched = await launch(url,
          forceSafariVC: false); // Launch the app if installed!

      if (!launched) {
        launch(url); // Launch web view if app is not installed!
      }
    } catch (e) {
      launch(url); // Launch web view if app is not installed!
    }
  }

  Future<bool> onWillPopLogout() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to logout?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  if (Platform.isAndroid || Platform.isIOS) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LandingScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LandingScreen(),
                      ),
                    );
                  }
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}

BottomNavigationBarItem bottomNavigationBarItem(SvgPicture icon, String label) {
  return BottomNavigationBarItem(
    activeIcon: _navItemIcon(
        icon, label, AsianPaintColors.buttonTextColor, Colors.white),
    icon:
        _navItemIcon(icon, label, AsianPaintColors.kPrimaryColor, Colors.white),
    label: '',
  );
}

Padding _navItemIcon(SvgPicture icon, String label, Color? backgrondColor,
    Color? foregroundColor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 0),
    child: Row(
      children: [
        Expanded(
          child: Container(
            color: backgrondColor,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: Column(
                children: [
                  icon,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Text(
                      label,
                      style: TextStyle(
                          color: foregroundColor,
                          fontSize: 11,
                          fontFamily: AsianPaintsFonts.bathSansRegular),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
