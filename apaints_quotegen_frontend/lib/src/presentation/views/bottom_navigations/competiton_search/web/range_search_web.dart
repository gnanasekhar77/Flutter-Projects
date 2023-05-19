import 'dart:convert';

import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/models/competition_search/competition_search_result_response.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_list/competition_search_list_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_list/competiton_search_list_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_result/competition_search_result_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_result/competiton_search_result_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/competiton_search/web/web_range_card.dart';

class RangeWeb extends StatefulWidget {
  const RangeWeb({super.key});

  @override
  State<RangeWeb> createState() => _RangeWebState();
}

const List<String> listitems = [
  'pavan',
  'vamsi',
  'sravan',
  'sandeep',
  'satheesh'
];

class _RangeWebState extends State<RangeWeb> {
  Map<String, List<String>>? searchList = {};
  String? brandText;
  List<CompetitionSearchResultData>? resultsList;
  Bundleinfo1? bundleInfoList1;
  Bundleinfo1? bundleInfoList2;
  int totalCompetitorPrice = 0;
  int totalComp1Price = 0;
  int totalComp2Price = 0;
  String? rangeName1;
  String? rangeName2;
  String? rangeDesc1;
  String? rangeDesc2;
  bool? refreshed = false;
  List<String>? bundleList;
  List<String>? sanwareList;
  @override
  Widget build(BuildContext context) {
    GetCompetitionSearchResultBloc competitionSearchResultBloc =
        context.read<GetCompetitionSearchResultBloc>();

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

    return RefreshIndicator(
      onRefresh: () => _pullRefresh(),
      child: BlocProvider(
        create: (context) {
          return GetCompetitionSearchListBloc()
            ..getCompetitionSearchList(token: '');
        },
        child: BlocConsumer<GetCompetitionSearchListBloc,
            CompetitionSearchListState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is CompetitionSearchListLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is CompetitionSearchListLoaded) {
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
              return Scaffold(
                body: SingleChildScrollView(
                  child: Container(
                    color: AsianPaintColors.whiteColor,
                    height: MediaQuery.of(context).size.height,
                    margin: const EdgeInsets.fromLTRB(0, 25, 0, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                flex: 1,
                                child: Container(
                                    height: 50,
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Center(
                                        child: Autocomplete(optionsBuilder:
                                            ((TextEditingValue textValue) {
                                      brandText = textValue.text;
                                      // if (textValue.text.isEmpty) {
                                      //   return const Iterable<String>.empty();
                                      // } else {
                                      return (searchList?.keys ?? []).where(
                                          (ele) => ele.toLowerCase().startsWith(
                                              textValue.text.toLowerCase()));
                                      // }
                                    }), onSelected: (selectesString) {
                                      print(selectesString);
                                      brandText = selectesString;
                                    }, optionsViewBuilder:
                                            (context, onSelected, options) {
                                      return Material(
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
                                                      fontFamily:
                                                          AsianPaintsFonts
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
                                      );
                                    }, fieldViewBuilder: (context,
                                            textEditingController,
                                            focusNode,
                                            onFieldSubmitted) {
                                      (refreshed ?? false)
                                          ? textEditingController.text = ''
                                          : textEditingController;
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
                                    }))),
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
                                      bundleInfoList1 =
                                          competitionSearchResultBloc
                                              .competitionSearchResultResponse
                                              ?.bundleinfo1;
                                      bundleInfoList2 =
                                          competitionSearchResultBloc
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
                                      // logger('Bundle List: ${bundleInfoList}');

                                      logger(
                                          'Range 1: $rangeName1, Result 2: $rangeName2');
                                      logger(
                                          'Results List: ${json.encode(resultsList)}');
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
                                            resultsList?[i]
                                                    .cODE1SKUDATA
                                                    ?.sKUMRP ??
                                                '0');
                                        totalComp2Price += int.parse(
                                            resultsList?[i]
                                                    .cODE2SKUDATA
                                                    ?.sKUMRP ??
                                                '0');
                                      }
                                      logger(
                                          'Results List Length: ${resultsList?.length}');
                                    });
                                  }
                                },
                                builder: (context, state) {
                                  return Flexible(
                                    flex: 1,
                                    child: Container(
                                        // width: 300,
                                        height: 50,
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
                                        child: Center(
                                            child: Autocomplete(optionsBuilder:
                                                ((TextEditingValue textValue) {
                                          if ((brandText ?? '').isEmpty) {
                                            FlutterToastProvider().show(
                                                message: 'Please select brand');
                                            return const Iterable<
                                                String>.empty();
                                          } else {
                                            // if (textValue.text.isEmpty) {
                                            //   return const Iterable<String>.empty();
                                            // } else {

                                            // }
                                            return (searchList?[brandText] ??
                                                    [])
                                                .where((ele) => ele
                                                    .toLowerCase()
                                                    .startsWith(textValue.text
                                                        .toLowerCase()));
                                          }
                                        }), onSelected: (selectesString) {
                                          competitionSearchResultBloc
                                              .getCompetitionSearchList(
                                                  brandName: brandText,
                                                  rangeName: selectesString,
                                                  skuName: '');
                                        }, optionsViewBuilder:
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
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishRegular,
                                                        fontSize: 11,
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
                                        }, fieldViewBuilder: (context,
                                                textEditingController,
                                                focusNode,
                                                onFieldSubmitted) {
                                          (refreshed ?? false)
                                              ? textEditingController.text = ''
                                              : textEditingController;
                                          return TextField(
                                            controller: textEditingController,
                                            focusNode: focusNode,
                                            style: TextStyle(
                                                fontFamily: AsianPaintsFonts
                                                    .mulishRegular,
                                                fontSize: 12),
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    borderSide: const BorderSide(
                                                        color: Colors.black)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    borderSide: const BorderSide(
                                                        color: Colors.black)),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .black)),
                                                hintText: 'Competitor Range',
                                                hintStyle: const TextStyle(
                                                    fontSize: 10),
                                                suffixIcon: const Icon(
                                                  Icons.search,
                                                  color: Colors.black,
                                                )),
                                          );
                                        }))),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 1100,
                              child: (resultsList ?? []).isNotEmpty
                                  ? SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.58,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1.8,
                                      child: RangeCards(
                                        compData: resultsList,
                                        totalCompetitorPrice:
                                            totalCompetitorPrice,
                                        totalComp1Price: totalComp1Price,
                                        totalComp2Price: totalComp2Price,
                                        range1: rangeName1,
                                        range2: rangeName2,
                                        rangeDesc1: rangeDesc1,
                                        rangeDesc2: rangeDesc2,
                                        bundleList: bundleList,
                                        sanwareList: sanwareList,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        )
                      ],
                    ),
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
