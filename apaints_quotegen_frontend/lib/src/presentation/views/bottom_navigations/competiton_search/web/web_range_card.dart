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
import 'package:APaints_QGen/src/data/models/competition_search_san_bund_response.dart';
import 'package:APaints_QGen/src/data/models/sku_request_model.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/bundle_sanware_list/competition_search_san_bund_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/bundle_sanware_list/competiton_search_san_bund_bloc.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/view_quote.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RangeCards extends StatefulWidget {
  final List<String>? bundleList;
  final List<String>? sanwareList;
  final List<CompetitionSearchResultData>? compData;
  final int? totalCompetitorPrice;
  final int? totalComp1Price;
  final int? totalComp2Price;
  final String? range1;
  final String? range2;
  final String? rangeDesc1;
  final String? rangeDesc2;

  const RangeCards(
      {super.key,
      this.bundleList,
      this.sanwareList,
      this.compData,
      this.totalCompetitorPrice,
      this.totalComp1Price,
      this.totalComp2Price,
      this.range1,
      this.range2,
      this.rangeDesc1,
      this.rangeDesc2});

  @override
  State<RangeCards> createState() => _RangeCardsState();
}

class _RangeCardsState extends State<RangeCards> {
  final secureStorageProvider = getSingleton<SecureStorageProvider>();
  Map<String, List<String>> bundleListMap = {};

  List<String>? bundleList = [];
  List<String>? sanwareList = [];

  int totalCompetitorPrice = 0;
  int totalComp1Price = 0;
  int totalComp2Price = 0;

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < (widget.compData ?? []).length; i++) {
      if ((widget.compData?[i].cOMPSKUDATA?.cOMPCATCODE ?? '').isNotEmpty) {
        totalCompetitorPrice += int.parse(
            widget.compData?[i].cOMPSKUDATA?.cOMPMRP?.replaceAll(",", "") ??
                '0');
      }

      if ((widget.compData?[i].cODE1SKUDATA?.cATCODE ?? '').isNotEmpty) {
        totalComp1Price +=
            int.parse(widget.compData?[i].cODE1SKUDATA?.sKUMRP ?? '0');
      }

      if ((widget.compData?[i].cODE2SKUDATA?.cATCODE ?? '').isNotEmpty) {
        totalComp2Price +=
            int.parse(widget.compData?[i].cODE2SKUDATA?.sKUMRP ?? '0');
      }
      logger('Total competitor price: $totalCompetitorPrice');
      logger('Total comp1 price: $totalComp1Price');
      logger('Total comp2 price: $totalComp2Price');
    }
    return Scaffold(
        body: SingleChildScrollView(
      physics: const ScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: SizedBox(
        //  margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
        width: MediaQuery.of(context).size.width,
        height: 200 * ((widget.compData ?? []).length) +
            400, //MediaQuery.of(context).size.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              width: MediaQuery.of(context).size.width * 0.13,
              //  height: MediaQuery.of(context).size.height,
              // color: Colors.amber,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: false,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    maintainInteractivity: false,
                    child: Container(
                      height: 70,
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              side: const BorderSide(
                                  width: 1,
                                  color: Color.fromRGBO(11, 56, 85, 1)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              backgroundColor:
                                  const Color.fromRGBO(11, 56, 85, 1)),
                          onPressed: () {},
                          child: Text(
                            'Add To Quote',
                            style: TextStyle(
                                fontFamily: AsianPaintsFonts.mulishRegular,
                                fontSize: 13,
                                color: AsianPaintColors.whiteColor),
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    visible: false,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    maintainInteractivity: false,
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Text('${widget.rangeDesc2}',
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 10,
                                fontFamily: AsianPaintsFonts.mulishRegular,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromRGBO(244, 130, 33, 1)))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: true,
                    maintainAnimation: true,
                    maintainInteractivity: false,
                    maintainSize: true,
                    maintainState: true,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            width: 70,
                            child: Text(
                              'Total Price',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '₹ $totalCompetitorPrice',
                            style: const TextStyle(
                                color: Color.fromRGBO(195, 67, 40, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.08,
                    child: Text('Competitor Range',
                        style: TextStyle(
                            fontSize: 10,
                            fontFamily: AsianPaintsFonts.mulishRegular,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromRGBO(244, 130, 33, 1))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.12,
                    height: 200 * ((widget.compData ?? []).length) + 15,
                    child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.compData?.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            width: 280,
                            height: 200,
                            child: Card(
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 100,
                                      padding: const EdgeInsets.only(
                                          top: 20,
                                          left: 10,
                                          right: 10,
                                          bottom: 5),
                                      child: Image.network(
                                          '${(widget.compData?[index].cOMPSKUDATA?.cOMPIMAGE ?? '').isEmpty ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png' : widget.compData?[index].cOMPSKUDATA?.cOMPIMAGE}'),
                                    ),
                                    Container(
                                      width: 230,
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${widget.compData?[index].cOMPSKUDATA?.cOMPCATCODE}',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 5, 0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  flex: 1,
                                                  child: Text(
                                                    '${widget.compData?[index].cOMPSKUDATA?.cOMPDESCRIPTION}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    softWrap: false,
                                                    textWidthBasis:
                                                        TextWidthBasis
                                                            .longestLine,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 10,
                                                        color: Color.fromRGBO(
                                                            102, 103, 105, 1)),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 1,
                                                  child: Text(
                                                    (widget
                                                                    .compData?[
                                                                        index]
                                                                    .cOMPSKUDATA
                                                                    ?.cOMPMRP ??
                                                                '')
                                                            .isEmpty
                                                        ? '₹0'
                                                        : '₹ ${widget.compData?[index].cOMPSKUDATA?.cOMPMRP}',
                                                    style: const TextStyle(
                                                        color: Color.fromRGBO(
                                                            195, 67, 40, 1),
                                                        fontSize: 16,
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
                          );
                        }),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              width: MediaQuery.of(context).size.width * 0.15,
              child: Column(
                children: [
                  Container(
                    height: 70,
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            side: const BorderSide(
                                width: 1, color: Color.fromRGBO(11, 56, 85, 1)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            backgroundColor:
                                const Color.fromRGBO(11, 56, 85, 1)),
                        onPressed: () {
                          showBundleSanwareFilter(
                              context, "Competitor 1", widget.range1 ?? '');
                        },
                        child: Text(
                          'Add To Quote',
                          style: TextStyle(
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              fontSize: 13,
                              color: AsianPaintColors.whiteColor),
                        )),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    visible: true,
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Text('${widget.rangeDesc1}',
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 10,
                                fontFamily: AsianPaintsFonts.mulishRegular,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromRGBO(244, 130, 33, 1)))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          width: 70,
                          child: Text(
                            'Total Price',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '₹ $totalComp1Price',
                          style: const TextStyle(
                              color: Color.fromRGBO(195, 67, 40, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: Text("AP Range - ${widget.range1 ?? ''} ",
                        style: TextStyle(
                            fontSize: 10,
                            fontFamily: AsianPaintsFonts.mulishRegular,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromRGBO(244, 130, 33, 1))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.12,
                    height: 200 * ((widget.compData ?? []).length) + 15,
                    child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.compData?.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            width: 280,
                            height: 200,
                            child: Card(
                              child: (widget.compData?[index].cODE1SKUDATA
                                              ?.cATCODE ??
                                          '')
                                      .isEmpty
                                  ? const Center(
                                      child: Text('No Data Available'),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          height: 100,
                                          padding: const EdgeInsets.only(
                                              top: 20,
                                              left: 10,
                                              right: 10,
                                              bottom: 5),
                                          child: Image.network(
                                              '${(widget.compData?[index].cODE1SKUDATA?.sKUIMAGE ?? '').isEmpty ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png' : widget.compData?[index].cODE1SKUDATA?.sKUIMAGE}'),
                                        ),
                                        Container(
                                          width: 230,
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${widget.compData?[index].cODE1SKUDATA?.cATCODE}',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 5, 0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      flex: 1,
                                                      child: Text(
                                                        '${widget.compData?[index].cODE1SKUDATA?.sKUDESCRIPTION}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        softWrap: false,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 10,
                                                            color:
                                                                Color.fromRGBO(
                                                                    102,
                                                                    103,
                                                                    105,
                                                                    1)),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      flex: 1,
                                                      child: Text(
                                                        (widget
                                                                        .compData?[
                                                                            index]
                                                                        .cODE1SKUDATA
                                                                        ?.sKUMRP ??
                                                                    '')
                                                                .isEmpty
                                                            ? '₹0'
                                                            : '₹ ${widget.compData?[index].cODE1SKUDATA?.sKUMRP}',
                                                        style: const TextStyle(
                                                            color:
                                                                Color.fromRGBO(
                                                                    195,
                                                                    67,
                                                                    40,
                                                                    1),
                                                            fontSize: 16,
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
                          );
                        }),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Visibility(
                    visible: true,
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Text('${widget.rangeDesc1}',
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 10,
                                fontFamily: AsianPaintsFonts.mulishRegular,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromRGBO(244, 130, 33, 1)))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          width: 70,
                          child: Text(
                            'Total Price',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '₹ $totalComp1Price',
                          style: TextStyle(
                              color: AsianPaintColors.forgotPasswordTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 70,
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            side: const BorderSide(
                                width: 1, color: Color.fromRGBO(11, 56, 85, 1)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            backgroundColor:
                                const Color.fromRGBO(11, 56, 85, 1)),
                        onPressed: () {
                          showBundleSanwareFilter(
                              context, "Competitor 1", widget.range1 ?? '');
                        },
                        child: Text(
                          'Add To Quote',
                          style: TextStyle(
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              fontSize: 13,
                              color: AsianPaintColors.whiteColor),
                        )),
                  ),
                ],
              ),
            ),
            // ------------------------------------------------------------------
            (widget.compData?[0].cODE2SKUDATA?.cATCODE ?? '').isEmpty
                ? const SizedBox()
                : Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Column(
                      children: [
                        Container(
                          height: 70,
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  side: const BorderSide(
                                      width: 1,
                                      color: Color.fromRGBO(11, 56, 85, 1)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  backgroundColor:
                                      const Color.fromRGBO(11, 56, 85, 1)),
                              onPressed: () {
                                showBundleSanwareFilter(context, "Competitor 2",
                                    widget.range2 ?? '');
                              },
                              child: Text(
                                'Add To Quote',
                                style: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishRegular,
                                    fontSize: 13,
                                    color: AsianPaintColors.whiteColor),
                              )),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: true,
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Text('${widget.rangeDesc2}',
                                  maxLines: 3,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontFamily:
                                          AsianPaintsFonts.mulishRegular,
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromRGBO(
                                          244, 130, 33, 1)))),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                width: 70,
                                child: Text(
                                  'Total Price',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                '₹ $totalComp2Price',
                                style: const TextStyle(
                                    color: Color.fromRGBO(195, 67, 40, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                          child: Text("AP Range - ${widget.range2 ?? ''} ",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: AsianPaintsFonts.mulishRegular,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      const Color.fromRGBO(244, 130, 33, 1))),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.12,
                          height: 200 * ((widget.compData ?? []).length) + 15,
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.compData?.length,
                              itemBuilder: (BuildContext context, int index) {
                                return SizedBox(
                                  width: 250,
                                  height: 200,
                                  child: Card(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          height: 100,
                                          padding: const EdgeInsets.only(
                                              top: 20,
                                              left: 10,
                                              right: 10,
                                              bottom: 5),
                                          child: Image.network(
                                            (widget
                                                            .compData?[index]
                                                            .cODE2SKUDATA
                                                            ?.sKUIMAGE ??
                                                        '')
                                                    .isEmpty
                                                ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
                                                : widget
                                                        .compData?[index]
                                                        .cODE2SKUDATA
                                                        ?.sKUIMAGE ??
                                                    '',
                                          ),
                                        ),
                                        Container(
                                          width: 200,
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget
                                                        .compData?[index]
                                                        .cODE2SKUDATA
                                                        ?.cATCODE ??
                                                    '',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 5, 0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      flex: 1,
                                                      child: Text(
                                                        widget
                                                                .compData?[
                                                                    index]
                                                                .cODE2SKUDATA
                                                                ?.sKUDESCRIPTION ??
                                                            '',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        softWrap: false,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 10,
                                                            color:
                                                                Color.fromRGBO(
                                                                    102,
                                                                    103,
                                                                    105,
                                                                    1)),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      flex: 1,
                                                      child: Text(
                                                        widget
                                                                .compData?[
                                                                    index]
                                                                .cODE2SKUDATA
                                                                ?.sKUMRP ??
                                                            "0",
                                                        style: const TextStyle(
                                                            color:
                                                                Color.fromRGBO(
                                                                    195,
                                                                    67,
                                                                    40,
                                                                    1),
                                                            fontSize: 16,
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
                                );
                              }),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Visibility(
                          visible: true,
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Text('${widget.rangeDesc2}',
                                  maxLines: 3,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontFamily:
                                          AsianPaintsFonts.mulishRegular,
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromRGBO(
                                          244, 130, 33, 1)))),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                width: 70,
                                child: Text(
                                  'Total Price',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                '₹ $totalComp2Price',
                                style: const TextStyle(
                                    color: Color.fromRGBO(195, 67, 40, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 70,
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  side: const BorderSide(
                                      width: 1,
                                      color: Color.fromRGBO(11, 56, 85, 1)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  backgroundColor:
                                      const Color.fromRGBO(11, 56, 85, 1)),
                              onPressed: () {
                                showBundleSanwareFilter(context, "Competitor 2",
                                    widget.range2 ?? '');
                              },
                              child: Text(
                                'Add To Quote',
                                style: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishRegular,
                                    fontSize: 13,
                                    color: AsianPaintColors.whiteColor),
                              )),
                        ),
                      ],
                    ),
                  ),
            // ----------------------------------------------------------------------------
          ],
        ),
      ),
    ));
  }

  void showBundleSanwareFilter(
      BuildContext context, String competitor, String range) {
    String bundleType = '';
    String sanwareType = '';
    List<SKUData> skudDataList = [];
    List<AREANAME> areaNames = [];
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          insetPadding: const EdgeInsets.all(8),
          child: BlocConsumer<GetCompetitionSanBundResultBloc,
              CompetitionSearchSanBundState>(
            listener: (context, state) {
              if (state is CompetitionSearchSanBundLoaded) {
                GetCompetitionSanBundResultBloc competitionSanBundResultBloc =
                    context.read<GetCompetitionSanBundResultBloc>();
                logger(
                    "Ssanware result: ${competitionSanBundResultBloc.competitionSearchSanBundResponse?.bundleinfo?.bundle?[0].aREANAME?.length}");
                List<AREANAME> sanAreas = competitionSanBundResultBloc
                        .competitionSearchSanBundResponse
                        ?.bundleinfo
                        ?.sanware?[0]
                        .aREANAME ??
                    [];
                List<AREANAME> bundAreas = competitionSanBundResultBloc
                        .competitionSearchSanBundResponse
                        ?.bundleinfo
                        ?.bundle?[0]
                        .aREANAME ??
                    [];

                areaNames = [];
                for (int i = 0; i < sanAreas.length; i++) {
                  areaNames.add(sanAreas[i]);
                }
                for (int i = 0; i < bundAreas.length; i++) {
                  areaNames.add(bundAreas[i]);
                }

                for (int i = 0; i < areaNames.length; i++) {
                  AREANAME areaname = areaNames[i];
                  SKUData skuData = SKUData();
                  skuData.sKURANGE = areaname.sKURANGE;
                  skuData.sKUIMAGE = areaname.sKUIMAGE ?? '';
                  skuData.sKUCATEGORY = areaname.sKUCATEGORY;
                  skuData.sKUUSP = areaname.sKUUSP;
                  skuData.sKUPRODUCTCAT = areaname.sKUPRODUCTCAT;
                  skuData.sKUDESCRIPTION = areaname.sKUDESCRIPTION ?? '';
                  skuData.complementary = [];
                  skuData.sKUMRP = areaname.sKUMRP ?? '';
                  skuData.sKUCODE = areaname.sKUCODE ?? '';
                  skuData.sKUSRP = areaname.sKUUSP;
                  skuData.sKUDRAWING = areaname.sKUDRAWING;
                  skuData.sKUBRAND = areaname.sKUBRAND;

                  List<String> areas = [];
                  List<Area> areasList = [];
                  int price = 0;

                  for (int j = 0; j < (areaname.aREAINFOBJ ?? []).length; j++) {
                    areas = [];
                    areasList = [];
                    if (areas.isNotEmpty) {
                      if (areas[j].trim() != areaname.aREAINFOBJ?[j].aREA) {
                        areas.add(areaname.aREAINFOBJ?[j].aREA ?? '');
                        break;
                      }
                    } else {
                      areas.add(areaname.aREAINFOBJ?[j].aREA ?? '');
                    }

                    if (areasList.isNotEmpty) {
                      if ((areasList[j].areaname ?? '').trim() !=
                          areaname.aREAINFOBJ?[j].aREA) {
                        areasList.add(Area(
                            areaname: areaname.aREAINFOBJ?[j].aREA ?? '',
                            areaqty: areaname.aREAINFOBJ?[j].qTY ?? ''));
                        break;
                      }
                    } else {
                      areasList.add(Area(
                          areaname: areaname.aREAINFOBJ?[j].aREA ?? '',
                          areaqty: areaname.aREAINFOBJ?[j].qTY ?? ''));
                    }
                  }
                  // logger('Areas Length: ${areas.length}');
                  // logger('Area length: ${areasList.length}');
                  skuData.aREAINFO = areas;
                  skuData.areaInfo = areasList;

                  skuData.skuCatCode = areaname.sKUCATCODE ?? '';
                  skuData.sKUTYPE = '';
                  skuData.discount = 0;
                  skuData.quantity = '1';
                  // logger('SKU MRP: ${areaname.sKUMRP}');
                  skuData.totalPrice = int.parse(
                      areaname.sKUMRP == 'NA' ? '0' : areaname.sKUMRP ?? '0');
                  skuData.totalPriceAfterDiscount = int.parse(
                      areaname.sKUMRP == 'NA' ? '0' : areaname.sKUMRP ?? '0');
                  skuData.index = 0;

                  skuData.skuTypeExpanded = '';
                  skuData.productCardDescriptior = '';
                  price += skuData.totalPriceAfterDiscount ?? 0;

                  skudDataList.add(skuData);
                }
                Navigator.pop(context);
                if (Journey.skuResponseLists.isNotEmpty) {
                  showCreateExistingDialog(context, skudDataList, competitor);
                } else {
                  calculateSKU(skudDataList, competitor);
                }
              }
            },
            builder: (context, state) {
              GetCompetitionSanBundResultBloc competitionSanBundResultBloc =
                  context.read<GetCompetitionSanBundResultBloc>();
              return Container(
                width: 280,
                height: 280,
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Choose Options',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AsianPaintsFonts.bathSansRegular,
                          color: AsianPaintColors.buttonTextColor,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Center(
                            child: Autocomplete(
                          // initialValue:
                          //     TextEditingValue(text: brandText ?? ''),
                          optionsBuilder: ((TextEditingValue textValue) {
                            bundleType = textValue.text;

                            return (widget.bundleList ?? []).where((ele) => ele
                                .toLowerCase()
                                .startsWith(textValue.text.toLowerCase()));
                          }),
                          onSelected: (selectesString) {
                            print(selectesString);
                            bundleType = selectesString;
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                child: SizedBox(
                                  width: 200,
                                  height: 400,
                                  child: RawScrollbar(
                                    thumbVisibility: true,
                                    child: ListView.separated(
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          final option =
                                              options.elementAt(index);

                                          return ListTile(
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
                                        separatorBuilder: (context, index) =>
                                            const Divider(),
                                        itemCount: options.length),
                                  ),
                                ),
                              ),
                            );
                          },
                          fieldViewBuilder: (context, textEditingController,
                              focusNode, onFieldSubmitted) {
                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              style: TextStyle(
                                  fontFamily: AsianPaintsFonts.mulishRegular,
                                  fontSize: 12),
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                          color: Colors.black)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                          color: Colors.black)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                          color: Colors.black)),
                                  hintText: 'Bundle Type*',
                                  hintStyle: const TextStyle(fontSize: 10),
                                  suffixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.black,
                                  )),
                            );
                          },
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Center(
                            child: Autocomplete(
                          // initialValue:
                          //     TextEditingValue(text: brandText ?? ''),
                          optionsBuilder: ((TextEditingValue textValue) {
                            sanwareType = textValue.text;
                            if (bundleType.isEmpty) {
                              FlutterToastProvider()
                                  .show(message: 'Please select bundle type');
                              return const Iterable<String>.empty();
                            } else {
                              return (widget.sanwareList ?? []).where((ele) =>
                                  ele.toLowerCase().startsWith(
                                      textValue.text.toLowerCase()));
                            }
                          }),
                          onSelected: (selectesString) {
                            print(selectesString);
                            sanwareType = selectesString;
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                child: SizedBox(
                                  width: 200,
                                  height: 400,
                                  child: RawScrollbar(
                                    thumbVisibility: true,
                                    child: ListView.separated(
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          final option =
                                              options.elementAt(index);

                                          return ListTile(
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
                                        separatorBuilder: (context, index) =>
                                            const Divider(),
                                        itemCount: options.length),
                                  ),
                                ),
                              ),
                            );
                          },
                          fieldViewBuilder: (context, textEditingController,
                              focusNode, onFieldSubmitted) {
                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              style: TextStyle(
                                  fontFamily: AsianPaintsFonts.mulishRegular,
                                  fontSize: 12),
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                          color: Colors.black)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                          color: Colors.black)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                          color: Colors.black)),
                                  hintText: 'Sanware Type',
                                  hintStyle: const TextStyle(fontSize: 10),
                                  suffixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.black,
                                  )),
                            );
                          },
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: SizedBox(
                        height: 45,
                        width: 350,
                        child: APElevatedButton(
                          onPressed: () async {
                            competitionSanBundResultBloc
                                .getCompetitionSanBundList(
                                    range: range,
                                    bundle: bundleType,
                                    sanware: sanwareType);
                          },
                          label: state is CompetitionSearchSanBundLoading
                              ? Center(
                                  child: SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                        color:
                                            AsianPaintColors.buttonTextColor),
                                  ),
                                )
                              : Text(
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
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showCreateExistingDialog(
      BuildContext context, List<SKUData> skuData, String competitor) {
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
                width: 350,
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

                                      calculateSKU(skuData, competitor);
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

  void calculateSKU(List<SKUData> skuSData, String competitor) {
    int price = 0;
    List<SKUData> skuDataList = [];

    logger('Journey list length before: ${Journey.skuResponseLists.length}');
    for (int i = 0; i < (skuSData).length; i++) {
      if (i < (skuSData).length - 1) {
        if (skuSData[i].skuCatCode != skuSData[i + 1].skuCatCode) {
          Journey.skuResponseLists.add(skuSData[i]);
        }
      } else {
        Journey.skuResponseLists.add(skuSData[i]);
      }
    }
    logger('Journey list length after: ${Journey.skuResponseLists.length}');

    secureStorageProvider.saveQuoteToDisk(Journey.skuResponseLists);
    secureStorageProvider.saveCartDetails(skuDataList);

    secureStorageProvider.saveTotalPrice(price.toString());

    secureStorageProvider.saveQuoteToDisk(Journey.skuResponseLists);
    secureStorageProvider.saveCartDetails(skuDataList);

    secureStorageProvider.saveTotalPrice(price.toString());
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
