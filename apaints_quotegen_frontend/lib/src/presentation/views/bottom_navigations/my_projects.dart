import 'dart:io';

import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/presentation/views/loading/loading_screen.dart';
import 'package:APaints_QGen/src/presentation/views/project/projects_list.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/view_quote.dart';
import 'package:APaints_QGen/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart' as badges;

class MyProjects extends StatefulWidget {
  static const routeName = Routes.MyProjectsScreen;
  bool? myproject = false;

  MyProjects({super.key, this.myproject});

  @override
  State<MyProjects> createState() => _MyProjectsState();
}

class _MyProjectsState extends State<MyProjects> {
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
      logger('Cart Count: $cartBadgeAmount');
      if (cartBadgeAmount != null) {
        _showCartBadge = cartBadgeAmount! > 0;
      }
      return cartBadgeAmount ?? 0;
    }

    Widget shoppingCartBadge(int cartBadgeAmount) {
      logger('Cart amount: $cartBadgeAmount');
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

    return Responsive(
      mobile: FutureBuilder(
        future: getCartCount(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              return Scaffold(
                backgroundColor: AsianPaintColors.appBackgroundColor,
                key: scaffoldKey,
                body: ProjectsList(
                  fromMyProjs: widget.myproject,
                  appBarVisible: false,
                ),
              );
            default:
              const SizedBox();
          }
          return const SizedBox();
        },
      ),
      desktop: const ProjectsList(),
      tablet: ProjectsList(fromMyProjs: widget.myproject),
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
