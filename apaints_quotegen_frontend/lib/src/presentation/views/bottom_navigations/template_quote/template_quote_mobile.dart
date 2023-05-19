import 'dart:convert';
import 'dart:io';

import 'package:APaints_QGen/src/core/utils/enums/create_existing_flip.dart';
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
import 'package:APaints_QGen/src/routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/utils/colors.dart';
import '../../../../core/utils/fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TemplateQuote extends StatefulWidget {
  static const routeName = Routes.TemplateQuoteScreen;

  const TemplateQuote({super.key});
  //double optionsMaxWidth = 100.0;

  @override
  State<TemplateQuote> createState() => _TemplateQuoteState();
}

class _TemplateQuoteState extends State<TemplateQuote> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double optionsMaxWidth = 80.0;

  int? cartBadgeAmount;

  String? category;
  String? brand;
  String? range;
  List<SKUData>? skuData;
  bool? _showCartBadge;
  Color color = Colors.red;

  final secureStorageProvider = getSingleton<SecureStorageProvider>();

  List<String> brandsList = <String>[];
  List<BUNDLERANGE> bundleRangeList = <BUNDLERANGE>[];
  List<String> rangesList = <String>[];

  List<TempQuoteSearchResultsData>? tempQuoteResultsData = [];
  List<Sanwaredata>? sanwareData = [];
  late GetTempQuoteSearchResultBloc tempQuoteSearchResultBloc;
  String? brandName = '';
  String? rangeName = '';
  String? bundleType = '';
  String? sanwareType = '';

  @override
  Widget build(BuildContext context) {
    logger('Brand Name: $brandName');
    Map<String, List<BUNDLERANGE>>? brandsMap = {};
    List<Rangesdata> rangesData = [];

    List<String> brandsList = <String>[];
    List<String> rangesList = <String>[];
    List<String> bundleTypesList = <String>[];
    List<String> sanwareTypesList = <String>[];
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

    @override
    initState() {
      setState(() {
        tempQuoteResultsData = [];
        sanwareData = [];
      });
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

    Future<void> _pullRefresh() async {
      setState(() {
        tempQuoteResultsData = [];
        brandName = '';
        rangeName = '';
        bundleType = '';
        sanwareType = '';
        TemplateQuoteListBloc templateQuoteListBloc =
            context.read<TemplateQuoteListBloc>();
        templateQuoteListBloc.getTemplateQuoteList(token: '');
      });
    }

    showLoaderDialog(BuildContext context) {
      AlertDialog alert = AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            Container(
                margin: const EdgeInsets.only(left: 7),
                child: const Text("Loading...")),
          ],
        ),
      );
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    return WillPopScope(
      onWillPop: onWillPopLogout,
      child: FutureBuilder(
        initialData: initState(),
        future: getCartCount(),
        builder: (context, snapshot) {
          logger('In Template Quote');
          return Scaffold(
            key: scaffoldKey,
            backgroundColor: AsianPaintColors.whiteColor,
            body:
                //  const Center(
                //   child: Text("Template Quote"),
                // )
                RefreshIndicator(
              onRefresh: _pullRefresh,
              child: BlocProvider<TemplateQuoteListBloc>(
                create: (context) {
                  return TemplateQuoteListBloc()
                    ..getTemplateQuoteList(token: '');
                },
                child:
                    BlocConsumer<TemplateQuoteListBloc, TemplateQuoteListState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    if (state is TemplateQuoteListLoading) {
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AsianPaintColors.kPrimaryColor,
                          ),
                        ),
                      );
                    }

                    if (state is TemplateQuoteListLoaded) {
                      // Navigator.pop(context);
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
                          brandsMap[templateQuoteListBloc
                                  .templateQuoteListResponse
                                  ?.data?[i]
                                  .bUNDLEBRAND ??
                              ''] = templateQuoteListBloc
                                  .templateQuoteListResponse
                                  ?.data?[i]
                                  .bUNDLERANGE ??
                              [];

                          logger('Bundle Name: ${bundleTypesList.length}');
                        }

                        rangesList.clear();
                        logger('Brand Name: $brandName');
                        if ((brandName ?? '').isEmpty) {
                          for (int i = 0;
                              i <
                                  (templateQuoteListBloc
                                              .templateQuoteListResponse
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
                              sanwareTypesList =
                                  rangesData[i].sANWARETYPES ?? [];
                            }
                          }
                        } else {
                          for (int i = 0;
                              i < (brandsMap[brandName] ?? []).length;
                              i++) {
                            rangesList.add(
                                brandsMap[brandName]?[i].bUNDLERANGE ?? '');
                          }

                          for (int i = 0;
                              i < (brandsMap[brandName] ?? []).length;
                              i++) {
                            if (brandsMap[brandName]?[i].bUNDLERANGE ==
                                rangeName) {
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
                        logger(
                            'Sanware List: ${json.encode(sanwareTypesList)}');
                      }

                      return FutureBuilder(
                        future: getData(),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return const Center(
                                child: CircularProgressIndicator(),
                              );

                            case ConnectionState.done:
                              return BlocConsumer<GetTempQuoteSearchResultBloc,
                                  TempQuoteSearchResultState>(
                                listener: (context, state) {
                                  if (state is TempQuoteSearchResultLoading) {
                                    showLoaderDialog(context);
                                    // const Center(
                                    //   child: CircularProgressIndicator(),
                                    // );
                                  }
                                  if (state is TempQuoteSearchResultLoaded) {
                                    Navigator.pop(context);
                                    tempQuoteSearchResultBloc = context
                                        .read<GetTempQuoteSearchResultBloc>();
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
                                          .bUNDLENAME = tempQuoteSearchResultBloc
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
                                          .bUNDLEBRAND = tempQuoteSearchResultBloc
                                              .templateQuoteResultsListResponse
                                              ?.data?[i]
                                              .bUNDLEBRAND ??
                                          '';
                                      tempQuoteSearchResultsData
                                          .bUNDLERANGE = tempQuoteSearchResultBloc
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
                                      tempQuoteSearchResultsData.sKUCATEGORY =
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
                                          .sKUCATCODE = tempQuoteSearchResultBloc
                                              .templateQuoteResultsListResponse
                                              ?.data?[i]
                                              .sKUCATCODE ??
                                          '';
                                      tempQuoteSearchResultsData.sKUPRODUCTCAT =
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
                                          .dESCRIPTION = tempQuoteSearchResultBloc
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
                                          .aREAINFOBJ = tempQuoteSearchResultBloc
                                              .templateQuoteResultsListResponse
                                              ?.data?[i]
                                              .aREAINFOBJ ??
                                          [];
                                      tempQuoteSearchResultsData
                                          .sKUDRAWING = tempQuoteSearchResultBloc
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
                                          .sKUTYPEDUP = tempQuoteSearchResultBloc
                                              .templateQuoteResultsListResponse
                                              ?.data?[i]
                                              .sKUTYPEDUP ??
                                          '';
                                      tempQuoteSearchResultsData.discount = 0;
                                      tempQuoteSearchResultsData.totalPrice =
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
                                      tempQuoteSearchResultsData.bUNDLENAME =
                                          '';
                                      tempQuoteSearchResultsData.sKUTYPE =
                                          sanwareData?[j].sKUTYPE ?? '';
                                      tempQuoteSearchResultsData.sKURANGE =
                                          sanwareData?[j].sKURANGE ?? '';
                                      tempQuoteSearchResultsData.sKUCODE =
                                          sanwareData?[j].sKUCODE ?? '';
                                      tempQuoteSearchResultsData.bUNDLEBRAND =
                                          sanwareData?[j].sKUBRAND ?? '';
                                      tempQuoteSearchResultsData.bUNDLERANGE =
                                          sanwareData?[j].sKURANGE ?? '';
                                      tempQuoteSearchResultsData.sKUIMAGE =
                                          sanwareData?[j].sKUIMAGE ?? '';
                                      tempQuoteSearchResultsData.sKUCATEGORY =
                                          sanwareData?[j].sKUCATEGORY ?? '';
                                      tempQuoteSearchResultsData.cORESKU =
                                          sanwareData?[j].sKUCODE ?? '';
                                      tempQuoteSearchResultsData.sKUUSP =
                                          sanwareData?[j].sKUUSP ?? '';
                                      tempQuoteSearchResultsData.sKUCATCODE =
                                          sanwareData?[j].sKUCATCODE ?? '';
                                      tempQuoteSearchResultsData.sKUPRODUCTCAT =
                                          sanwareData?[j].sKUPRODUCTCAT ?? '';
                                      tempQuoteSearchResultsData
                                              .sKUTYPEEXPANDED =
                                          sanwareData?[j].sKUTYPEEXPANDED ?? '';
                                      tempQuoteSearchResultsData
                                              .sKUDESCRIPTION =
                                          sanwareData?[j].sKUDESCRIPTION ?? '';
                                      tempQuoteSearchResultsData.sKUMRP =
                                          sanwareData?[j].sKUMRP ?? '';
                                      tempQuoteSearchResultsData.dESCRIPTION =
                                          sanwareData?[j].sKUDESCRIPTION ?? '';
                                      tempQuoteSearchResultsData.sKUSRP =
                                          sanwareData?[j].sKUSRP ?? '';
                                      tempQuoteSearchResultsData.aREAINFOBJ =
                                          sanwareData?[j].aREAINFOBJ ?? [];
                                      tempQuoteSearchResultsData.sKUDRAWING =
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
                                      tempQuoteSearchResultsData.sKUTYPEDUP =
                                          sanwareData?[j].sKUTYPE ?? '';
                                      tempQuoteSearchResultsData.discount = 0;
                                      tempQuoteSearchResultsData.quantity = '1';
                                      tempQuoteSearchResultsData.totalPrice =
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
                                  GetTempQuoteSearchResultBloc
                                      tempQuoteSearchResultBloc = context
                                          .read<GetTempQuoteSearchResultBloc>();
                                  logger(
                                      '----------------- rangesList $rangesList');
                                  return Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 20, 5, 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Flexible(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(5, 0, 0, 0),
                                                    child: Container(
                                                        height: 60,
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 0, 0, 0),
                                                        child: Center(
                                                            child: Autocomplete(
                                                          initialValue:
                                                              TextEditingValue(
                                                                  text:
                                                                      brandName ??
                                                                          ''),
                                                          optionsBuilder:
                                                              ((TextEditingValue
                                                                  textValue) {
                                                            return (brandsMap
                                                                    .keys)
                                                                .where((ele) => ele
                                                                    .toLowerCase()
                                                                    .startsWith(
                                                                        textValue
                                                                            .text
                                                                            .toLowerCase()));
                                                          }),
                                                          onSelected:
                                                              (selectesString) {
                                                            print(
                                                                selectesString);
                                                            brandName =
                                                                selectesString;

                                                            rangesList.clear();
                                                            setState(() {
                                                              rangeName = '';
                                                              bundleType = '';
                                                              sanwareType = '';
                                                              tempQuoteResultsData =
                                                                  [];
                                                            });

                                                            for (int i = 0;
                                                                i <
                                                                    (brandsMap[brandName] ??
                                                                            [])
                                                                        .length;
                                                                i++) {
                                                              rangesList.add(
                                                                  brandsMap[brandName]
                                                                              ?[
                                                                              i]
                                                                          .bUNDLERANGE ??
                                                                      '');
                                                            }

                                                            if ((rangeName ??
                                                                    '')
                                                                .isEmpty) {
                                                              tempQuoteResultsData =
                                                                  [];

                                                              return;
                                                            } else if ((bundleType ??
                                                                    '')
                                                                .isEmpty) {
                                                              tempQuoteResultsData =
                                                                  [];

                                                              return;
                                                            } else {
                                                              tempQuoteSearchResultBloc.getTempQuoteSearchList(
                                                                  brandName:
                                                                      brandName ??
                                                                          '',
                                                                  rangeName:
                                                                      rangeName ??
                                                                          '',
                                                                  bundleType:
                                                                      bundleType ??
                                                                          '',
                                                                  sanwareType:
                                                                      sanwareType ??
                                                                          '');
                                                            }
                                                          },
                                                          optionsViewBuilder:
                                                              (context,
                                                                  onSelected,
                                                                  options) {
                                                            return Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    3,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2,
                                                                child: Material(
                                                                  child:
                                                                      Scrollbar(
                                                                    child: ListView
                                                                        .separated(
                                                                      padding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      shrinkWrap:
                                                                          true,
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        final option =
                                                                            options.elementAt(index);

                                                                        return option.toString().isNotEmpty
                                                                            ? ListTile(
                                                                                focusNode: FocusNode(),
                                                                                dense: true,
                                                                                visualDensity: const VisualDensity(vertical: -3),
                                                                                title: Text(
                                                                                  option.toString(),
                                                                                  style: TextStyle(fontFamily: AsianPaintsFonts.mulishRegular, fontSize: 11),
                                                                                ),
                                                                                style: ListTileStyle.list,
                                                                                onTap: () {
                                                                                  onSelected(option);
                                                                                },
                                                                              )
                                                                            : null;
                                                                      },
                                                                      separatorBuilder: (context,
                                                                              index) =>
                                                                          const Divider(
                                                                              height: 1),
                                                                      itemCount:
                                                                          options
                                                                              .length,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          fieldViewBuilder: (context,
                                                              textEditingController,
                                                              focusNode,
                                                              onFieldSubmitted) {
                                                            return TextField(
                                                              controller:
                                                                  textEditingController,
                                                              focusNode:
                                                                  focusNode,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishRegular,
                                                                  fontSize: 11,
                                                                  color: AsianPaintColors
                                                                      .skuDescriptionColor),
                                                              decoration:
                                                                  InputDecoration(
                                                                      border: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              30),
                                                                          borderSide: BorderSide(
                                                                              color: AsianPaintColors
                                                                                  .dialogBorder)),
                                                                      focusedBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              30),
                                                                          borderSide: BorderSide(
                                                                              color: AsianPaintColors
                                                                                  .dialogBorder)),
                                                                      enabledBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              30),
                                                                          borderSide: BorderSide(
                                                                              color: AsianPaintColors
                                                                                  .dialogBorder)),
                                                                      hintText:
                                                                          'Select Brand',
                                                                      hintStyle: const TextStyle(
                                                                          fontSize:
                                                                              11),
                                                                      suffixIcon:
                                                                          Icon(
                                                                        Icons
                                                                            .search,
                                                                        color: Colors
                                                                            .grey[600],
                                                                      )),
                                                            );
                                                          },
                                                        ))),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(5, 0, 0, 0),
                                                    child: Container(
                                                        height: 60,
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 0, 0, 0),
                                                        child: Center(
                                                            child: Autocomplete(
                                                          initialValue:
                                                              TextEditingValue(
                                                                  text:
                                                                      rangeName ??
                                                                          ''),
                                                          optionsBuilder:
                                                              ((TextEditingValue
                                                                  textValue) {
                                                            if (textValue
                                                                .text.isEmpty) {
                                                              // setState(() {
                                                              tempQuoteResultsData =
                                                                  [];
                                                              // });
                                                            }
                                                            rangeName =
                                                                textValue.text;
                                                            return (rangesList)
                                                                .where((ele) => ele
                                                                    .toLowerCase()
                                                                    .startsWith(
                                                                        textValue
                                                                            .text
                                                                            .toLowerCase()));
                                                          }),
                                                          onSelected:
                                                              (selectesString) {
                                                            print(
                                                                'Selected String: $selectesString');
                                                            rangeName =
                                                                selectesString;

                                                            setState(() {
                                                              bundleType = '';
                                                              sanwareType = '';
                                                              tempQuoteResultsData =
                                                                  [];
                                                            });
                                                          },
                                                          optionsViewBuilder:
                                                              (context,
                                                                  onSelected,
                                                                  options) {
                                                            return Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child: SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    2.5,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child: Material(
                                                                  child:
                                                                      Scrollbar(
                                                                    thumbVisibility:
                                                                        true,
                                                                    child: ListView.separated(
                                                                        // padding: EdgeInsets.zero,
                                                                        itemBuilder: (context, index) {
                                                                          final option =
                                                                              options.elementAt(index);

                                                                          return ListTile(
                                                                            dense:
                                                                                true,
                                                                            visualDensity:
                                                                                const VisualDensity(vertical: -3),
                                                                            title:
                                                                                Text(
                                                                              option.toString(),
                                                                              style: TextStyle(fontFamily: AsianPaintsFonts.mulishRegular, fontSize: 11),
                                                                            ),
                                                                            onTap:
                                                                                () {
                                                                              onSelected(option);
                                                                            },
                                                                          );
                                                                        },
                                                                        separatorBuilder: (context, index) => const Divider(),
                                                                        itemCount: options.length),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          fieldViewBuilder: (context,
                                                              textEditingController,
                                                              focusNode,
                                                              onFieldSubmitted) {
                                                            return TextField(
                                                              controller:
                                                                  textEditingController,
                                                              focusNode:
                                                                  focusNode,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishRegular,
                                                                  fontSize: 11,
                                                                  color: AsianPaintColors
                                                                      .skuDescriptionColor),
                                                              decoration:
                                                                  InputDecoration(
                                                                      border: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              30),
                                                                          borderSide: BorderSide(
                                                                              color: AsianPaintColors
                                                                                  .dialogBorder)),
                                                                      focusedBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              30),
                                                                          borderSide: BorderSide(
                                                                              color: AsianPaintColors
                                                                                  .dialogBorder)),
                                                                      enabledBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              30),
                                                                          borderSide: BorderSide(
                                                                              color: AsianPaintColors
                                                                                  .dialogBorder)),
                                                                      hintText:
                                                                          'Select Range*',
                                                                      // suffixText:
                                                                      //     '*',
                                                                      // suffixStyle: TextStyle(
                                                                      //     color: AsianPaintColors
                                                                      //         .forgotPasswordTextColor),
                                                                      hintStyle: const TextStyle(
                                                                          fontSize:
                                                                              11),
                                                                      suffixIcon:
                                                                          Icon(
                                                                        Icons
                                                                            .search,
                                                                        color: Colors
                                                                            .grey[600],
                                                                      )),
                                                              onSubmitted:
                                                                  (value) {
                                                                if ((rangeName ??
                                                                        '')
                                                                    .isEmpty) {
                                                                  FlutterToastProvider().show(
                                                                      message:
                                                                          "Please select Range");
                                                                  setState(() {
                                                                    tempQuoteResultsData =
                                                                        [];
                                                                  });
                                                                }
                                                              },
                                                            );
                                                          },
                                                        ))),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            //2nd row
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Flexible(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(5, 0, 0, 0),
                                                    child: Container(
                                                        height: 60,
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 0, 0, 0),
                                                        child: Center(
                                                            child: Autocomplete(
                                                          initialValue:
                                                              TextEditingValue(
                                                                  text:
                                                                      bundleType ??
                                                                          ''),
                                                          optionsBuilder:
                                                              ((TextEditingValue
                                                                  textValue) {
                                                            if (textValue
                                                                .text.isEmpty) {
                                                              // setState(() {
                                                              tempQuoteResultsData =
                                                                  [];
                                                              // });
                                                            }
                                                            bundleType =
                                                                textValue.text;
                                                            return (bundleTypesList)
                                                                .where((ele) => ele
                                                                    .toLowerCase()
                                                                    .startsWith(
                                                                        textValue
                                                                            .text
                                                                            .toLowerCase()));
                                                          }),
                                                          onSelected:
                                                              (selectesString) {
                                                            print(
                                                                selectesString);
                                                            bundleType =
                                                                selectesString;
                                                            setState(() {
                                                              sanwareType = '';
                                                              tempQuoteResultsData =
                                                                  [];
                                                            });
                                                            if ((rangeName ??
                                                                    '')
                                                                .isEmpty) {
                                                              // FlutterToastProvider()
                                                              //     .show(
                                                              //         message:
                                                              //             "Please select Range");
                                                            } else {
                                                              tempQuoteSearchResultBloc.getTempQuoteSearchList(
                                                                  brandName:
                                                                      brandName ??
                                                                          '',
                                                                  rangeName:
                                                                      rangeName ??
                                                                          '',
                                                                  bundleType:
                                                                      bundleType ??
                                                                          '',
                                                                  sanwareType:
                                                                      sanwareType ??
                                                                          '');
                                                            }
                                                          },
                                                          optionsViewBuilder:
                                                              (context,
                                                                  onSelected,
                                                                  options) {
                                                            return Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    3,
                                                                child:
                                                                    RawScrollbar(
                                                                  thumbVisibility:
                                                                      true,
                                                                  child:
                                                                      Material(
                                                                    child: ListView.separated(
                                                                        padding: EdgeInsets.zero,
                                                                        itemBuilder: (context, index) {
                                                                          final option =
                                                                              options.elementAt(index);

                                                                          return ListTile(
                                                                            dense:
                                                                                true,
                                                                            visualDensity:
                                                                                const VisualDensity(vertical: -3),
                                                                            title:
                                                                                Text(
                                                                              option.toString(),
                                                                              style: TextStyle(fontFamily: AsianPaintsFonts.mulishRegular, fontSize: 11),
                                                                            ),
                                                                            onTap:
                                                                                () {
                                                                              onSelected(option);
                                                                            },
                                                                          );
                                                                        },
                                                                        separatorBuilder: (context, index) => const Divider(),
                                                                        itemCount: options.length),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          fieldViewBuilder: (context,
                                                              textEditingController,
                                                              focusNode,
                                                              onFieldSubmitted) {
                                                            return TextField(
                                                              controller:
                                                                  textEditingController,
                                                              focusNode:
                                                                  focusNode,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishRegular,
                                                                  fontSize: 10,
                                                                  color: AsianPaintColors
                                                                      .skuDescriptionColor),
                                                              decoration:
                                                                  InputDecoration(
                                                                      border: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              30),
                                                                          borderSide: BorderSide(
                                                                              color: AsianPaintColors
                                                                                  .dialogBorder)),
                                                                      focusedBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              30),
                                                                          borderSide: BorderSide(
                                                                              color: AsianPaintColors
                                                                                  .dialogBorder)),
                                                                      enabledBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              30),
                                                                          borderSide: BorderSide(
                                                                              color: AsianPaintColors
                                                                                  .dialogBorder)),
                                                                      hintText:
                                                                          'Bundle Type*',
                                                                      hintStyle: const TextStyle(
                                                                          fontSize:
                                                                              11),
                                                                      suffixIcon:
                                                                          Icon(
                                                                        Icons
                                                                            .search,
                                                                        color: Colors
                                                                            .grey[600],
                                                                      )),
                                                              onSubmitted:
                                                                  (value) {
                                                                if ((bundleType ??
                                                                        '')
                                                                    .isEmpty) {
                                                                  FlutterToastProvider().show(
                                                                      message:
                                                                          "Please select Bundle");
                                                                  setState(() {
                                                                    tempQuoteResultsData =
                                                                        [];
                                                                  });
                                                                }
                                                              },
                                                            );
                                                          },
                                                        ))),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(5, 0, 0, 0),
                                                    child: Container(
                                                        height: 60,
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 0, 0, 0),
                                                        child: Center(
                                                            child: Autocomplete(
                                                          // initialValue:
                                                          //     TextEditingValue(
                                                          //         text:
                                                          //             sanwareType ??
                                                          //                 ''),
                                                          optionsBuilder:
                                                              ((TextEditingValue
                                                                  textValue) {
                                                            sanwareType =
                                                                textValue.text;
                                                            if ((rangeName ??
                                                                    '')
                                                                .isEmpty) {
                                                              // FlutterToastProvider()
                                                              //     .show(
                                                              //         message:
                                                              //             "Please select Range");
                                                              return const Iterable<
                                                                  String>.empty();
                                                            }
                                                            if ((bundleType ??
                                                                    '')
                                                                .isEmpty) {
                                                              // FlutterToastProvider()
                                                              //     .show(
                                                              //         message:
                                                              //             "Please select Bundle");
                                                              return const Iterable<
                                                                  String>.empty();
                                                            } else {
                                                              return (sanwareTypesList).where((ele) => ele
                                                                  .toLowerCase()
                                                                  .startsWith(
                                                                      textValue
                                                                          .text
                                                                          .toLowerCase()));
                                                            }
                                                          }),
                                                          onSelected:
                                                              (selectesString) {
                                                            print(
                                                                selectesString);
                                                            sanwareType =
                                                                selectesString;
                                                            tempQuoteSearchResultBloc.getTempQuoteSearchList(
                                                                brandName:
                                                                    brandName ??
                                                                        '',
                                                                rangeName:
                                                                    rangeName ??
                                                                        '',
                                                                bundleType:
                                                                    bundleType ??
                                                                        '',
                                                                sanwareType:
                                                                    sanwareType ??
                                                                        '');
                                                          },
                                                          optionsViewBuilder:
                                                              (context,
                                                                  onSelected,
                                                                  options) {
                                                            return Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child: SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    3,
                                                                child: Material(
                                                                  child:
                                                                      Scrollbar(
                                                                    thumbVisibility:
                                                                        true,
                                                                    child: ListView.separated(
                                                                        padding: EdgeInsets.zero,
                                                                        itemBuilder: (context, index) {
                                                                          final option =
                                                                              options.elementAt(index);

                                                                          return ListTile(
                                                                            dense:
                                                                                true,
                                                                            visualDensity:
                                                                                const VisualDensity(vertical: -3),
                                                                            title:
                                                                                Text(
                                                                              option.toString(),
                                                                              style: TextStyle(fontFamily: AsianPaintsFonts.mulishRegular, fontSize: 11),
                                                                            ),
                                                                            onTap:
                                                                                () {
                                                                              onSelected(option);
                                                                            },
                                                                          );
                                                                        },
                                                                        separatorBuilder: (context, index) => const Divider(),
                                                                        itemCount: options.length),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          fieldViewBuilder: (context,
                                                              textEditingController,
                                                              focusNode,
                                                              onFieldSubmitted) {
                                                            return TextField(
                                                              controller:
                                                                  textEditingController,
                                                              focusNode:
                                                                  focusNode,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishRegular,
                                                                  fontSize: 11,
                                                                  color: AsianPaintColors
                                                                      .skuDescriptionColor),
                                                              decoration:
                                                                  InputDecoration(
                                                                      border: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              30),
                                                                          borderSide: BorderSide(
                                                                              color: AsianPaintColors
                                                                                  .dialogBorder)),
                                                                      focusedBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              30),
                                                                          borderSide: BorderSide(
                                                                              color: AsianPaintColors
                                                                                  .dialogBorder)),
                                                                      enabledBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              30),
                                                                          borderSide: BorderSide(
                                                                              color: AsianPaintColors
                                                                                  .dialogBorder)),
                                                                      hintText:
                                                                          'Sanware Type',
                                                                      hintStyle: const TextStyle(
                                                                          fontSize:
                                                                              11),
                                                                      suffixIcon:
                                                                          Icon(
                                                                        Icons
                                                                            .search,
                                                                        color: Colors
                                                                            .grey[600],
                                                                      )),
                                                              onSubmitted:
                                                                  (value) {
                                                                if ((rangeName ??
                                                                        '')
                                                                    .isEmpty) {
                                                                  FlutterToastProvider().show(
                                                                      message:
                                                                          "Please select Range");
                                                                  setState(() {
                                                                    tempQuoteResultsData =
                                                                        [];
                                                                  });
                                                                } else if ((bundleType ??
                                                                        '')
                                                                    .isEmpty) {
                                                                  FlutterToastProvider().show(
                                                                      message:
                                                                          "Please select Bundle");
                                                                  setState(() {
                                                                    tempQuoteResultsData =
                                                                        [];
                                                                  });
                                                                }
                                                              },
                                                            );
                                                          },
                                                        ))),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        (tempQuoteResultsData ?? []).isNotEmpty
                                            ? StatefulBuilder(
                                                builder: (context, setState) {
                                                return Expanded(
                                                  child: Scrollbar(
                                                    thumbVisibility: true,
                                                    child: ListView.builder(
                                                      physics:
                                                          const AlwaysScrollableScrollPhysics(),
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          (tempQuoteResultsData ??
                                                                  [])
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Card(
                                                          shadowColor:
                                                              AsianPaintColors
                                                                  .bottomTextColor,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            side: BorderSide(
                                                              color: AsianPaintColors
                                                                  .segregationColor,
                                                              width: 1,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          elevation: 0,
                                                          child: ListTile(
                                                            dense: true,
                                                            visualDensity:
                                                                const VisualDensity(
                                                                    vertical:
                                                                        -3),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            tileColor:
                                                                AsianPaintColors
                                                                    .whiteColor,
                                                            leading:
                                                                Image.network(
                                                              (tempQuoteResultsData?[index]
                                                                              .sKUIMAGE ??
                                                                          '')
                                                                      .isEmpty
                                                                  ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
                                                                  : tempQuoteResultsData?[
                                                                              index]
                                                                          .sKUIMAGE ??
                                                                      '',
                                                              width: 60,
                                                              height: 80,
                                                            ),
                                                            subtitle: Column(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          0,
                                                                          5,
                                                                          0,
                                                                          0),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        tempQuoteResultsData?[index].sKUCATCODE ??
                                                                            '',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              AsianPaintColors.chooseYourAccountColor,
                                                                          fontFamily:
                                                                              AsianPaintsFonts.mulishMedium,
                                                                          //fontWeight: FontWeight.w600,
                                                                          fontSize:
                                                                              12,
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {},
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/images/cancel.png',
                                                                          width:
                                                                              12,
                                                                          height:
                                                                              12,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Flexible(
                                                                      child:
                                                                          Text(
                                                                        tempQuoteResultsData?[index].sKUDESCRIPTION ??
                                                                            '',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              AsianPaintColors.skuDescriptionColor,
                                                                          fontFamily:
                                                                              AsianPaintsFonts.mulishRegular,
                                                                          //fontWeight: FontWeight.w600,
                                                                          fontSize:
                                                                              10,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      ' \u{20B9} ${(tempQuoteResultsData?[index].sKUMRP ?? '0').isEmpty ? '0' : tempQuoteResultsData?[index].sKUMRP}',
                                                                      style:
                                                                          TextStyle(
                                                                        color: AsianPaintColors
                                                                            .userTypeTextColor,
                                                                        fontFamily:
                                                                            AsianPaintsFonts.mulishBold,
                                                                        //fontWeight: FontWeight.w600,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Row(
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
                                                                            style:
                                                                                TextStyle(
                                                                              color: AsianPaintColors.quantityColor,
                                                                              fontFamily: AsianPaintsFonts.mulishMedium,
                                                                              //fontWeight: FontWeight.w600,
                                                                              fontSize: 10,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                8,
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                25,
                                                                            width:
                                                                                50,
                                                                            child:
                                                                                TextField(
                                                                              enableInteractiveSelection: false,
                                                                              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
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
                                                                        const SizedBox(
                                                                          width:
                                                                              8,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              20,
                                                                          height:
                                                                              25,
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Text(
                                                                              '${(tempQuoteResultsData?[index].aREAINFOBJ ?? []).length}',
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(fontSize: 10, fontFamily: AsianPaintsFonts.mulishRegular, color: AsianPaintColors.kPrimaryColor),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        // SizedBox(
                                                                        //   height:
                                                                        //       25,
                                                                        //   width:
                                                                        //       50,
                                                                        //   child:
                                                                        //       TextField(
                                                                        //     enableInteractiveSelection:
                                                                        //         false,
                                                                        //         keyboardType: TextInputType.number,
                                                                        //     inputFormatters: <TextInputFormatter>[
                                                                        //       LengthLimitingTextInputFormatter(4),
                                                                        //       FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                                                        //     ],
                                                                        //     controller:
                                                                        //         TextEditingController.fromValue(TextEditingValue(text: (tempQuoteResultsData?[index].quantity ?? 0).toString(), selection: TextSelection.fromPosition(TextPosition(offset: (tempQuoteResultsData?[index].quantity ?? 0).toString().length)))),
                                                                        //     textAlign:
                                                                        //         TextAlign.center,
                                                                        //     style: TextStyle(
                                                                        //         backgroundColor: AsianPaintColors.whiteColor,
                                                                        //         fontSize: 10,
                                                                        //         fontFamily: AsianPaintsFonts.mulishRegular,
                                                                        //         color: AsianPaintColors.kPrimaryColor),
                                                                        //     cursorColor:
                                                                        //         AsianPaintColors.kPrimaryColor,
                                                                        //     decoration:
                                                                        //         InputDecoration(
                                                                        //       fillColor: AsianPaintColors.whiteColor,
                                                                        //       filled: true,
                                                                        //       border: OutlineInputBorder(
                                                                        //         borderSide: BorderSide(
                                                                        //           color: AsianPaintColors.quantityBorder,
                                                                        //         ),
                                                                        //       ),
                                                                        //       enabledBorder: OutlineInputBorder(
                                                                        //         borderSide: BorderSide(
                                                                        //           color: AsianPaintColors.quantityBorder,
                                                                        //         ),
                                                                        //       ),
                                                                        //       focusedBorder: OutlineInputBorder(
                                                                        //         borderSide: BorderSide(
                                                                        //           color: AsianPaintColors.quantityBorder,
                                                                        //         ),
                                                                        //       ),
                                                                        //     ),
                                                                        //     onChanged:
                                                                        //         (value) {
                                                                        //       tempQuoteResultsData?[index].quantity = value;
                                                                        //       logger('Quantity: ${tempQuoteResultsData?[index].quantity}');

                                                                        //       tempQuoteResultsData?[index].totalPrice = int.parse(tempQuoteResultsData?[index].quantity ?? '0') * int.parse(tempQuoteResultsData?[index].sKUMRP ?? '');
                                                                        //       logger('Total Price: ${tempQuoteResultsData?[index].totalPrice}');

                                                                        //       double values = double.parse('${tempQuoteResultsData?[index].totalPrice ?? 0}') * double.parse('${tempQuoteResultsData?[index].discount ?? 0}');
                                                                        //       double discountAmount = double.parse('${values / 100}');
                                                                        //       logger("Discount: $discountAmount");

                                                                        //       setState(
                                                                        //         () {
                                                                        //           tempQuoteResultsData?[index].totalPriceAfterDiscount = ((tempQuoteResultsData?[index].totalPrice) ?? 0) - discountAmount.round();
                                                                        //         },
                                                                        //       );
                                                                        //     },
                                                                        //   ),
                                                                        // ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                SizedBox(
                                                                  child: ListView
                                                                      .builder(
                                                                    itemCount: tempQuoteResultsData?[
                                                                            index]
                                                                        .aREAINFOBJ
                                                                        ?.length,
                                                                    shrinkWrap:
                                                                        true,
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(0),
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
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                      'Total Price : ',
                                                                      style:
                                                                          TextStyle(
                                                                        color: AsianPaintColors
                                                                            .quantityColor,
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
                                                                        color: AsianPaintColors
                                                                            .forgotPasswordTextColor,
                                                                        fontFamily:
                                                                            AsianPaintsFonts.mulishBold,
                                                                        //fontWeight: FontWeight.w600,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              })
                                            : const SizedBox(),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: SizedBox(
                                              height: 50,
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  if ((tempQuoteResultsData ??
                                                          [])
                                                      .isNotEmpty) {
                                                    if (Journey.skuResponseLists
                                                        .isNotEmpty) {
                                                      showCreateExistingDialog(
                                                          context);
                                                    } else {
                                                      calculateSku();
                                                    }
                                                  } else {
                                                    FlutterToastProvider().show(
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
                                        )
                                      ],
                                    ),
                                  );
                                },
                              );
                            default:
                              return const SizedBox();
                          }
                        },
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),
          );
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
                width: double.infinity,
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
    // Journey.skuResponseLists = [];

    for (int i = 0; i < (tempQuoteResultsData ?? []).length; i++) {
      SKUData skuData = SKUData();
      skuData.sKURANGE = tempQuoteResultsData?[i].sKURANGE ?? '';
      skuData.sKUIMAGE = tempQuoteResultsData?[i].sKUIMAGE ?? '';
      skuData.sKUCATEGORY = tempQuoteResultsData?[i].sKUCATEGORY ?? '';
      skuData.sKUUSP = tempQuoteResultsData?[i].sKUUSP ?? '';
      skuData.sKUPRODUCTCAT = tempQuoteResultsData?[i].sKUPRODUCTCAT ?? '';
      skuData.sKUDESCRIPTION = tempQuoteResultsData?[i].sKUDESCRIPTION ?? '';
      skuData.complementary = [];
      skuData.sKUMRP = (tempQuoteResultsData?[i].sKUMRP ?? '').isEmpty
          ? '0'
          : tempQuoteResultsData?[i].sKUMRP ?? '';
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
    logger('Journey list length: ${tempQuoteResultsData?.length}');

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
      const Duration(microseconds: 0),
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
