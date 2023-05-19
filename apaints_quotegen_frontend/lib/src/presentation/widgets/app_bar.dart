import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/presentation/blocs/search/search_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/search/search_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/search/search_state.dart';
import 'package:APaints_QGen/src/presentation/views/home/home_screen.dart';
import 'package:APaints_QGen/src/presentation/views/loading/loading_screen.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/sku_list.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/view_quote.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:badges/badges.dart' as badges;
import 'package:url_launcher/url_launcher.dart';

import '../views/bottom_navigations/quick_quote.dart';
import 'sidemenunav.dart';

class AppBarTemplate extends StatefulWidget implements PreferredSizeWidget {
  bool isVisible = true;
  String? header;
  int? cartBadgeAmount = 0;

  AppBarTemplate(
      {super.key,
      required this.isVisible,
      required this.header,
      this.cartBadgeAmount});

  @override
  State<AppBarTemplate> createState() => _AppBarTemplateState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _AppBarTemplateState extends State<AppBarTemplate> {
  late bool _showCartBadge = false;
  Color color = Colors.red;
  String? category, brand, range;
  List<SKUData>? skuData;
  bool _folded = true;
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();

    getCartCount() async {
      int count = await secureStorageProvider.getCartCount();
      if (mounted) {
        setState(() {
          widget.cartBadgeAmount = count;
        });
      }
    }

    getCartCount();
    if (widget.cartBadgeAmount != null) {
      _showCartBadge = widget.cartBadgeAmount! > 0;
    }

    return Responsive(
      mobile: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 10.0,
        elevation: 5.0,
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Journey.area = 'ALL';
                      Journey.selectedIndex = 0;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return HomeScreen(loginType: Journey.loginType);
                          },
                        ),
                      );
                    },
                    child: SvgPicture.asset('assets/images/home.svg'),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      // Journey.area = 'ALL';
                      // Journey.selectedIndex = 0;
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset('assets/images/back.svg'),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              ),
              Row(children: [
                Text(
                  widget.header!,
                  style: TextStyle(
                      color: AsianPaintColors.whiteColor,
                      fontWeight: FontWeight.w500,
                      fontFamily: AsianPaintsFonts.bathSansRegular),
                ),
              ]),
              Row(
                children: [
                  Visibility(
                    visible: widget.isVisible,
                    maintainAnimation: !widget.isVisible,
                    maintainSize: !widget.isVisible,
                    maintainState: !widget.isVisible,
                    child: _shoppingCartBadge(skuData ?? [], category ?? '',
                        brand ?? '', range ?? ''),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  InkWell(
                      onTap: () {
                        showSearch(
                            context: context,
                            delegate: SearchList(
                                searchBloc:
                                    BlocProvider.of<SearchListBloc>(context)));
                      },
                      child: SvgPicture.asset('assets/images/search.svg')),
                ],
              )
            ],
          ),
        ),
      ),
      desktop: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: BackButton(
            color: AsianPaintColors.whiteColor,
          ),
        ),
        backgroundColor: AsianPaintColors.resetPasswordLabelColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Journey.loginType == 'Internal';

                Navigator.pushAndRemoveUntil<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const Sidemen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: SvgPicture.asset(
                "./assets/images/bathsans_logo.svg",
                height: 17,
              ),
            ),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset("./assets/images/rounduser.svg",
                        height: 35),
                    InkWell(
                      onTap: () {
                        showSearch(
                            context: context,
                            delegate: SearchListWeb(
                                searchBloc:
                                    BlocProvider.of<SearchListBloc>(context)));
                      },
                      child: SvgPicture.asset(
                          "./assets/images/outline-search-normal.svg",
                          height: 18),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 13,
                ),
                InkWell(
                  onTapDown: (details) {
                    showPopuMenu(context);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset("./assets/images/rounduser.svg",
                          height: 35),
                      SvgPicture.asset("./assets/images/outline-user.svg",
                          height: 20),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 13,
                ),
                // Image.asset(
                //   './images/user_desktop.png',
                //   width: 25,
                //   height: 25,
                // ),
                // const SizedBox(width: 13),
                InkWell(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset("./assets/images/rounduser.svg",
                          height: 35),
                      _shoppingCartBadge(skuData ?? [], category ?? '',
                          brand ?? '', range ?? ''),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      tablet: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 10.0,
        elevation: 5.0,
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            String? loginType;
                            secureStorageProvider
                                .read(key: "logintype")
                                .then((value) {
                              loginType = value;
                            });
                            return HomeScreen(loginType: loginType);
                          },
                        ),
                      );
                    },
                    child: SvgPicture.asset('assets/images/home.svg'),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  SvgPicture.asset('assets/images/back.svg'),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              ),
              Row(children: [
                Text(
                  widget.header!,
                  style: TextStyle(
                      color: AsianPaintColors.whiteColor,
                      fontWeight: FontWeight.w500,
                      fontFamily: AsianPaintsFonts.bathSansRegular),
                ),
              ]),
              Row(
                children: [
                  Visibility(
                    visible: widget.isVisible,
                    maintainAnimation: widget.isVisible,
                    maintainSize: widget.isVisible,
                    maintainState: widget.isVisible,
                    child: SvgPicture.asset(
                      'assets/images/cart.svg',
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  SvgPicture.asset('assets/images/search.svg'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _shoppingCartBadge(
      List<SKUData> skuData, String category, String brand, String range) {
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: 0, end: 3),
      showBadge: _showCartBadge,
      badgeColor: color,
      badgeContent: Text(
        widget.cartBadgeAmount.toString(),
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

  @override
  Size get preferredSize => const Size.fromHeight(55);

  void showPopuMenu(BuildContext context) async {
    await showMenu(
      elevation: 0.0,
      surfaceTintColor: Colors.white,

      // shadowColor: Colors.white,

      //color: Colors.amber,
      constraints: const BoxConstraints.tightForFinite(width: 215),
      context: context,
      position: const RelativeRect.fromLTRB(
        545,
        45,
        70,
        0,
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 1,
          child: Container(
            margin: const EdgeInsets.all(0),

            // decoration: BoxDecoration(
            //     border: Border.all(color: AsianPaintColors.appBackgroundColor),
            //     borderRadius: BorderRadius.all(Radius.circular(10))),
            // width: 150,
            padding: const EdgeInsets.all(0),
            child: Transform(
              transform: Matrix4.translationValues(0, -10, 0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                elevation: 20,
                margin: const EdgeInsets.all(0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 215,
                      //color: AsianPaintColors.kPrimaryColor,
                      margin: const EdgeInsets.symmetric(vertical: 0.0),
                      decoration: BoxDecoration(
                          color: AsianPaintColors.kPrimaryColor,
                          borderRadius: const BorderRadiusDirectional.only(
                              topStart: Radius.circular(5),
                              bottomStart: Radius.circular(5))),
                      child: const SizedBox(
                          child: Icon(
                        Icons.account_circle,
                        size: 50,
                        color: Color.fromARGB(255, 255, 120, 2),
                      )
                          // child: SvgPicture.asset(
                          //   'assets/images/circle.svg',
                          //   height: 20,

                          //   //color: AsianPaintColors.buttonTextColor,
                          //   //cacheColorFilter: isVisible,
                          // ),
                          ),
                    ),
                    // const SizedBox(
                    //   width: 15,
                    // ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "John Doe",
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: AsianPaintsFonts.mulishBold,
                                color: AsianPaintColors.kPrimaryLightColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 135,
                          child: Divider(
                            height: 20,
                            thickness: 0,
                            color: Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchSocialMediaAppIfInstalled(
                              url:
                                  'https://bathsense.asianpaints.com/home.html', //Instagram
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                SvgPicture.asset('assets/images/web.svg'),
                                // Image(
                                //  image: AssetImage('assets/images/web.svg'),
                                //   width: 10,
                                //   height: 10,
                                // ),

                                //Icon(Icons.web_rounded),

                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Web',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: AsianPaintsFonts.mulishBold,
                                    color: AsianPaintColors.kPrimaryLightColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchSocialMediaAppIfInstalled(
                              url:
                                  'https://www.instagram.com/bathsense.asianpaints/', //Instagram
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                SvgPicture.asset('assets/images/instagram.svg'),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Instagram',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: AsianPaintsFonts.mulishBold,
                                    color: AsianPaintColors.kPrimaryLightColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchSocialMediaAppIfInstalled(
                              url:
                                  'https://www.facebook.com/asianpaints.bathsense', //Instagram
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                SvgPicture.asset('assets/images/facebook.svg'),
                                // Icon(
                                //   Icons.facebook_outlined,
                                //   // color: Colors.white,
                                // ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Facebook',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: AsianPaintsFonts.mulishBold,
                                    color: AsianPaintColors.kPrimaryLightColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchSocialMediaAppIfInstalled(
                              url:
                                  'https://www.youtube.com/@bathsense.asianpaints', //Instagram
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                // SvgPicture.asset('assets/images/youtube.svg'),
                                SvgPicture.asset('assets/images/youtube.svg'),
                                const SizedBox(
                                  width: 10,
                                ),

                                Text(
                                  'Youtube',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: AsianPaintsFonts.mulishBold,
                                    color: AsianPaintColors.kPrimaryLightColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const LandingScreen()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                // SvgPicture.asset('assets/images/youtube.svg'),
                                SvgPicture.asset('assets/images/logout.svg'),
                                const SizedBox(
                                  width: 15,
                                ),

                                Text('Log out',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontFamily:
                                            AsianPaintsFonts.mulishMedium,
                                        color: AsianPaintColors
                                            .forgotPasswordTextColor)),
                              ],
                            ),
                          ),
                        ),
                        // GestureDetector(
                        //   onTap: () {
                        //     Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) => const LandingScreen()));
                        //   },
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(0.0),
                        //     child: Row(
                        //       children: [
                        //         SizedBox(
                        //           width: 10,
                        //         ),
                        //         SvgPicture.asset('assets/images/logout.svg'),
                        //         const SizedBox(
                        //           width: 10,
                        //         ),
                        //         Text(
                        //           "Logout",
                        //           style: TextStyle(
                        //               fontSize: 15,
                        //               fontFamily: AsianPaintsFonts.mulishMedium,
                        //               color: AsianPaintColors
                        //                   .forgotPasswordTextColor),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value != null) print(value);
    });
  }
}

Future<void> _launchSocialMediaAppIfInstalled({
  required String url,
}) async {
  try {
    bool launched =
        await launch(url, forceSafariVC: false); // Launch the app if installed!

    if (!launched) {
      launch(url); // Launch web view if app is not installed!
    }
  } catch (e) {
    launch(url); // Launch web view if app is not installed!
  }
}

// searchbar

class SearchListWeb extends SearchDelegate<List> {
  SearchListBloc searchBloc;
  SearchListWeb({required this.searchBloc});
  String? queryString;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(
            Icons.clear,
            color: AsianPaintColors.kPrimaryColor,
          ),
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
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SearchError) {
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
        // if (state is SearchUninitialized) {
        //   return const Center(child: CircularProgressIndicator());
        // }
        List<SKUData> skuData = [];
        if (state is SearchError) {
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

          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: GridView.builder(

                // shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  // childAspectRatio: 3 / 2.6,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
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
                            category:
                                state.searchResponseModel[index].sKUCATEGORY ??
                                    '',
                            brand: state.searchResponseModel[index].sKUBRAND,
                            range: state.searchResponseModel[index].sKURANGE,
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
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Image.network(
                                (images[index]).isEmpty
                                    ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
                                    : images[index],
                                width: MediaQuery.of(context).size.width * 0.4,
                                height:
                                    MediaQuery.of(context).size.height * 0.18,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    results[index],
                                    style: TextStyle(
                                        color: AsianPaintColors
                                            .chooseYourAccountColor,
                                        fontSize: 12,
                                        fontFamily:
                                            AsianPaintsFonts.mulishBold),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    descriptions[index],
                                    style: TextStyle(
                                        color: AsianPaintColors
                                            .skuDescriptionColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            AsianPaintsFonts.mulishRegular),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    productDescriptors[index],
                                    style: TextStyle(
                                        color: AsianPaintColors
                                            .skuDescriptionColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            AsianPaintsFonts.mulishRegular),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
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
                                        fontFamily:
                                            AsianPaintsFonts.mulishBold),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ),
                  );
                }),
          );
        }
        return const Scaffold();
      },
    );
  }
}
