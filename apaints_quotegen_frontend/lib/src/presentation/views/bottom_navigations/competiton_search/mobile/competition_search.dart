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
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/competiton_search/mobile/range_search.dart';

import 'package:APaints_QGen/src/presentation/views/bottom_navigations/competiton_search/mobile/sku_search.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/competiton_search/web/range_search_web.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/competiton_search/web/sku_search_web.dart';

import 'package:APaints_QGen/src/presentation/views/bottom_navigations/quick_quote.dart';
import 'package:APaints_QGen/src/presentation/views/loading/loading_screen.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/view_quote.dart';
import 'package:APaints_QGen/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetitionSearch extends StatefulWidget {
  static const routeName = Routes.CompetitionSearchScreen;

  const CompetitionSearch({super.key});

  @override
  State<CompetitionSearch> createState() => _CompetitionSearchState();
}

class _CompetitionSearchState extends State<CompetitionSearch> {
  int? cartBadgeAmount;

  String? category;
  String? brand;
  String? range;
  List<SKUData>? skuData;
  bool? _showCartBadge;
  Color color = Colors.red;

  final secureStorageProvider = getSingleton<SecureStorageProvider>();

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    Future<int> getCartCount() async {
      cartBadgeAmount = await secureStorageProvider.getCartCount();
      category = await secureStorageProvider.getCategory();
      brand = await secureStorageProvider.getBrand();
      range = await secureStorageProvider.getRange();
      skuData = await secureStorageProvider.getQuoteFromDisk();
      logger('Cart Count in competition: $cartBadgeAmount');
      if (cartBadgeAmount != null) {
        _showCartBadge = cartBadgeAmount! > 0;
      }
      return cartBadgeAmount ?? 0;
    }

    Widget shoppingCartBadge(int cartBadgeAmount) {
      logger('Cart amount in competition: $cartBadgeAmount');
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

    Future<void> pullRefresh() async {
      setState(() {});
    }

    return WillPopScope(
      onWillPop: onWillPopLogout,
      child: FutureBuilder(
        future: getCartCount(),
        builder: (context, snapshot) {
          logger("in range Search");

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              return Responsive(
                tablet: const Scaffold(),
                desktop: const DefaultTabController(
                    length: 2,
                    child: Scaffold(
                      appBar: TabBar(
                          labelColor: Color.fromRGBO(244, 130, 33, 1),
                          unselectedLabelColor: Colors.black,
                          indicatorColor: Color.fromRGBO(244, 130, 33, 1),
                          tabs: [
                            Tab(
                              text: 'Range',
                            ),
                            Tab(
                              text: 'SKU',
                            )
                          ]),
                      body: TabBarView(children: [RangeWeb(), SkuWeb()]),

                      // ------------------------------------------------
                    )),
                mobile: DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    key: scaffoldKey,
                    appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(50),
                      child: Material(
                        color: AsianPaintColors.whiteColor,
                        child: TabBar(
                            overlayColor: MaterialStatePropertyAll(
                                AsianPaintColors.whiteColor),
                            labelColor: AsianPaintColors.buttonTextColor,
                            unselectedLabelColor:
                                AsianPaintColors.buttonTextColor,
                            indicatorColor: AsianPaintColors.buttonTextColor,
                            labelStyle: TextStyle(
                              fontFamily: AsianPaintsFonts.mulishBold,
                              fontSize: 14,
                            ),
                            unselectedLabelStyle: TextStyle(
                              fontFamily: AsianPaintsFonts.mulishBold,
                              fontSize: 14,
                            ),
                            tabs: const [
                              Tab(
                                text: 'Range',
                              ),
                              Tab(
                                text: 'SKU',
                              )
                            ]),
                      ),
                    ),
                    body: RefreshIndicator(
                      onRefresh: pullRefresh,
                      child: const TabBarView(
                          children: [RangeSearch(), SkuSearch()]),
                    ),
                  ),
                ),
              );
          }
        },
      ),
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
                  bool kisweb;
                  try {
                    if (Platform.isAndroid || Platform.isIOS) {
                      kisweb = false;
                    } else {
                      kisweb = true;
                    }
                  } catch (e) {
                    kisweb = true;
                  }
                  if(kisweb) {
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

// -----------------------------------------------------------------------------



// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------------


