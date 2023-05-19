import 'dart:convert';
import 'dart:io';

import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/arguments.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/models/project_description_response_model.dart';
import 'package:APaints_QGen/src/data/models/sku_request_model.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/create_quote/create_quote_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/create_quote/create_quote_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/export_project/export_project_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/export_project/export_project_state.dart';
import 'package:APaints_QGen/src/presentation/views/home/home_screen.dart';
import 'package:APaints_QGen/src/presentation/views/project/project_description.dart';
import 'package:APaints_QGen/src/presentation/views/project/projects_list.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/sku_list.dart';
import 'package:APaints_QGen/src/presentation/widgets/app_bar.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/elevated_button.dart';
import 'package:APaints_QGen/src/presentation/widgets/my_projects_ui_web.dart';
import 'package:APaints_QGen/src/presentation/widgets/pdf_cache_url.dart';
import 'package:APaints_QGen/src/presentation/widgets/sidemenunav.dart';
import 'package:APaints_QGen/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/datasources/remote/secure_storage_provider.dart';

class ViewQuote extends StatefulWidget {
  static const routeName = Routes.ViewQuoteScreen;
  SKUData? skuData;
  String? quantity;
  int? totalPrice;
  List<SKUData>? skuResponseList;
  List<Projectdetails>? projectDetailsList;
  bool? fromFlip;
  bool? fromFlipScreen = false;
  String? projectID;
  int? totalWithGST;
  int? totalDiscountAmount;

  final int catIndex, brandIndex, rangeIndex;
  final String? category, brand, range;

  ViewQuote(
      {super.key,
      this.skuData,
      this.quantity,
      this.totalPrice,
      required this.catIndex,
      required this.brandIndex,
      required this.rangeIndex,
      this.category,
      this.brand,
      this.range,
      this.skuResponseList,
      this.projectDetailsList,
      this.fromFlip,
      this.projectID,
      this.fromFlipScreen,
      this.totalWithGST,
      this.totalDiscountAmount});

  @override
  State<ViewQuote> createState() => _ViewQuoteState();
}

class _ViewQuoteState extends State<ViewQuote> {
  final secureStorageProvider = getSingleton<SecureStorageProvider>();
  // List<SKUData> skuDataList = Journey.skuDataList!;
  List<TextEditingController> discountControllers = [];
  List<TextEditingController> qtyControllers = [];
  bool isFirstTime = true;
  int totPrice = 0;

  double totalAfterGST = 0;
  double totalBeforeGST = 0;
  int totalDiscountAmount = 0;
  String? projectID;
  List<String> areas = [
    'SHOWER',
    'KITCHEN_REFUGE',
    'BASIN',
    'WC',
  ];
  Map<int, int> quantities = {};
  List<String> isChecked = [];
  late Arguments arguments;
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();

  @override
  void initState() {
    super.initState();

    logger('Project ID in view quote: ${widget.projectID}');
  }

  String? validate = "VALIDATOR";
  int? preGst = 0;
  String? category, brand, range;
  Color borderColor = AsianPaintColors.segregationColor;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    logger('Quote ID: ${Journey.quoteID}');
    logger("Response Size in widget: ${json.encode(widget.skuResponseList)}");
    bool _value = false;
    late BuildContext dialogContext;
    Map<int, String> areaData = {};
    List<Area>? areaInfo = [];
    int? catIndex, brandIndex, rangeIndex;

    Future<List<SKUData>> getSkuList() async {
      String price = await secureStorageProvider.getTotalPrice();
      projectID = await secureStorageProvider.getProjectID();
      logger("project ID in async: $projectID");
      logger('From flip: ${widget.fromFlip}');
      totalBeforeGST = double.parse(price);
      totalAfterGST = widget.fromFlipScreen ?? false
          ? totalBeforeGST
          : totalBeforeGST + ((totalBeforeGST * 18) / 100);
      logger('Total AfterPrice: $totalAfterGST');
      logger('Price: $price');

      return List<SKUData>.from(
          await _secureStorageProvider.getQuoteFromDisk() as Iterable);
    }

    return FutureBuilder<List<SKUData>>(
      future: getSkuList(),
      builder: (context, snapshot) {
        Journey.skuResponseLists = snapshot.data ?? [];
        double price = 0;
        int quan = 0;
        logger('IS exist: ${Journey.isExist}');
        for (int i = 0; i < (snapshot.data ?? []).length; i++) {
          if (snapshot.data?[i].discount == 0 &&
              (snapshot.data?[i].netDiscount == '0' ||
                  snapshot.data?[i].netDiscount == null) &&
              (Journey.isExist ?? false)) {
            snapshot.data?[i].netDiscount =
                (((((snapshot.data?[i].discount ?? 0) / 100) + 0.18) / 1.18) *
                        100)
                    .toStringAsFixed(5);
            double values = double.parse('${snapshot.data?[i].totalPrice}') *
                double.parse(snapshot.data?[i].netDiscount ?? '0');
            double discountAmount = double.parse('${values / 100}');

            snapshot.data?[i].totalPriceAfterDiscount =
                ((snapshot.data?[i].totalPrice) ?? 0) - discountAmount.round();
          } else {
            logger('Discount in for: ${snapshot.data?[i].netDiscount}');
            if ((widget.fromFlip ?? false)) {
              snapshot.data?[i].netDiscount =
                  (((((snapshot.data?[i].discount ?? 0) / 100) + 0.18) / 1.18) *
                          100)
                      .toStringAsFixed(5);
              logger('Net Discount in for: ${snapshot.data?[i].netDiscount}');
              logger('Total price in for: ${snapshot.data?[i].totalPrice}');
              double values = double.parse('${snapshot.data?[i].totalPrice}') *
                  double.parse(snapshot.data?[i].netDiscount ?? '0');
              double discountAmount = double.parse('${values / 100}');

              snapshot.data?[i].totalPriceAfterDiscount =
                  ((snapshot.data?[i].totalPrice) ?? 0) -
                      discountAmount.round();
            } else {
              snapshot.data?[i].netDiscount =
                  (((((snapshot.data?[i].discount ?? 0) / 100) + 0.18) / 1.18) *
                          100)
                      .toStringAsFixed(5);
              logger('Net Discount in for: ${snapshot.data?[i].netDiscount}');
              double values = double.parse('${snapshot.data?[i].totalPrice}') *
                  double.parse(snapshot.data?[i].netDiscount ?? '0');
              double discountAmount = double.parse('${values / 100}');

              snapshot.data?[i].totalPriceAfterDiscount =
                  ((snapshot.data?[i].totalPrice) ?? 0) -
                      discountAmount.round();
            }

            logger(
                'Total Discount in for: ${snapshot.data?[i].totalPriceAfterDiscount}');
          }
          quan += int.parse(snapshot.data?[i].quantity ?? '0');

          if ((widget.fromFlip ?? false)) {
            snapshot.data?[i].netDiscount =
                (((((snapshot.data?[i].discount ?? 0) / 100) + 0.18) / 1.18) *
                        100)
                    .toStringAsFixed(5);
            double values = double.parse('${snapshot.data?[i].totalPrice}') *
                double.parse(snapshot.data?[i].netDiscount ?? '0');
            double discountAmount = double.parse('${values / 100}');
            price += ((snapshot.data?[i].totalPrice) ?? 0) - discountAmount;
          } else {
            snapshot.data?[i].totalPrice =
                int.parse(snapshot.data?[i].quantity ?? '0') *
                    ((snapshot.data?[i].sKUMRP ?? '').isEmpty
                        ? 0
                        : int.parse(snapshot.data?[i].sKUMRP ?? ''));
            snapshot.data?[i].netDiscount =
                (((((snapshot.data?[i].discount ?? 0) / 100) + 0.18) / 1.18) *
                        100)
                    .toStringAsFixed(5);
            double values = double.parse('${snapshot.data?[i].totalPrice}') *
                double.parse(snapshot.data?[i].netDiscount ?? '0');
            double discountAmount = double.parse('${values / 100}');
            price += ((snapshot.data?[i].totalPrice) ?? 0) - discountAmount;
            snapshot.data?[i].totalPriceAfterDiscount =
                ((snapshot.data?[i].totalPrice) ?? 0) - discountAmount.round();
          }

          totalBeforeGST = price;
          logger('Quantity 1: ${snapshot.data?[i].quantity}');
          logger('Mrp: ${snapshot.data?[i].sKUMRP}');
          logger('Price: $price');
          totalAfterGST = widget.fromFlipScreen ?? false
              ? totalBeforeGST
              : totalBeforeGST + ((totalBeforeGST * 18) / 100).round();

          totalDiscountAmount += (((snapshot.data?[i].totalPrice ?? 0) *
                  (double.parse(snapshot.data?[i].netDiscount ?? '0')) /
                  100)
              .round());

          logger('Total With GST: $totalAfterGST');

          // totalAfterGST = totalAfterGST - totalDiscountAmount;
          if (widget.totalWithGST != null && widget.totalWithGST != 0) {
            totalAfterGST = (widget.totalWithGST ?? 0).roundToDouble();
            totalDiscountAmount = widget.totalDiscountAmount ?? 0;
          }
        }
        Journey.totalQuantity = snapshot.data?.length;
        // getRange(snapshot.data ?? []);
        if ((snapshot.data ?? []).isNotEmpty) {
          try {
            List<String> ranges = [];
            for (int i = 0; i < (snapshot.data ?? []).length; i++) {
              ranges.add(((snapshot.data?[i].sKURANGE ?? '').isNotEmpty
                  ? (snapshot.data?[i].sKURANGE ?? '')
                  : 'Body Showers'));
            }
            logger('Ranges: ${json.encode(ranges)}');
            var map = {};

            for (var x in ranges) {
              map[x] = !map.containsKey(x) ? (1) : (map[x] + 1);
            }
            logger('Ranges: $ranges');

            // Count occurrences of each item
            final folded = ranges.fold({}, (acc, curr) {
              acc[curr] = (acc[curr] ?? 0) + 1;
              return acc;
            });

            logger('Folded: $folded');

            // Sort the keys (your values) by its occurrences
            final sortedKeys = folded.keys.toList()
              ..sort((a, b) => folded[b].compareTo(folded[a]));
            logger('Sorted keys: $sortedKeys');
            category = '';
            brand = '';
            range = (sortedKeys.first) ?? '';
            logger('Range : ${sortedKeys.first}');

            for (int i = 0; i < (snapshot.data ?? []).length; i++) {
              if ((snapshot.data)?[i].sKURANGE == range) {
                category = snapshot.data?[i].sKUCATEGORY ?? '';
                brand = snapshot.data?[i].sKUBRAND ?? '';
              }
              // else {
              //   category = 'Bath Fittings';
              //   brand = 'Showers';
              // }
            }

            logger('Category : $category');
            logger('Brand : $brand');

            catIndex = (Journey.catagoriesData ?? []).indexWhere(
              (element) =>
                  element.category ==
                  ((category ?? 'Bath Fittings').isEmpty
                      ? 'Bath Fittings'
                      : category),
            );

            brandIndex =
                ((Journey.catagoriesData ?? [])[catIndex ?? 0].list ?? [])
                    .indexWhere((element) =>
                        element.brand ==
                        ((brand ?? 'Showers').isEmpty ? 'Showers' : brand));
            rangeIndex = (((Journey.catagoriesData ?? [])[catIndex ?? 0].list ??
                            [])[brandIndex ?? 0]
                        .range ??
                    [])
                .indexWhere((element) =>
                    element.skuRange ==
                    ((range ?? 'Body Showers').isEmpty
                        ? 'Body Showers'
                        : range));
          } on Exception catch (e) {
            logger(e.toString());
          }
        }
        logger('Sapshot Data: ${snapshot.data?.length}');

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.done:
            // if (snapshot.data == null) {
            //   snapshot.data = widget.skuResponseList;
            // }
            return Responsive(
              mobile: StatefulBuilder(
                builder: (context, setState) {
                  secureStorageProvider.saveCartCount(snapshot.data?.length);

                  return SafeArea(
                    child: Scaffold(
                      backgroundColor: AsianPaintColors.appBackgroundColor,
                      appBar: AppBarTemplate(
                        isVisible: false,
                        header: AppLocalizations.of(context).quote,
                      ),
                      body: (snapshot.data ?? []).isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Center(
                                    child: Text('Cart is empty'),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          height: 40,
                                          width: 120,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              Journey.selectedIndex = 0;
                                              Journey.skuResponseLists =
                                                  snapshot.data ?? [];
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomeScreen(
                                                          loginType: Journey
                                                              .loginType),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(35.0),
                                              ),
                                              backgroundColor: AsianPaintColors
                                                  .userTypeTextColor,
                                              shadowColor: AsianPaintColors
                                                  .buttonBorderColor,
                                              textStyle: TextStyle(
                                                color: AsianPaintColors
                                                    .buttonTextColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: AsianPaintsFonts
                                                    .mulishRegular,
                                              ),
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .add_sku,
                                              style: TextStyle(
                                                fontFamily:
                                                    AsianPaintsFonts.mulishBold,
                                                color:
                                                    AsianPaintColors.whiteColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: SizedBox(
                                      height: 40,
                                      width: 120,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(
                                            () {
                                              setState(
                                                () {
                                                  logger(
                                                      'On pressed for clear data');
                                                  Journey.skuResponseLists = [];
                                                  snapshot.data?.clear();
                                                  secureStorageProvider
                                                      .saveQuoteToDisk(Journey
                                                          .skuResponseLists);
                                                  secureStorageProvider
                                                      .saveCartCount(0);
                                                },
                                              );
                                            },
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(35.0),
                                          ),
                                          backgroundColor: AsianPaintColors
                                              .userTypeTextColor,
                                          shadowColor: AsianPaintColors
                                              .buttonBorderColor,
                                          textStyle: TextStyle(
                                            color: AsianPaintColors
                                                .buttonTextColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            fontFamily:
                                                AsianPaintsFonts.mulishRegular,
                                          ),
                                        ),
                                        child: Text(
                                          'Clear cart',
                                          style: TextStyle(
                                            fontFamily:
                                                AsianPaintsFonts.mulishBold,
                                            color: AsianPaintColors.whiteColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Expanded(
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: ListView.separated(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        separatorBuilder:
                                            (BuildContext context, int index) =>
                                                const Divider(
                                          color: Colors.transparent,
                                          endIndent: 5,
                                          indent: 5,
                                        ),
                                        itemCount: snapshot.data?.length ?? 0,
                                        itemBuilder: (context, index) {
                                          // widget.skuResponseList?[index].discount = 0;
                                          // skuDataList[index].totalAmount =
                                          if ((snapshot.data ?? []).isEmpty) {
                                            return const Center(
                                              child: Text('No data available'),
                                            );
                                          } else {
                                            return Card(
                                              shadowColor: AsianPaintColors
                                                  .bottomTextColor,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  color: (snapshot.data?[index]
                                                                      .areaInfo ??
                                                                  [])
                                                              .isNotEmpty &&
                                                          (snapshot
                                                                      .data?[
                                                                          index]
                                                                      .areaInfo?[
                                                                          0]
                                                                      .areaqty ??
                                                                  '')
                                                              .isEmpty
                                                      ? borderColor
                                                      : AsianPaintColors
                                                          .segregationColor,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              elevation: 0,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: ListTile(
                                                contentPadding:
                                                    const EdgeInsets.all(10),
                                                tileColor:
                                                    AsianPaintColors.whiteColor,
                                                leading: SizedBox(
                                                  width: 60,
                                                  height: 60,
                                                  child: Image.network((snapshot
                                                                  .data?[index]
                                                                  .sKUIMAGE ??
                                                              '')
                                                          .isEmpty
                                                      ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
                                                      : snapshot.data?[index]
                                                              .sKUIMAGE ??
                                                          ''),
                                                ),
                                                title: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          snapshot.data?[index]
                                                                  .skuCatCode ??
                                                              '',
                                                          style: TextStyle(
                                                              color: AsianPaintColors
                                                                  .projectUserNameColor,
                                                              fontFamily:
                                                                  AsianPaintsFonts
                                                                      .mulishMedium,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            setState(
                                                              () {
                                                                setState(() {
                                                                  snapshot
                                                                      .data?[
                                                                          index]
                                                                      .totalPrice = int.parse(
                                                                          snapshot.data?[index].quantity ??
                                                                              '0') *
                                                                      int.parse(
                                                                          snapshot.data?[index].sKUMRP ??
                                                                              '');
                                                                  snapshot.data
                                                                      ?.removeAt(
                                                                          index);
                                                                  if ((snapshot
                                                                              .data ??
                                                                          [])
                                                                      .isEmpty) {
                                                                    totalAfterGST =
                                                                        0;
                                                                    totalDiscountAmount =
                                                                        0;
                                                                  }
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          snapshot
                                                                              .data!
                                                                              .length;
                                                                      i++) {
                                                                    totalAfterGST =
                                                                        0;
                                                                    totalDiscountAmount =
                                                                        0;
                                                                    totalBeforeGST =
                                                                        0;

                                                                    setState(
                                                                      () {
                                                                        double
                                                                            values =
                                                                            double.parse('${snapshot.data?[i].totalPrice}') *
                                                                                double.parse('${snapshot.data?[i].netDiscount}');
                                                                        double
                                                                            discountAmount =
                                                                            double.parse('${values / 100}');
                                                                        snapshot
                                                                            .data?[
                                                                                i]
                                                                            .totalPriceAfterDiscount = ((snapshot.data?[i].totalPrice) ??
                                                                                0) -
                                                                            discountAmount.round();

                                                                        snapshot
                                                                            .data?[
                                                                                i]
                                                                            .discPrice = ((snapshot.data?[i].totalPrice) ??
                                                                                0) -
                                                                            discountAmount;
                                                                        logger(
                                                                            'Total price amount: ${snapshot.data?[i].totalPriceAfterDiscount}');
                                                                        snapshot
                                                                            .data
                                                                            ?.forEach((element) {
                                                                          totalDiscountAmount +=
                                                                              ((element.totalPrice! * double.parse(element.netDiscount ?? '0')) / 100).round();
                                                                          totalAfterGST +=
                                                                              (element.discPrice ?? 0);

                                                                          logger(
                                                                              totalDiscountAmount);
                                                                        });
                                                                        totalBeforeGST =
                                                                            totalAfterGST;
                                                                        totalAfterGST +=
                                                                            ((totalAfterGST * 18) / 100).round();
                                                                        logger(
                                                                            totalAfterGST);
                                                                      },
                                                                    );
                                                                  }
                                                                  Journey.skuResponseLists =
                                                                      snapshot.data ??
                                                                          [];
                                                                  if ((snapshot
                                                                              .data ??
                                                                          [])
                                                                      .isNotEmpty) {
                                                                    List<String>
                                                                        ranges =
                                                                        [];
                                                                    for (int i =
                                                                            0;
                                                                        i < (snapshot.data ?? []).length;
                                                                        i++) {
                                                                      ranges.add(
                                                                          snapshot.data?[i].sKURANGE ??
                                                                              '');
                                                                    }
                                                                    // logger('Ranges: ${json.encode(ranges)}');
                                                                    var map =
                                                                        {};

                                                                    for (var x
                                                                        in ranges) {
                                                                      map[x] = !map.containsKey(
                                                                              x)
                                                                          ? (1)
                                                                          : (map[x] +
                                                                              1);
                                                                    }
                                                                    logger(
                                                                        'Ranges: $ranges');

                                                                    // Count occurrences of each item
                                                                    final folded =
                                                                        ranges.fold(
                                                                            {},
                                                                            (acc,
                                                                                curr) {
                                                                      acc[curr] =
                                                                          (acc[curr] ?? 0) +
                                                                              1;
                                                                      return acc;
                                                                    });

                                                                    // Sort the keys (your values) by its occurrences
                                                                    final sortedKeys = folded
                                                                        .keys
                                                                        .toList()
                                                                      ..sort((a,
                                                                              b) =>
                                                                          folded[b]
                                                                              .compareTo(folded[a]));

                                                                    category =
                                                                        '';
                                                                    brand = '';
                                                                    range =
                                                                        sortedKeys
                                                                            .first;
                                                                    for (int i =
                                                                            0;
                                                                        i < ((snapshot).data ?? []).length;
                                                                        i++) {
                                                                      if ((snapshot.data)?[i]
                                                                              .sKURANGE ==
                                                                          map.keys
                                                                              .toList()
                                                                              .first) {
                                                                        category =
                                                                            snapshot.data?[i].sKUCATEGORY ??
                                                                                '';
                                                                        brand =
                                                                            snapshot.data?[i].sKUBRAND ??
                                                                                '';
                                                                      }
                                                                    }
                                                                    catIndex = (Journey.catagoriesData ??
                                                                            [])
                                                                        .indexWhere(
                                                                      (element) =>
                                                                          element
                                                                              .category ==
                                                                          category,
                                                                    );
                                                                    brandIndex = ((Journey.catagoriesData ?? [])[catIndex ?? 0].list ??
                                                                            [])
                                                                        .indexWhere((element) =>
                                                                            element.brand ==
                                                                            brand);
                                                                    rangeIndex = (((Journey.catagoriesData ?? [])[catIndex ?? 0].list ?? [])[brandIndex ?? 0].range ??
                                                                            [])
                                                                        .indexWhere((element) =>
                                                                            element.skuRange ==
                                                                            range);
                                                                  }

                                                                  secureStorageProvider
                                                                      .saveQuoteToDisk(
                                                                          snapshot.data ??
                                                                              []);
                                                                  int quantity =
                                                                      0;
                                                                  int cartCount =
                                                                      0;
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          Journey
                                                                              .skuResponseLists
                                                                              .length;
                                                                      i++) {
                                                                    quantity += int.parse(
                                                                        Journey.skuResponseLists[i].quantity ??
                                                                            '');
                                                                  }
                                                                  cartCount = Journey
                                                                      .skuResponseLists
                                                                      .length;
                                                                  _secureStorageProvider
                                                                      .saveCartCount(
                                                                          cartCount);

                                                                  logger(
                                                                      'Cart count: $cartCount');
                                                                  logger(
                                                                      'Quantity: $quantity');
                                                                });
                                                                // Navigator.pop(context);
                                                                logger(
                                                                    'Length: ${snapshot.data?.length}');
                                                              },
                                                            );
                                                          },
                                                          child: Image.asset(
                                                            'assets/images/cancel.png',
                                                            width: 12,
                                                            height: 12,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            snapshot
                                                                    .data?[
                                                                        index]
                                                                    .sKUDESCRIPTION ??
                                                                '',
                                                            textAlign: TextAlign
                                                                .justify,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            softWrap: false,
                                                            textWidthBasis:
                                                                TextWidthBasis
                                                                    .longestLine,
                                                            style: TextStyle(
                                                              color: AsianPaintColors
                                                                  .skuDescriptionColor,
                                                              fontFamily:
                                                                  AsianPaintsFonts
                                                                      .mulishRegular,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        (Journey.isExist ??
                                                                true)
                                                            ? Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        AppLocalizations.of(context)
                                                                            .add_discount,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              AsianPaintColors.quantityColor,
                                                                          fontFamily:
                                                                              AsianPaintsFonts.mulishMedium,
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            60,
                                                                        height:
                                                                            25,
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              TextFormField(
                                                                            enableInteractiveSelection:
                                                                                false,
                                                                            inputFormatters: <TextInputFormatter>[
                                                                              LengthLimitingTextInputFormatter(2),
                                                                              FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                                                            ],
                                                                            controller:
                                                                                TextEditingController.fromValue(TextEditingValue(text: (snapshot.data?[index].discount ?? 0).toString(), selection: TextSelection.fromPosition(TextPosition(offset: (snapshot.data?[index].discount ?? 0).toString().length)))),
                                                                            keyboardType:
                                                                                const TextInputType.numberWithOptions(signed: true, decimal: true),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            cursorColor:
                                                                                AsianPaintColors.kPrimaryColor,
                                                                            style: TextStyle(
                                                                                backgroundColor: AsianPaintColors.whiteColor,
                                                                                fontSize: 10,
                                                                                color: AsianPaintColors.kPrimaryColor,
                                                                                fontFamily: AsianPaintsFonts.mulishRegular),
                                                                            decoration:
                                                                                InputDecoration(
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
                                                                            onFieldSubmitted:
                                                                                (value) {
                                                                              if (isFirstTime && value != '0') {
                                                                                for (int i = 0; i < (snapshot.data ?? []).length; i++) {
                                                                                  setState(
                                                                                    () {
                                                                                      snapshot.data?[i].discount = int.parse(value);
                                                                                      snapshot.data?[i].netDiscount = (((((snapshot.data?[i].discount ?? 0) / 100) + 0.18) / 1.18) * 100).toStringAsFixed(5);
                                                                                    },
                                                                                  );
                                                                                  value.isNotEmpty || value != "0" ? (snapshot.data?[index].discount = int.parse(value)) : (snapshot.data?[index].discount = 0);
                                                                                  snapshot.data?[index].totalPrice = int.parse(snapshot.data?[index].quantity ?? '0') * int.parse(snapshot.data?[index].sKUMRP ?? '');

                                                                                  totalAfterGST = 0;
                                                                                  totalDiscountAmount = 0;
                                                                                  totalBeforeGST = 0;
                                                                                  // snapshot.data?[index].netDiscount = '${((((snapshot.data?[index].discount ?? 0) + 0.18) / 1.18) * 100).round()}';

                                                                                  setState(
                                                                                    () {
                                                                                      double values = double.parse('${snapshot.data?[i].totalPrice}') * double.parse('${snapshot.data?[i].netDiscount}');
                                                                                      double discountAmount = double.parse('${values / 100}');
                                                                                      logger('Discount amount: $discountAmount');
                                                                                      snapshot.data?[i].totalPriceAfterDiscount = ((snapshot.data?[i].totalPrice) ?? 0) - discountAmount.round();
                                                                                      snapshot.data?[i].discPrice = ((snapshot.data?[i].totalPrice) ?? 0) - discountAmount;
                                                                                      logger('Total price amount: ${snapshot.data?[i].totalPriceAfterDiscount}');
                                                                                      snapshot.data?.forEach((element) {
                                                                                        totalDiscountAmount += ((element.totalPrice! * double.parse(element.netDiscount ?? '0')) / 100).round();
                                                                                        totalAfterGST += (element.discPrice ?? 0);

                                                                                        logger(totalDiscountAmount);
                                                                                      });
                                                                                      totalBeforeGST = totalAfterGST;
                                                                                      totalAfterGST += ((totalAfterGST * 18) / 100).round();
                                                                                      logger("TotalAfterGST:  $totalAfterGST");
                                                                                    },
                                                                                  );
                                                                                }

                                                                                isFirstTime = false;
                                                                                Journey.skuResponseLists = snapshot.data ?? [];
                                                                                secureStorageProvider.saveQuoteToDisk(snapshot.data ?? []);
                                                                              }
                                                                            },
                                                                            onChanged:
                                                                                (value) async {
                                                                              if (value.isEmpty) {
                                                                                value = '0';
                                                                              }
                                                                              snapshot.data?[index].discount = int.parse(value);
                                                                              snapshot.data?[index].netDiscount = (((((snapshot.data?[index].discount ?? 0) / 100) + 0.18) / 1.18) * 100).toStringAsFixed(5);

                                                                              for (int i = 0; i < (snapshot.data ?? []).length; i++) {
                                                                                value.isNotEmpty || value != "0" ? (snapshot.data?[index].discount = int.parse(value)) : (snapshot.data?[index].discount = 0);
                                                                                snapshot.data?[index].totalPrice = int.parse(snapshot.data?[index].quantity ?? '0') * int.parse(snapshot.data?[index].sKUMRP ?? '');

                                                                                totalAfterGST = 0;
                                                                                totalBeforeGST = 0;
                                                                                totalDiscountAmount = 0;
                                                                                // snapshot.data?[index].netDiscount = '${((((snapshot.data?[index].discount ?? 0) + 0.18) / 1.18) * 100).round()}';

                                                                                setState(
                                                                                  () {
                                                                                    double values = double.parse('${snapshot.data?[i].totalPrice}') * double.parse('${snapshot.data?[i].netDiscount}');
                                                                                    double discountAmount = double.parse('${values / 100}');
                                                                                    logger('Discount amount: $discountAmount');
                                                                                    snapshot.data?[i].totalPriceAfterDiscount = ((snapshot.data?[i].totalPrice) ?? 0) - discountAmount.round();
                                                                                    snapshot.data?[i].discPrice = ((snapshot.data?[i].totalPrice) ?? 0) - discountAmount;
                                                                                    logger('Total price amount: ${snapshot.data?[i].totalPriceAfterDiscount}');
                                                                                    snapshot.data?.forEach((element) {
                                                                                      totalDiscountAmount += ((element.totalPrice! * double.parse(element.netDiscount ?? '0')) / 100).round();
                                                                                      totalAfterGST += (element.discPrice ?? 0);

                                                                                      logger(totalDiscountAmount);
                                                                                    });
                                                                                    totalBeforeGST = totalAfterGST;
                                                                                    totalAfterGST += ((totalAfterGST * 18) / 100).round();
                                                                                    logger("TotalAfterGST:  $totalAfterGST");
                                                                                  },
                                                                                );
                                                                              }
                                                                              Journey.skuResponseLists = snapshot.data ?? [];
                                                                              secureStorageProvider.saveQuoteToDisk(snapshot.data ?? []);
                                                                            },
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                ],
                                                              )
                                                            : const SizedBox(),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Text(
                                                              AppLocalizations.of(
                                                                      context)
                                                                  .pre_gst_discount,
                                                              style: TextStyle(
                                                                color: AsianPaintColors
                                                                    .quantityColor,
                                                                fontFamily:
                                                                    AsianPaintsFonts
                                                                        .mulishMedium,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  '${double.parse(snapshot.data?[index].netDiscount ?? '0').toStringAsFixed(2)} %',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .normal,
                                                                      fontFamily:
                                                                          AsianPaintsFonts
                                                                              .mulishRegular,
                                                                      color: AsianPaintColors
                                                                          .kPrimaryColor),
                                                                ))
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(children: [
                                                          Text(
                                                            'MRP:',
                                                            style: TextStyle(
                                                              color: AsianPaintColors
                                                                  .quantityColor,
                                                              fontFamily:
                                                                  AsianPaintsFonts
                                                                      .mulishMedium,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            '\u{20B9} ${snapshot.data?[index].sKUMRP ?? ''}',
                                                            style: TextStyle(
                                                              color: AsianPaintColors
                                                                  .kPrimaryColor,
                                                              fontFamily:
                                                                  AsianPaintsFonts
                                                                      .mulishBold,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ]),
                                                        Row(children: [
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .total_price,
                                                            style: TextStyle(
                                                                color: AsianPaintColors
                                                                    .quantityColor,
                                                                fontFamily:
                                                                    AsianPaintsFonts
                                                                        .mulishBold,
                                                                fontSize: 10),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            '\u{20B9} ${snapshot.data?[index].totalPriceAfterDiscount}',
                                                            style: TextStyle(
                                                                color: AsianPaintColors
                                                                    .forgotPasswordTextColor,
                                                                fontFamily:
                                                                    AsianPaintsFonts
                                                                        .mulishBold,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 10),
                                                          ),
                                                        ]),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          AppLocalizations.of(
                                                                  context)
                                                              .total_qty,
                                                          style: TextStyle(
                                                            color: AsianPaintColors
                                                                .quantityColor,
                                                            fontFamily:
                                                                AsianPaintsFonts
                                                                    .mulishMedium,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        SizedBox(
                                                          width: 50,
                                                          height: 25,
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child:
                                                                TextFormField(
                                                              enableInteractiveSelection:
                                                                  false,
                                                              inputFormatters: <
                                                                  TextInputFormatter>[
                                                                LengthLimitingTextInputFormatter(
                                                                    4),
                                                                FilteringTextInputFormatter
                                                                    .allow(RegExp(
                                                                        "[0-9]")),
                                                              ],
                                                              controller: TextEditingController.fromValue(TextEditingValue(
                                                                  text: (snapshot
                                                                              .data?[
                                                                                  index]
                                                                              .quantity ??
                                                                          1)
                                                                      .toString(),
                                                                  selection: TextSelection.fromPosition(TextPosition(
                                                                      offset: (snapshot.data?[index].quantity ??
                                                                              1)
                                                                          .toString()
                                                                          .length)))),

                                                              keyboardType:
                                                                  const TextInputType
                                                                          .numberWithOptions(
                                                                      signed:
                                                                          true,
                                                                      decimal:
                                                                          true),
                                                              // initialValue:
                                                              //     '${Journey.skuRequestBody!.quoteinfo![index].totalqty}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  backgroundColor:
                                                                      AsianPaintColors
                                                                          .whiteColor,
                                                                  fontSize: 10,
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishRegular,
                                                                  color: AsianPaintColors
                                                                      .kPrimaryColor),
                                                              cursorColor:
                                                                  AsianPaintColors
                                                                      .kPrimaryColor,
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: AsianPaintColors
                                                                        .quantityBorder,
                                                                  ),
                                                                ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: AsianPaintColors
                                                                        .quantityBorder,
                                                                  ),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: AsianPaintColors
                                                                        .quantityBorder,
                                                                  ),
                                                                ),
                                                              ),

                                                              onChanged:
                                                                  (value) {
                                                                if (value
                                                                    .isEmpty) {
                                                                  value = '0';
                                                                }
                                                                // if (value ==
                                                                //     '0') {
                                                                //   value = '1';
                                                                // }

                                                                if (value !=
                                                                    '0') {
                                                                  snapshot
                                                                      .data?[
                                                                          index]
                                                                      .quantity = value;

                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          (snapshot.data ?? [])
                                                                              .length;
                                                                      i++) {
                                                                    value.isNotEmpty ||
                                                                            value !=
                                                                                "0"
                                                                        ? (snapshot.data?[index].quantity =
                                                                            value)
                                                                        : (snapshot
                                                                            .data?[index]
                                                                            .quantity = '1');
                                                                    snapshot
                                                                        .data?[
                                                                            i]
                                                                        .totalPrice = int.parse((snapshot.data?[i].quantity ?? '0').isEmpty
                                                                            ? '1'
                                                                            : snapshot.data?[i].quantity ??
                                                                                '1') *
                                                                        int.parse(snapshot.data?[i].sKUMRP ??
                                                                            '');

                                                                    totalAfterGST =
                                                                        0;
                                                                    totalDiscountAmount =
                                                                        0;
                                                                    totalBeforeGST =
                                                                        0;
                                                                    // snapshot.data?[index].netDiscount = '${((((snapshot.data?[index].discount ?? 0) + 0.18) / 1.18) * 100).round()}';

                                                                    setState(
                                                                      () {
                                                                        logger(
                                                                            'Total Price: ${snapshot.data?[i].totalPrice}');
                                                                        logger(
                                                                            'Net Amount: ${snapshot.data?[i].netDiscount}');
                                                                        double
                                                                            values =
                                                                            double.parse('${snapshot.data?[i].totalPrice}') *
                                                                                double.parse('${snapshot.data?[i].netDiscount}');
                                                                        double
                                                                            discountAmount =
                                                                            double.parse('${values / 100}');
                                                                        logger(
                                                                            'Discount amount: $discountAmount');
                                                                        snapshot
                                                                            .data?[
                                                                                i]
                                                                            .totalPriceAfterDiscount = ((snapshot.data?[i].totalPrice) ??
                                                                                0) -
                                                                            discountAmount.round();
                                                                        snapshot
                                                                            .data?[
                                                                                i]
                                                                            .discPrice = ((snapshot.data?[i].totalPrice) ??
                                                                                0) -
                                                                            discountAmount;
                                                                        logger(
                                                                            'Total price amount: ${snapshot.data?[i].totalPriceAfterDiscount}');
                                                                        snapshot
                                                                            .data
                                                                            ?.forEach((element) {
                                                                          totalDiscountAmount +=
                                                                              ((element.totalPrice! * double.parse(element.netDiscount ?? '0')) / 100).round();
                                                                          totalAfterGST +=
                                                                              (element.discPrice ?? 0);

                                                                          logger(
                                                                              totalDiscountAmount);
                                                                        });
                                                                        totalBeforeGST =
                                                                            totalAfterGST;
                                                                        totalAfterGST +=
                                                                            ((totalAfterGST * 18) / 100).round();
                                                                        logger(
                                                                            "TotalAfterGST:  $totalAfterGST");
                                                                      },
                                                                    );
                                                                  }
                                                                  Journey.skuResponseLists =
                                                                      snapshot.data ??
                                                                          [];
                                                                  secureStorageProvider
                                                                      .saveQuoteToDisk(
                                                                          snapshot.data ??
                                                                              []);
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),

                                                    (snapshot.data?[index]
                                                                        .areaInfo ??
                                                                    [])
                                                                .isNotEmpty &&
                                                            ((snapshot
                                                                        .data?[
                                                                            index]
                                                                        .areaInfo
                                                                        ?.length ??
                                                                    0) <=
                                                                1) &&
                                                            ((snapshot
                                                                        .data?[
                                                                            index]
                                                                        .areaInfo?[
                                                                            0]
                                                                        .areaname ??
                                                                    '')
                                                                .isNotEmpty)
                                                        ? ListView.builder(
                                                            itemCount: snapshot
                                                                    .data?[
                                                                        index]
                                                                    .areaInfo
                                                                    ?.length ??
                                                                0,
                                                            shrinkWrap: true,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(0),
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            itemExtent: 50,
                                                            itemBuilder:
                                                                (context, ind) {
                                                              logger(
                                                                  'In quantity 1: ${snapshot.data?[index].areaInfo?[ind].areaqty ?? '1'}');
                                                              snapshot
                                                                  .data?[index]
                                                                  .areaInfo?[
                                                                      ind]
                                                                  .areaname = snapshot
                                                                      .data?[
                                                                          index]
                                                                      .areaInfo?[
                                                                          ind]
                                                                      .areaname
                                                                      ?.toUpperCase() ??
                                                                  '';
                                                              snapshot
                                                                  .data?[index]
                                                                  .areaInfo?[
                                                                      ind]
                                                                  .areaqty = (snapshot
                                                                              .data?[
                                                                                  index]
                                                                              .areaInfo?[
                                                                                  ind]
                                                                              .areaqty ??
                                                                          '1')
                                                                      .isEmpty
                                                                  ? '1'
                                                                  : snapshot
                                                                          .data?[
                                                                              index]
                                                                          .areaInfo?[
                                                                              ind]
                                                                          .areaqty ??
                                                                      '1';

                                                              return Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        3),
                                                                child:
                                                                    Container(
                                                                        color: AsianPaintColors
                                                                            .textFieldBorderColor,
                                                                        margin: const EdgeInsets.symmetric(
                                                                            vertical:
                                                                                0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                              child: Text(
                                                                                snapshot.data?[index].areaInfo?[ind].areaname?.toUpperCase() ?? '',
                                                                                style: TextStyle(
                                                                                  fontSize: 10,
                                                                                  fontFamily: AsianPaintsFonts.mulishRegular,
                                                                                  fontWeight: FontWeight.w400,
                                                                                  color: AsianPaintColors.skuDescriptionColor,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 70,
                                                                              child: Row(
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                                                                    child: Text(
                                                                                      'Qty:',
                                                                                      style: TextStyle(
                                                                                        fontSize: 8,
                                                                                        fontFamily: AsianPaintsFonts.mulishRegular,
                                                                                        fontWeight: FontWeight.w400,
                                                                                        color: AsianPaintColors.quantityColor,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 20,
                                                                                    height: 25,
                                                                                    child: Align(
                                                                                      alignment: Alignment.center,
                                                                                      child: Text(
                                                                                        (snapshot.data?[index].areaInfo?[ind].areaqty ?? '1').isEmpty ? '1' : '${snapshot.data?[index].areaInfo?[ind].areaqty ?? 0}',
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
                                                          )
                                                        : (snapshot
                                                                        .data?[
                                                                            index]
                                                                        .aREAINFO
                                                                        ?.length ??
                                                                    0) <=
                                                                1
                                                            ? ListView.builder(
                                                                itemCount: snapshot
                                                                        .data?[
                                                                            index]
                                                                        .aREAINFO
                                                                        ?.length ??
                                                                    0,
                                                                shrinkWrap:
                                                                    true,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(0),
                                                                physics:
                                                                    const NeverScrollableScrollPhysics(),
                                                                itemExtent: 50,
                                                                itemBuilder:
                                                                    (context,
                                                                        ind) {
                                                                  logger(
                                                                      'Quantity 2: ${(snapshot.data?[index].quantity ?? '1')}');
                                                                  snapshot
                                                                      .data?[
                                                                          index]
                                                                      .areaInfo?[
                                                                          ind]
                                                                      .areaname = snapshot
                                                                          .data?[
                                                                              index]
                                                                          .aREAINFO?[ind] ??
                                                                      '';
                                                                  snapshot
                                                                      .data?[
                                                                          index]
                                                                      .areaInfo?[
                                                                          ind]
                                                                      .areaqty = (snapshot.data?[index].quantity ??
                                                                              '1')
                                                                          .isEmpty
                                                                      ? '1'
                                                                      : snapshot
                                                                              .data?[index]
                                                                              .quantity ??
                                                                          '1';

                                                                  return Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        vertical:
                                                                            3),
                                                                    child: Container(
                                                                        color: AsianPaintColors.textFieldBorderColor,
                                                                        margin: const EdgeInsets.symmetric(vertical: 0),
                                                                        child: Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                              child: Text(
                                                                                snapshot.data?[index].aREAINFO?[ind] ?? '',
                                                                                style: TextStyle(
                                                                                  fontSize: 10,
                                                                                  fontFamily: AsianPaintsFonts.mulishRegular,
                                                                                  fontWeight: FontWeight.w400,
                                                                                  color: AsianPaintColors.skuDescriptionColor,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 70,
                                                                              child: Row(
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                                                                    child: Text(
                                                                                      'Qty:',
                                                                                      style: TextStyle(
                                                                                        fontSize: 8,
                                                                                        fontFamily: AsianPaintsFonts.mulishRegular,
                                                                                        fontWeight: FontWeight.w400,
                                                                                        color: AsianPaintColors.quantityColor,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 20,
                                                                                    height: 25,
                                                                                    child: Align(
                                                                                      alignment: Alignment.center,
                                                                                      child: Text(
                                                                                        (snapshot.data?[index].quantity ?? '1').isEmpty ? '1' : '${snapshot.data?[index].quantity ?? 1}',
                                                                                        // textAlign: TextAlign.center,
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
                                                              )
                                                            : ListView.builder(
                                                                itemCount: snapshot
                                                                    .data?[
                                                                        index]
                                                                    .areaInfo
                                                                    ?.length,
                                                                shrinkWrap:
                                                                    true,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(0),
                                                                physics:
                                                                    const NeverScrollableScrollPhysics(),
                                                                itemExtent: 50,
                                                                itemBuilder:
                                                                    (context,
                                                                        i) {
                                                                  logger(
                                                                      'Quantity 3: ${snapshot.data?[index].areaInfo?[i].areaqty}');
                                                                  return snapshot.data?[index].areaInfo?[i].areaqty == null ||
                                                                          snapshot.data?[index].areaInfo?[i].areaqty ==
                                                                              '0' ||
                                                                          snapshot.data?[index].areaInfo?[i].areaqty ==
                                                                              ''
                                                                      ? null
                                                                      : StatefulBuilder(builder:
                                                                          (context,
                                                                              setState) {
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
                                                                                      child: Text(
                                                                                        snapshot.data?[index].areaInfo?[i].areaname ?? '',
                                                                                        style: TextStyle(
                                                                                          fontSize: 10,
                                                                                          fontFamily: AsianPaintsFonts.mulishRegular,
                                                                                          fontWeight: FontWeight.w400,
                                                                                          color: AsianPaintColors.skuDescriptionColor,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 70,
                                                                                      child: Row(
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                                                                            child: Text(
                                                                                              'Qty:',
                                                                                              style: TextStyle(
                                                                                                fontSize: 8,
                                                                                                fontFamily: AsianPaintsFonts.mulishRegular,
                                                                                                fontWeight: FontWeight.w400,
                                                                                                color: AsianPaintColors.quantityColor,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 20,
                                                                                            height: 25,
                                                                                            child: Align(
                                                                                              alignment: Alignment.center,
                                                                                              child: Text(
                                                                                                (snapshot.data?[index].areaInfo?[i].areaqty ?? '1').isEmpty ? '1' : '${(snapshot.data?[index].areaInfo?[i].areaqty)}',
                                                                                                // textAlign: TextAlign.center,
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
                                                                        });
                                                                },
                                                              ),
                                                    // : const SizedBox(),
                                                    // Text(Journey.areaDetails?[0].areaqty ?? "Text"),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            snapshot
                                                                .data?[index]
                                                                .areaInfo = [];
                                                            areaInfo = [];

                                                            areaInfo = snapshot
                                                                .data?[index]
                                                                .aREAINFO
                                                                ?.map((e) =>
                                                                    Area(
                                                                        areaname:
                                                                            e))
                                                                .toList();

                                                            _value = false;
                                                            final Map<int,
                                                                    String>
                                                                data =
                                                                <int, String>{};
                                                            areas = [];

                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (dcontext) {
                                                                dialogContext =
                                                                    dcontext;
                                                                return Dialog(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  elevation:
                                                                      0.0,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      shape: BoxShape
                                                                          .rectangle,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                          color:
                                                                              Colors.black26,
                                                                          blurRadius:
                                                                              10.0,
                                                                          offset: Offset(
                                                                              0.0,
                                                                              10.0),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .all(
                                                                          10.0),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min, // To make the card compact
                                                                        children: <
                                                                            Widget>[
                                                                          InkWell(
                                                                            onTap:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                Align(
                                                                              alignment: Alignment.centerRight,
                                                                              child: Image.asset(
                                                                                'assets/images/cancel.png',
                                                                                width: 13,
                                                                                height: 13,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            'Select Area',
                                                                            style:
                                                                                TextStyle(
                                                                              color: AsianPaintColors.buttonTextColor,
                                                                              fontFamily: AsianPaintsFonts.bathSansRegular,
                                                                              fontSize: 20,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Center(
                                                                            child:
                                                                                Text.rich(
                                                                              TextSpan(
                                                                                text: 'Total Qty: ',
                                                                                style: TextStyle(fontFamily: AsianPaintsFonts.mulishRegular, fontSize: 11, fontWeight: FontWeight.w500, color: AsianPaintColors.quantityColor),
                                                                                children: <InlineSpan>[
                                                                                  TextSpan(
                                                                                    text: '${snapshot.data?[index].quantity ?? 0}',
                                                                                    style: TextStyle(fontSize: 11, fontFamily: AsianPaintsFonts.mulishMedium, color: AsianPaintColors.forgotPasswordTextColor),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          ListView
                                                                              .separated(
                                                                            separatorBuilder: (BuildContext context, int index) =>
                                                                                Divider(
                                                                              color: AsianPaintColors.quantityBorder,
                                                                              endIndent: 5,
                                                                              indent: 5,
                                                                            ),
                                                                            itemCount:
                                                                                areaInfo?.length ?? 0,
                                                                            shrinkWrap:
                                                                                true,
                                                                            padding:
                                                                                const EdgeInsets.all(0),
                                                                            physics:
                                                                                const NeverScrollableScrollPhysics(),
                                                                            itemBuilder:
                                                                                (context, ind) {
                                                                              return StatefulBuilder(
                                                                                builder: (context, setState) {
                                                                                  return SizedBox(
                                                                                    height: 40,
                                                                                    child: CheckboxListTile(
                                                                                      contentPadding: EdgeInsets.zero,
                                                                                      selected: _value,
                                                                                      value: _value,
                                                                                      autofocus: false,
                                                                                      controlAffinity: ListTileControlAffinity.leading,
                                                                                      title: Transform.translate(
                                                                                          offset: const Offset(-15, 0),
                                                                                          child: Text(
                                                                                            areaInfo?[ind].areaname ?? '',
                                                                                            style: TextStyle(
                                                                                              fontSize: 10,
                                                                                              fontFamily: AsianPaintsFonts.mulishMedium,
                                                                                              color: AsianPaintColors.quantityColor,
                                                                                            ),
                                                                                          )),
                                                                                      secondary: SizedBox(
                                                                                        width: 70,
                                                                                        child: Row(
                                                                                          children: [
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.fromLTRB(
                                                                                                0,
                                                                                                0,
                                                                                                3,
                                                                                                0,
                                                                                              ),
                                                                                              child: Text(
                                                                                                'Qty',
                                                                                                style: TextStyle(
                                                                                                  fontSize: 8,
                                                                                                  fontFamily: AsianPaintsFonts.mulishMedium,
                                                                                                  fontWeight: FontWeight.w400,
                                                                                                  color: AsianPaintColors.quantityColor,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: 40,
                                                                                              height: 25,
                                                                                              child: TextFormField(
                                                                                                enableInteractiveSelection: false,
                                                                                                controller: areaInfo?[ind].areaqtyController,
                                                                                                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(fontSize: 10, fontFamily: AsianPaintsFonts.mulishRegular, color: AsianPaintColors.kPrimaryColor),
                                                                                                cursorColor: AsianPaintColors.kPrimaryColor,
                                                                                                decoration: InputDecoration(
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
                                                                                                onChanged: (value) {
                                                                                                  setState(() {
                                                                                                    List<int>? validate = [];
                                                                                                    areaInfo?[ind].areaqty = value;

                                                                                                    if (value.isEmpty) {
                                                                                                      setState(
                                                                                                        () {
                                                                                                          _value = false;
                                                                                                        },
                                                                                                      );
                                                                                                    } else {
                                                                                                      setState(
                                                                                                        () {
                                                                                                          _value = true;
                                                                                                        },
                                                                                                      );
                                                                                                    }

                                                                                                    if (_value) {
                                                                                                      data[ind] = areaInfo?[ind].areaqty ?? '';
                                                                                                    } else {
                                                                                                      data.removeWhere((key, value) => key == ind);
                                                                                                    }
                                                                                                    int quantity = 0;
                                                                                                    if (data.values.isNotEmpty) {
                                                                                                      for (int i = 0; i < data.values.length; i++) {
                                                                                                        if (data.values.elementAt(i).isNotEmpty) {
                                                                                                          quantity += int.parse(data.values.elementAt(i));
                                                                                                          logger(quantity);
                                                                                                        }
                                                                                                      }

                                                                                                      if (quantity > int.parse(snapshot.data?[index].quantity ?? '')) {
                                                                                                        _value = true;
                                                                                                        FlutterToastProvider().show(message: 'Entered quantity is greater than total quantity');
                                                                                                      } else {
                                                                                                        if (areaInfo?[ind].areaqty != null) {
                                                                                                          if (_value) {
                                                                                                            if ((snapshot.data?[index].areaInfo ?? []).isNotEmpty) {
                                                                                                              logger("In contains");

                                                                                                              for (var element in List<Area>.from(snapshot.data?[index].areaInfo ?? [])) {
                                                                                                                if (element.areaname == areaInfo?[ind].areaname) {
                                                                                                                  logger("In if......");

                                                                                                                  element.areaqty = areaInfo![ind].areaqty;

                                                                                                                  // snapshot.data?[index].areaInfo?.remove(areaInfo?[ind]);
                                                                                                                } else {
                                                                                                                  logger("In else......");
                                                                                                                  snapshot.data?[index].areaInfo?.remove(areaInfo?[ind]);

                                                                                                                  snapshot.data?[index].areaInfo?.add(areaInfo![ind]);

                                                                                                                  // snapshot.data?[index].areaInfo?.add(areaInfo![ind]);
                                                                                                                }
                                                                                                              }

                                                                                                              // snapshot.data?[index].areaInfo?.add(areaInfo![ind]);
                                                                                                            } else {
                                                                                                              logger('In not contains');
                                                                                                              validate.add(ind);
                                                                                                              snapshot.data?[index].areaInfo?.add(areaInfo![ind]);
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                        Journey.skuResponseLists = snapshot.data ?? [];
                                                                                                        secureStorageProvider.saveQuoteToDisk(snapshot.data ?? []);
                                                                                                      }
                                                                                                    } else {
                                                                                                      Journey.skuResponseLists = snapshot.data ?? [];
                                                                                                      secureStorageProvider.saveQuoteToDisk(snapshot.data ?? []);
                                                                                                      logger('In else');
                                                                                                      Navigator.pop(context);
                                                                                                    }
                                                                                                    logger('In On changed: ${snapshot.data?[index].areaInfo?.length}');
                                                                                                  });
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      onChanged: (value) {
                                                                                        setState(() {
                                                                                          _value = !_value;
                                                                                        });
                                                                                      },
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              );
                                                                            },
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                20,
                                                                          ),
                                                                          Center(
                                                                            child:
                                                                                SizedBox(
                                                                              height: 40,
                                                                              width: MediaQuery.of(context).size.width * 0.5,
                                                                              child: ElevatedButton(
                                                                                onPressed: () async {
                                                                                  setState(() {});
                                                                                  int quantity = 0;
                                                                                  if (data.values.isNotEmpty) {
                                                                                    for (int i = 0; i < data.values.length; i++) {
                                                                                      if (data.values.elementAt(i).isNotEmpty) {
                                                                                        quantity += int.parse(data.values.elementAt(i));
                                                                                        logger(quantity);
                                                                                      }
                                                                                    }

                                                                                    if (quantity > int.parse(snapshot.data?[index].quantity ?? '')) {
                                                                                      _value = true;
                                                                                      snapshot.data?[index].areaInfo = [];
                                                                                      FlutterToastProvider().show(message: 'Entered quantity is greater than total quantity');
                                                                                    } else {
                                                                                      Navigator.pop(context, Arguments(data));
                                                                                    }
                                                                                  } else {
                                                                                    logger('In else');
                                                                                    Navigator.pop(context);
                                                                                  }
                                                                                },
                                                                                style: ElevatedButton.styleFrom(
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(35.0),
                                                                                  ),
                                                                                  backgroundColor: AsianPaintColors.buttonColor,
                                                                                  shadowColor: AsianPaintColors.buttonBorderColor,
                                                                                  textStyle: TextStyle(
                                                                                    color: AsianPaintColors.buttonTextColor,
                                                                                    fontSize: 10,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: AsianPaintsFonts.mulishRegular,
                                                                                  ),
                                                                                ),
                                                                                child: Text(
                                                                                  'Save',
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
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: Visibility(
                                                            visible: (snapshot
                                                                            .data?[index]
                                                                            .aREAINFO
                                                                            ?.length ??
                                                                        0) >
                                                                    1
                                                                ? true
                                                                : false,
                                                            child: Text(
                                                              AppLocalizations.of(
                                                                      context)
                                                                  .add_area,
                                                              style: TextStyle(
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                color: AsianPaintColors
                                                                    .buttonTextColor,
                                                                fontFamily:
                                                                    AsianPaintsFonts
                                                                        .mulishBold,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                            // singleItemList(
                                            //     widget.skuResponseList ?? [], index);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 0, 10, 0),
                                        child: RichText(
                                          text: TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: "Total SKU's Added: ",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishMedium,
                                                      fontSize: 12,
                                                      color: AsianPaintColors
                                                          .blackColor)),
                                              TextSpan(
                                                  text:
                                                      '${Journey.skuResponseLists.length}',
                                                  style: TextStyle(
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishBold,
                                                    color: AsianPaintColors
                                                        .kPrimaryColor,
                                                    fontSize: 13,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.transparent),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 5),
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: SizedBox(
                                              height: 40,
                                              width: 120,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  Journey.selectedIndex = 0;
                                                  Journey.skuResponseLists =
                                                      snapshot.data ?? [];
                                                  secureStorageProvider
                                                      .saveQuoteToDisk(
                                                          snapshot.data ?? []);

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SKUList(
                                                        brandIndex:
                                                            brandIndex ?? 0,
                                                        catIndex: catIndex ?? 0,
                                                        brand: brand,
                                                        category: category,
                                                        range: range,
                                                        rangeIndex:
                                                            rangeIndex ?? 0,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            35.0),
                                                  ),
                                                  backgroundColor:
                                                      AsianPaintColors
                                                          .userTypeTextColor,
                                                  shadowColor: AsianPaintColors
                                                      .buttonBorderColor,
                                                  textStyle: TextStyle(
                                                    color: AsianPaintColors
                                                        .buttonTextColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishRegular,
                                                  ),
                                                ),
                                                child: Text(
                                                  AppLocalizations.of(context)
                                                      .add_sku,
                                                  style: TextStyle(
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishBold,
                                                    color: AsianPaintColors
                                                        .whiteColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  BottomSheet(
                                    backgroundColor: Colors.white,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color:
                                              AsianPaintColors.bottomTextColor),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(25.0),
                                      ),
                                    ),
                                    onClosing: () {},
                                    builder: (context) {
                                      // logger('$totalQtyAmount');

                                      return Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: SizedBox(
                                          height: 100,
                                          child: Column(
                                            children: [
                                              Visibility(
                                                visible:
                                                    Journey.isExist ?? true,
                                                maintainAnimation:
                                                    Journey.isExist ?? true,
                                                maintainSize:
                                                    (Journey.isExist ?? true),
                                                maintainInteractivity:
                                                    (Journey.isExist ?? true),
                                                maintainState:
                                                    (Journey.isExist ?? true),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .discount_amount,
                                                      style: TextStyle(
                                                        color: AsianPaintColors
                                                            .chooseYourAccountColor,
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishRegular,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    Text(
                                                      '\u{20B9} $totalDiscountAmount',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishRegular,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: AsianPaintColors
                                                            .chooseYourAccountColor,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)
                                                        .total_amount_including_gst,
                                                    style: TextStyle(
                                                      color: AsianPaintColors
                                                          .chooseYourAccountColor,
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishBold,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Text(
                                                    '\u{20B9} ${totalAfterGST.round()}',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishBold,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: AsianPaintColors
                                                          .forgotPasswordTextColor,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              BlocConsumer<CreateQuoteBloc,
                                                  CreateQuoteState>(
                                                builder: (context, state) {
                                                  return Center(
                                                    child: SizedBox(
                                                      height: 50,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: APElevatedButton(
                                                        onPressed: () async {
                                                          bool isAreaEmpty =
                                                              false;

                                                          for (int i = 0;
                                                              i <
                                                                  (snapshot.data ??
                                                                          [])
                                                                      .length;
                                                              i++) {
                                                            logger(
                                                                "In Hello Area condition ${json.encode(snapshot.data?[i].areaInfo)}");
                                                            // if ((snapshot
                                                            //             .data?[
                                                            //                 i]
                                                            //             .areaInfo ??
                                                            //         [])
                                                            //     .isEmpty) {
                                                            //   isAreaEmpty =
                                                            //       true;
                                                            //   setState(
                                                            //     () {
                                                            //       borderColor =
                                                            //           AsianPaintColors
                                                            //               .forgotPasswordTextColor;
                                                            //     },
                                                            //   );
                                                            // }

                                                            for (Area element
                                                                in (snapshot
                                                                        .data?[
                                                                            i]
                                                                        .areaInfo ??
                                                                    [])) {
                                                              logger(
                                                                  "In Area name condition ${element.areaname}");
                                                              logger(
                                                                  "In Area qty condition ${element.areaqty}");
                                                              if ((element.areaname ??
                                                                          '')
                                                                      .isEmpty &&
                                                                  (element.areaqty ??
                                                                          '')
                                                                      .isEmpty) {
                                                                borderColor = ((element.areaqty ??
                                                                            '')
                                                                        .isEmpty)
                                                                    ? AsianPaintColors
                                                                        .forgotPasswordTextColor
                                                                    : AsianPaintColors
                                                                        .segregationColor;
                                                                logger(
                                                                    "In Area condition");
                                                                isAreaEmpty =
                                                                    true;
                                                                break;
                                                              } else {
                                                                setState(
                                                                  () {
                                                                    // borderColor =
                                                                    //     AsianPaintColors
                                                                    //         .segregationColor;
                                                                  },
                                                                );
                                                              }
                                                            }
                                                          }

                                                          if (!isAreaEmpty) {
                                                            secureStorageProvider
                                                                .saveQuoteToDisk(
                                                                    snapshot.data ??
                                                                        []);
                                                            Journey.quoteResponseList =
                                                                snapshot.data ??
                                                                    [];

                                                            if ((widget.fromFlip ??
                                                                    (Journey.fromFlip ??
                                                                        false)) &&
                                                                projectID !=
                                                                    null &&
                                                                projectID!
                                                                    .isNotEmpty) {
                                                              logger(
                                                                  'Quote Name: ${Journey.quoteName}');
                                                              CreateQuoteBloc
                                                                  createProjectBloc =
                                                                  context.read<
                                                                      CreateQuoteBloc>();

                                                              List<Quoteinfo>
                                                                  quoteInfoList =
                                                                  [];
                                                              List<SKUData>
                                                                  skuDataList =
                                                                  snapshot.data ??
                                                                      [];
                                                              for (int i = 0;
                                                                  i <
                                                                      skuDataList
                                                                          .length;
                                                                  i++) {
                                                                // List<String> areaStr =
                                                                List<Area>
                                                                    areaInfo =
                                                                    [];
                                                                List<Area>
                                                                    areas =
                                                                    skuDataList[i]
                                                                            .areaInfo ??
                                                                        [];
                                                                for (int j = 0;
                                                                    j <
                                                                        areas
                                                                            .length;
                                                                    j++) {
                                                                  Area area =
                                                                      Area();
                                                                  area.areaname =
                                                                      areas[j].areaname ??
                                                                          '';
                                                                  area.areaqty =
                                                                      areas[j].areaqty ??
                                                                          '';
                                                                  areaInfo.add(
                                                                      area);
                                                                }
                                                                Quoteinfo
                                                                    quoteinfo =
                                                                    Quoteinfo();
                                                                quoteinfo
                                                                        .skuid =
                                                                    skuDataList[
                                                                            i]
                                                                        .skuCatCode;
                                                                quoteinfo
                                                                        .discount =
                                                                    skuDataList[
                                                                            i]
                                                                        .discount
                                                                        .toString();
                                                                quoteinfo
                                                                        .netDiscount =
                                                                    skuDataList[
                                                                            i]
                                                                        .netDiscount;
                                                                quoteinfo
                                                                        .totalqty =
                                                                    skuDataList[
                                                                            i]
                                                                        .quantity
                                                                        .toString();
                                                                quoteinfo.area =
                                                                    areaInfo;
                                                                quoteinfo
                                                                        .totalprice =
                                                                    skuDataList[
                                                                            i]
                                                                        .totalPriceAfterDiscount
                                                                        .toString();
                                                                quoteinfo
                                                                    .bundletype = '';
                                                                quoteinfo
                                                                        .netDiscount =
                                                                    skuDataList[i]
                                                                            .netDiscount ??
                                                                        "0";
                                                                quoteInfoList.add(
                                                                    quoteinfo);
                                                              }

                                                              if (quoteInfoList
                                                                  .isNotEmpty) {
                                                                createProjectBloc
                                                                    .createQuote(
                                                                  quoteInfoList:
                                                                      quoteInfoList,
                                                                  category: widget
                                                                      .category,
                                                                  brand: widget
                                                                      .brand,
                                                                  range: widget
                                                                      .range,
                                                                  discountAmount:
                                                                      totalDiscountAmount
                                                                          .toString(),
                                                                  totalPriceWithGST:
                                                                      totalAfterGST
                                                                          .round()
                                                                          .toString(),
                                                                  quoteName: Journey
                                                                      .quoteName,
                                                                  projectID:
                                                                      projectID,
                                                                  quoteType: "",
                                                                  isExist: true,
                                                                  quoteID: Journey
                                                                          .quoteID ??
                                                                      '',
                                                                  projectName:
                                                                      '',
                                                                  contactPerson:
                                                                      '',
                                                                  mobileNumber:
                                                                      '',
                                                                  siteAddress:
                                                                      '',
                                                                  noOfBathrooms:
                                                                      '',
                                                                );
                                                              }

                                                              Journey.skuResponseLists =
                                                                  [];
                                                              secureStorageProvider
                                                                  .saveQuoteToDisk(
                                                                      Journey
                                                                          .skuResponseLists);

                                                              Journey.quoteName =
                                                                  '';
                                                              Journey.quoteID =
                                                                  '';

                                                              secureStorageProvider
                                                                  .saveProjectID(
                                                                      '');
                                                            } else {
                                                              if (snapshot.data
                                                                      ?.isNotEmpty ??
                                                                  false) {
                                                                Journey.quoteResponseList =
                                                                    snapshot
                                                                        .data;

                                                                Journey.totalAmountAfterGST =
                                                                    totalAfterGST
                                                                        .round();
                                                                Journey.totalDiscountAmount =
                                                                    totalDiscountAmount;
                                                                Journey.category =
                                                                    widget
                                                                        .category;
                                                                Journey.brand =
                                                                    widget
                                                                        .brand;
                                                                Journey.range =
                                                                    widget
                                                                        .range;
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return showQuoteDialog();
                                                                  },
                                                                );
                                                              } else {
                                                                FlutterToastProvider()
                                                                    .show(
                                                                        message:
                                                                            'Cannot create a quote with empty list');
                                                              }
                                                            }
                                                          } else {
                                                            setState(
                                                              () {
                                                                FlutterToastProvider()
                                                                    .show(
                                                                        message:
                                                                            'Area cannot be empty');
                                                              },
                                                            );
                                                          }
                                                        },
                                                        label: state
                                                                is CreateQuoteLoading
                                                            ? Center(
                                                                child: SizedBox(
                                                                  height: 15,
                                                                  width: 15,
                                                                  child: CircularProgressIndicator(
                                                                      color: AsianPaintColors
                                                                          .whiteColor),
                                                                ),
                                                              )
                                                            : Text(
                                                                AppLocalizations.of(
                                                                        context)
                                                                    .save_quote,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishBold,
                                                                  color: AsianPaintColors
                                                                      .whiteColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                listener: (context, state) {
                                                  if (state
                                                      is CreateQuoteLoaded) {
                                                    Journey.quoteName = '';
                                                    Journey.quoteID = '';

                                                    secureStorageProvider
                                                        .saveProjectID('');
                                                    if (projectID != null &&
                                                        projectID!.isNotEmpty) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProjectDescription(
                                                                  projectID:
                                                                      projectID),
                                                        ),
                                                      );
                                                      Journey.projectID = '';
                                                    }
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                      // bottomSheet:
                    ),
                  );
                },
              ),
              desktop: StatefulBuilder(
                builder: (context, setState) {
                  logger("Response Size: ${snapshot.data?.length}");

                  return Scaffold(
                    key: scaffoldKey,
                    backgroundColor: AsianPaintColors.appBackgroundColor,
                    appBar: AppBarTemplate(
                      isVisible: true,
                      header: AppLocalizations.of(context).sku,
                    ),
                    body: Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 90, top: 50),
                              width: MediaQuery.of(context).size.width / 1.9,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Quote",
                                    style: TextStyle(
                                      fontFamily:
                                          AsianPaintsFonts.bathSansRegular,
                                      color:
                                          AsianPaintColors.projectUserNameColor,
                                      fontSize: 25,
                                    ),
                                  ),
                                  (snapshot.data ?? []).isNotEmpty
                                      ? SizedBox(
                                          height: 30,
                                          width: 120,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              setState(
                                                () {
                                                  setState(
                                                    () {
                                                      logger(
                                                          'On pressed for clear data');
                                                      Journey.skuResponseLists =
                                                          [];
                                                      snapshot.data?.clear();
                                                      secureStorageProvider
                                                          .saveQuoteToDisk(Journey
                                                              .skuResponseLists);
                                                      secureStorageProvider
                                                          .saveCartCount(0);
                                                      totalBeforeGST = 0;
                                                      totalAfterGST = 0;
                                                      totalDiscountAmount = 0;
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(35.0),
                                              ),
                                              backgroundColor: AsianPaintColors
                                                  .userTypeTextColor,
                                              shadowColor: AsianPaintColors
                                                  .buttonBorderColor,
                                              textStyle: TextStyle(
                                                color: AsianPaintColors
                                                    .buttonTextColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: AsianPaintsFonts
                                                    .mulishRegular,
                                              ),
                                            ),
                                            child: Text(
                                              'Clear cart',
                                              style: TextStyle(
                                                fontFamily:
                                                    AsianPaintsFonts.mulishBold,
                                                color:
                                                    AsianPaintColors.whiteColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox(
                                          height: 0,
                                        ),
                                  const SizedBox(width: 50),
                                  SizedBox(
                                    height: 30,
                                    width: 120,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Journey.selectedIndex = 0;
                                        Journey.skuResponseLists =
                                            snapshot.data ?? [];
                                        secureStorageProvider.saveQuoteToDisk(
                                            snapshot.data ?? []);
                                        if ((snapshot.data ?? []).isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SKUList(
                                                brandIndex: brandIndex ?? 0,
                                                catIndex: catIndex ?? 0,
                                                brand: brand,
                                                category: category,
                                                range: range,
                                                rangeIndex: rangeIndex ?? 0,
                                              ),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Sidemen(),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(35.0),
                                        ),
                                        backgroundColor:
                                            AsianPaintColors.userTypeTextColor,
                                        shadowColor:
                                            AsianPaintColors.buttonBorderColor,
                                        textStyle: TextStyle(
                                          color:
                                              AsianPaintColors.buttonTextColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          fontFamily:
                                              AsianPaintsFonts.mulishRegular,
                                        ),
                                      ),
                                      child: Text(
                                        'Add SKU',
                                        style: TextStyle(
                                          fontFamily:
                                              AsianPaintsFonts.mulishBold,
                                          color: AsianPaintColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2.3,
                                //height: 500,
                                padding:
                                    const EdgeInsets.only(left: 70, bottom: 15),
                                child: ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const Divider(
                                    color: Colors.transparent,
                                    endIndent: 5,
                                    indent: 5,
                                  ),
                                  itemCount: snapshot.data?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    // logger(
                                    //     'Item List size: ${snapshot.data?[index].areaInfo?[0].areaqty}');
                                    if ((snapshot.data ?? []).isEmpty) {
                                      return const Center(
                                        child: Text('No data available'),
                                      );
                                    } else {
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: (snapshot.data?[index]
                                                                .areaInfo ??
                                                            [])
                                                        .isNotEmpty &&
                                                    ((snapshot
                                                                    .data?[
                                                                        index]
                                                                    .areaInfo?[
                                                                        0]
                                                                    .areaqty ??
                                                                '')
                                                            .isEmpty ||
                                                        snapshot
                                                                .data?[index]
                                                                .areaInfo?[0]
                                                                .areaqty ==
                                                            null)
                                                ? borderColor
                                                : AsianPaintColors
                                                    .segregationColor,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        elevation: 0,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(10),
                                          tileColor:
                                              AsianPaintColors.whiteColor,
                                          minLeadingWidth: 120,
                                          leading: Image.network(
                                            (snapshot.data?[index].sKUIMAGE ??
                                                        '')
                                                    .isEmpty
                                                ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
                                                : snapshot.data?[index]
                                                        .sKUIMAGE! ??
                                                    '',
                                            width: 120,
                                            height: 120,
                                          ),
                                          title: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    snapshot.data?[index]
                                                            .skuCatCode ??
                                                        '',
                                                    style: TextStyle(
                                                      color: AsianPaintColors
                                                          .projectUserNameColor,
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishMedium,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      int price = 0;
                                                      setState(
                                                        () {
                                                          setState(() {
                                                            snapshot
                                                                .data?[index]
                                                                .totalPrice = int
                                                                    .parse(snapshot
                                                                            .data?[
                                                                                index]
                                                                            .quantity ??
                                                                        '0') *
                                                                int.parse(snapshot
                                                                        .data?[
                                                                            index]
                                                                        .sKUMRP ??
                                                                    '');
                                                            snapshot.data
                                                                ?.removeAt(
                                                                    index);
                                                            if ((snapshot
                                                                        .data ??
                                                                    [])
                                                                .isEmpty) {
                                                              totalAfterGST = 0;
                                                              totalDiscountAmount =
                                                                  0;
                                                            }
                                                            for (int i = 0;
                                                                i <
                                                                    snapshot
                                                                        .data!
                                                                        .length;
                                                                i++) {
                                                              totalAfterGST = 0;
                                                              totalDiscountAmount =
                                                                  0;
                                                              totalBeforeGST =
                                                                  0;

                                                              price += (int.parse((snapshot.data?[i].quantity ??
                                                                              '')
                                                                          .isEmpty
                                                                      ? '1'
                                                                      : snapshot
                                                                              .data?[
                                                                                  i]
                                                                              .quantity ??
                                                                          '0') *
                                                                  int.parse(snapshot
                                                                          .data?[
                                                                              i]
                                                                          .sKUMRP ??
                                                                      '0'));
                                                              setState(
                                                                () {
                                                                  double values = double
                                                                          .parse(
                                                                              '${snapshot.data?[i].totalPrice}') *
                                                                      double.parse(
                                                                          '${snapshot.data?[i].netDiscount}');
                                                                  double
                                                                      discountAmount =
                                                                      double.parse(
                                                                          '${values / 100}');
                                                                  snapshot
                                                                      .data?[i]
                                                                      .totalPriceAfterDiscount = ((snapshot
                                                                              .data?[
                                                                                  i]
                                                                              .totalPrice) ??
                                                                          0) -
                                                                      discountAmount
                                                                          .round();

                                                                  snapshot
                                                                      .data?[i]
                                                                      .discPrice = ((snapshot
                                                                              .data?[i]
                                                                              .totalPrice) ??
                                                                          0) -
                                                                      discountAmount;
                                                                  logger(
                                                                      'Total price amount: ${snapshot.data?[i].totalPriceAfterDiscount}');
                                                                  snapshot.data
                                                                      ?.forEach(
                                                                          (element) {
                                                                    totalDiscountAmount +=
                                                                        ((element.totalPrice! * double.parse(element.netDiscount ?? '0')) /
                                                                                100)
                                                                            .round();
                                                                    totalAfterGST +=
                                                                        (element.discPrice ??
                                                                            0);

                                                                    logger(
                                                                        totalDiscountAmount);
                                                                  });

                                                                  // snapshot.data
                                                                  //     ?.forEach(
                                                                  //         (element) {
                                                                  //   totalDiscountAmount +=
                                                                  //       ((element.totalPrice! * double.parse(element.netDiscount ?? '0')) /
                                                                  //               100)
                                                                  //           .round();
                                                                  //   totalAfterGST +=
                                                                  //       element.totalPriceAfterDiscount ??
                                                                  //           0;

                                                                  //   logger(
                                                                  //       totalDiscountAmount);
                                                                  // });
                                                                  totalAfterGST +=
                                                                      ((totalAfterGST * 18) /
                                                                              100)
                                                                          .round();
                                                                  logger(
                                                                      totalAfterGST);
                                                                  totalBeforeGST =
                                                                      price
                                                                          .roundToDouble();
                                                                },
                                                              );
                                                            }
                                                            Journey.skuResponseLists =
                                                                snapshot.data ??
                                                                    [];
                                                            secureStorageProvider
                                                                .saveQuoteToDisk(
                                                                    snapshot.data ??
                                                                        []);
                                                            int quantity = 0;
                                                            int cartCount = 0;
                                                            for (int i = 0;
                                                                i <
                                                                    Journey
                                                                        .skuResponseLists
                                                                        .length;
                                                                i++) {
                                                              quantity += int
                                                                  .parse(Journey
                                                                          .skuResponseLists[
                                                                              i]
                                                                          .quantity ??
                                                                      '');
                                                            }
                                                            cartCount = Journey
                                                                .skuResponseLists
                                                                .length;
                                                            Journey.totalQuantity =
                                                                Journey
                                                                    .skuResponseLists
                                                                    .length;
                                                            _secureStorageProvider
                                                                .saveCartCount(
                                                                    cartCount);
                                                            logger(
                                                                'Cart count: $cartCount');
                                                            logger(
                                                                'Quantity: $quantity');
                                                          });
                                                          // Navigator.pop(context);
                                                          logger(
                                                              'Length: ${snapshot.data?.length}');
                                                        },
                                                      );
                                                    },
                                                    child: Image.asset(
                                                      'assets/images/cancel.png',
                                                      width: 13,
                                                      height: 13,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Flexible(
                                                    flex: 1,
                                                    child: Text(
                                                      snapshot.data?[index]
                                                              .sKUDESCRIPTION ??
                                                          '',
                                                      // AppLocalizations.of(context).angle_cock,
                                                      textAlign:
                                                          TextAlign.justify,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: false,
                                                      textWidthBasis:
                                                          TextWidthBasis
                                                              .longestLine,
                                                      style: TextStyle(
                                                        color: AsianPaintColors
                                                            .skuDescriptionColor,
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishRegular,
                                                        fontSize: 9,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 6,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              (Journey.isExist ?? true)
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Net Discount',
                                                              //AppLocalizations.of(context).add_discount,
                                                              style: TextStyle(
                                                                color: AsianPaintColors
                                                                    .quantityColor,
                                                                fontFamily:
                                                                    AsianPaintsFonts
                                                                        .mulishMedium,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            SizedBox(
                                                              width: 55,
                                                              height: 25,
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child:
                                                                    TextField(
                                                                  enableInteractiveSelection:
                                                                      false,
                                                                  inputFormatters: <
                                                                      TextInputFormatter>[
                                                                    LengthLimitingTextInputFormatter(
                                                                        2),
                                                                    FilteringTextInputFormatter
                                                                        .allow(RegExp(
                                                                            "[0-9]")),
                                                                  ],
                                                                  controller: TextEditingController.fromValue(TextEditingValue(
                                                                      text: (snapshot.data?[index].discount ??
                                                                              0)
                                                                          .toString(),
                                                                      selection: TextSelection.fromPosition(TextPosition(
                                                                          offset: (snapshot.data?[index].discount ?? 0)
                                                                              .toString()
                                                                              .length)))),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  cursorColor:
                                                                      AsianPaintColors
                                                                          .kPrimaryColor,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: AsianPaintColors
                                                                          .kPrimaryColor,
                                                                      fontFamily:
                                                                          AsianPaintsFonts
                                                                              .mulishRegular),
                                                                  decoration:
                                                                      InputDecoration(
                                                                    suffixText:
                                                                        '%',
                                                                    suffixStyle:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                                    fillColor:
                                                                        AsianPaintColors
                                                                            .whiteColor,
                                                                    filled:
                                                                        true,
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: AsianPaintColors
                                                                            .quantityBorder,
                                                                      ),
                                                                    ),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: AsianPaintColors
                                                                            .quantityBorder,
                                                                      ),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: AsianPaintColors
                                                                            .quantityBorder,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  onSubmitted:
                                                                      (value) {
                                                                    if (isFirstTime &&
                                                                        value !=
                                                                            '0') {
                                                                      for (int i =
                                                                              0;
                                                                          i < snapshot.data!.length;
                                                                          i++) {
                                                                        setState(
                                                                          () {
                                                                            snapshot.data?[i].discount =
                                                                                int.parse(value);
                                                                            snapshot.data?[i].netDiscount =
                                                                                (((((snapshot.data?[i].discount ?? 0) / 100) + 0.18) / 1.18) * 100).toStringAsFixed(5);
                                                                          },
                                                                        );
                                                                        value.isNotEmpty || value != "0"
                                                                            ? (snapshot.data?[index].discount =
                                                                                int.parse(value))
                                                                            : (snapshot.data?[index].discount = 0);
                                                                        snapshot
                                                                            .data?[
                                                                                index]
                                                                            .totalPrice = int.parse(snapshot.data?[index].quantity ??
                                                                                '0') *
                                                                            int.parse(snapshot.data?[index].sKUMRP ??
                                                                                '');

                                                                        totalAfterGST =
                                                                            0;
                                                                        totalDiscountAmount =
                                                                            0;
                                                                        totalBeforeGST =
                                                                            0;

                                                                        setState(
                                                                          () {
                                                                            double
                                                                                values =
                                                                                double.parse('${snapshot.data?[i].totalPrice}') * double.parse('${snapshot.data?[i].netDiscount}');
                                                                            double
                                                                                discountAmount =
                                                                                double.parse('${values / 100}');
                                                                            snapshot.data?[i].totalPriceAfterDiscount =
                                                                                ((snapshot.data?[i].totalPrice) ?? 0) - discountAmount.round();
                                                                            snapshot.data?[i].discPrice =
                                                                                ((snapshot.data?[i].totalPrice) ?? 0) - discountAmount;
                                                                            logger('Total price amount: ${snapshot.data?[i].totalPriceAfterDiscount}');
                                                                            snapshot.data?.forEach((element) {
                                                                              totalDiscountAmount += ((element.totalPrice! * double.parse(element.netDiscount ?? '0')) / 100).round();
                                                                              totalAfterGST += (element.discPrice ?? 0);

                                                                              logger(totalDiscountAmount);
                                                                            });

                                                                            totalBeforeGST =
                                                                                totalAfterGST.roundToDouble();
                                                                            totalAfterGST +=
                                                                                ((totalAfterGST * 18) / 100).round();
                                                                            logger(totalAfterGST);
                                                                          },
                                                                        );
                                                                      }

                                                                      isFirstTime =
                                                                          false;
                                                                      Journey.skuResponseLists =
                                                                          snapshot.data ??
                                                                              [];
                                                                      secureStorageProvider.saveQuoteToDisk(
                                                                          snapshot.data ??
                                                                              []);
                                                                    }
                                                                  },
                                                                  onChanged:
                                                                      (value) async {
                                                                    snapshot
                                                                            .data?[
                                                                                index]
                                                                            .discount =
                                                                        int.parse(
                                                                            value);
                                                                    snapshot
                                                                        .data?[
                                                                            index]
                                                                        .netDiscount = (((((snapshot.data?[index].discount ?? 0) / 100) + 0.18) /
                                                                                1.18) *
                                                                            100)
                                                                        .toStringAsFixed(
                                                                            5);

                                                                    for (int i =
                                                                            0;
                                                                        i < (snapshot.data ?? []).length;
                                                                        i++) {
                                                                      value.isNotEmpty ||
                                                                              value !=
                                                                                  "0"
                                                                          ? (snapshot.data?[index].discount = int.parse(
                                                                              value))
                                                                          : (snapshot
                                                                              .data?[index]
                                                                              .discount = 0);
                                                                      snapshot
                                                                          .data?[
                                                                              index]
                                                                          .totalPrice = int.parse(snapshot.data?[index].quantity ??
                                                                              '0') *
                                                                          int.parse(snapshot.data?[index].sKUMRP ??
                                                                              '');

                                                                      totalAfterGST =
                                                                          0;
                                                                      totalDiscountAmount =
                                                                          0;
                                                                      totalBeforeGST =
                                                                          0;
                                                                      // snapshot.data?[index].netDiscount = '${((((snapshot.data?[index].discount ?? 0) + 0.18) / 1.18) * 100).round()}';

                                                                      setState(
                                                                        () {
                                                                          double
                                                                              values =
                                                                              double.parse('${snapshot.data?[i].totalPrice}') * double.parse('${snapshot.data?[i].netDiscount}');
                                                                          double
                                                                              discountAmount =
                                                                              double.parse('${values / 100}');
                                                                          logger(
                                                                              'Discount amount: $discountAmount');
                                                                          snapshot
                                                                              .data?[i]
                                                                              .totalPriceAfterDiscount = ((snapshot.data?[i].totalPrice) ?? 0) - discountAmount.round();
                                                                          snapshot
                                                                              .data?[i]
                                                                              .discPrice = ((snapshot.data?[i].totalPrice) ?? 0) - discountAmount;
                                                                          logger(
                                                                              'Total price amount: ${snapshot.data?[i].totalPriceAfterDiscount}');
                                                                          snapshot
                                                                              .data
                                                                              ?.forEach((element) {
                                                                            totalDiscountAmount +=
                                                                                ((element.totalPrice! * double.parse(element.netDiscount ?? '0')) / 100).round();
                                                                            totalAfterGST +=
                                                                                (element.discPrice ?? 0);

                                                                            logger(totalDiscountAmount);
                                                                          });
                                                                          totalBeforeGST =
                                                                              totalAfterGST.roundToDouble();
                                                                          totalAfterGST +=
                                                                              ((totalAfterGST * 18) / 100).round();
                                                                          logger(
                                                                              "TotalAfterGST:  $totalAfterGST");
                                                                        },
                                                                      );
                                                                    }
                                                                    Journey.skuResponseLists =
                                                                        snapshot.data ??
                                                                            [];
                                                                    secureStorageProvider.saveQuoteToDisk(
                                                                        snapshot.data ??
                                                                            []);
                                                                  },
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Text(
                                                              AppLocalizations.of(
                                                                      context)
                                                                  .pre_gst_discount,
                                                              style: TextStyle(
                                                                color: AsianPaintColors
                                                                    .quantityColor,
                                                                fontFamily:
                                                                    AsianPaintsFonts
                                                                        .mulishMedium,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            SizedBox(
                                                              width: 50,
                                                              height: 30,
                                                              child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(
                                                                    '${double.parse(snapshot.data?[index].netDiscount ?? '0').toStringAsFixed(2)} %',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                  )),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  : const SizedBox(),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'MRP:',
                                                        //AppLocalizations.of(context).total_price,
                                                        style: TextStyle(
                                                            color: AsianPaintColors
                                                                .quantityColor,
                                                            fontFamily:
                                                                AsianPaintsFonts
                                                                    .mulishMedium,
                                                            fontSize: 10),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        '\u{20B9} ${snapshot.data?[index].sKUMRP ?? ''}',
                                                        textAlign:
                                                            TextAlign.justify,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        softWrap: false,
                                                        textWidthBasis:
                                                            TextWidthBasis
                                                                .longestLine,
                                                        style: TextStyle(
                                                          color: AsianPaintColors
                                                              .kPrimaryColor,
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishBold,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(children: [
                                                    Text(
                                                      'Total Pre-GST price',
                                                      //AppLocalizations.of(context).total_price,
                                                      style: TextStyle(
                                                          color: AsianPaintColors
                                                              .quantityColor,
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishMedium,
                                                          fontSize: 10),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      '\u{20B9} ${snapshot.data?[index].totalPriceAfterDiscount}',
                                                      style: TextStyle(
                                                          color: AsianPaintColors
                                                              .forgotPasswordTextColor,
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishBold,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13),
                                                    ),
                                                  ]),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Total Qty',
                                                    //AppLocalizations.of(context).total_qty,
                                                    style: TextStyle(
                                                      color: AsianPaintColors
                                                          .quantityColor,
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishMedium,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 9,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 6,
                                                  ),
                                                  SizedBox(
                                                    width: 50,
                                                    height: 25,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: TextFormField(
                                                        enableInteractiveSelection:
                                                            false,
                                                        controller: TextEditingController.fromValue(TextEditingValue(
                                                            text: (snapshot
                                                                        .data?[
                                                                            index]
                                                                        .quantity ??
                                                                    0)
                                                                .toString(),
                                                            selection: TextSelection.fromPosition(TextPosition(
                                                                offset: (snapshot
                                                                            .data?[index]
                                                                            .quantity ??
                                                                        0)
                                                                    .toString()
                                                                    .length)))),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontFamily:
                                                                AsianPaintsFonts
                                                                    .mulishRegular,
                                                            color: AsianPaintColors
                                                                .kPrimaryColor),
                                                        cursorColor:
                                                            AsianPaintColors
                                                                .kPrimaryColor,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: AsianPaintColors
                                                                  .quantityBorder,
                                                            ),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: AsianPaintColors
                                                                  .quantityBorder,
                                                            ),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: AsianPaintColors
                                                                  .quantityBorder,
                                                            ),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          if (value == '0') {
                                                            value = '1';
                                                          }

                                                          if (value != '0') {
                                                            snapshot
                                                                    .data?[index]
                                                                    .quantity =
                                                                value;

                                                            for (int i = 0;
                                                                i <
                                                                    (snapshot.data ??
                                                                            [])
                                                                        .length;
                                                                i++) {
                                                              value.isNotEmpty ||
                                                                      value !=
                                                                          "0"
                                                                  ? (snapshot
                                                                          .data?[
                                                                              index]
                                                                          .quantity =
                                                                      value)
                                                                  : (snapshot
                                                                      .data?[
                                                                          index]
                                                                      .quantity = '0');
                                                              snapshot
                                                                  .data?[index]
                                                                  .totalPrice = int.parse(snapshot
                                                                          .data?[
                                                                              index]
                                                                          .quantity ??
                                                                      '0') *
                                                                  int.parse(snapshot
                                                                          .data?[
                                                                              index]
                                                                          .sKUMRP ??
                                                                      '');

                                                              totalAfterGST = 0;
                                                              totalDiscountAmount =
                                                                  0;
                                                              totalBeforeGST =
                                                                  0;
                                                              // snapshot.data?[index].netDiscount = '${((((snapshot.data?[index].discount ?? 0) + 0.18) / 1.18) * 100).round()}';

                                                              setState(
                                                                () {
                                                                  double values = double
                                                                          .parse(
                                                                              '${snapshot.data?[i].totalPrice}') *
                                                                      double.parse(
                                                                          '${snapshot.data?[i].netDiscount}');
                                                                  double
                                                                      discountAmount =
                                                                      double.parse(
                                                                          '${values / 100}');
                                                                  logger(
                                                                      'Discount amount: $discountAmount');
                                                                  snapshot
                                                                      .data?[i]
                                                                      .totalPriceAfterDiscount = ((snapshot
                                                                              .data?[
                                                                                  i]
                                                                              .totalPrice) ??
                                                                          0) -
                                                                      discountAmount
                                                                          .round();
                                                                  snapshot
                                                                      .data?[i]
                                                                      .discPrice = ((snapshot
                                                                              .data?[i]
                                                                              .totalPrice) ??
                                                                          0) -
                                                                      discountAmount;
                                                                  logger(
                                                                      'Total price amount: ${snapshot.data?[i].totalPriceAfterDiscount}');
                                                                  snapshot.data
                                                                      ?.forEach(
                                                                          (element) {
                                                                    totalDiscountAmount +=
                                                                        ((element.totalPrice! * double.parse(element.netDiscount ?? '0')) /
                                                                                100)
                                                                            .round();
                                                                    totalAfterGST +=
                                                                        (element.discPrice ??
                                                                            0);

                                                                    logger(
                                                                        totalDiscountAmount);
                                                                  });
                                                                  totalBeforeGST =
                                                                      totalAfterGST
                                                                          .roundToDouble();
                                                                  totalAfterGST +=
                                                                      ((totalAfterGST * 18) /
                                                                              100)
                                                                          .round();
                                                                  logger(
                                                                      "TotalAfterGST:  $totalAfterGST");
                                                                },
                                                              );
                                                            }
                                                            Journey.skuResponseLists =
                                                                snapshot.data ??
                                                                    [];
                                                            secureStorageProvider
                                                                .saveQuoteToDisk(
                                                                    snapshot.data ??
                                                                        []);
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              ((snapshot.data?[index].areaInfo ??
                                                                  [])
                                                              .isNotEmpty &&
                                                          (snapshot
                                                                      .data?[
                                                                          index]
                                                                      .areaInfo
                                                                      ?.length ??
                                                                  0) <=
                                                              1) &&
                                                      ((snapshot.data?[index]
                                                                      .areaInfo ??
                                                                  [])
                                                              .isNotEmpty &&
                                                          (snapshot
                                                                      .data?[
                                                                          index]
                                                                      .areaInfo?[
                                                                          0]
                                                                      .areaname ??
                                                                  '')
                                                              .isNotEmpty)
                                                  ? ListView.builder(
                                                      itemCount: snapshot
                                                              .data?[index]
                                                              .areaInfo
                                                              ?.length ??
                                                          0,
                                                      shrinkWrap: true,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemExtent: 50,
                                                      itemBuilder:
                                                          (context, ind) {
                                                        snapshot
                                                            .data?[index]
                                                            .areaInfo?[ind]
                                                            .areaname = snapshot
                                                                .data?[index]
                                                                .areaInfo?[ind]
                                                                .areaname
                                                                ?.toUpperCase() ??
                                                            '';
                                                        snapshot
                                                            .data?[index]
                                                            .areaInfo?[ind]
                                                            .areaqty = (snapshot
                                                                        .data?[
                                                                            index]
                                                                        .areaInfo?[
                                                                            ind]
                                                                        .areaqty ??
                                                                    '1')
                                                                .isEmpty
                                                            ? '1'
                                                            : snapshot
                                                                    .data?[
                                                                        index]
                                                                    .areaInfo?[
                                                                        ind]
                                                                    .areaqty ??
                                                                '1';

                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 3),
                                                          child: Container(
                                                              color: AsianPaintColors
                                                                  .textFieldBorderColor,
                                                              margin: const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            10,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    child: Text(
                                                                      '${snapshot.data?[index].areaInfo?[ind].areaname?.toUpperCase()}',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        fontFamily:
                                                                            AsianPaintsFonts.mulishRegular,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        color: AsianPaintColors
                                                                            .skuDescriptionColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 70,
                                                                    child: Row(
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              0,
                                                                              0,
                                                                              5,
                                                                              0),
                                                                          child:
                                                                              Text(
                                                                            'Qty',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 8,
                                                                              fontFamily: AsianPaintsFonts.mulishRegular,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: AsianPaintColors.quantityColor,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              40,
                                                                          height:
                                                                              25,
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Text(
                                                                              (snapshot.data?[index].areaInfo?[ind].areaqty ?? '1').isEmpty ? '1' : '${snapshot.data?[index].areaInfo?[ind].areaqty ?? 0}',
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
                                                    )
                                                  : (snapshot
                                                                  .data?[index]
                                                                  .aREAINFO
                                                                  ?.length ??
                                                              0) <=
                                                          1
                                                      ? ListView.builder(
                                                          itemCount: snapshot
                                                                  .data?[index]
                                                                  .aREAINFO
                                                                  ?.length ??
                                                              0,
                                                          shrinkWrap: true,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0),
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          itemExtent: 50,
                                                          itemBuilder:
                                                              (context, ind) {
                                                            snapshot
                                                                .data?[index]
                                                                .areaInfo?[ind]
                                                                .areaname = snapshot
                                                                        .data?[
                                                                            index]
                                                                        .aREAINFO?[
                                                                    ind] ??
                                                                '';
                                                            snapshot
                                                                .data?[index]
                                                                .areaInfo?[ind]
                                                                .areaqty = (snapshot
                                                                            .data?[
                                                                                index]
                                                                            .quantity ??
                                                                        '1')
                                                                    .isEmpty
                                                                ? '1'
                                                                : snapshot
                                                                        .data?[
                                                                            index]
                                                                        .quantity ??
                                                                    '1';

                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          3),
                                                              child: Container(
                                                                  color: AsianPaintColors
                                                                      .textFieldBorderColor,
                                                                  margin: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          0),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.fromLTRB(
                                                                            10,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                        child:
                                                                            Text(
                                                                          snapshot.data?[index].aREAINFO?[ind] ??
                                                                              '',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                10,
                                                                            fontFamily:
                                                                                AsianPaintsFonts.mulishRegular,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color:
                                                                                AsianPaintColors.skuDescriptionColor,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            70,
                                                                        child:
                                                                            Row(
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
                                                                                  (snapshot.data?[index].quantity ?? '1').isEmpty ? '1' : '${snapshot.data?[index].quantity ?? 1}',
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
                                                        )
                                                      : ListView.builder(
                                                          itemCount: snapshot
                                                              .data?[index]
                                                              .areaInfo
                                                              ?.length,
                                                          shrinkWrap: true,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0),
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          itemExtent: 50,
                                                          itemBuilder:
                                                              (context, i) {
                                                            return snapshot.data?[index].areaInfo?[i].areaqty ==
                                                                        null ||
                                                                    snapshot
                                                                            .data?[
                                                                                index]
                                                                            .areaInfo?[
                                                                                i]
                                                                            .areaqty ==
                                                                        '0' ||
                                                                    snapshot
                                                                            .data?[
                                                                                index]
                                                                            .areaInfo?[
                                                                                i]
                                                                            .areaqty ==
                                                                        ''
                                                                ? null
                                                                : StatefulBuilder(
                                                                    builder:
                                                                        (context,
                                                                            setState) {
                                                                    return Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          vertical:
                                                                              3),
                                                                      child: Container(
                                                                          color: AsianPaintColors.textFieldBorderColor,
                                                                          margin: const EdgeInsets.symmetric(vertical: 0),
                                                                          child: Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                child: Align(
                                                                                  alignment: Alignment.center,
                                                                                  child: Text(
                                                                                    snapshot.data?[index].areaInfo?[i].areaname ?? '',
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
                                                                                          (snapshot.data?[index].areaInfo?[i].areaqty ?? '1').isEmpty ? '1' : '${(snapshot.data?[index].areaInfo?[i].areaqty)}',
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
                                                                  });
                                                          },
                                                        ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      snapshot.data?[index]
                                                          .areaInfo = [];
                                                      areaInfo = [];

                                                      areaInfo = snapshot
                                                          .data?[index].aREAINFO
                                                          ?.map((e) =>
                                                              Area(areaname: e))
                                                          .toList();

                                                      _value = false;
                                                      final Map<int, String>
                                                          data =
                                                          <int, String>{};
                                                      areas = [];

                                                      // Dialog dialog =
                                                      showDialog(
                                                        context: context,
                                                        builder: (dcontext) {
                                                          dialogContext =
                                                              dcontext;
                                                          return Dialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            elevation: 0.0,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            child: SizedBox(
                                                              width: 400,
                                                              height: 420,
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  shape: BoxShape
                                                                      .rectangle,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  boxShadow: const [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black26,
                                                                      blurRadius:
                                                                          10.0,
                                                                      offset: Offset(
                                                                          0.0,
                                                                          10.0),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          10.0),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min, // To make the card compact
                                                                    children: <
                                                                        Widget>[
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.centerRight,
                                                                          child:
                                                                              Image.asset(
                                                                            'assets/images/cancel.png',
                                                                            width:
                                                                                13,
                                                                            height:
                                                                                13,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        'Select Area',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              AsianPaintColors.buttonTextColor,
                                                                          fontFamily:
                                                                              AsianPaintsFonts.bathSansRegular,
                                                                          fontSize:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            20,
                                                                      ),
                                                                      Center(
                                                                        child: Text
                                                                            .rich(
                                                                          TextSpan(
                                                                            text:
                                                                                'Total Qty: ',
                                                                            style: TextStyle(
                                                                                fontFamily: AsianPaintsFonts.mulishRegular,
                                                                                fontSize: 11,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: AsianPaintColors.quantityColor),
                                                                            children: <InlineSpan>[
                                                                              TextSpan(
                                                                                text: '${snapshot.data?[index].quantity ?? 0}',
                                                                                style: TextStyle(fontSize: 11, fontFamily: AsianPaintsFonts.mulishMedium, color: AsianPaintColors.forgotPasswordTextColor),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      ListView
                                                                          .separated(
                                                                        separatorBuilder:
                                                                            (BuildContext context, int index) =>
                                                                                Divider(
                                                                          color:
                                                                              AsianPaintColors.quantityBorder,
                                                                          endIndent:
                                                                              5,
                                                                          indent:
                                                                              5,
                                                                        ),
                                                                        itemCount:
                                                                            areaInfo?.length ??
                                                                                0,
                                                                        shrinkWrap:
                                                                            true,
                                                                        padding:
                                                                            const EdgeInsets.all(0),
                                                                        physics:
                                                                            const NeverScrollableScrollPhysics(),
                                                                        itemBuilder:
                                                                            (context,
                                                                                ind) {
                                                                          final controller =
                                                                              TextEditingController();

                                                                          return StatefulBuilder(
                                                                            builder:
                                                                                (context, setState) {
                                                                              return SizedBox(
                                                                                height: 40,
                                                                                child: CheckboxListTile(
                                                                                  contentPadding: EdgeInsets.zero,
                                                                                  selected: _value,
                                                                                  value: _value,
                                                                                  autofocus: false,
                                                                                  controlAffinity: ListTileControlAffinity.leading,
                                                                                  title: Transform.translate(
                                                                                      offset: const Offset(-15, 0),
                                                                                      child: Text(
                                                                                        areaInfo?[ind].areaname ?? '',
                                                                                        style: TextStyle(
                                                                                          fontSize: 10,
                                                                                          fontFamily: AsianPaintsFonts.mulishMedium,
                                                                                          color: AsianPaintColors.quantityColor,
                                                                                        ),
                                                                                      )),
                                                                                  secondary: SizedBox(
                                                                                    width: 70,
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.fromLTRB(
                                                                                            0,
                                                                                            0,
                                                                                            3,
                                                                                            0,
                                                                                          ),
                                                                                          child: Text(
                                                                                            'Qty',
                                                                                            style: TextStyle(
                                                                                              fontSize: 8,
                                                                                              fontFamily: AsianPaintsFonts.mulishMedium,
                                                                                              fontWeight: FontWeight.w400,
                                                                                              color: AsianPaintColors.quantityColor,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: 40,
                                                                                          height: 25,
                                                                                          child: TextField(
                                                                                            enableInteractiveSelection: false,
                                                                                            controller: areaInfo?[ind].areaqtyController,

                                                                                            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                                                                            // initialValue:
                                                                                            //     '${Journey.skuRequestBody!.quoteinfo![index].totalqty}',
                                                                                            textAlign: TextAlign.center,

                                                                                            style: TextStyle(fontSize: 10, fontFamily: AsianPaintsFonts.mulishRegular, color: AsianPaintColors.kPrimaryColor),
                                                                                            cursorColor: AsianPaintColors.kPrimaryColor,
                                                                                            decoration: InputDecoration(
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
                                                                                            onChanged: (value) {
                                                                                              setState(() {
                                                                                                List<int>? validate = [];
                                                                                                areaInfo?[ind].areaqty = value;

                                                                                                if (value.isEmpty) {
                                                                                                  setState(
                                                                                                    () {
                                                                                                      _value = false;
                                                                                                    },
                                                                                                  );
                                                                                                } else {
                                                                                                  setState(
                                                                                                    () {
                                                                                                      _value = true;
                                                                                                    },
                                                                                                  );
                                                                                                }

                                                                                                if (_value) {
                                                                                                  data[ind] = areaInfo?[ind].areaqty ?? '';
                                                                                                } else {
                                                                                                  data.removeWhere((key, value) => key == ind);
                                                                                                }
                                                                                                int quantity = 0;
                                                                                                if (data.values.isNotEmpty) {
                                                                                                  for (int i = 0; i < data.values.length; i++) {
                                                                                                    if (data.values.elementAt(i).isNotEmpty) {
                                                                                                      quantity += int.parse(data.values.elementAt(i));
                                                                                                      logger(quantity);
                                                                                                    }
                                                                                                  }

                                                                                                  if (quantity > int.parse(snapshot.data?[index].quantity ?? '')) {
                                                                                                    _value = true;
                                                                                                    FlutterToastProvider().show(message: 'Entered quantity is greater than total quantity');
                                                                                                  } else {
                                                                                                    if (areaInfo?[ind].areaqty != null) {
                                                                                                      if (_value) {
                                                                                                        if ((snapshot.data?[index].areaInfo ?? []).isNotEmpty) {
                                                                                                          logger("In contains");

                                                                                                          for (var element in List<Area>.from(snapshot.data?[index].areaInfo ?? [])) {
                                                                                                            if (element.areaname == areaInfo?[ind].areaname) {
                                                                                                              logger("In if......");

                                                                                                              element.areaqty = areaInfo![ind].areaqty;

                                                                                                              // snapshot.data?[index].areaInfo?.remove(areaInfo?[ind]);
                                                                                                            } else {
                                                                                                              logger("In else......");
                                                                                                              snapshot.data?[index].areaInfo?.remove(areaInfo?[ind]);

                                                                                                              snapshot.data?[index].areaInfo?.add(areaInfo![ind]);

                                                                                                              // snapshot.data?[index].areaInfo?.add(areaInfo![ind]);
                                                                                                            }
                                                                                                          }

                                                                                                          // snapshot.data?[index].areaInfo?.add(areaInfo![ind]);
                                                                                                        } else {
                                                                                                          logger('In not contains');
                                                                                                          validate.add(ind);
                                                                                                          snapshot.data?[index].areaInfo?.add(areaInfo![ind]);
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                    Journey.skuResponseLists = snapshot.data ?? [];
                                                                                                    secureStorageProvider.saveQuoteToDisk(snapshot.data ?? []);
                                                                                                  }
                                                                                                } else {
                                                                                                  Journey.skuResponseLists = snapshot.data ?? [];
                                                                                                  secureStorageProvider.saveQuoteToDisk(snapshot.data ?? []);
                                                                                                  logger('In else');
                                                                                                  Navigator.pop(context);
                                                                                                }
                                                                                              });
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  onChanged: (value) {
                                                                                    setState(() {
                                                                                      _value = !_value;
                                                                                    });
                                                                                  },
                                                                                ),
                                                                              );
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            60,
                                                                      ),
                                                                      Center(
                                                                        child:
                                                                            SizedBox(
                                                                          height:
                                                                              40,
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.2,
                                                                          child:
                                                                              ElevatedButton(
                                                                            onPressed:
                                                                                () async {
                                                                              // widget
                                                                              //     .skuResponseList?[
                                                                              //         index]
                                                                              //     .aREAINFO = [];

                                                                              setState(() {});
                                                                              int quantity = 0;
                                                                              if (data.values.isNotEmpty) {
                                                                                for (int i = 0; i < data.values.length; i++) {
                                                                                  if (data.values.elementAt(i).isNotEmpty) {
                                                                                    quantity += int.parse(data.values.elementAt(i));
                                                                                    logger(quantity);
                                                                                  }
                                                                                }

                                                                                if (quantity > int.parse(snapshot.data?[index].quantity ?? '')) {
                                                                                  _value = true;
                                                                                  snapshot.data?[index].areaInfo = [];
                                                                                  FlutterToastProvider().show(message: 'Entered quantity is greater than total quantity');
                                                                                } else {
                                                                                  Navigator.pop(context, Arguments(data));
                                                                                }
                                                                              } else {
                                                                                logger('In else');
                                                                                Navigator.pop(context);
                                                                              }
                                                                            },
                                                                            style:
                                                                                ElevatedButton.styleFrom(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(35.0),
                                                                              ),
                                                                              backgroundColor: AsianPaintColors.buttonColor,
                                                                              shadowColor: AsianPaintColors.buttonBorderColor,
                                                                              textStyle: TextStyle(
                                                                                color: AsianPaintColors.buttonTextColor,
                                                                                fontSize: 10,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontFamily: AsianPaintsFonts.mulishRegular,
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              'Save',
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
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ).then((value) {
                                                        setState(
                                                          () {
                                                            arguments = value;
                                                            areaData = arguments
                                                                .dataMap;
                                                            logger(
                                                                'Selected map: ${arguments.dataMap.length}');
                                                          },
                                                        );
                                                      });
                                                    },
                                                    child: Visibility(
                                                      visible: (snapshot
                                                                      .data?[
                                                                          index]
                                                                      .aREAINFO
                                                                      ?.length ??
                                                                  0) >
                                                              1
                                                          ? true
                                                          : false,
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)
                                                            .add_area,
                                                        style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          color: AsianPaintColors
                                                              .buttonTextColor,
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishBold,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        //2nd side column start here
                        const SizedBox(
                          width: 60,
                        ),
                        (snapshot.data ?? []).isNotEmpty
                            ? Column(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 3.2,
                                    height: 270,
                                    padding: const EdgeInsets.only(top: 100),
                                    child: Card(
                                      child: ListTile(
                                        //contentPadding: EdgeInsets.all(1),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.only(top: 6),
                                              child: Text(
                                                "Billing Information",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: AsianPaintsFonts
                                                      .mulishBold,
                                                  color: AsianPaintColors
                                                      .chooseYourAccountColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Total Bill (${Journey.totalQuantity} item)",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishMedium,
                                                      color: AsianPaintColors
                                                          .textFieldLabelColor,
                                                      fontSize: 9),
                                                ),
                                                Text(
                                                  '${totalBeforeGST.round()}',
                                                  style: TextStyle(
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishSemiBold,
                                                    color: AsianPaintColors
                                                        .chooseYourAccountColor,
                                                    fontSize: 10,
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "GST %",
                                                  style: TextStyle(
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishMedium,
                                                    color: AsianPaintColors
                                                        .textFieldLabelColor,
                                                    fontSize: 9,
                                                  ),
                                                ),
                                                Text(
                                                  '18 %',
                                                  style: TextStyle(
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishSemiBold,
                                                    color: AsianPaintColors
                                                        .chooseYourAccountColor,
                                                    fontSize: 10,
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            (Journey.isExist ?? true)
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Discount Amount",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishMedium,
                                                          color: AsianPaintColors
                                                              .textFieldLabelColor,
                                                          fontSize: 9,
                                                        ),
                                                      ),
                                                      Text(
                                                        '\u{20B9} $totalDiscountAmount',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishSemiBold,
                                                          color: AsianPaintColors
                                                              .chooseYourAccountColor,
                                                          fontSize: 10,
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : const SizedBox(),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            const Text(
                                                "--------------------------------------------------------"),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Grand Total",
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishMedium,
                                                      color: AsianPaintColors
                                                          .textFieldLabelColor),
                                                ),
                                                Text(
                                                  '\u{20B9} ${totalAfterGST.round()}',
                                                  style: TextStyle(
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishRegular,
                                                      color: AsianPaintColors
                                                          .forgotPasswordTextColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 9),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  BlocConsumer<CreateQuoteBloc,
                                      CreateQuoteState>(
                                    listener: (context, state) {
                                      if (state is CreateQuoteLoaded) {
                                        Journey.quoteName = '';
                                        Journey.quoteID = '';

                                        secureStorageProvider.saveProjectID('');
                                        if (projectID != null &&
                                            projectID!.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProjectsList(
                                                      projID: projectID),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    builder: (context, state) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const SizedBox(
                                            width: 230,
                                          ),
                                          SizedBox(
                                              height: 40,
                                              width: 240,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  bool isAreaEmpty = false;
                                                  for (int i = 0;
                                                      i <
                                                          (snapshot.data ?? [])
                                                              .length;
                                                      i++) {
                                                    for (Area element
                                                        in (snapshot.data?[i]
                                                                .areaInfo ??
                                                            [])) {
                                                      logger(
                                                          "In Area condition ${json.encode(snapshot.data?[i].areaInfo)}");
                                                      if ((element.areaname ??
                                                              '')
                                                          .isEmpty) {
                                                        borderColor = ((element
                                                                        .areaqty ??
                                                                    '')
                                                                .isEmpty)
                                                            ? AsianPaintColors
                                                                .forgotPasswordTextColor
                                                            : AsianPaintColors
                                                                .segregationColor;
                                                        logger(
                                                            "In Area condition");
                                                        isAreaEmpty = true;
                                                        break;
                                                      } else {
                                                        setState(
                                                          () {},
                                                        );
                                                      }
                                                    }
                                                  }

                                                  if (!isAreaEmpty) {
                                                    secureStorageProvider
                                                        .saveQuoteToDisk(
                                                            snapshot.data ??
                                                                []);
                                                    Journey.quoteResponseList =
                                                        snapshot.data ?? [];
                                                    logger(
                                                        "Widget from flip: ${widget.fromFlip}");
                                                    logger(
                                                        "Journey from flip: ${Journey.fromFlip}");
                                                    logger(
                                                        "Project ID: $projectID");
                                                    if ((widget.fromFlip ??
                                                            (Journey.fromFlip ??
                                                                false)) &&
                                                        projectID != null &&
                                                        projectID!.isNotEmpty) {
                                                      logger(
                                                          'Quote Name: ${Journey.quoteName}');
                                                      CreateQuoteBloc
                                                          createProjectBloc =
                                                          context.read<
                                                              CreateQuoteBloc>();

                                                      List<Quoteinfo>
                                                          quoteInfoList = [];
                                                      List<SKUData>
                                                          skuDataList =
                                                          snapshot.data ?? [];
                                                      for (int i = 0;
                                                          i <
                                                              skuDataList
                                                                  .length;
                                                          i++) {
                                                        // List<String> areaStr =
                                                        List<Area> areaInfo =
                                                            [];
                                                        List<Area> areas =
                                                            skuDataList[i]
                                                                    .areaInfo ??
                                                                [];
                                                        for (int j = 0;
                                                            j < areas.length;
                                                            j++) {
                                                          Area area = Area();
                                                          area.areaname = areas[
                                                                      j]
                                                                  .areaname ??
                                                              '';
                                                          area.areaqty = areas[
                                                                      j]
                                                                  .areaqty ??
                                                              '';
                                                          areaInfo.add(area);
                                                        }
                                                        Quoteinfo quoteinfo =
                                                            Quoteinfo();
                                                        quoteinfo.skuid =
                                                            skuDataList[i]
                                                                .skuCatCode;
                                                        quoteinfo.discount =
                                                            skuDataList[i]
                                                                .discount
                                                                .toString();
                                                        quoteinfo.netDiscount =
                                                            skuDataList[i]
                                                                .netDiscount;
                                                        quoteinfo.totalqty =
                                                            skuDataList[i]
                                                                .quantity
                                                                .toString();
                                                        quoteinfo.area =
                                                            areaInfo;
                                                        quoteinfo.totalprice =
                                                            skuDataList[i]
                                                                .totalPriceAfterDiscount
                                                                .toString();
                                                        quoteinfo.bundletype =
                                                            '';
                                                        quoteinfo.netDiscount =
                                                            skuDataList[i]
                                                                    .netDiscount ??
                                                                '0';
                                                        quoteInfoList
                                                            .add(quoteinfo);
                                                      }

                                                      if (quoteInfoList
                                                          .isNotEmpty) {
                                                        createProjectBloc
                                                            .createQuote(
                                                          quoteInfoList:
                                                              quoteInfoList,
                                                          category:
                                                              widget.category,
                                                          brand: widget.brand,
                                                          range: widget.range,
                                                          discountAmount:
                                                              totalDiscountAmount
                                                                  .toString(),
                                                          totalPriceWithGST:
                                                              totalAfterGST
                                                                  .round()
                                                                  .toString(),
                                                          quoteName:
                                                              Journey.quoteName,
                                                          projectID: projectID,
                                                          quoteType: "",
                                                          isExist: true,
                                                          quoteID:
                                                              Journey.quoteID ??
                                                                  '',
                                                          projectName: '',
                                                          contactPerson: '',
                                                          mobileNumber: '',
                                                          siteAddress: '',
                                                          noOfBathrooms: '',
                                                        );
                                                      }

                                                      Journey.skuResponseLists =
                                                          [];
                                                      secureStorageProvider
                                                          .saveQuoteToDisk(Journey
                                                              .skuResponseLists);

                                                      Journey.quoteName = '';
                                                      Journey.quoteID = '';

                                                      secureStorageProvider
                                                          .saveProjectID('');
                                                    } else {
                                                      if (snapshot.data
                                                              ?.isNotEmpty ??
                                                          false) {
                                                        Journey.quoteResponseList =
                                                            snapshot.data;

                                                        Journey.totalAmountAfterGST =
                                                            totalAfterGST
                                                                .round();
                                                        Journey.totalDiscountAmount =
                                                            totalDiscountAmount;
                                                        Journey.category =
                                                            widget.category;
                                                        Journey.brand =
                                                            widget.brand;
                                                        Journey.range =
                                                            widget.range;
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return showQuoteDialog();
                                                          },
                                                        );
                                                      } else {
                                                        FlutterToastProvider().show(
                                                            message:
                                                                'Cannot create a quote with empty list');
                                                      }
                                                    }
                                                  } else {
                                                    setState(
                                                      () {
                                                        FlutterToastProvider().show(
                                                            message:
                                                                'Area cannot be empty');
                                                      },
                                                    );
                                                  }
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          AsianPaintColors
                                                              .kPrimaryColor),
                                                ),
                                                child: state
                                                        is CreateQuoteLoading
                                                    ? Center(
                                                        child: SizedBox(
                                                          height: 15,
                                                          width: 15,
                                                          child: CircularProgressIndicator(
                                                              color: AsianPaintColors
                                                                  .whiteColor),
                                                        ),
                                                      )
                                                    : Text(
                                                        AppLocalizations.of(
                                                                context)
                                                            .save_quote,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishBold,
                                                          color:
                                                              AsianPaintColors
                                                                  .whiteColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                              ))
                                        ],
                                      );
                                    },
                                  )
                                ],
                              )
                            : const SizedBox(
                                height: 0,
                              ),
                      ],
                    ),
                  );
                },
              ),
              tablet: const Scaffold(),
            );
          default:
            return const Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }

  Widget showQuoteDialog() {
    CreateQuoteBloc createProjectBloc = context.read<CreateQuoteBloc>();
    final quoteController = TextEditingController();
    return Responsive(
      tablet: const Scaffold(),
      mobile: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: SizedBox(
          height: 300,
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 15, 20, 0),
                      child: Image.asset(
                        'assets/images/cancel.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New Quote",
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: AsianPaintsFonts.bathSansRegular,
                        color: AsianPaintColors.buttonTextColor,
                        //fontWeight: FontWeight.,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(17, 0, 17, 45),
                width: double.infinity,
                child: TextFormField(
                  enableInteractiveSelection: false,
                  controller: quoteController,
                  cursorColor: AsianPaintColors.textFieldLabelColor,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: AsianPaintColors.textFieldUnderLineColor)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: AsianPaintColors.textFieldUnderLineColor,
                    )),
                    filled: true,
                    focusColor: AsianPaintColors.textFieldUnderLineColor,
                    fillColor: AsianPaintColors.textFieldBorderColor,
                    border: const UnderlineInputBorder(),
                    labelText:
                        'Quote name', //AppLocalizations.of(context).user_id,
                    labelStyle: TextStyle(
                        fontFamily: AsianPaintsFonts.mulishMedium,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AsianPaintColors.textFieldLabelColor),
                  ),
                ),
              ),
              BlocConsumer<CreateQuoteBloc, CreateQuoteState>(
                builder: (context, state) {
                  return SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (quoteController.text.trim().isNotEmpty) {
                          Journey.quoteName = quoteController.text;
                          Navigator.pop(context);
                          if (Journey.quoteName != null &&
                              projectID != null &&
                              (projectID ?? '').isNotEmpty) {
                            List<Quoteinfo> quoteInfoList = [];
                            List<SKUData> skuDataList =
                                Journey.quoteResponseList ?? [];
                            for (int i = 0; i < skuDataList.length; i++) {
                              List<Area> areaInfo = [];
                              List<Area> areas = skuDataList[i].areaInfo ?? [];
                              for (int j = 0; j < areas.length; j++) {
                                Area area = Area();
                                area.areaname = areas[j].areaname ?? '';
                                area.areaqty = areas[j].areaqty ?? '';
                                areaInfo.add(area);
                              }
                              Quoteinfo quoteinfo = Quoteinfo();
                              quoteinfo.skuid = skuDataList[i].skuCatCode;
                              quoteinfo.discount =
                                  skuDataList[i].discount.toString();
                              quoteinfo.netDiscount =
                                  skuDataList[i].netDiscount;
                              quoteinfo.totalqty =
                                  skuDataList[i].quantity.toString();
                              quoteinfo.area = areaInfo;
                              quoteinfo.totalprice = skuDataList[i]
                                  .totalPriceAfterDiscount
                                  .toString();
                              quoteinfo.bundletype = '';
                              quoteinfo.netDiscount =
                                  skuDataList[i].netDiscount ?? '0';
                              quoteInfoList.add(quoteinfo);
                            }

                            if (quoteInfoList.isNotEmpty) {
                              createProjectBloc.createQuote(
                                quoteInfoList: quoteInfoList,
                                category: widget.category,
                                brand: widget.brand,
                                range: widget.range,
                                discountAmount: totalDiscountAmount.toString(),
                                totalPriceWithGST:
                                    totalAfterGST.round().toString(),
                                quoteName: Journey.quoteName,
                                projectID: projectID,
                                quoteType: "",
                                isExist: true,
                                quoteID: Journey.quoteID ?? '',
                                projectName: '',
                                contactPerson: '',
                                mobileNumber: '',
                                siteAddress: '',
                                noOfBathrooms: '',
                              );
                            }

                            Journey.skuResponseLists = [];
                            secureStorageProvider
                                .saveQuoteToDisk(Journey.skuResponseLists);

                            secureStorageProvider.saveProjectID('');
                            Journey.quoteName = '';
                            Journey.quoteID = '';
                          } else {
                            logger('Project ID: ${Journey.projectID}');
                            secureStorageProvider.saveCategory(category);
                            secureStorageProvider.saveBrand(brand);
                            secureStorageProvider.saveRange(range);
                            secureStorageProvider.saveProjectID('');
                            if (quoteController.text.trim().isNotEmpty) {
                              if ((Journey.projectID ?? '').isEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProjectsList(),
                                  ),
                                );
                              }
                            } else {
                              FlutterToastProvider().show(
                                  message: 'Please enter valid Quote name');
                            }
                          }
                        } else {
                          FlutterToastProvider()
                              .show(message: 'Please enter valid Quote name');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                        backgroundColor:
                            AsianPaintColors.resetPasswordLabelColor,
                        shadowColor: AsianPaintColors.buttonBorderColor,
                        textStyle: TextStyle(
                          color: AsianPaintColors.whiteColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: AsianPaintsFonts.mulishBold,
                        ),
                      ),
                      child: Text(
                        'Create & Add to Project',
                        style: TextStyle(
                          fontFamily: AsianPaintsFonts.mulishBold,
                          color: AsianPaintColors.whiteColor,
                          //color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
                listener: (context, state) {
                  if (state is CreateQuoteInitial) {
                    SizedBox(
                      height: displayHeight(context) * 0.65,
                      width: displayWidth(context),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is CreateQuoteLoading) {
                    SizedBox(
                      height: displayHeight(context) * 0.65,
                      width: displayWidth(context),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is CreateQuoteLoaded) {
                    logger('Create quote Loaded');
                    Journey.quoteName = '';
                    Journey.quoteID = '';
                    Journey.projectID = projectID;

                    secureStorageProvider.saveProjectID('');
                    if (projectID != null && projectID!.isNotEmpty) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProjectDescription(projectID: projectID),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      desktop: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: SizedBox(
          height: 300,
          width: 300,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 15, 20, 0),
                      child: Image.asset(
                        'assets/images/cancel.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New Quote",
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: AsianPaintsFonts.bathSansRegular,
                        color: AsianPaintColors.buttonTextColor,
                        //fontWeight: FontWeight.,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 17, 45),
                width: double.infinity,
                child: TextFormField(
                  enableInteractiveSelection: false,
                  controller: quoteController,
                  cursorColor: AsianPaintColors.textFieldLabelColor,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: AsianPaintColors.textFieldUnderLineColor)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: AsianPaintColors.textFieldUnderLineColor,
                    )),
                    filled: true,
                    focusColor: AsianPaintColors.textFieldUnderLineColor,
                    fillColor: AsianPaintColors.textFieldBorderColor,
                    border: const UnderlineInputBorder(),
                    labelText:
                        'Quote name', //AppLocalizations.of(context).user_id,
                    labelStyle: TextStyle(
                        fontFamily: AsianPaintsFonts.mulishMedium,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AsianPaintColors.textFieldLabelColor),
                  ),
                ),
              ),
              BlocConsumer<CreateQuoteBloc, CreateQuoteState>(
                listener: (context, state) {
                  if (state is CreateQuoteInitial) {
                    SizedBox(
                      height: displayHeight(context) * 0.65,
                      width: displayWidth(context),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is CreateQuoteLoading) {
                    SizedBox(
                      height: displayHeight(context) * 0.65,
                      width: displayWidth(context),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is CreateQuoteLoaded) {
                    logger('Create quote Loaded');
                    Journey.quoteName = '';
                    Journey.quoteID = '';
                    Journey.projectID = projectID;

                    secureStorageProvider.saveProjectID('');
                    if (projectID != null && projectID!.isNotEmpty) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectsList(
                            projID: Journey.projectID,
                            projIndex: 0,
                            fromMyProjs: false,
                          ),
                        ),
                      );
                    }
                  }
                },
                builder: (context, state) {
                  return SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        Journey.quoteName = quoteController.text;

                        if (quoteController.text.trim().isNotEmpty) {
                          Journey.quoteName = quoteController.text;
                          Navigator.pop(context);
                          if (Journey.quoteName != null &&
                              projectID != null &&
                              (projectID ?? '').isNotEmpty) {
                            List<Quoteinfo> quoteInfoList = [];
                            List<SKUData> skuDataList =
                                Journey.quoteResponseList ?? [];
                            for (int i = 0; i < skuDataList.length; i++) {
                              List<Area> areaInfo = [];
                              List<Area> areas = skuDataList[i].areaInfo ?? [];
                              for (int j = 0; j < areas.length; j++) {
                                Area area = Area();
                                area.areaname = areas[j].areaname ?? '';
                                area.areaqty = areas[j].areaqty ?? '';
                                areaInfo.add(area);
                              }
                              Quoteinfo quoteinfo = Quoteinfo();
                              quoteinfo.skuid = skuDataList[i].skuCatCode;
                              quoteinfo.discount =
                                  skuDataList[i].discount.toString();
                              quoteinfo.netDiscount =
                                  skuDataList[i].netDiscount;
                              quoteinfo.totalqty =
                                  skuDataList[i].quantity.toString();
                              quoteinfo.area = areaInfo;
                              quoteinfo.totalprice = skuDataList[i]
                                  .totalPriceAfterDiscount
                                  .toString();
                              quoteinfo.bundletype = '';
                              quoteinfo.netDiscount =
                                  skuDataList[i].netDiscount ?? '0';
                              quoteInfoList.add(quoteinfo);
                            }

                            if (quoteInfoList.isNotEmpty) {
                              createProjectBloc.createQuote(
                                quoteInfoList: quoteInfoList,
                                category: widget.category,
                                brand: widget.brand,
                                range: widget.range,
                                discountAmount: totalDiscountAmount.toString(),
                                totalPriceWithGST:
                                    totalAfterGST.round().toString(),
                                quoteName: Journey.quoteName,
                                projectID: projectID,
                                quoteType: "",
                                isExist: true,
                                quoteID: Journey.quoteID ?? '',
                                projectName: '',
                                contactPerson: '',
                                mobileNumber: '',
                                siteAddress: '',
                                noOfBathrooms: '',
                              );
                            }

                            Journey.skuResponseLists = [];
                            secureStorageProvider
                                .saveQuoteToDisk(Journey.skuResponseLists);

                            secureStorageProvider.saveProjectID('');
                            Journey.quoteName = '';
                            Journey.quoteID = '';
                          } else {
                            logger('Project ID: ${Journey.projectID}');
                            if (quoteController.text.trim().isNotEmpty) {
                              if ((Journey.projectID ?? '').isEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyProjectUi(
                                        fromMyProjs: false,
                                        fromViewQuote: true),
                                  ),
                                );
                              }
                            } else {
                              FlutterToastProvider().show(
                                  message: 'Please enter valid Quote name');
                            }
                          }
                        } else {
                          FlutterToastProvider()
                              .show(message: 'Please enter valid Quote name');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                        backgroundColor:
                            AsianPaintColors.resetPasswordLabelColor,
                        shadowColor: AsianPaintColors.buttonBorderColor,
                        textStyle: TextStyle(
                          color: AsianPaintColors.whiteColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: AsianPaintsFonts.mulishBold,
                        ),
                      ),
                      child: Text(
                        'Create & Add to Project',
                        style: TextStyle(
                          fontFamily: AsianPaintsFonts.mulishBold,
                          color: AsianPaintColors.whiteColor,
                          //color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showExportPopupMenu(
    BuildContext context, Offset offset, String projectID) async {
  await showMenu(
    clipBehavior: Clip.hardEdge,
    context: context,
    position: RelativeRect.fromLTRB(
      offset.dx,
      offset.dy,
      0,
      offset.dx,
    ),
    items: [
      PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              SvgPicture.asset('./assets/images/share.svg'),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                //width: 120,
                child: Text(
                  "Share",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AsianPaintsFonts.mulishRegular,
                    fontWeight: FontWeight.w400,
                    color: AsianPaintColors.skuDescriptionColor,
                  ),
                ),
              ),
            ],
          )),
      PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              SvgPicture.asset('./assets/images/excel.svg'),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                //width: 120,
                child: Text(
                  "Export as Excel",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AsianPaintsFonts.mulishRegular,
                    fontWeight: FontWeight.w400,
                    color: AsianPaintColors.skuDescriptionColor,
                  ),
                ),
              ),
            ],
          )),
      PopupMenuItem(
          value: 2,
          child: BlocConsumer<ExportProjectBloc, ExportProjectState>(
            builder: (context, state) {
              ExportProjectBloc exportProjectBloc =
                  context.read<ExportProjectBloc>();
              return InkWell(
                onTap: () async {
                  var appDir = (await getTemporaryDirectory()).path;
                  Directory(appDir).delete(recursive: true);
                  exportProjectBloc.getExportProject(
                      projectID: projectID, quoteID: '');
                },
                child: Row(
                  children: [
                    SvgPicture.asset('./assets/images/pdf.svg'),
                    const SizedBox(
                      width: 10,
                    ),
                    state is ExportProjectLoading
                        ? SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                                color: AsianPaintColors.buttonTextColor),
                          )
                        : Text(
                            "Export as Pdf",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              fontWeight: FontWeight.w400,
                              color: AsianPaintColors.skuDescriptionColor,
                            ),
                          ),
                  ],
                ),
              );
            },
            listener: (context, state) {
              ExportProjectBloc exportProjectBloc =
                  context.read<ExportProjectBloc>();
              if (state is ExportProjectLoading) {
                const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ExportProjectLoaded) {
                Navigator.pop(context);
                Navigator.pop(context);
                // Share.share(
                //     exportProjectBloc.exportProjectResponseModel?.pdfurl ?? '');
                Navigator.push(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (_) => PDFViewerCachedFromUrl(
                      url: exportProjectBloc
                              .exportProjectResponseModel?.pdfurl ??
                          '',
                      name: projectID,
                      allowShare: true,
                    ),
                  ),
                );
              }
            },
          )),
    ],
  ).then((value) {
// NOTE: even you didnt select item this method will be called with null of value so you should call your call back with checking if value is not null

    if (value != null) print(value);
  });
}

void showExportPopupMenuWeb(
    BuildContext context, Offset offset, String projectID) async {
  await showMenu(
    clipBehavior: Clip.hardEdge,
    context: context,
    position: RelativeRect.fromLTRB(
      offset.dx,
      offset.dy,
      0,
      offset.dx,
    ),
    items: [
      PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              SvgPicture.asset('./assets/images/share.svg'),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                //width: 120,
                child: Text(
                  "Share",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AsianPaintsFonts.mulishRegular,
                    fontWeight: FontWeight.w400,
                    color: AsianPaintColors.skuDescriptionColor,
                  ),
                ),
              ),
            ],
          )),
      PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              SvgPicture.asset('./assets/images/excel.svg'),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                //width: 120,
                child: Text(
                  "Export as Excel",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AsianPaintsFonts.mulishRegular,
                    fontWeight: FontWeight.w400,
                    color: AsianPaintColors.skuDescriptionColor,
                  ),
                ),
              ),
            ],
          )),
      PopupMenuItem(
          value: 2,
          child: BlocConsumer<ExportProjectBloc, ExportProjectState>(
            builder: (context, state) {
              ExportProjectBloc exportProjectBloc =
                  context.read<ExportProjectBloc>();
              return InkWell(
                onTap: () async {
                  var appDir = (await getTemporaryDirectory()).path;
                  Directory(appDir).delete(recursive: true);
                  exportProjectBloc.getExportProject(
                      projectID: projectID, quoteID: '');
                },
                child: Row(
                  children: [
                    SvgPicture.asset('./assets/images/pdf.svg'),
                    const SizedBox(
                      width: 10,
                    ),
                    state is ExportProjectLoading
                        ? SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                                color: AsianPaintColors.buttonTextColor),
                          )
                        : Text(
                            "Export as Pdf",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              fontWeight: FontWeight.w400,
                              color: AsianPaintColors.skuDescriptionColor,
                            ),
                          ),
                  ],
                ),
              );
            },
            listener: (context, state) {
              ExportProjectBloc exportProjectBloc =
                  context.read<ExportProjectBloc>();
              if (state is ExportProjectLoading) {
                const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ExportProjectLoaded) {
                downloadFile(
                    exportProjectBloc.exportProjectResponseModel?.pdfurl ?? '');
              }
            },
          )),
    ],
  );
}

downloadFile(url) {
  launchUrl(Uri.parse(url));
}
