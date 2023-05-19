import 'dart:io';

import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/data/repositories/search_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/categories/categories_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/categories/categories_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/search/search_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/search/search_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/search/search_state.dart';
import 'package:APaints_QGen/src/presentation/views/loading/loading_screen.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/brands_list.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/sku_list.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/view_quote.dart';
import 'package:APaints_QGen/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:badges/badges.dart' as badges;

class QuickQuote extends StatefulWidget {
  static const routeName = Routes.QuickQuoteScreen;

  const QuickQuote({super.key});

  @override
  State<QuickQuote> createState() => _QuickQuoteState();
}

class _QuickQuoteState extends State<QuickQuote> {
  bool? _showCartBadge;
  Color color = Colors.red;

  bool loadingStatus = false;
  String? userName = "";
  int? cartBadgeAmount;

  String? category;
  String? brand;
  String? range;
  List<SKUData>? skuData;

  final secureStorageProvider = getSingleton<SecureStorageProvider>();

  @override
  void initState() {
    getUsername();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String?> getUsername() async {
    userName = await secureStorageProvider.read(key: 'username');
    cartBadgeAmount = await secureStorageProvider.getCartCount();
    logger("Cart Amount in init: $cartBadgeAmount");

    return userName;
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    logger('In widget!!!');

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

    // getCartCount();

    return Responsive(
      tablet: const Scaffold(),
      desktop: WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          backgroundColor: AsianPaintColors.appBackgroundColor,
          key: scaffoldKey,
          body: MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (context) => CategoriesListBloc()..getCategories())
            ],
            child: BlocConsumer<CategoriesListBloc, CategoriesState>(
              buildWhen: (previous, current) {
                return true;
              },
              builder: (context, state) {
                CategoriesListBloc categoriesListBloc =
                    context.read<CategoriesListBloc>();
                // categoriesListBloc.close();
                if (state is CategoriesInitial) {
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is CategoriesLoading) {
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is CategoriesLoaded) {
                  Journey.catagoriesData =
                      categoriesListBloc.getCategoriesModel?.data ?? [];
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              AppLocalizations.of(context).categories,
                              style: TextStyle(
                                color: AsianPaintColors.projectUserNameColor,
                                fontFamily: AsianPaintsFonts.bathSansRegular,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                            child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 20,
                                ),
                                itemCount: Journey.catagoriesData?.length ?? 0,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      secureStorageProvider.add(
                                          key: 'index', value: '$index');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BrandsList(
                                            categoryIndex: index,
                                            category: Journey
                                                .catagoriesData![index]
                                                .category!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      //height: 100,width: 200,
                                      // padding: const EdgeInsets.all(4.0),
                                      child: Card(
                                        //margin: EdgeInsets.all(20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        color: AsianPaintColors.whiteColor,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Image.network(
                                                Journey.catagoriesData![index]
                                                    .categoryImage!,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.30,
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 0, 5),
                                                child: Text(
                                                  Journey.catagoriesData![index]
                                                      .category!,
                                                  style: TextStyle(
                                                      color: AsianPaintColors
                                                          .forgotPasswordTextColor,
                                                      fontSize: 12,
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishRegular),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is CategoriesFailure) {
                  return CategoriesListBloc().loadingStatus == true
                      ? SizedBox(
                          height: displayHeight(context) * 0.65,
                          width: displayWidth(context),
                          child:
                              const Center(child: CircularProgressIndicator()))
                      : SizedBox(
                          height: displayHeight(context) * 0.65,
                          width: displayWidth(context),
                          child: Center(
                              child: Text(
                            state.message,
                            style: const TextStyle(fontSize: 14),
                          )));
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    child: Text(
                      AppLocalizations.of(context).categories,
                      style: TextStyle(
                          color: AsianPaintColors.kPrimaryColor,
                          fontSize: 12,
                          fontFamily: AsianPaintsFonts.mulishSemiBold),
                    ),
                  ),
                );
              },
              listener: (context, state) {
                if (state is CategoriesInitial) {
                  // bloc.getCategories();
                }
              },
            ),
          ),
        ),
      ),
      mobile: FutureBuilder(
        future: getCartCount(),
        builder: (context, snapshot) {
          return WillPopScope(
            onWillPop: onWillPop,
            child: Scaffold(
              backgroundColor: AsianPaintColors.appBackgroundColor,
              key: scaffoldKey,
              // appBar: AppBar(
              //   centerTitle: false,
              //   titleSpacing: 0,
              //   title: SvgPicture.asset('assets/images/bathsans_logo.svg'),
              //   leading: Padding(
              //     padding: const EdgeInsets.fromLTRB(5, 11, 5, 11),
              //     child: GestureDetector(
              //       onTap: () {
              //         scaffoldKey.currentState!.openDrawer();
              //       },
              //       child: SvgPicture.asset(
              //         'assets/images/navigation_menu.svg',
              //         width: 30,
              //         height: 30,
              //       ),
              //     ),
              //   ),
              //   actions: <Widget>[
              //     shoppingCartBadge(snapshot.data ?? 1),
              //     InkWell(
              //       onTap: () {
              //         showSearch(
              //             context: context,
              //             delegate: SearchList(
              //                 searchBloc:
              //                     BlocProvider.of<SearchListBloc>(context)));
              //       },
              //       child: Padding(
              //         padding: const EdgeInsets.fromLTRB(3, 8, 8, 8),
              //         child: SvgPicture.asset('assets/images/search.svg'),
              //       ),
              //     ),
              //   ],
              // ),
              body: MultiBlocProvider(
                providers: [
                  BlocProvider(
                      create: (context) =>
                          CategoriesListBloc()..getCategories()),
                  BlocProvider(
                    create: (context) => SearchListBloc(
                      searchListRepo: SearchRepositoryImpl(),
                    ),
                  ),
                ],
                child: BlocConsumer<CategoriesListBloc, CategoriesState>(
                  buildWhen: (previous, current) {
                    return true;
                  },
                  builder: (context, state) {
                    CategoriesListBloc categoriesListBloc =
                        context.read<CategoriesListBloc>();
                    if (state is CategoriesInitial) {
                      Center(
                        child: SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                              color: AsianPaintColors.buttonTextColor),
                        ),
                      );
                    } else if (state is CategoriesLoading) {
                      Center(
                        child: SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                              color: AsianPaintColors.buttonTextColor),
                        ),
                      );
                    } else if (state is CategoriesLoaded) {
                      Journey.catagoriesData =
                          categoriesListBloc.getCategoriesModel?.data ?? [];
                      return LayoutBuilder(
                        builder: (p0, p1) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 10, 0, 0),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      AppLocalizations.of(context).categories,
                                      style: TextStyle(
                                          color: AsianPaintColors.kPrimaryColor,
                                          fontFamily:
                                              AsianPaintsFonts.mulishSemiBold),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: RawScrollbar(
                                    thumbVisibility: true,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: GridView.builder(
                                          shrinkWrap: true,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  childAspectRatio: 3 / 2.6,
                                                  crossAxisSpacing: 2),
                                          itemCount:
                                              Journey.catagoriesData?.length ??
                                                  0,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return InkWell(
                                              onTap: () {
                                                secureStorageProvider.add(
                                                    key: 'index',
                                                    value: '$index');
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BrandsList(
                                                      categoryIndex: index,
                                                      category: Journey
                                                              .catagoriesData?[
                                                                  index]
                                                              .category ??
                                                          '',
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                color: Colors.white,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Image.network(
                                                            Journey
                                                                    .catagoriesData?[
                                                                        index]
                                                                    .categoryImage ??
                                                                '',
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.16,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Text(
                                                              Journey
                                                                      .catagoriesData?[
                                                                          index]
                                                                      .category ??
                                                                  '',
                                                              style: TextStyle(
                                                                  color: AsianPaintColors
                                                                      .forgotPasswordTextColor,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishMedium),
                                                            ),
                                                          ),
                                                        ]),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else if (state is CategoriesFailure) {
                      return CategoriesListBloc().loadingStatus == true
                          ? SizedBox(
                              height: displayHeight(context) * 0.65,
                              width: displayWidth(context),
                              child: const Center(
                                  child: CircularProgressIndicator()))
                          : SizedBox(
                              height: displayHeight(context) * 0.65,
                              width: displayWidth(context),
                              child: Center(
                                  child: Text(
                                state.message,
                                style: const TextStyle(fontSize: 14),
                              )));
                    }
                    return SizedBox(
                      height: displayHeight(context) * 0.65,
                      width: displayWidth(context),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  listener: (context, state) {
                    if (state is CategoriesInitial) {
                      // bloc.getCategories();
                    }
                  },
                ),
              ),
              // drawer: Drawer(
              //   backgroundColor: AsianPaintColors.whiteColor,
              //   child: ListView(
              //     children: [
              //       DrawerHeader(
              //         decoration: BoxDecoration(
              //           color: AsianPaintColors.kPrimaryColor,
              //         ),
              //         child: Container(
              //           width: double.infinity,
              //           color: AsianPaintColors.kPrimaryColor,
              //           child: Column(
              //             children: [
              //               InkWell(
              //                 onTap: () {
              //                   Navigator.pop(context);
              //                 },
              //                 child: Align(
              //                   alignment: Alignment.topLeft,
              //                   child:
              //                       SvgPicture.asset('assets/images/back.svg'),
              //                 ),
              //               ),
              //               const SizedBox(height: 5),
              //               Center(
              //                 child: CircleAvatar(
              //                   foregroundColor:
              //                       AsianPaintColors.buttonTextColor,
              //                   radius: 30,
              //                   backgroundImage:
              //                       const AssetImage('assets/images/user.png'),
              //                 ),
              //               ),
              //               const SizedBox(height: 10),
              //               Text(
              //                 Journey.username!,
              //                 style: TextStyle(
              //                   fontSize: 15,
              //                   color: Colors.white,
              //                   fontFamily: AsianPaintsFonts.mulishRegular,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //       Divider(
              //           thickness: 1, color: AsianPaintColors.quantityBorder),
              //       ListTile(
              //         tileColor: AsianPaintColors.whiteColor,
              //         iconColor: AsianPaintColors.forgotPasswordTextColor,
              //         leading: const Icon(Icons.login_outlined),
              //         title: Text(
              //           AppLocalizations.of(context).logout,
              //           style: TextStyle(
              //             fontFamily: AsianPaintsFonts.mulishRegular,
              //             color: AsianPaintColors.forgotPasswordTextColor,
              //           ),
              //         ),
              //         onTap: () {
              //           onWillPopLogout();

              //           // Add Navigation logic here
              //         },
              //       ),
              //       Divider(
              //         thickness: 1,
              //         color: AsianPaintColors.quantityBorder,
              //       ),
              //     ],
              //   ),
              // ),
            ),
          );
        },
      ),
    );
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
                  if (kisweb) {
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

class SearchList extends SearchDelegate<List> {
  SearchListBloc searchBloc;
  SearchList({required this.searchBloc});
  String? queryString;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear, color: AsianPaintColors.kPrimaryColor),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: Icon(
        Icons.arrow_back,
        color: AsianPaintColors.kPrimaryColor,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    logger('Query: $query');
    queryString = query;
    searchBloc.add(Search(query: query));
    return BlocBuilder<SearchListBloc, SearchState>(
      builder: (BuildContext context, SearchState state) {
        if (state is SearchUninitialized) {
          // results = [];
          // images = [];
          // ranges = [];
          // descriptions = [];
          // prices = [];
          // productDescriptors = [];
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SearchError) {
          // results = [];
          // images = [];
          // ranges = [];
          // descriptions = [];
          // prices = [];
          // productDescriptors = [];
          return const Center(
            child: Text('Failed To Load'),
          );
        }
        if (state is SearchLoaded) {
          if (state.searchResponseModel.isEmpty) {
            return const Center(
              child: Text('No Results'),
            );
          }
          return ListView.builder(
            itemCount: state.searchResponseModel.length,
            itemBuilder: (context, index) {
              var result = state.searchResponseModel[index].skuCatCode;
              return ListTile(
                title: Text(result ?? 'Dummy',
                    style: TextStyle(color: AsianPaintColors.blackColor)),
              );
            },
          );
        }
        return const Scaffold();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    queryString = query;
    searchBloc.add(Search(query: query));

    logger('Query: $query');

    return BlocBuilder<SearchListBloc, SearchState>(
      builder: (BuildContext context, SearchState state) {
        if (state is SearchUninitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SearchError) {
          // results = [];
          // images = [];
          // ranges = [];
          // descriptions = [];
          // prices = [];
          // productDescriptors = [];
          return const Center(
            child: Text('Failed To Load'),
          );
        }
        if (state is SearchUninitialized) {
          // results = [];
          // images = [];
          // ranges = [];
          // descriptions = [];
          // prices = [];
          // productDescriptors = [];
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SearchLoaded) {
          if (state.searchResponseModel.isEmpty) {
            return const Center(
              child: Text('No Results'),
            );
          }
          List<SKUData> skuData = [];
          List<String> results = [];
          List<String> images = [];
          List<String> ranges = [];
          List<String> descriptions = [];
          List<String> prices = [];
          List<String> productDescriptors = [];

          for (int i = 0; i < state.searchResponseModel.length; i++) {
            results.add(state.searchResponseModel[i].skuCatCode ?? '');
            images.add(state.searchResponseModel[i].sKUIMAGE ?? '');
            ranges.add(state.searchResponseModel[i].sKURANGE ?? '');
            descriptions.add(state.searchResponseModel[i].sKUDESCRIPTION ?? '');
            prices.add(state.searchResponseModel[i].sKUMRP ?? '');
            productDescriptors
                .add(state.searchResponseModel[i].productCardDescriptior ?? '');
          }

          return results.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                  child: GridView.builder(

                      // shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 4.0,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: 0,
                      ),
                      itemCount: results.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            skuData.add(state.searchResponseModel[index]);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SKUList(
                                  catIndex: 0,
                                  brandIndex: 0,
                                  rangeIndex: 0,
                                  category: state.searchResponseModel[index]
                                          .sKUCATEGORY ??
                                      '',
                                  brand:
                                      state.searchResponseModel[index].sKUBRAND,
                                  range:
                                      state.searchResponseModel[index].sKURANGE,
                                  skuResponse: skuData,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: SingleChildScrollView(
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Image.network(
                                        images[index],
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 15, 0, 0),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            results[index],
                                            style: TextStyle(
                                                color: AsianPaintColors
                                                    .chooseYourAccountColor,
                                                fontSize: 12,
                                                fontFamily: AsianPaintsFonts
                                                    .mulishBold),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 0, 0),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            descriptions[index],
                                            style: TextStyle(
                                                color: AsianPaintColors
                                                    .skuDescriptionColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: AsianPaintsFonts
                                                    .mulishRegular),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 5, 0, 0),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            productDescriptors[index],
                                            style: TextStyle(
                                                color: AsianPaintColors
                                                    .skuDescriptionColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: AsianPaintsFonts
                                                    .mulishRegular),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 0, 5),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            textAlign: TextAlign.start,
                                            '\u{20B9} ${prices[index]}',
                                            style: TextStyle(
                                                color: AsianPaintColors
                                                    .forgotPasswordTextColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: AsianPaintsFonts
                                                    .mulishBold),
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                        );
                      }),
                )
              : const SizedBox();
        }
        return const Scaffold();
      },
    );
  }
}
