import 'dart:convert';
import 'dart:io';

import 'package:APaints_QGen/src/core/utils/colors.dart';

import 'package:APaints_QGen/src/core/utils/enums/create_existing_flip.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/sku_request_model.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/data/models/template_quote/template_quote_list_response.dart';
import 'package:APaints_QGen/src/data/models/template_quote/template_quote_results_response.dart';
import 'package:APaints_QGen/src/presentation/blocs/template_quote/search_list/template_quote_list_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/template_quote/search_list/template_quote_list_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/template_quote/search_result/temp_quote_search_result_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/template_quote/search_result/temp_quote_search_result_state.dart';
import 'package:APaints_QGen/src/presentation/views/loading/loading_screen.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/view_quote.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/elevated_button.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TemplateQuoteUi extends StatefulWidget {
  const TemplateQuoteUi({Key? key}) : super(key: key);

  @override
  State<TemplateQuoteUi> createState() => TemplateQuoteUiState();
}

class TemplateQuoteUiState extends State<TemplateQuoteUi> {
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  int? cartBadgeAmount;

  String? category;
  String? brand;
  String? range;
  List<SKUData>? skuData;
  bool? _showCartBadge;
  Color color = Colors.red;

  final secureStorageProvider = getSingleton<SecureStorageProvider>();

  List<TempQuoteSearchResultsData>? tempQuoteResultsData = [];
  List<Sanwaredata>? sanwareData = [];

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
    logger('Cart amount in template: $cartBadgeAmount');
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

  String? brandName = '';
  String? rangeName = '';
  String? bundleType = '';
  String? sanwareType = '';
  @override
  Widget build(BuildContext context) {
    List<String> brandsList = <String>[];
    List<String> rangesList = <String>[];
    List<String> bundleTypesList = <String>[];
    List<String> sanwareTypesList = <String>[];
    List<Rangesdata> rangesData = [];

    Map<String, List<BUNDLERANGE>>? brandsMap = {};

    @override
    initState() {
      setState(() {
        tempQuoteResultsData = [];
        sanwareData = [];
      });
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

    return WillPopScope(
      onWillPop: onWillPopLogout,
      child: FutureBuilder(
        initialData: initState(),
        future: getCartCount(),
        builder: (context, snapshot) {
          return BlocProvider(
            create: (context) =>
                TemplateQuoteListBloc()..getTemplateQuoteList(token: ''),
            child: BlocConsumer<TemplateQuoteListBloc, TemplateQuoteListState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is TemplateQuoteListLoading) {
                  const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is TemplateQuoteListLoaded) {
                  TemplateQuoteListBloc templateQuoteListBloc =
                      context.read<TemplateQuoteListBloc>();
                  getData() async {
                    brandsList.clear();
                    for (int i = 0;
                        i <
                            (templateQuoteListBloc
                                        .templateQuoteListResponse?.data ??
                                    [])
                                .length;
                        i++) {
                      brandsMap[templateQuoteListBloc.templateQuoteListResponse
                              ?.data?[i].bUNDLEBRAND ??
                          ''] = templateQuoteListBloc.templateQuoteListResponse
                              ?.data?[i].bUNDLERANGE ??
                          [];
                      // if (brandsList.isNotEmpty) {
                      //   if (!brandsList.contains(templateQuoteListBloc
                      //       .templateQuoteListResponse?.bUNDLEBRAND?[i])) {
                      //     brandsList.add(templateQuoteListBloc
                      //             .templateQuoteListResponse
                      //             ?.bUNDLEBRAND?[i] ??
                      //         '');
                      //     break;
                      //   }
                      // } else {
                      //   brandsList.add(templateQuoteListBloc
                      //           .templateQuoteListResponse
                      //           ?.bUNDLEBRAND?[i] ??
                      //       '');
                      // }

                      logger('Bundle Name: ${bundleTypesList.length}');
                    }
                    rangesList.clear();
                    rangesList.clear();
                    logger('Brand Name: $brandName');
                    if ((brandName ?? '').isEmpty) {
                      for (int i = 0;
                          i <
                              (templateQuoteListBloc.templateQuoteListResponse
                                          ?.rangesdata ??
                                      [])
                                  .length;
                          i++) {
                        rangesData.add((templateQuoteListBloc
                                .templateQuoteListResponse?.rangesdata ??
                            [])[i]);
                      }
                      for (int i = 0; i < (rangesData).length; i++) {
                        rangesList.add(rangesData[i].bUNDLERANGE ?? '');
                      }

                      for (int i = 0; i < rangesData.length; i++) {
                        if (rangesData[i].bUNDLERANGE == rangeName) {
                          logger(
                              'Bundle map list in if: ${json.encode(brandsMap[brandName]?[i].bUNDLENAME)}');
                          bundleTypesList = rangesData[i].bUNDLENAME ?? [];
                          sanwareTypesList = rangesData[i].sANWARETYPES ?? [];
                        }
                      }
                    } else {
                      for (int i = 0;
                          i < (brandsMap[brandName] ?? []).length;
                          i++) {
                        rangesList
                            .add(brandsMap[brandName]?[i].bUNDLERANGE ?? '');
                      }

                      for (int i = 0;
                          i < (brandsMap[brandName] ?? []).length;
                          i++) {
                        if (brandsMap[brandName]?[i].bUNDLERANGE == rangeName) {
                          logger(
                              'Bundle map list: ${json.encode(brandsMap[brandName]?[i].bUNDLENAME)}');
                          bundleTypesList =
                              brandsMap[brandName]?[i].bUNDLENAME ?? [];
                          sanwareTypesList =
                              brandsMap[brandName]?[i].sANWARETYPES ?? [];
                        }
                      }
                    }

                    logger('Brands List: ${json.encode(brandsList)}');
                    logger('Ranges List: ${json.encode(rangesList)}');
                    logger('Bundle List: ${json.encode(bundleTypesList)}');
                    logger('Sanware List: ${json.encode(sanwareTypesList)}');
                  }

                  return FutureBuilder(
                    future: getData(),
                    builder: (context, snapshot) {
                      GetTempQuoteSearchResultBloc tempQuoteSearchResultBloc =
                          context.read<GetTempQuoteSearchResultBloc>();
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(
                            child: SizedBox(
                                height: 80,
                                width: 80,
                                child: CircularProgressIndicator(
                                  color: AsianPaintColors.buttonTextColor,
                                )),
                          );
                        case ConnectionState.done:
                          return Scaffold(
                            backgroundColor:
                                AsianPaintColors.appBackgroundColor,
                            body: SingleChildScrollView(
                              // scrollDirection: Axis.horizontal,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(children: [
                                      SizedBox(
                                        height: 70,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        child: LayoutBuilder(
                                          builder:
                                              (_, BoxConstraints constraints) =>
                                                  Autocomplete<String>(
                                            initialValue: TextEditingValue(
                                                text: brandName ?? ''),
                                            optionsMaxHeight: 100,
                                            fieldViewBuilder: (BuildContext
                                                    context,
                                                TextEditingController
                                                    textEditingController,
                                                FocusNode focusNode,
                                                VoidCallback onFieldSubmitted) {
                                              return TextField(
                                                controller:
                                                    textEditingController,
                                                focusNode: focusNode,
                                                style: TextStyle(
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishRegular,
                                                    fontSize: 12,
                                                    color: AsianPaintColors
                                                        .skuDescriptionColor),
                                                decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                        borderSide: BorderSide(
                                                            color: AsianPaintColors
                                                                .dialogBorder)),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                        borderSide: BorderSide(
                                                            color: AsianPaintColors
                                                                .dialogBorder)),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                        borderSide: BorderSide(
                                                            color: AsianPaintColors
                                                                .dialogBorder)),
                                                    hintText: 'Select Brand',
                                                    hintStyle:
                                                        const TextStyle(fontSize: 12),
                                                    suffixIcon: Icon(
                                                      Icons.search,
                                                      color: Colors.grey[600],
                                                    )),
                                              );
                                            },
                                            //optionsMaxHeight: 500,
                                            optionsViewBuilder: (
                                              context,
                                              onSelected,
                                              options,
                                            ) {
                                              return Material(
                                                child: ListView.separated(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final option = options
                                                        .elementAt(index);

                                                    return option
                                                            .toString()
                                                            .isNotEmpty
                                                        ? ListTile(
                                                            focusNode:
                                                                FocusNode(),
                                                            title: Text(
                                                              option.toString(),
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishRegular,
                                                                  fontSize: 12),
                                                            ),
                                                            style: ListTileStyle
                                                                .list,
                                                            onTap: () {
                                                              onSelected(
                                                                  option);
                                                            },
                                                          )
                                                        : null;
                                                  },
                                                  separatorBuilder: (context,
                                                          index) =>
                                                      const Divider(height: 1),
                                                  itemCount: options.length,
                                                ),
                                              );
                                            },
                                            onSelected: (user) {
                                              // brandName = user;
                                              brandName = user;

                                              rangesList.clear();
                                              setState(() {
                                                rangeName = '';
                                                bundleType = '';
                                                sanwareType = '';
                                                tempQuoteResultsData = [];
                                              });

                                              for (int i = 0;
                                                  i <
                                                      (brandsMap[brandName] ??
                                                              [])
                                                          .length;
                                                  i++) {
                                                rangesList.add(
                                                    brandsMap[brandName]?[i]
                                                            .bUNDLERANGE ??
                                                        '');
                                              }

                                              if ((rangeName ?? '').isEmpty) {
                                                tempQuoteResultsData = [];

                                                return;
                                              } else if ((bundleType ?? '')
                                                  .isEmpty) {
                                                tempQuoteResultsData = [];

                                                return;
                                              } else {
                                                tempQuoteSearchResultBloc
                                                    .getTempQuoteSearchList(
                                                        brandName:
                                                            brandName ?? '',
                                                        rangeName:
                                                            rangeName ?? '',
                                                        bundleType:
                                                            bundleType ?? '',
                                                        sanwareType:
                                                            sanwareType ?? '');
                                              }
                                            },
                                            displayStringForOption: ((user) =>
                                                user),

                                            optionsBuilder: (TextEditingValue
                                                textEditingValue) {
                                              brandName = textEditingValue.text;
                                              // if ((rangeName ?? '').isEmpty) {
                                              //   FlutterToastProvider().show(
                                              //       message:
                                              //           "Please select Range");
                                              //   // setState(() {
                                              //   tempQuoteResultsData = [];
                                              //   // });
                                              //   return const Iterable<
                                              //       String>.empty();
                                              // } else if ((bundleType ?? '')
                                              //     .isEmpty) {
                                              //   FlutterToastProvider().show(
                                              //       message:
                                              //           "Please select Bundle");
                                              //   // setState(() {
                                              //   tempQuoteResultsData = [];
                                              //   // });
                                              //   return const Iterable<
                                              //       String>.empty();
                                              // } else {
                                              return (brandsMap.keys).where(
                                                  (ele) => ele
                                                      .toLowerCase()
                                                      .startsWith(
                                                          textEditingValue.text
                                                              .toLowerCase()));
                                              // }
                                            },
                                            // onSelected: (String selection) {
                                            //   debugPrint('You just selected $selection');
                                            // },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      SizedBox(
                                        height: 70,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        child: LayoutBuilder(
                                          builder:
                                              (_, BoxConstraints constraints) =>
                                                  Autocomplete<String>(
                                            // optionsMaxHeight: 100,
                                            initialValue: TextEditingValue(
                                                text: rangeName ?? ''),
                                            fieldViewBuilder: (BuildContext
                                                    context,
                                                TextEditingController
                                                    textEditingController,
                                                FocusNode focusNode,
                                                VoidCallback onFieldSubmitted) {
                                              return TextField(
                                                controller:
                                                    textEditingController,
                                                focusNode: focusNode,
                                                style: TextStyle(
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishRegular,
                                                    fontSize: 12,
                                                    color: AsianPaintColors
                                                        .skuDescriptionColor),
                                                decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                        borderSide: BorderSide(
                                                            color: AsianPaintColors
                                                                .dialogBorder)),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                        borderSide: BorderSide(
                                                            color: AsianPaintColors
                                                                .dialogBorder)),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        borderSide: BorderSide(
                                                            color: AsianPaintColors
                                                                .dialogBorder)),
                                                    hintText: 'Select Range*',
                                                    suffixText: '*',
                                                    suffixStyle: const TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                    hintStyle: const TextStyle(fontSize: 12),
                                                    suffixIcon: Icon(
                                                      Icons.search,
                                                      color: Colors.grey[600],
                                                    )),
                                                // onSubmitted: (value) {
                                                //   if ((rangeName ?? '')
                                                //       .isEmpty) {
                                                //     FlutterToastProvider().show(
                                                //         message:
                                                //             "Please select Range");
                                                //     setState(() {
                                                //       tempQuoteResultsData = [];
                                                //     });
                                                //   } else if ((bundleType ?? '')
                                                //       .isEmpty) {
                                                //     FlutterToastProvider().show(
                                                //         message:
                                                //             "Please select Bundle");
                                                //     setState(() {
                                                //       tempQuoteResultsData = [];
                                                //     });
                                                //   }
                                                // },
                                              );
                                            },
                                            //optionsMaxHeight: 500,
                                            optionsViewBuilder: (
                                              context,
                                              onSelected,
                                              options,
                                            ) {
                                              return Material(
                                                child: ListView.separated(
                                                    padding: EdgeInsets.zero,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final option = options
                                                          .elementAt(index);

                                                      return ListTile(
                                                        title: Text(
                                                          option.toString(),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  AsianPaintsFonts
                                                                      .mulishRegular,
                                                              fontSize: 12),
                                                        ),
                                                        onTap: () {
                                                          onSelected(option);
                                                        },
                                                      );
                                                    },
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            const Divider(),
                                                    itemCount: options.length),
                                              );
                                            },
                                            onSelected: (user) {
                                              rangeName = user;

                                              setState(() {
                                                bundleType = '';
                                                sanwareType = '';
                                                tempQuoteResultsData = [];
                                              });
                                            },
                                            displayStringForOption: ((user) =>
                                                user),

                                            optionsBuilder: (TextEditingValue
                                                textEditingValue) {
                                              rangeName = textEditingValue.text;
                                              return (rangesList).where((ele) =>
                                                  ele.toLowerCase().startsWith(
                                                      textEditingValue.text
                                                          .toLowerCase()));
                                            },
                                            // onSelected: (String selection) {
                                            //   debugPrint('You just selected $selection');
                                            // },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      SizedBox(
                                        height: 70,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        child: LayoutBuilder(
                                          builder:
                                              (_, BoxConstraints constraints) =>
                                                  Autocomplete<String>(
                                            // optionsMaxHeight: 100,
                                            initialValue: TextEditingValue(
                                                text: bundleType ?? ''),
                                            fieldViewBuilder: (BuildContext
                                                    context,
                                                TextEditingController
                                                    textEditingController,
                                                FocusNode focusNode,
                                                VoidCallback onFieldSubmitted) {
                                              return TextField(
                                                controller:
                                                    textEditingController,
                                                focusNode: focusNode,
                                                style: TextStyle(
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishRegular,
                                                    fontSize: 12,
                                                    color: AsianPaintColors
                                                        .skuDescriptionColor),
                                                decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                        borderSide: BorderSide(
                                                            color: AsianPaintColors
                                                                .dialogBorder)),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                        borderSide: BorderSide(
                                                            color: AsianPaintColors
                                                                .dialogBorder)),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        borderSide: BorderSide(
                                                            color: AsianPaintColors
                                                                .dialogBorder)),
                                                    hintText: 'Bundle Type*',
                                                    suffixText: '*',
                                                    suffixStyle: const TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                    hintStyle: const TextStyle(fontSize: 12),
                                                    suffixIcon: Icon(
                                                      Icons.search,
                                                      color: Colors.grey[600],
                                                    )),
                                                onSubmitted: (value) {
                                                  if ((rangeName ?? '')
                                                      .isEmpty) {
                                                    FlutterToastProvider().show(
                                                        message:
                                                            "Please select Range");
                                                    setState(() {
                                                      tempQuoteResultsData = [];
                                                    });
                                                  } else if ((bundleType ?? '')
                                                      .isEmpty) {
                                                    FlutterToastProvider().show(
                                                        message:
                                                            "Please select Bundle");
                                                    setState(() {
                                                      tempQuoteResultsData = [];
                                                    });
                                                  }
                                                },
                                              );
                                            },
                                            //optionsMaxHeight: 500,
                                            optionsViewBuilder: (
                                              context,
                                              onSelected,
                                              options,
                                            ) {
                                              return Material(
                                                child: ListView.separated(
                                                    padding: EdgeInsets.zero,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final option = options
                                                          .elementAt(index);

                                                      return ListTile(
                                                        title: Text(
                                                          option.toString(),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  AsianPaintsFonts
                                                                      .mulishRegular,
                                                              fontSize: 12),
                                                        ),
                                                        onTap: () {
                                                          onSelected(option);
                                                        },
                                                      );
                                                    },
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            const Divider(),
                                                    itemCount: options.length),
                                              );
                                            },
                                            onSelected: (user) {
                                              bundleType = user;
                                              setState(() {
                                                sanwareType = '';
                                                tempQuoteResultsData = [];
                                              });
                                              if ((rangeName ?? '').isEmpty) {
                                                // FlutterToastProvider()
                                                //     .show(
                                                //         message:
                                                //             "Please select Range");
                                              } else {
                                                tempQuoteSearchResultBloc
                                                    .getTempQuoteSearchList(
                                                        brandName:
                                                            brandName ?? '',
                                                        rangeName:
                                                            rangeName ?? '',
                                                        bundleType:
                                                            bundleType ?? '',
                                                        sanwareType:
                                                            sanwareType ?? '');
                                              }
                                            },
                                            displayStringForOption: ((user) =>
                                                user),

                                            optionsBuilder: (TextEditingValue
                                                textEditingValue) {
                                              bundleType =
                                                  textEditingValue.text;
                                              return (bundleTypesList).where(
                                                  (ele) => ele
                                                      .toLowerCase()
                                                      .startsWith(
                                                          textEditingValue.text
                                                              .toLowerCase()));
                                            },
                                            // onSelected: (String selection) {
                                            //   debugPrint('You just selected $selection');
                                            // },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      SizedBox(
                                        height: 70,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        child: LayoutBuilder(
                                          builder:
                                              (_, BoxConstraints constraints) =>
                                                  Autocomplete<String>(
                                            // optionsMaxHeight: 100,
                                            fieldViewBuilder: (BuildContext
                                                    context,
                                                TextEditingController
                                                    textEditingController,
                                                FocusNode focusNode,
                                                VoidCallback onFieldSubmitted) {
                                              return TextField(
                                                controller:
                                                    textEditingController,
                                                focusNode: focusNode,
                                                style: TextStyle(
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishRegular,
                                                    fontSize: 12,
                                                    color: AsianPaintColors
                                                        .skuDescriptionColor),
                                                decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                        borderSide: BorderSide(
                                                            color: AsianPaintColors
                                                                .dialogBorder)),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                        borderSide: BorderSide(
                                                            color: AsianPaintColors
                                                                .dialogBorder)),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                        borderSide: BorderSide(
                                                            color: AsianPaintColors
                                                                .dialogBorder)),
                                                    hintText: 'Sanware Type',
                                                    hintStyle:
                                                        const TextStyle(fontSize: 12),
                                                    suffixIcon: Icon(
                                                      Icons.search,
                                                      color: Colors.grey[600],
                                                    )),
                                                onSubmitted: (value) {
                                                  if ((rangeName ?? '')
                                                      .isEmpty) {
                                                    FlutterToastProvider().show(
                                                        message:
                                                            "Please select Range");
                                                    setState(() {
                                                      tempQuoteResultsData = [];
                                                    });
                                                  } else if ((bundleType ?? '')
                                                      .isEmpty) {
                                                    FlutterToastProvider().show(
                                                        message:
                                                            "Please select Bundle");
                                                    setState(() {
                                                      tempQuoteResultsData = [];
                                                    });
                                                  }
                                                },
                                              );
                                            },
                                            //optionsMaxHeight: 500,
                                            optionsViewBuilder: (
                                              context,
                                              onSelected,
                                              options,
                                            ) {
                                              return Material(
                                                child: ListView.separated(
                                                    padding: EdgeInsets.zero,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final option = options
                                                          .elementAt(index);

                                                      return ListTile(
                                                        title: Text(
                                                          option.toString(),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  AsianPaintsFonts
                                                                      .mulishRegular,
                                                              fontSize: 12),
                                                        ),
                                                        onTap: () {
                                                          onSelected(option);
                                                        },
                                                      );
                                                    },
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            const Divider(),
                                                    itemCount: options.length),
                                              );
                                            },
                                            onSelected: (user) {
                                              sanwareType = user;
                                              tempQuoteSearchResultBloc
                                                  .getTempQuoteSearchList(
                                                      brandName:
                                                          brandName ?? '',
                                                      rangeName:
                                                          rangeName ?? '',
                                                      bundleType:
                                                          bundleType ?? '',
                                                      sanwareType:
                                                          sanwareType ?? '');
                                            },
                                            displayStringForOption: ((user) =>
                                                user),

                                            optionsBuilder: (TextEditingValue
                                                textEditingValue) {
                                              sanwareType =
                                                  textEditingValue.text;
                                              if ((rangeName ?? '').isEmpty) {
                                                FlutterToastProvider().show(
                                                    message:
                                                        "Please select Range");
                                                return const Iterable<
                                                    String>.empty();
                                              }
                                              if ((bundleType ?? '').isEmpty) {
                                                FlutterToastProvider().show(
                                                    message:
                                                        "Please select Bundle");
                                                return const Iterable<
                                                    String>.empty();
                                              } else {
                                                return (sanwareTypesList).where(
                                                    (ele) => ele
                                                        .toLowerCase()
                                                        .startsWith(
                                                            textEditingValue
                                                                .text
                                                                .toLowerCase()));
                                              }
                                            },
                                            // onSelected: (String selection) {
                                            //   debugPrint('You just selected $selection');
                                            // },
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                  BlocConsumer<GetTempQuoteSearchResultBloc,
                                      TempQuoteSearchResultState>(
                                    listener: (context, state) {
                                      logger('----------stateeeee $state');

                                      if (state
                                          is TempQuoteSearchResultLoaded) {
                                        // setState(() {
                                        tempQuoteSearchResultBloc =
                                            context.read<
                                                GetTempQuoteSearchResultBloc>();
                                        // setState(() {
                                        tempQuoteResultsData = [];
                                        sanwareData = [];
                                        // tempQuoteResultsData =
                                        //     tempQuoteSearchResultBloc
                                        //             .templateQuoteResultsListResponse
                                        //             ?.data ??
                                        //         [];
                                        sanwareData = tempQuoteSearchResultBloc
                                                .templateQuoteResultsListResponse
                                                ?.sanwaredata ??
                                            [];
                                        logger(
                                            'Template Results New: ${json.encode(tempQuoteResultsData?.length)}');
                                        for (int i = 0;
                                            i <
                                                (tempQuoteSearchResultBloc
                                                            .templateQuoteResultsListResponse
                                                            ?.data ??
                                                        [])
                                                    .length;
                                            i++) {
                                          TempQuoteSearchResultsData
                                              tempQuoteSearchResultsData =
                                              TempQuoteSearchResultsData();
                                          tempQuoteSearchResultsData
                                                  .bUNDLENAME =
                                              tempQuoteSearchResultBloc
                                                      .templateQuoteResultsListResponse
                                                      ?.data?[i]
                                                      .bUNDLENAME ??
                                                  '';
                                          tempQuoteSearchResultsData
                                              .sKUTYPE = tempQuoteSearchResultBloc
                                                  .templateQuoteResultsListResponse
                                                  ?.data?[i]
                                                  .sKUTYPE ??
                                              '';
                                          tempQuoteSearchResultsData
                                              .sKURANGE = tempQuoteSearchResultBloc
                                                  .templateQuoteResultsListResponse
                                                  ?.data?[i]
                                                  .sKURANGE ??
                                              '';
                                          tempQuoteSearchResultsData
                                              .sKUCODE = tempQuoteSearchResultBloc
                                                  .templateQuoteResultsListResponse
                                                  ?.data?[i]
                                                  .sKUCODE ??
                                              '';
                                          tempQuoteSearchResultsData
                                              .QUANTITY = tempQuoteSearchResultBloc
                                                  .templateQuoteResultsListResponse
                                                  ?.data?[i]
                                                  .QUANTITY ??
                                              '1';
                                          tempQuoteSearchResultsData
                                                  .bUNDLEBRAND =
                                              tempQuoteSearchResultBloc
                                                      .templateQuoteResultsListResponse
                                                      ?.data?[i]
                                                      .bUNDLEBRAND ??
                                                  '';
                                          tempQuoteSearchResultsData
                                                  .bUNDLERANGE =
                                              tempQuoteSearchResultBloc
                                                      .templateQuoteResultsListResponse
                                                      ?.data?[i]
                                                      .bUNDLERANGE ??
                                                  '';
                                          tempQuoteSearchResultsData
                                              .sKUIMAGE = tempQuoteSearchResultBloc
                                                  .templateQuoteResultsListResponse
                                                  ?.data?[i]
                                                  .sKUIMAGE ??
                                              '';
                                          tempQuoteSearchResultsData
                                                  .sKUCATEGORY =
                                              tempQuoteSearchResultBloc
                                                  .templateQuoteResultsListResponse
                                                  ?.data?[i]
                                                  .sKUCATEGORY;
                                          tempQuoteSearchResultsData
                                              .cORESKU = tempQuoteSearchResultBloc
                                                  .templateQuoteResultsListResponse
                                                  ?.data?[i]
                                                  .cORESKU ??
                                              '';
                                          tempQuoteSearchResultsData
                                              .sKUUSP = tempQuoteSearchResultBloc
                                                  .templateQuoteResultsListResponse
                                                  ?.data?[i]
                                                  .sKUUSP ??
                                              '';
                                          tempQuoteSearchResultsData
                                                  .sKUCATCODE =
                                              tempQuoteSearchResultBloc
                                                      .templateQuoteResultsListResponse
                                                      ?.data?[i]
                                                      .sKUCATCODE ??
                                                  '';
                                          tempQuoteSearchResultsData
                                                  .sKUPRODUCTCAT =
                                              tempQuoteSearchResultBloc
                                                      .templateQuoteResultsListResponse
                                                      ?.data?[i]
                                                      .sKUPRODUCTCAT ??
                                                  '';
                                          tempQuoteSearchResultsData
                                                  .sKUTYPEEXPANDED =
                                              tempQuoteSearchResultBloc
                                                      .templateQuoteResultsListResponse
                                                      ?.data?[i]
                                                      .sKUTYPEEXPANDED ??
                                                  '';
                                          tempQuoteSearchResultsData
                                                  .sKUDESCRIPTION =
                                              tempQuoteSearchResultBloc
                                                      .templateQuoteResultsListResponse
                                                      ?.data?[i]
                                                      .sKUDESCRIPTION ??
                                                  '';
                                          tempQuoteSearchResultsData
                                              .sKUMRP = tempQuoteSearchResultBloc
                                                  .templateQuoteResultsListResponse
                                                  ?.data?[i]
                                                  .sKUMRP ??
                                              '0';
                                          tempQuoteSearchResultsData
                                                  .dESCRIPTION =
                                              tempQuoteSearchResultBloc
                                                      .templateQuoteResultsListResponse
                                                      ?.data?[i]
                                                      .dESCRIPTION ??
                                                  '';
                                          tempQuoteSearchResultsData
                                              .sKUSRP = tempQuoteSearchResultBloc
                                                  .templateQuoteResultsListResponse
                                                  ?.data?[i]
                                                  .sKUSRP ??
                                              '';
                                          tempQuoteSearchResultsData
                                                  .aREAINFOBJ =
                                              tempQuoteSearchResultBloc
                                                      .templateQuoteResultsListResponse
                                                      ?.data?[i]
                                                      .aREAINFOBJ ??
                                                  [];
                                          tempQuoteSearchResultsData
                                                  .sKUDRAWING =
                                              tempQuoteSearchResultBloc
                                                      .templateQuoteResultsListResponse
                                                      ?.data?[i]
                                                      .sKUDRAWING ??
                                                  '';
                                          tempQuoteSearchResultsData
                                                  .pRODUCTCARDDESCRIPTOR =
                                              tempQuoteSearchResultBloc
                                                      .templateQuoteResultsListResponse
                                                      ?.data?[i]
                                                      .pRODUCTCARDDESCRIPTOR ??
                                                  '';
                                          tempQuoteSearchResultsData
                                              .sKUBRAND = tempQuoteSearchResultBloc
                                                  .templateQuoteResultsListResponse
                                                  ?.data?[i]
                                                  .sKUBRAND ??
                                              '';
                                          tempQuoteSearchResultsData
                                              .aREAINFO = tempQuoteSearchResultBloc
                                                  .templateQuoteResultsListResponse
                                                  ?.data?[i]
                                                  .aREAINFO ??
                                              [];
                                          tempQuoteSearchResultsData
                                                  .sKUTYPEDUP =
                                              tempQuoteSearchResultBloc
                                                      .templateQuoteResultsListResponse
                                                      ?.data?[i]
                                                      .sKUTYPEDUP ??
                                                  '';
                                          tempQuoteSearchResultsData.discount =
                                              0;
                                          tempQuoteSearchResultsData
                                                  .totalPrice =
                                              int.parse(
                                                  '${(tempQuoteSearchResultBloc.templateQuoteResultsListResponse?.data?[i].sKUMRP ?? '0').isEmpty ? '0' : tempQuoteSearchResultBloc.templateQuoteResultsListResponse?.data?[i].sKUMRP}');
                                          tempQuoteSearchResultsData
                                                  .totalPriceAfterDiscount =
                                              int.parse(
                                                  '${(tempQuoteSearchResultBloc.templateQuoteResultsListResponse?.data?[i].sKUMRP ?? '0').isEmpty ? '0' : tempQuoteSearchResultBloc.templateQuoteResultsListResponse?.data?[i].sKUMRP}');
                                          tempQuoteSearchResultsData
                                              .quantity = tempQuoteSearchResultBloc
                                                  .templateQuoteResultsListResponse
                                                  ?.data?[i]
                                                  .QUANTITY ??
                                              '1';
                                          (tempQuoteResultsData ?? [])
                                              .add(tempQuoteSearchResultsData);
                                        }
                                        logger(
                                            'Template Results Before: ${json.encode(tempQuoteResultsData?.length)}');

                                        for (int j = 0;
                                            j < (sanwareData ?? []).length;
                                            j++) {
                                          TempQuoteSearchResultsData
                                              tempQuoteSearchResultsData =
                                              TempQuoteSearchResultsData();
                                          tempQuoteSearchResultsData
                                              .bUNDLENAME = '';
                                          tempQuoteSearchResultsData.sKUTYPE =
                                              sanwareData?[j].sKUTYPE ?? '';
                                          tempQuoteSearchResultsData.sKURANGE =
                                              sanwareData?[j].sKURANGE ?? '';
                                          tempQuoteSearchResultsData.sKUCODE =
                                              sanwareData?[j].sKUCODE ?? '';
                                          tempQuoteSearchResultsData
                                                  .bUNDLEBRAND =
                                              sanwareData?[j].sKUBRAND ?? '';
                                          tempQuoteSearchResultsData
                                                  .bUNDLERANGE =
                                              sanwareData?[j].sKURANGE ?? '';
                                          tempQuoteSearchResultsData.sKUIMAGE =
                                              sanwareData?[j].sKUIMAGE ?? '';
                                          tempQuoteSearchResultsData
                                                  .sKUCATEGORY =
                                              sanwareData?[j].sKUCATEGORY ?? '';
                                          tempQuoteSearchResultsData.cORESKU =
                                              sanwareData?[j].sKUCODE ?? '';
                                          tempQuoteSearchResultsData.sKUUSP =
                                              sanwareData?[j].sKUUSP ?? '';
                                          tempQuoteSearchResultsData
                                                  .sKUCATCODE =
                                              sanwareData?[j].sKUCATCODE ?? '';
                                          tempQuoteSearchResultsData
                                                  .sKUPRODUCTCAT =
                                              sanwareData?[j].sKUPRODUCTCAT ??
                                                  '';
                                          tempQuoteSearchResultsData
                                                  .sKUTYPEEXPANDED =
                                              sanwareData?[j].sKUTYPEEXPANDED ??
                                                  '';
                                          tempQuoteSearchResultsData
                                                  .sKUDESCRIPTION =
                                              sanwareData?[j].sKUDESCRIPTION ??
                                                  '';
                                          tempQuoteSearchResultsData.sKUMRP =
                                              sanwareData?[j].sKUMRP ?? '';
                                          tempQuoteSearchResultsData
                                                  .dESCRIPTION =
                                              sanwareData?[j].sKUDESCRIPTION ??
                                                  '';
                                          tempQuoteSearchResultsData.sKUSRP =
                                              sanwareData?[j].sKUSRP ?? '';
                                          tempQuoteSearchResultsData
                                                  .aREAINFOBJ =
                                              sanwareData?[j].aREAINFOBJ ?? [];
                                          tempQuoteSearchResultsData
                                                  .sKUDRAWING =
                                              sanwareData?[j].sKUDRAWING ?? '';
                                          tempQuoteSearchResultsData
                                                  .pRODUCTCARDDESCRIPTOR =
                                              sanwareData?[j]
                                                      .pRODUCTCARDDESCRIPTOR ??
                                                  '';
                                          tempQuoteSearchResultsData.sKUBRAND =
                                              sanwareData?[j].sKUBRAND ?? '';
                                          tempQuoteSearchResultsData.aREAINFO =
                                              sanwareData?[j].aREAINFO ?? [];
                                          tempQuoteSearchResultsData
                                                  .sKUTYPEDUP =
                                              sanwareData?[j].sKUTYPE ?? '';
                                          tempQuoteSearchResultsData.discount =
                                              0;
                                          tempQuoteSearchResultsData.quantity =
                                              '1';
                                          tempQuoteSearchResultsData
                                                  .totalPrice =
                                              int.parse(
                                                  sanwareData?[j].sKUMRP ?? '');
                                          tempQuoteSearchResultsData
                                                  .totalPriceAfterDiscount =
                                              int.parse(
                                                  sanwareData?[j].sKUMRP ?? '');
                                          (tempQuoteResultsData ?? [])
                                              .add(tempQuoteSearchResultsData);
                                          logger(
                                              'Template Results After: ${json.encode(tempQuoteResultsData?.length)}');
                                        }
                                        // });
                                      }
                                    },
                                    builder: (context, state) {
                                      if (state
                                          is TempQuoteSearchResultLoading) {
                                        return Column(
                                          children: const [
                                            SizedBox(
                                              height: 200,
                                            ),
                                            Center(
                                                child: SizedBox(
                                                    height: 50,
                                                    width: 50,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.red,
                                                    ))),
                                          ],
                                        );
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 10, 0, 0),
                                        child: Column(
                                          children: [
                                            (tempQuoteResultsData ?? [])
                                                    .isNotEmpty
                                                ? Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            1.1,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 100,
                                                            right: 100),
                                                    child: GridView.builder(
                                                      shrinkWrap: true,
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        crossAxisSpacing: 2,
                                                        mainAxisSpacing: 2,
                                                        childAspectRatio:
                                                            (1 / .6),
                                                      ),
                                                      itemCount:
                                                          (tempQuoteResultsData ??
                                                                  [])
                                                              .length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                                  index) =>
                                                              Card(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          child: Row(
                                                            // mainAxisAlignment:
                                                            //     MainAxisAlignment
                                                            //         .start,
                                                            children: [
                                                              Image.network(
                                                                (tempQuoteResultsData?[index].sKUIMAGE ??
                                                                            '')
                                                                        .isEmpty
                                                                    ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
                                                                    : tempQuoteResultsData?[index]
                                                                            .sKUIMAGE ??
                                                                        '',
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.1,
                                                                height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height,
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.22,
                                                                    // height:
                                                                    //     10,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          padding:
                                                                              const EdgeInsets.all(0),
                                                                          child:
                                                                              Text(
                                                                            tempQuoteResultsData?[index].sKUCATCODE ??
                                                                                '',
                                                                            style:
                                                                                TextStyle(
                                                                              color: AsianPaintColors.chooseYourAccountColor,
                                                                              fontFamily: AsianPaintsFonts.mulishMedium,
                                                                              //fontWeight: FontWeight.w600,
                                                                              fontSize: 13,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          padding:
                                                                              const EdgeInsets.all(0),
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () {},
                                                                            child:
                                                                                Image.asset(
                                                                              'assets/images/cancel.png',
                                                                              width: MediaQuery.of(context).size.width * 0.02,
                                                                              height: MediaQuery.of(context).size.height * 0.02,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),

                                                                  SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.22,
                                                                    // height:
                                                                    //     10,
                                                                    child: Row(
                                                                      // mainAxisAlignment:
                                                                      //     MainAxisAlignment
                                                                      //         .spaceBetween,
                                                                      children: [
                                                                        Flexible(
                                                                          child:
                                                                              Text(
                                                                            tempQuoteResultsData?[index].sKUDESCRIPTION ??
                                                                                '',
                                                                            style:
                                                                                TextStyle(
                                                                              color: AsianPaintColors.skuDescriptionColor,
                                                                              fontFamily: AsianPaintsFonts.mulishRegular,
                                                                              //fontWeight: FontWeight.w600,
                                                                              fontSize: 10,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          ' \u{20B9} ${(tempQuoteResultsData?[index].sKUMRP ?? '0').isEmpty ? '0' : tempQuoteResultsData?[index].sKUMRP}',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                AsianPaintColors.userTypeTextColor,
                                                                            fontFamily:
                                                                                AsianPaintsFonts.mulishBold,
                                                                            //fontWeight: FontWeight.w600,
                                                                            fontSize:
                                                                                13,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),

                                                                  SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.22,
                                                                    // height:
                                                                    //     10,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Visibility(
                                                                          visible:
                                                                              false,
                                                                          maintainAnimation:
                                                                              true,
                                                                          maintainInteractivity:
                                                                              false,
                                                                          maintainSize:
                                                                              true,
                                                                          maintainState:
                                                                              true,
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Text(
                                                                                'Add Discount',
                                                                                style: TextStyle(
                                                                                  color: AsianPaintColors.quantityColor,
                                                                                  fontFamily: AsianPaintsFonts.mulishMedium,
                                                                                  //fontWeight: FontWeight.w600,
                                                                                  fontSize: 10,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 8,
                                                                              ),
                                                                              SizedBox(
                                                                                height: 10,
                                                                                width: MediaQuery.of(context).size.width * 0.032,
                                                                                child: TextField(
                                                                                  inputFormatters: <TextInputFormatter>[
                                                                                    LengthLimitingTextInputFormatter(2),
                                                                                    FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                                                                  ],
                                                                                  controller: TextEditingController.fromValue(
                                                                                    TextEditingValue(
                                                                                      text: (tempQuoteResultsData?[index].discount ?? 0).toString(),
                                                                                      selection: TextSelection.fromPosition(
                                                                                        TextPosition(offset: (tempQuoteResultsData?[index].discount ?? 0).toString().length),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  textAlign: TextAlign.center,
                                                                                  style: TextStyle(backgroundColor: AsianPaintColors.whiteColor, fontSize: 10, fontFamily: AsianPaintsFonts.mulishRegular, color: AsianPaintColors.kPrimaryColor),
                                                                                  cursorColor: AsianPaintColors.kPrimaryColor,
                                                                                  decoration: InputDecoration(
                                                                                    suffixText: '%',
                                                                                    suffixStyle: const TextStyle(
                                                                                      fontSize: 10,
                                                                                    ),
                                                                                    fillColor: AsianPaintColors.whiteColor,
                                                                                    filled: true,
                                                                                    border: OutlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: AsianPaintColors.quantityBorder,
                                                                                      ),
                                                                                    ),
                                                                                    enabledBorder: OutlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: AsianPaintColors.quantityBorder,
                                                                                      ),
                                                                                    ),
                                                                                    focusedBorder: OutlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: AsianPaintColors.quantityBorder,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  onChanged: (value) async {
                                                                                    value.isNotEmpty ? (tempQuoteResultsData?[index].discount = int.parse(value)) : (tempQuoteResultsData?[index].discount = 0);
                                                                                    logger("Discount: ${tempQuoteResultsData?[index].discount}");
                                                                                    tempQuoteResultsData?[index].totalPrice = int.parse(tempQuoteResultsData?[index].quantity ?? '0') * int.parse(((tempQuoteResultsData?[index].sKUMRP ?? '').isEmpty ? '0' : tempQuoteResultsData?[index].sKUMRP) ?? '0');

                                                                                    double values = double.parse('${tempQuoteResultsData?[index].totalPrice}') * double.parse('${tempQuoteResultsData?[index].discount}');
                                                                                    double discountAmount = double.parse('${values / 100}');
                                                                                    logger("Discount: $discountAmount");

                                                                                    setState(
                                                                                      () {
                                                                                        tempQuoteResultsData?[index].totalPriceAfterDiscount = ((tempQuoteResultsData?[index].totalPrice) ?? 0) - discountAmount.round();
                                                                                      },
                                                                                    );
                                                                                    // }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              'Total Qty',
                                                                              style: TextStyle(
                                                                                color: AsianPaintColors.quantityColor,
                                                                                fontFamily: AsianPaintsFonts.mulishMedium,
                                                                                //fontWeight: FontWeight.w600,
                                                                                fontSize: 10,
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: MediaQuery.of(context).size.width * 0.01,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 20,
                                                                              height: 25,
                                                                              child: Align(
                                                                                alignment: Alignment.center,
                                                                                child: Text(
                                                                                  '${(tempQuoteResultsData?[index].aREAINFOBJ ?? []).length}',
                                                                                  textAlign: TextAlign.center,
                                                                                  style: TextStyle(fontSize: 10, fontFamily: AsianPaintsFonts.mulishRegular, color: AsianPaintColors.kPrimaryColor),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  // const SizedBox(
                                                                  //   height: 15,
                                                                  // ),
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.22,
                                                                    child: ListView
                                                                        .builder(
                                                                      itemCount: tempQuoteResultsData?[
                                                                              index]
                                                                          .aREAINFOBJ
                                                                          ?.length,
                                                                      shrinkWrap:
                                                                          true,
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              0),
                                                                      physics:
                                                                          const NeverScrollableScrollPhysics(),
                                                                      itemExtent:
                                                                          50,
                                                                      itemBuilder:
                                                                          (context,
                                                                              i) {
                                                                        logger(
                                                                            'Area Length: ${tempQuoteResultsData?[index].aREAINFOBJ?[i].qTY}');
                                                                        return Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(vertical: 3),
                                                                          child: Container(
                                                                              color: AsianPaintColors.textFieldBorderColor,
                                                                              margin: const EdgeInsets.symmetric(vertical: 0),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                    child: Align(
                                                                                      alignment: Alignment.center,
                                                                                      child: Text(
                                                                                        tempQuoteResultsData?[index].aREAINFOBJ?[i].aREA ?? '',
                                                                                        style: TextStyle(
                                                                                          fontSize: 10,
                                                                                          fontFamily: AsianPaintsFonts.mulishRegular,
                                                                                          fontWeight: FontWeight.w400,
                                                                                          color: AsianPaintColors.skuDescriptionColor,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 70,
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                                                                          child: Text(
                                                                                            'Qty',
                                                                                            style: TextStyle(
                                                                                              fontSize: 8,
                                                                                              fontFamily: AsianPaintsFonts.mulishRegular,
                                                                                              fontWeight: FontWeight.w400,
                                                                                              color: AsianPaintColors.quantityColor,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: 40,
                                                                                          height: 25,
                                                                                          child: Align(
                                                                                            alignment: Alignment.center,
                                                                                            child: Text(
                                                                                              '1',
                                                                                              textAlign: TextAlign.center,
                                                                                              style: TextStyle(fontSize: 10, fontFamily: AsianPaintsFonts.mulishRegular, color: AsianPaintColors.kPrimaryColor),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )

                                                                              //
                                                                              ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.22,
                                                                    // height:
                                                                    //     10,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Text(
                                                                          'Total Price : ',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                AsianPaintColors.quantityColor,
                                                                            fontFamily:
                                                                                AsianPaintsFonts.mulishMedium,
                                                                            //fontWeight: FontWeight.w600,
                                                                            fontSize:
                                                                                10,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          '\u{20B9} ${tempQuoteResultsData?[index].totalPriceAfterDiscount}',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                AsianPaintColors.forgotPasswordTextColor,
                                                                            fontFamily:
                                                                                AsianPaintsFonts.mulishBold,
                                                                            //fontWeight: FontWeight.w600,
                                                                            fontSize:
                                                                                15,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            (tempQuoteResultsData ?? [])
                                                    .isNotEmpty
                                                ? Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 50,
                                                            right: 20),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: SizedBox(
                                                          height: 45,
                                                          width: 250,
                                                          child: ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              if ((tempQuoteResultsData ??
                                                                      [])
                                                                  .isNotEmpty) {
                                                                if (Journey
                                                                    .skuResponseLists
                                                                    .isNotEmpty) {
                                                                  showCreateExistingDialog(
                                                                      context);
                                                                } else {
                                                                  calculateSku();
                                                                }
                                                              } else {
                                                                FlutterToastProvider()
                                                                    .show(
                                                                        message:
                                                                            'Data is empty');
                                                              }
                                                            },
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all(
                                                                      AsianPaintColors
                                                                          .kPrimaryColor),
                                                            ),
                                                            child: Text(
                                                              'Export template as new quote',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: AsianPaintColors
                                                                      .whiteColor,
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishBold),
                                                            ),
                                                          )),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            const SizedBox(
                                              height: 10,
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        default:
                          return const SizedBox();
                      }
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          );
        },
      ),
    );
  }

  void showCreateExistingDialog(
    BuildContext context,
  ) {
    bool isCreateQuoteClicked = false;

    CreateOrExistingFlip? character = CreateOrExistingFlip.create;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: SizedBox(
                height: 350,
                width: 300,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 18, 0, 0),
                          child: Text(
                            "Select Option",
                            style: TextStyle(
                              fontFamily: AsianPaintsFonts.bathSansRegular,
                              color: AsianPaintColors.buttonTextColor,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 18, 20, 0),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Image.asset(
                              'assets/images/cancel.png',
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 25, 18, 0),
                          child: Text(
                            "Your quote consist of SKU'S from other modules,",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              fontWeight: FontWeight.w400,
                              color: AsianPaintColors.textFieldLabelColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 3, 18, 0),
                          child: Text(
                            "Please select an option to save your quote",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              fontWeight: FontWeight.w400,
                              color: AsianPaintColors.textFieldLabelColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                horizontalTitleGap: 0,
                                title: Text(
                                  'Create new quote',
                                  style: TextStyle(
                                      color:
                                          AsianPaintColors.textFieldLabelColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          AsianPaintsFonts.mulishRegular),
                                ),
                                leading: Radio<CreateOrExistingFlip>(
                                  activeColor: AsianPaintColors.buttonTextColor,
                                  fillColor: MaterialStatePropertyAll(
                                      AsianPaintColors.buttonTextColor),
                                  value: CreateOrExistingFlip.create,
                                  groupValue: character,
                                  onChanged: (CreateOrExistingFlip? value) {
                                    setState(() {
                                      character = value;
                                      isCreateQuoteClicked = false;
                                      logger(character.toString());
                                    });
                                  },
                                ),
                              ),
                              ListTile(
                                horizontalTitleGap: 0,
                                title: Text(
                                  'Add to existing quote',
                                  style: TextStyle(
                                      color:
                                          AsianPaintColors.textFieldLabelColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          AsianPaintsFonts.mulishRegular),
                                ),
                                leading: Radio<CreateOrExistingFlip>(
                                  activeColor: AsianPaintColors.buttonTextColor,
                                  fillColor: MaterialStatePropertyAll(
                                      AsianPaintColors.buttonTextColor),
                                  value: CreateOrExistingFlip.existing,
                                  groupValue: character,
                                  onChanged: (CreateOrExistingFlip? value) {
                                    setState(() {
                                      character = value;
                                      isCreateQuoteClicked = true;
                                      logger(character.toString());
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: SizedBox(
                                  height: 45,
                                  width: 350,
                                  child: APElevatedButton(
                                    onPressed: () {
                                      if (!isCreateQuoteClicked) {
                                        Journey.skuResponseLists = [];
                                      }
                                      Navigator.pop(context);
                                      calculateSku();
                                    },
                                    label: Text(
                                      AppLocalizations.of(context).save,
                                      style: TextStyle(
                                        fontFamily: AsianPaintsFonts.mulishBold,
                                        color: AsianPaintColors.whiteColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(30, 15, 18, 5),
                                child: Text(
                                  "*Creating new quote will delete existing quote",
                                  style: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishRegular,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: AsianPaintColors
                                        .forgotPasswordTextColor,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void calculateSku() {
    int price = 0;
    List<SKUData> skuDataList = [];
    List<Area> areaInfo = [];

    for (int i = 0; i < (tempQuoteResultsData ?? []).length; i++) {
      SKUData skuData = SKUData();
      skuData.sKURANGE = tempQuoteResultsData?[i].sKURANGE ?? '';
      skuData.sKUIMAGE = tempQuoteResultsData?[i].sKUIMAGE ?? '';
      skuData.sKUCATEGORY = tempQuoteResultsData?[i].sKUCATEGORY ?? '';
      skuData.sKUUSP = tempQuoteResultsData?[i].sKUUSP ?? '';
      skuData.sKUPRODUCTCAT = tempQuoteResultsData?[i].sKUPRODUCTCAT ?? '';
      skuData.sKUDESCRIPTION = tempQuoteResultsData?[i].sKUDESCRIPTION ?? '';
      skuData.complementary = [];
      skuData.sKUMRP = (tempQuoteResultsData?[i].sKUMRP ?? '0').isEmpty
          ? '0'
          : tempQuoteResultsData?[i].sKUMRP ?? '0';
      skuData.sKUCODE = tempQuoteResultsData?[i].sKUCODE ?? '';
      skuData.sKUSRP = tempQuoteResultsData?[i].sKUSRP ?? '';
      skuData.sKUDRAWING = tempQuoteResultsData?[i].sKUDRAWING ?? '';
      skuData.sKUBRAND = tempQuoteResultsData?[i].sKUBRAND ?? '';
      skuData.aREAINFO = (tempQuoteResultsData?[i].aREAINFO ?? []);
      skuData.skuCatCode = tempQuoteResultsData?[i].sKUCATCODE ?? '';
      skuData.sKUTYPE = tempQuoteResultsData?[i].sKUTYPE ?? '';
      skuData.discount = tempQuoteResultsData?[i].discount ?? 0;
      skuData.quantity =
          (tempQuoteResultsData?[i].aREAINFOBJ ?? []).length.toString();
      int quantity = (tempQuoteResultsData?[i].aREAINFOBJ ?? []).length;
      logger('Quanty: $quantity');

      skuData.totalPrice =
          (tempQuoteResultsData?[i].totalPrice ?? 0) * quantity;
      skuData.totalPriceAfterDiscount =
          (tempQuoteResultsData?[i].totalPrice ?? 0) * quantity;
      skuData.index = 0;

      areaInfo = [];

      for (int j = 0;
          j < (tempQuoteResultsData?[i].aREAINFOBJ ?? []).length;
          j++) {
        areaInfo.add(Area(
            areaname: tempQuoteResultsData?[i].aREAINFOBJ?[j].aREA,
            areaqty: '1'));
      }
      skuData.areaInfo = areaInfo;
      skuData.skuTypeExpanded = '';
      skuData.productCardDescriptior = '';
      price += skuData.totalPriceAfterDiscount ?? 0;

      skuDataList.add(skuData);

      Journey.skuResponseLists.add(skuData);
    }

    // if (!isCreateQuoteClicked) {
    //   Journey.skuResponseLists = [];
    // }

    // Journey.skuResponseLists = skuDataList;
    secureStorageProvider.saveQuoteToDisk(Journey.skuResponseLists);
    secureStorageProvider.saveCartDetails(skuDataList);

    secureStorageProvider.saveTotalPrice(price.toString());
    // quantity = 0;
    int quantity = 0;
    int cartCount = 0;
    setState(
      () {
        for (int i = 0; i < Journey.skuResponseLists.length; i++) {
          quantity += int.parse(Journey.skuResponseLists[i].quantity ?? '');
        }
        cartCount = Journey.skuResponseLists.length;
        secureStorageProvider.saveCartCount(cartCount);
        logger('Cart count: $cartCount');
        logger('Quantity: $quantity');
      },
    );

    FlutterToastProvider().show(message: "Successfully added SKU's to Quote!!");
    // Navigator.pop(context);
    Future.delayed(
      const Duration(seconds: 0),
      () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewQuote(
              catIndex: 0,
              brandIndex: 0,
              rangeIndex: 0,
              category: '',
              brand: '',
              range: '',
              quantity: '',
              skuResponseList: const [],
              fromFlip: false,
            ),
          ),
        );
      },
    );
  }
}
