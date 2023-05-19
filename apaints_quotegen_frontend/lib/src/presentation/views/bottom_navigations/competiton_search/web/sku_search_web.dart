import 'dart:convert';

import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/enums/create_existing_flip.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/competition_search/competition_search_result_response.dart';
import 'package:APaints_QGen/src/data/models/sku_request_model.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_list/competition_search_list_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_list/competiton_search_list_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_result/competition_search_result_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_result/competiton_search_result_bloc.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/view_quote.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SkuWeb extends StatefulWidget {
  const SkuWeb({super.key});

  @override
  State<SkuWeb> createState() => _SkuWebState();
}

class _SkuWebState extends State<SkuWeb> {
  final secureStorageProvider = getSingleton<SecureStorageProvider>();
  Map<String, List<String>>? searchList = {};
  String? brandText;
  String? rangeName;
  String? skuName;
  List<CompetitionSearchResultData>? resultsList = [];

  Set<String>? skuList = {};
  String? rangeName1;
  String? rangeName2;
  bool? refreshed = false;

  Future<void> pullRefresh() async {
    brandText = '';

    setState(() {
      // searchList = {};
      resultsList = [];
      brandText = '';
      refreshed = false;
      GetCompetitionSearchListBloc getCompetitionSearchListBloc =
          context.read<GetCompetitionSearchListBloc>();
      getCompetitionSearchListBloc.getCompetitionSearchList(token: '');
    });
  }

  @override
  Widget build(BuildContext context) {
    GetCompetitionSearchResultBloc competitionSearchResultBloc =
        context.read<GetCompetitionSearchResultBloc>();
    logger(
        'In SKU Search Web Loading::::: ${json.encode(competitionSearchResultBloc.competitionSearchResultResponse?.data)}');

    return BlocProvider<GetCompetitionSearchListBloc>(
      create: (context) =>
          GetCompetitionSearchListBloc()..getCompetitionSearchList(token: ''),
      child: BlocConsumer<GetCompetitionSearchListBloc,
          CompetitionSearchListState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is CompetitionSearchListLoading) {
            logger('In SKU Search Web Loading:::::');

            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is CompetitionSearchListLoaded) {
            logger('In SKU Search Web Loaded:::::');

            GetCompetitionSearchListBloc competitionSearchListBloc =
                context.read<GetCompetitionSearchListBloc>();

            for (int i = 0;
                i <
                    (competitionSearchListBloc
                                .competitionSearchListResponse?.data ??
                            [])
                        .length;
                i++) {
              searchList?[competitionSearchListBloc
                      .competitionSearchListResponse?.data?[i].bRANDNAME ??
                  ''] = competitionSearchListBloc
                      .competitionSearchListResponse?.data?[i].rANGE ??
                  [];
            }
            logger(
                'Competitor data length: ${competitionSearchListBloc.competitionSearchListResponse?.data?.length}');
            logger('Brands length: ${searchList}');
            return RefreshIndicator(
              onRefresh: () => pullRefresh(),
              child: Scaffold(
                body: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: 50,
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Center(
                                  child: Autocomplete(optionsBuilder:
                                          ((TextEditingValue textValue) {
                                brandText = textValue.text;
                                // if (textValue.text.isEmpty) {
                                //   return const Iterable<String>.empty();
                                // } else {
                                return (searchList?.keys ?? []).isNotEmpty
                                    ? (searchList?.keys ?? []).where((ele) =>
                                        ele.toLowerCase().startsWith(
                                            textValue.text.toLowerCase()))
                                    : const Iterable<String>.empty();
                                // }
                              }),
                                      // ----
                                      onSelected: (selectesString) {
                                print(selectesString);
                                brandText = selectesString;
                              },
                                      // ----
                                      optionsViewBuilder:
                                          (context, onSelected, options) {
                                return Material(
                                  child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        final option = options.elementAt(index);

                                        return ListTile(
                                          dense: true,
                                          visualDensity:
                                              const VisualDensity(vertical: -3),
                                          title: Text(
                                            option,
                                            style: TextStyle(
                                              fontFamily: AsianPaintsFonts
                                                  .mulishRegular,
                                              fontSize: 12,
                                            ),
                                          ),
                                          onTap: () {
                                            onSelected(option);
                                          },
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const Divider(),
                                      itemCount: options.length),
                                );
                              }, fieldViewBuilder: (context,
                                          textEditingController,
                                          focusNode,
                                          onFieldSubmitted) {
                                TextEditingController editingController =
                                    TextEditingController();
                                return TextField(
                                  controller: (refreshed ?? false)
                                      ? editingController
                                      : textEditingController,
                                  focusNode: focusNode,
                                  style: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishRegular,
                                    fontSize: 12,
                                  ),
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                              color: Colors.black)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                              color: Colors.black)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                              color: Colors.black)),
                                      hintText: 'Competitor Brand',
                                      hintStyle: const TextStyle(fontSize: 12),
                                      suffixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.black,
                                      )),
                                );
                              }))),
                          BlocConsumer<GetCompetitionSearchResultBloc,
                              CompetitionSearchResultState>(
                            listener: (context, state) {
                              setState(() {
                                List<CompetitionSearchResultData>?
                                    skuResultsList = competitionSearchResultBloc
                                            .competitionSearchResultResponse!
                                            .data ??
                                        [];

                                for (int i = 0;
                                    i < (skuResultsList).length;
                                    i++) {
                                  logger(
                                      'Comp Code: ${skuResultsList[i].cOMPSKUDATA?.cOMPSKUTYPE}');
                                  if ((skuResultsList[i]
                                              .cOMPSKUDATA
                                              ?.cOMPSKUTYPE ??
                                          '')
                                      .isNotEmpty) {
                                    skuList?.add(skuResultsList[i]
                                            .cOMPSKUDATA
                                            ?.cOMPSKUTYPE ??
                                        '');
                                  }
                                }
                              });
                            },
                            builder: (context, state) {
                              return Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: 50,
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Center(
                                  child: Autocomplete(
                                    optionsBuilder:
                                        ((TextEditingValue textValue) {
                                      if ((brandText ?? '').isEmpty) {
                                        FlutterToastProvider().show(
                                            message: 'Please select brand');
                                        return const Iterable<String>.empty();
                                      } else {
                                        return (searchList?[brandText] ?? [])
                                            .where((ele) => ele
                                                .toLowerCase()
                                                .startsWith(textValue.text
                                                    .toLowerCase()));
                                      }
                                    }),
                                    onSelected: (selectesString) {
                                      print(selectesString);
                                      rangeName = selectesString;
                                      competitionSearchResultBloc
                                          .getCompetitionSearchList(
                                              brandName: brandText,
                                              rangeName: selectesString,
                                              skuName: '');
                                    },
                                    optionsViewBuilder:
                                        (context, onSelected, options) {
                                      return Material(
                                        child: ListView.separated(
                                            padding: EdgeInsets.zero,
                                            itemBuilder: (context, index) {
                                              final option =
                                                  options.elementAt(index);

                                              return ListTile(
                                                dense: true,
                                                visualDensity:
                                                    const VisualDensity(
                                                        vertical: -3),
                                                title: Text(
                                                  option,
                                                  style: TextStyle(
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishRegular,
                                                    fontSize: 12,
                                                  ),
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
                                    fieldViewBuilder: (context,
                                        textEditingController,
                                        focusNode,
                                        onFieldSubmitted) {
                                      TextEditingController editingController =
                                          TextEditingController();
                                      return TextField(
                                        controller: (refreshed ?? false)
                                            ? editingController
                                            : textEditingController,
                                        focusNode: focusNode,
                                        style: TextStyle(
                                            fontFamily:
                                                AsianPaintsFonts.mulishRegular,
                                            fontSize: 12),
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                borderSide: const BorderSide(
                                                    color: Colors.black)),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                borderSide: const BorderSide(
                                                    color: Colors.black)),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                borderSide: const BorderSide(
                                                    color: Colors.black)),
                                            hintText: 'Competitor Range',
                                            hintStyle:
                                                const TextStyle(fontSize: 12),
                                            suffixIcon: const Icon(
                                              Icons.search,
                                              color: Colors.black,
                                            )),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 50,
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Center(
                              child: Autocomplete(
                                optionsBuilder: ((TextEditingValue textValue) {
                                  return (skuList ?? {}).where((ele) => ele
                                      .toLowerCase()
                                      .startsWith(
                                          textValue.text.toLowerCase()));
                                }),
                                onSelected: (selectesString) {
                                  print(selectesString);
                                  List<CompetitionSearchResultData>?
                                      skuResultsList =
                                      competitionSearchResultBloc
                                              .competitionSearchResultResponse!
                                              .data ??
                                          [];

                                  for (int i = 0;
                                      i < skuResultsList.length;
                                      i++) {
                                    if ((skuResultsList[i]
                                                .cOMPSKUDATA
                                                ?.cOMPSKUTYPE ??
                                            '')
                                        .contains(selectesString)) {
                                      setState(() {
                                        resultsList = [];
                                        resultsList?.add((skuResultsList)[i]);
                                      });
                                    }
                                  }
                                  rangeName1 = competitionSearchResultBloc
                                          .competitionSearchResultResponse
                                          ?.range1Name ??
                                      '';
                                  rangeName2 = competitionSearchResultBloc
                                          .competitionSearchResultResponse
                                          ?.range2Name ??
                                      '';

                                  logger(
                                      'Results: ${json.encode(resultsList)}');

                                  skuName = selectesString;
                                },
                                optionsViewBuilder:
                                    (context, onSelected, options) {
                                  return Material(
                                    child: ListView.separated(
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          final option =
                                              options.elementAt(index);

                                          return ListTile(
                                            title: Text(
                                              option,
                                              style: TextStyle(
                                                fontFamily: AsianPaintsFonts
                                                    .mulishRegular,
                                                fontSize: 12,
                                              ),
                                            ),
                                            onTap: () {
                                              onSelected(option);
                                            },
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                            const Divider(),
                                        itemCount: options.length),
                                  );
                                },
                                fieldViewBuilder: (context,
                                    textEditingController,
                                    focusNode,
                                    onFieldSubmitted) {
                                  TextEditingController editingController =
                                      TextEditingController();
                                  return TextField(
                                    controller: (refreshed ?? false)
                                        ? editingController
                                        : textEditingController,
                                    focusNode: focusNode,
                                    style: TextStyle(
                                      fontFamily:
                                          AsianPaintsFonts.mulishRegular,
                                      fontSize: 12,
                                    ),
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: const BorderSide(
                                                color: Colors.black)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: const BorderSide(
                                                color: Colors.black)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: const BorderSide(
                                                color: Colors.black)),
                                        hintText: 'Enter or Select SKU*',
                                        hintStyle:
                                            const TextStyle(fontSize: 12),
                                        suffixIcon: const Icon(
                                          Icons.search,
                                          color: Colors.black,
                                        )),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      // -----------------------------------------------------------------
                      // cards
                      const SizedBox(
                        height: 20,
                      ),
                      (resultsList ?? []).isNotEmpty &&
                              (skuName ?? '').isNotEmpty
                          ? SizedBox(
                              // height: 400,
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      // color: Colors.red,
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 0, 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Competitor Range',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontFamily: AsianPaintsFonts
                                                      .mulishRegular,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color.fromRGBO(
                                                      244, 130, 33, 1))),
                                          SizedBox(
                                            height: 220,
                                            width: 200,
                                            child: Card(
                                              child:
                                                  // (resultsList?[0]
                                                  //                 .cODE2SKUDATA
                                                  //                 ?.cATCODE ??
                                                  //             '')
                                                  //         .isEmpty
                                                  //     ? Text(
                                                  //         'No Data Available')
                                                  //     :
                                                  Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SizedBox(
                                                      width: 100,
                                                      height: 100,
                                                      child: Image.network(
                                                        (resultsList?[0]
                                                                        .cOMPSKUDATA
                                                                        ?.cOMPIMAGE ??
                                                                    '')
                                                                .isEmpty
                                                            ? "https://apldam.blob.core.windows.net/aplms/noImageAvailable.png"
                                                            : '${resultsList?[0].cOMPSKUDATA?.cOMPIMAGE}',
                                                        width: 140,
                                                        height: 140,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${resultsList?[0].cOMPSKUDATA?.cOMPCATCODE}',
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Container(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Flexible(
                                                                flex: 1,
                                                                child: Text(
                                                                  '${resultsList?[0].cOMPSKUDATA?.cOMPDESCRIPTION}',
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  softWrap:
                                                                      false,
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          12,
                                                                      color: Color.fromRGBO(
                                                                          102,
                                                                          103,
                                                                          105,
                                                                          1)),
                                                                ),
                                                              ),
                                                              Flexible(
                                                                flex: 1,
                                                                child: Text(
                                                                  (resultsList?[0].cOMPSKUDATA?.cOMPMRP ??
                                                                              '')
                                                                          .isEmpty
                                                                      ? '₹ 0'
                                                                      : '₹ ${resultsList?[0].cOMPSKUDATA?.cOMPMRP}',
                                                                  style: const TextStyle(
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              195,
                                                                              67,
                                                                              40,
                                                                              1),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Visibility(
                                            visible: false,
                                            maintainAnimation: true,
                                            maintainInteractivity: true,
                                            maintainSize: true,
                                            maintainState: true,
                                            child: Container(
                                              height: 70,
                                              width: 200,
                                              padding: const EdgeInsets.all(15),
                                              child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      side: const BorderSide(
                                                          width: 1,
                                                          color: Color.fromRGBO(
                                                              11, 56, 85, 1)),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                      backgroundColor:
                                                          const Color.fromRGBO(
                                                              11, 56, 85, 1)),
                                                  onPressed: () {
                                                    // if (Journey.skuResponseLists
                                                    //     .isNotEmpty) {
                                                    //   showCreateExistingDialog(
                                                    //       context,
                                                    //       resultsList?[0]
                                                    //           .co);
                                                    // } else {
                                                    //   calculateSKU(resultsList?[0]
                                                    //       .cODE1SKUDATA);
                                                    // }
                                                  },
                                                  child: Text(
                                                    'Add To Quote',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishRegular,
                                                        fontSize: 13,
                                                        color: AsianPaintColors
                                                            .whiteColor),
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      // color: Colors.red,
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 0, 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('$rangeName1',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontFamily: AsianPaintsFonts
                                                      .mulishRegular,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color.fromRGBO(
                                                      244, 130, 33, 1))),
                                          SizedBox(
                                            height: 220,
                                            width: 200,
                                            child: Card(
                                              child: (resultsList?[0]
                                                              .cODE1SKUDATA
                                                              ?.cATCODE ??
                                                          '')
                                                      .isEmpty
                                                  ? const Center(
                                                      child: Text(
                                                          'No Data Available'))
                                                  : Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: SizedBox(
                                                            width: 100,
                                                            height: 100,
                                                            child:
                                                                Image.network(
                                                              (resultsList?[0]
                                                                              .cODE1SKUDATA
                                                                              ?.sKUIMAGE ??
                                                                          '')
                                                                      .isEmpty
                                                                  ? "https://apldam.blob.core.windows.net/aplms/noImageAvailable.png"
                                                                  : '${resultsList?[0].cODE1SKUDATA?.sKUIMAGE}',
                                                              width: 140,
                                                              height: 140,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${resultsList?[0].cODE1SKUDATA?.cATCODE}',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Container(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Flexible(
                                                                      flex: 1,
                                                                      child:
                                                                          Text(
                                                                        '${resultsList?[0].cODE1SKUDATA?.sKUDESCRIPTION}',
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        softWrap:
                                                                            false,
                                                                        style: const TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .w500,
                                                                            fontSize:
                                                                                12,
                                                                            color: Color.fromRGBO(
                                                                                102,
                                                                                103,
                                                                                105,
                                                                                1)),
                                                                      ),
                                                                    ),
                                                                    Flexible(
                                                                      flex: 1,
                                                                      child:
                                                                          Text(
                                                                        (resultsList?[0].cODE1SKUDATA?.sKUMRP ?? '').isEmpty
                                                                            ? '₹ 0'
                                                                            : '₹ ${resultsList?[0].cODE1SKUDATA?.sKUMRP}',
                                                                        style: const TextStyle(
                                                                            color: Color.fromRGBO(
                                                                                195,
                                                                                67,
                                                                                40,
                                                                                1),
                                                                            fontWeight:
                                                                                FontWeight.w600),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            height: 70,
                                            width: 200,
                                            padding: const EdgeInsets.all(15),
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    side: const BorderSide(
                                                        width: 1,
                                                        color: Color.fromRGBO(
                                                            11, 56, 85, 1)),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                    backgroundColor:
                                                        const Color.fromRGBO(
                                                            11, 56, 85, 1)),
                                                onPressed: () {
                                                  if ((resultsList?[0]
                                                              .cODE2SKUDATA
                                                              ?.cATCODE ??
                                                          '')
                                                      .isNotEmpty) {
                                                    if (Journey.skuResponseLists
                                                        .isNotEmpty) {
                                                      showCreateExistingDialog(
                                                          context,
                                                          resultsList?[0]
                                                              .cODE1SKUDATA);
                                                    } else {
                                                      calculateSKU(
                                                          resultsList?[0]
                                                              .cODE1SKUDATA);
                                                    }
                                                  } else {
                                                    FlutterToastProvider().show(
                                                        message:
                                                            'No Data available');
                                                  }
                                                },
                                                child: Text(
                                                  'Add To Quote',
                                                  style: TextStyle(
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishRegular,
                                                      fontSize: 13,
                                                      color: AsianPaintColors
                                                          .whiteColor),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  (resultsList?[0].cODE2SKUDATA?.cATCODE ?? '')
                                          .isEmpty
                                      ? const SizedBox()
                                      : Flexible(
                                          flex: 1,
                                          child: Container(
                                            // color: Colors.red,
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 0, 0, 0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('$rangeName2',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishRegular,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: const Color
                                                                .fromRGBO(
                                                            244, 130, 33, 1))),
                                                SizedBox(
                                                  height: 220,
                                                  width: 200,
                                                  child: Card(
                                                    child: (resultsList?[0]
                                                                    .cODE2SKUDATA
                                                                    ?.cATCODE ??
                                                                '')
                                                            .isEmpty
                                                        ? const Center(
                                                            child: Text(
                                                                'No Data Available'),
                                                          )
                                                        : Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SizedBox(
                                                                width: 100,
                                                                height: 100,
                                                                child: Image.network((resultsList?[0].cODE2SKUDATA?.sKUIMAGE ??
                                                                            '')
                                                                        .isEmpty
                                                                    ? "https://apldam.blob.core.windows.net/aplms/noImageAvailable.png"
                                                                    : '${resultsList?[0].cODE2SKUDATA?.sKUIMAGE}'),
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(10),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      '${resultsList?[0].cODE2SKUDATA?.cATCODE}',
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Flexible(
                                                                            child:
                                                                                Text(
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              softWrap: false,
                                                                              '${resultsList?[0].cODE2SKUDATA?.sKUDESCRIPTION}',
                                                                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Color.fromRGBO(102, 103, 105, 1)),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            (resultsList?[0].cODE2SKUDATA?.sKUMRP ?? '').isEmpty
                                                                                ? '₹ 0'
                                                                                : '₹ ${resultsList?[0].cODE2SKUDATA?.sKUMRP}',
                                                                            style:
                                                                                const TextStyle(color: Color.fromRGBO(195, 67, 40, 1), fontWeight: FontWeight.w600),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  height: 70,
                                                  width: 200,
                                                  padding:
                                                      const EdgeInsets.all(15),
                                                  child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          side:
                                                              const BorderSide(
                                                                  width: 1,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          11,
                                                                          56,
                                                                          85,
                                                                          1)),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          backgroundColor:
                                                              const Color
                                                                      .fromRGBO(
                                                                  11,
                                                                  56,
                                                                  85,
                                                                  1)),
                                                      onPressed: () {
                                                        if (Journey
                                                            .skuResponseLists
                                                            .isNotEmpty) {
                                                          showCreateExistingDialog(
                                                              context,
                                                              resultsList?[0]
                                                                  .cODE2SKUDATA);
                                                        } else {
                                                          calculateSKU(
                                                              resultsList?[0]
                                                                  .cODE2SKUDATA);
                                                        }
                                                      },
                                                      child: Text(
                                                        'Add To Quote',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                AsianPaintsFonts
                                                                    .mulishRegular,
                                                            fontSize: 13,
                                                            color:
                                                                AsianPaintColors
                                                                    .whiteColor),
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void showCreateExistingDialog(
    BuildContext context,
    CODE2SKUDATA? cODE1SKUDATA,
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
                                      calculateSKU(cODE1SKUDATA!);
                                      Navigator.pop(context);
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

  void calculateSKU(CODE2SKUDATA? cODE1SKUDATA) {
    int price = 0;
    List<SKUData> skuDataList = [];
    List<String> areas = [];
    List<Area> areasList = [];

    SKUData skuData = SKUData();
    skuData.sKURANGE = cODE1SKUDATA?.sKURANGE;
    skuData.sKUIMAGE = cODE1SKUDATA?.sKUIMAGE ?? '';
    skuData.sKUCATEGORY = cODE1SKUDATA?.sKUCATEGORY;
    skuData.sKUUSP = '';
    skuData.sKUPRODUCTCAT = '';
    skuData.sKUDESCRIPTION = cODE1SKUDATA?.sKUDESCRIPTION ?? '';
    skuData.complementary = [];
    skuData.sKUMRP = cODE1SKUDATA?.sKUMRP ?? '';
    skuData.sKUCODE = cODE1SKUDATA?.sKUCODE ?? '';
    skuData.sKUSRP = '';
    skuData.sKUDRAWING = '';
    skuData.sKUBRAND = cODE1SKUDATA?.sKUBRAND;
    for (int j = 0; j < (cODE1SKUDATA?.aREAINFO ?? []).length; j++) {
      areas = [];
      areasList = [];
      if (areas.isNotEmpty) {
        if (areas[j].trim() != cODE1SKUDATA?.aREAINFO?[j].aREA) {
          areas.add(cODE1SKUDATA?.aREAINFO?[j].aREA ?? 'Showers');
          break;
        }
      } else {
        areas.add(cODE1SKUDATA?.aREAINFO?[j].aREA ?? 'Showers');
      }

      if (areasList.isNotEmpty) {
        if ((areasList[j].areaname ?? '').trim() !=
            cODE1SKUDATA?.aREAINFO?[j].aREA) {
          areasList.add(Area(
              areaname: cODE1SKUDATA?.aREAINFO?[j].aREA ?? 'Showers',
              areaqty: (cODE1SKUDATA?.aREAINFO?[j].qTY ?? '1').isEmpty
                  ? '1'
                  : cODE1SKUDATA?.aREAINFO?[j].qTY ?? '1'));
          break;
        }
      } else {
        areasList.add(Area(
            areaname: cODE1SKUDATA?.aREAINFO?[j].aREA ?? 'Showers',
            areaqty: (cODE1SKUDATA?.aREAINFO?[j].qTY ?? '1').isEmpty
                ? '1'
                : cODE1SKUDATA?.aREAINFO?[j].qTY ?? '1'));
      }
    }
    skuData.aREAINFO = areas;
    skuData.areaInfo = areasList;
    // skuData.aREAINFO = [];
    skuData.skuCatCode = cODE1SKUDATA?.cATCODE ?? '';
    skuData.sKUTYPE = '';
    skuData.discount = 0;
    skuData.quantity = '1';
    skuData.totalPrice = int.parse(cODE1SKUDATA?.sKUMRP ?? '0');
    skuData.totalPriceAfterDiscount = int.parse(cODE1SKUDATA?.sKUMRP ?? '0');
    skuData.index = 0;

    // skuData.areaInfo = [];
    skuData.skuTypeExpanded = '';
    skuData.productCardDescriptior = '';
    price += skuData.totalPriceAfterDiscount ?? 0;

    Journey.skuResponseLists.add(skuData);

    skuDataList.add(skuData);

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
