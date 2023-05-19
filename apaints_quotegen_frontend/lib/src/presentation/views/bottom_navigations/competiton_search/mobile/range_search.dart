import 'dart:convert';

import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/models/competition_search/competition_search_result_response.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_list/competition_search_list_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_list/competiton_search_list_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_result/competition_search_result_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_result/competiton_search_result_bloc.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/competiton_search/mobile/mobile_range_card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RangeSearch extends StatefulWidget {
  const RangeSearch({super.key});

  @override
  State<RangeSearch> createState() => _RangeSearchState();
}

class _RangeSearchState extends State<RangeSearch> {
  Map<String, List<String>>? searchList = {};
  String? brandText = '';
  List<CompetitionSearchResultData>? resultsList;
  Bundleinfo1? bundleInfoList1;
  Bundleinfo1? bundleInfoList2;
  int totalComp1Price = 0;
  int totalComp2Price = 0;
  int totalCompetitorPrice = 0;

  String? rangeName1;
  String? rangeName2;
  String? rangeDesc1;
  String? rangeDesc2;
  bool? refreshed = false;
  List<String>? bundleList;
  List<String>? sanwareList;
  Future<void> _pullRefresh() async {
    brandText = '';

    setState(() {
      searchList = {};
      resultsList = [];
      brandText = '';
      refreshed = true;
      GetCompetitionSearchListBloc getCompetitionSearchListBloc =
          context.read<GetCompetitionSearchListBloc>();
      getCompetitionSearchListBloc.getCompetitionSearchList(token: '');
    });
  }

  @override
  Widget build(BuildContext context) {
    GetCompetitionSearchResultBloc competitionSearchResultBloc =
        context.read<GetCompetitionSearchResultBloc>();

    logger("in range Search");
    return RefreshIndicator(
      onRefresh: _pullRefresh,
      child: BlocProvider<GetCompetitionSearchListBloc>(
        create: (context) {
          return GetCompetitionSearchListBloc()
            ..getCompetitionSearchList(token: '');
        },
        child: BlocConsumer<GetCompetitionSearchListBloc,
            CompetitionSearchListState>(
          listener: (context, state) {},
          builder: (context, state) {
            GetCompetitionSearchListBloc competitionSearchListBloc =
                context.read<GetCompetitionSearchListBloc>();
            if (state is CompetitionSearchListLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is CompetitionSearchListLoaded) {
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
              return Scaffold(
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                  child: Autocomplete(
                                // initialValue:
                                //     TextEditingValue(text: brandText ?? ''),
                                optionsBuilder: ((TextEditingValue textValue) {
                                  brandText = textValue.text;
                                  if (textValue.text.isEmpty) {
                                    setState(() {
                                      resultsList = [];
                                    });
                                  }
                                  return (searchList?.keys ?? []).where((ele) =>
                                      ele.toLowerCase().startsWith(
                                          textValue.text.toLowerCase()));
                                }),
                                onSelected: (selectesString) {
                                  print(selectesString);
                                  brandText = selectesString;
                                },
                                optionsViewBuilder:
                                    (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      child: SizedBox(
                                        width: 200,
                                        height: 400,
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
                                                  option.toString(),
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
                                      ),
                                    ),
                                  );
                                },
                                fieldViewBuilder: (context,
                                    textEditingController,
                                    focusNode,
                                    onFieldSubmitted) {
                                  return TextField(
                                    controller: textEditingController,
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
                                        hintText: 'Competitor Brand',
                                        hintStyle:
                                            const TextStyle(fontSize: 10),
                                        suffixIcon: const Icon(
                                          Icons.search,
                                          color: Colors.black,
                                        )),
                                  );
                                },
                              )),
                            ),
                          ),
                          BlocConsumer<GetCompetitionSearchResultBloc,
                              CompetitionSearchResultState>(
                            listener: (context, state) {
                              if (state is CompetitionSearchResultInitial) {
                                const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (state is CompetitionSearchResultLoading) {
                                const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (state is CompetitionSearchResultLoaded) {
                                resultsList = [];
                                setState(() {
                                  resultsList = competitionSearchResultBloc
                                          .competitionSearchResultResponse!
                                          .data ??
                                      [];
                                  rangeName1 = competitionSearchResultBloc
                                          .competitionSearchResultResponse
                                          ?.range1Name ??
                                      '';
                                  rangeName2 = competitionSearchResultBloc
                                          .competitionSearchResultResponse
                                          ?.range2Name ??
                                      '';
                                  rangeDesc1 = competitionSearchResultBloc
                                          .competitionSearchResultResponse
                                          ?.range1Desc ??
                                      '';
                                  rangeDesc2 = competitionSearchResultBloc
                                          .competitionSearchResultResponse
                                          ?.range2Desc ??
                                      '';
                                  Bundleinfo1? bundleinfo1 =
                                      competitionSearchResultBloc
                                          .competitionSearchResultResponse
                                          ?.bundleinfo1;
                                  bundleInfoList1 = competitionSearchResultBloc
                                      .competitionSearchResultResponse
                                      ?.bundleinfo1;
                                  bundleInfoList2 = competitionSearchResultBloc
                                      .competitionSearchResultResponse
                                      ?.bundleinfo2;
                                  bundleList = competitionSearchResultBloc
                                          .competitionSearchResultResponse
                                          ?.bundleinfo1
                                          ?.bundle ??
                                      [];
                                  sanwareList = competitionSearchResultBloc
                                          .competitionSearchResultResponse
                                          ?.bundleinfo1
                                          ?.sanware ??
                                      [];
                                  logger('bundleList: ${bundleList?.length}');
                                  logger(
                                      'Sanware List: ${sanwareList?.length}');

                                  for (int i = 0;
                                      i < (resultsList ?? []).length;
                                      i++) {
                                    totalCompetitorPrice += int.parse(
                                        (resultsList?[i]
                                                .cOMPSKUDATA
                                                ?.cOMPMRP
                                                ?.replaceAll(',', '')) ??
                                            '0');
                                    totalComp1Price += int.parse(
                                        resultsList?[i].cODE1SKUDATA?.sKUMRP ??
                                            '0');
                                    totalComp2Price += int.parse(
                                        resultsList?[i].cODE2SKUDATA?.sKUMRP ??
                                            '0');
                                  }
                                  logger(
                                      'Results List Length: ${resultsList?.length}');
                                });
                              }
                            },
                            builder: (context, state) {
                              int popupOffset = 20;

                              return Flexible(
                                flex: 1,
                                child: RawAutocomplete(
                                  optionsBuilder:
                                      ((TextEditingValue textValue) {
                                    if ((brandText ?? '').isEmpty) {
                                      setState(() {
                                        resultsList = [];
                                      });
                                      FlutterToastProvider()
                                          .show(message: 'Please select brand');
                                      return const Iterable<String>.empty();
                                    } else {
                                      // if (textValue.text.isEmpty) {
                                      //   return const Iterable<String>.empty();
                                      // } else {

                                      // }
                                      return (searchList?[brandText] ?? [])
                                          .where((ele) => ele
                                              .toLowerCase()
                                              .startsWith(textValue.text
                                                  .toLowerCase()));
                                    }
                                  }),
                                  onSelected: (selectesString) {
                                    print(selectesString);
                                    competitionSearchResultBloc
                                        .getCompetitionSearchList(
                                            brandName: brandText,
                                            rangeName: selectesString,
                                            skuName: '');
                                  },
                                  // ----
                                  optionsViewBuilder:
                                      (context, onSelected, options) {
                                    ScrollController controller =
                                        ScrollController(
                                            keepScrollOffset: true);
                                    ScrollPhysics physics = ScrollPhysics();
                                    logger('Scroll Length: ${options.length}');
                                    return Align(
                                      alignment: Alignment.topCenter,
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                1.8,
                                        child: Material(
                                          child: ListView.separated(
                                            separatorBuilder:
                                                (context, index) =>
                                                    const Divider(),
                                            itemCount: options.length,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            shrinkWrap: false,
                                            // scrollDirection: Axis.vertical,
                                            padding: EdgeInsets.zero,
                                            dragStartBehavior:
                                                DragStartBehavior.start,
                                            // shrinkWrap: false,
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
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                onTap: () {
                                                  onSelected(option);
                                                },
                                              );
                                            },
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
                                      controller: textEditingController,
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
                                              const TextStyle(fontSize: 10),
                                          suffixIcon: const Icon(
                                            Icons.search,
                                            color: Colors.black,
                                          )),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 2,
                            height: 1100,
                            child: (resultsList ?? []).isNotEmpty
                                ? MobileRangeCard(
                                    compData: resultsList,
                                    totalCompetitorPrice: totalCompetitorPrice,
                                    totalComp1Price: totalComp1Price,
                                    totalComp2Price: totalComp2Price,
                                    range1: rangeName1,
                                    range2: rangeName2,
                                    bundleList: bundleList,
                                    sanwareList: sanwareList,
                                    rangeDesc1: rangeDesc1,
                                    rangeDesc2: rangeDesc2,
                                  )
                                : null,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
