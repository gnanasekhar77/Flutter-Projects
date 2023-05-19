import 'dart:convert';

import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/sku_request_model.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/presentation/blocs/sku/sku_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/sku/sku_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/sku/sku_state.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/view_quote.dart';
import 'package:APaints_QGen/src/presentation/views/sku/sku_description.dart';
import 'package:APaints_QGen/src/presentation/widgets/app_bar.dart';
import 'package:APaints_QGen/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SKUList extends StatefulWidget {
  static const routeName = Routes.SKUScreen;

  final int catIndex, brandIndex, rangeIndex;
  final String? category, brand, range;
  final String? skuCode, skuQty;
  final bool? fromProject;
  final String? quoteName;
  final List<SKUData>? skuResponse;
  final bool? fromFlip;

  const SKUList(
      {super.key,
      required this.catIndex,
      required this.brandIndex,
      required this.rangeIndex,
      required this.category,
      required this.brand,
      required this.range,
      this.skuCode,
      this.skuQty,
      this.fromProject,
      this.quoteName,
      this.skuResponse,
      this.fromFlip});

  @override
  State<SKUList> createState() => _SKUListState();
}

class _SKUListState extends State<SKUList> {
  bool flag = false;
  late String result = '';
  final qtyController = TextEditingController(text: "");
  List<SKUData> skuResponseLists = [];
  List<COMPLEMENTARY> complementaryList = [];
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  int cartCount = 0;
  FocusNode textSecondFocusNode = FocusNode();
  int totPrice = 0;
  int price = 0;
  List<TextEditingController> controllers = [];
  List<TextEditingController> compControllers = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      skuResponseLists = Journey.skuResponseLists;
      price = 0;
      totPrice = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SkuListBloc>();

    logger('From flip in SKu list: ${widget.fromFlip}');

    // List<String> areas = [
    //   'ALL',
    //   'SHOWER',
    //   'KITCHEN_REFUGE',
    //   'BASIN',
    //   'WC',
    // ];

    Set<String> areas = {};

    return Responsive(
      desktop: Scaffold(
        appBar: AppBarTemplate(
          header: AppLocalizations.of(context).sku,
          isVisible: true,
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => SkuListBloc()
                ..getSkuList(
                  category: widget.category,
                  brand: widget.brand,
                  range: widget.range,
                  area: '',
                  limit: 1,
                ),
            ),
          ],
          child: BlocConsumer<SkuListBloc, SkuState>(
            builder: (context, state) {
              Widget compItemListWeb(
                  List<COMPLEMENTARY> compData,
                  int index,
                  TextEditingController compController,
                  List<TextEditingController> compControllers) {
                int singleQuantity = 0;
                int singlePrice = 0;
                return Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: AsianPaintColors.appBackgroundColor,
                    ),
                  ),
                  child: ListTile(
                    leading: Image.network((compData[index].cMPIMAGE ?? '')
                            .isEmpty
                        ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
                        : compData[index].cMPIMAGE ?? ''),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              complementaryList[index].cMPCATCODE ?? '',
                              style: TextStyle(
                                color: AsianPaintColors.chooseYourAccountColor,
                                fontFamily: AsianPaintsFonts.mulishBold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              compData[index].cMPDESCRIPTION ?? '',
                              style: TextStyle(
                                color: AsianPaintColors.skuDescriptionColor,
                                fontFamily: AsianPaintsFonts.mulishRegular,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\u{20B9} ${compData[index].cMPMR}',
                              style: TextStyle(
                                color: AsianPaintColors.forgotPasswordTextColor,
                                fontFamily: AsianPaintsFonts.mulishSemiBold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(
                              width: 55,
                              height: 35,
                              child: TextFormField(
                                //enableInteractiveSelection: false,
                                enableInteractiveSelection: false,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        signed: true, decimal: true),
                                controller: compController,
                                // autofocus: true,
                                // focusNode: FocusNode.,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                                textAlignVertical: TextAlignVertical.center,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'),
                                  ),
                                  FilteringTextInputFormatter.deny(
                                    RegExp(
                                        r'^0+'), //users can't type 0 at 1st position
                                  ),
                                  // FilteringTextInputFormatter
                                  //     .allow(RegExp("[0-9]"))
                                ],
                                decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        10.0, 10.0, 10.0, 10.0),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AsianPaintColors.kPrimaryColor,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AsianPaintColors.kPrimaryColor,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AsianPaintColors.kPrimaryColor,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    filled: true,
                                    hintStyle:
                                        TextStyle(color: Colors.grey[800]),
                                    labelText: "+Add",
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    fillColor: Colors.white70),
                                // onTap: () {
                                //   if (compController.text.isEmpty) {
                                //     compController.text = '1';
                                //   }
                                // },
                                // onChanged: (value) {
                                //   int quantity = 0;

                                //   int price = 0;

                                //   logger(
                                //       'Complementary Length: ${compData.length}');

                                //   for (int i = 0; i < compData.length; i++) {
                                //     logger(
                                //         "In if condition i::: ${compControllers[i].text}");
                                //     logger(
                                //         "In if condition index::: ${compControllers[index].text}");

                                //     if ((compControllers[i].text).isNotEmpty) {
                                //       singleQuantity =
                                //           int.parse(compControllers[i].text);
                                //       price = price +
                                //           (int.parse(compControllers[i].text) *
                                //               int.parse(compData[i].cMPMR!));
                                //       singlePrice =
                                //           int.parse(compControllers[i].text) *
                                //               int.parse(compData[i].cMPMR!);

                                //       SKUData skuData = SKUData();
                                //       skuData.sKURANGE =
                                //           compData[i].cMPRANGE ?? '';
                                //       skuData.sKUIMAGE =
                                //           compData[i].cMPIMAGE ?? '';
                                //       skuData.sKUCATEGORY =
                                //           compData[i].cMPCATEGORY ?? '';
                                //       skuData.sKUUSP = compData[i].cMPUSP ?? '';
                                //       skuData.sKUPRODUCTCAT =
                                //           compData[i].cMPPRODUCTCAT ?? '';
                                //       skuData.sKUDESCRIPTION =
                                //           compData[i].cMPDESCRIPTION ?? '';
                                //       skuData.complementary = [];
                                //       skuData.sKUMRP = compData[i].cMPMR ?? '';
                                //       skuData.sKUCODE =
                                //           compData[i].cMPSKUCODE ?? '';
                                //       skuData.sKUSRP = compData[i].cMPSRP ?? '';
                                //       skuData.sKUDRAWING =
                                //           compData[i].cMPDRAWING ?? '';
                                //       skuData.sKUBRAND =
                                //           compData[i].cMPBRAND ?? '';
                                //       skuData.aREAINFO = [];
                                //       skuData.skuCatCode =
                                //           compData[i].cMPCATCODE ?? '';
                                //       skuData.sKUTYPE =
                                //           compData[i].cMPSKUTYPE ?? '';
                                //       skuData.discount = 0;
                                //       skuData.quantity =
                                //           compControllers[i].text;
                                //       skuData.totalPrice =
                                //           int.parse(compControllers[i].text) *
                                //               int.parse(compData[i].cMPMR!);
                                //       skuData.totalPriceAfterDiscount =
                                //           singlePrice;
                                //       skuData.index = 0;

                                //       skuData.areaInfo = [];
                                //       skuData.skuTypeExpanded = '';
                                //       skuData.productCardDescriptior = '';
                                //       price +=
                                //           skuData.totalPriceAfterDiscount ?? 0;

                                //       if (!Journey.skuResponseLists
                                //           .contains(skuData)) {
                                //         logger("In if condition:::");
                                //         Journey.skuResponseLists.add(skuData);
                                //       }
                                //     }
                                //   }

                                //   // skuRequestBody.quoteinfo = quoteInfoList;

                                //   // Journey.skuRequestBody = skuRequestBody;
                                //   Journey.totalQuantity = quantity;
                                //   Journey.totalPrice = price;

                                //   _secureStorageProvider.saveQuoteToDisk(
                                //       Journey.skuResponseLists);
                                //   _secureStorageProvider
                                //       .saveCartDetails(skuResponseLists);
                                //   _secureStorageProvider
                                //       .saveCategory(widget.category);
                                //   _secureStorageProvider
                                //       .saveBrand(widget.brand);
                                //   _secureStorageProvider
                                //       .saveRange(widget.range);
                                //   _secureStorageProvider
                                //       .saveTotalPrice(price.toString());

                                //   logger('Quantity: $quantity');
                                //   setState(
                                //     () {
                                //       cartCount =
                                //           Journey.skuResponseLists.length;
                                //       _secureStorageProvider
                                //           .saveCartCount(cartCount);
                                //       logger('Cart count: $cartCount');
                                //       logger('Quantity: $quantity');
                                //     },
                                //   );

                                //   quantity = 0;
                                //   price = 0;

                                //   for (int i = 0;
                                //       i < Journey.skuResponseLists.length;
                                //       i++) {
                                //     // if (compControllers[i].text.isNotEmpty) {

                                //     setState(() {
                                //       quantity = quantity +
                                //           int.parse(Journey.skuResponseLists[i]
                                //                   .quantity ??
                                //               '0');

                                //       price = price +
                                //           (int.parse(Journey.skuResponseLists[i]
                                //                       .quantity ??
                                //                   '0') *
                                //               int.parse(Journey
                                //                       .skuResponseLists[i]
                                //                       .sKUMRP ??
                                //                   '0'));
                                //       totPrice = price;
                                //     });

                                //     // }
                                //   }
                                // },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              Widget showCompSkuDialog(List<COMPLEMENTARY> complementaryList) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: SizedBox(
                    height: 400,
                    width: 400,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 20, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Complementary SKU's",
                                style: TextStyle(
                                  color: AsianPaintColors.buttonTextColor,
                                  fontFamily: AsianPaintsFonts.bathSansRegular,
                                  // fontWeight: FontWeight.w400,
                                  fontSize: 25,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop(context);
                                },
                                child: Image.asset(
                                  'assets/images/cancel.png',
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          height: 260,
                          child: ListView.separated(
                            itemBuilder: (BuildContext context, int index) {
                              compControllers
                                  .add(TextEditingController(text: ''));
                              if (complementaryList.isEmpty) {
                                return const Center(
                                  child: Text('No data available'),
                                );
                              } else {
                                return compItemListWeb(complementaryList, index,
                                    compControllers[index], compControllers);
                              }
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const Divider(
                                color: Colors.white,
                              );
                            },
                            itemCount: complementaryList.length,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 350,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              int quantity = 0;

                              int price = 0;
                              int singleQuantity = 0;
                              int singlePrice = 0;
                              List<Area> areas = [];
                              List<String> area = [];

                              logger(
                                  'Complementary Length: ${complementaryList.length}');

                              for (int i = 0;
                                  i < complementaryList.length;
                                  i++) {
                                logger(
                                    "In if condition i::: ${compControllers[i].text}");
                                logger(
                                    "In if condition index::: ${compControllers[i].text}");

                                if ((compControllers[i].text).isNotEmpty) {
                                  singleQuantity =
                                      int.parse(compControllers[i].text);
                                  price = price +
                                      (int.parse(compControllers[i].text) *
                                          int.parse(
                                              complementaryList[i].cMPMR!));
                                  singlePrice = int.parse(
                                          compControllers[i].text) *
                                      int.parse(complementaryList[i].cMPMR!);

                                  SKUData skuData = SKUData();
                                  skuData.sKURANGE =
                                      complementaryList[i].cMPRANGE ?? '';
                                  skuData.sKUIMAGE =
                                      complementaryList[i].cMPIMAGE ?? '';
                                  skuData.sKUCATEGORY =
                                      complementaryList[i].cMPCATEGORY ?? '';
                                  skuData.sKUUSP =
                                      complementaryList[i].cMPUSP ?? '';
                                  skuData.sKUPRODUCTCAT =
                                      complementaryList[i].cMPPRODUCTCAT ?? '';
                                  skuData.sKUDESCRIPTION =
                                      complementaryList[i].cMPDESCRIPTION ?? '';
                                  skuData.complementary = [];
                                  skuData.sKUMRP =
                                      complementaryList[i].cMPMR ?? '';
                                  skuData.sKUCODE =
                                      complementaryList[i].cMPSKUCODE ?? '';
                                  skuData.sKUSRP =
                                      complementaryList[i].cMPSRP ?? '';
                                  skuData.sKUDRAWING =
                                      complementaryList[i].cMPDRAWING ?? '';
                                  skuData.sKUBRAND =
                                      complementaryList[i].cMPBRAND ?? '';
                                  area = [];
                                  area.add('SHOWER_AREA');
                                  skuData.aREAINFO = area;
                                  skuData.skuCatCode =
                                      complementaryList[i].cMPCATCODE ?? '';
                                  skuData.sKUTYPE =
                                      complementaryList[i].cMPSKUTYPE ?? '';
                                  skuData.discount = 0;
                                  skuData.quantity = compControllers[i].text;
                                  skuData.totalPrice = int.parse(
                                          compControllers[i].text) *
                                      int.parse(complementaryList[i].cMPMR!);
                                  skuData.totalPriceAfterDiscount = singlePrice;
                                  skuData.index = 0;

                                  areas = [];
                                  areas.add(Area(
                                      areaname: 'SHOWER_AREA', areaqty: '1'));

                                  skuData.areaInfo = areas;
                                  skuData.skuTypeExpanded = '';
                                  skuData.productCardDescriptior = '';
                                  price += skuData.totalPriceAfterDiscount ?? 0;

                                  if (!Journey.skuResponseLists
                                      .contains(skuData)) {
                                    logger("In if condition:::");
                                    Journey.skuResponseLists.add(skuData);
                                  }
                                }
                              }

                              // skuRequestBody.quoteinfo = quoteInfoList;

                              // Journey.skuRequestBody = skuRequestBody;
                              Journey.totalQuantity = quantity;
                              Journey.totalPrice = price;

                              logger(
                                  'JOurney length: ${Journey.skuResponseLists.length}');

                              _secureStorageProvider
                                  .saveQuoteToDisk(Journey.skuResponseLists);
                              _secureStorageProvider
                                  .saveCartDetails(skuResponseLists);
                              _secureStorageProvider
                                  .saveCategory(widget.category);
                              _secureStorageProvider.saveBrand(widget.brand);
                              _secureStorageProvider.saveRange(widget.range);

                              logger('Quantity: $quantity');
                              setState(
                                () {
                                  cartCount = Journey.skuResponseLists.length;
                                  _secureStorageProvider
                                      .saveCartCount(cartCount);
                                  logger('Cart count: $cartCount');
                                  logger('Quantity: $quantity');
                                },
                              );

                              // quantity = 0;
                              // price = 0;

                              // for (int i = 0;
                              //     i < Journey.skuResponseLists.length;
                              //     i++) {
                              //   // if (compControllers[i].text.isNotEmpty) {
                              //   quantity = quantity +
                              //       int.parse(
                              //           Journey.skuResponseLists[i].quantity ??
                              //               '0');

                              //   price = price +
                              //       (int.parse(Journey
                              //                   .skuResponseLists[i].quantity ??
                              //               '0') *
                              //           int.parse(Journey
                              //                   .skuResponseLists[i].sKUMRP ??
                              //               '0'));
                              //   totPrice = price;
                              //   // }
                              // }
                              _secureStorageProvider
                                  .saveTotalPrice(price.toString());
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35.0),
                              ),
                              backgroundColor: AsianPaintColors.buttonColor,
                              shadowColor: AsianPaintColors.buttonBorderColor,
                              textStyle: TextStyle(
                                color: AsianPaintColors.buttonTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: AsianPaintsFonts.mulishRegular,
                              ),
                            ),
                            child: Text(
                              'Save & Return',
                              style: TextStyle(
                                fontFamily: AsianPaintsFonts.mulishBold,
                                color: AsianPaintColors.whiteColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              Widget singleItemListWeb(
                  SKUResponse skuResponse,
                  int index,
                  TextEditingController controller,
                  List<TextEditingController> controllers) {
                List<SKUData> skuResponseList = [];
                List<SkuRequestBody> skuRequestList = [];
                List<Quoteinfo> quoteInfoList = [];
                SkuRequestBody skuRequestBody = SkuRequestBody();
                int singleQuantity = 0;
                int singlePrice = 0;
                var results;
                return StatefulBuilder(
                  builder: (context, setState) {
                    return InkWell(
                      onTap: () async {
                        Journey.skuIndex = index;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SKUDescriptionPage(
                              quantity: controller.text,
                              key: Key(skuResponse.data!.length.toString()),
                              catIndex: widget.catIndex,
                              brandIndex: widget.brandIndex,
                              rangeIndex: widget.rangeIndex,
                              category: widget.category,
                              brand: widget.brand,
                              range: widget.range,
                              skuData: skuResponse.data![index],
                            ),
                          ),
                        ).then((value) => setState(() {
                              logger(value);
                              controller.text = value;
                              if (value.toString().isNotEmpty) {
                                FlutterToastProvider()
                                    .show(message: ' SKU added successfully!!');
                              }
                            }));

                        logger('Controller value: ${controller.text}');
                        logger('Result: ${Journey.att[0]}');
                        logger({skuResponse.data![index].skuCatCode});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Image.network(
                                      (skuResponse.data![index].sKUIMAGE ?? '')
                                              .isEmpty
                                          ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
                                          : skuResponse.data![index].sKUIMAGE!,
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.18,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 12, 0, 0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          skuResponse.data![index].skuCatCode!,
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
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 5, 0, 0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          skuResponse
                                              .data![index].sKUDESCRIPTION!,
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
                                          skuResponse.data![index]
                                              .productCardDescriptior!,
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
                                    // const SizedBox(
                                    //   height: 20,
                                    // ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 0, 0),
                                          child: Text(
                                            textAlign: TextAlign.start,
                                            '\u{20B9} ${skuResponse.data![index].sKUMRP!}',
                                            style: TextStyle(
                                                color: AsianPaintColors
                                                    .forgotPasswordTextColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: AsianPaintsFonts
                                                    .mulishBold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 10, 0),
                                          child: SizedBox(
                                            width: 50,
                                            height: 25,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: TextField(
                                                enableInteractiveSelection:
                                                    false,
                                                keyboardType:
                                                    const TextInputType
                                                            .numberWithOptions(
                                                        signed: true,
                                                        decimal: true),
                                                controller: controller,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                                textAlignVertical:
                                                    TextAlignVertical.bottom,
                                                textAlign: TextAlign.center,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(r'[0-9]'),
                                                  ),
                                                  FilteringTextInputFormatter
                                                      .deny(
                                                    RegExp(
                                                        r'^0+'), //users can't type 0 at 1st position
                                                  ),
                                                ],
                                                decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets
                                                                .fromLTRB(10.0,
                                                            10.0, 10.0, 10.0),
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AsianPaintColors
                                                            .kPrimaryColor,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AsianPaintColors
                                                            .kPrimaryColor,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AsianPaintColors
                                                            .kPrimaryColor,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    filled: true,
                                                    hintStyle: TextStyle(
                                                        color:
                                                            Colors.grey[800]),
                                                    labelText: "+Add",
                                                    fillColor: Colors.white70),
                                                onTap: () {
                                                  if (controller.text.isEmpty) {
                                                    controller.text = '1';
                                                    int quantity = 0;
                                                    FocusScope.of(context)
                                                        .requestFocus();

                                                    price = 0;
                                                    skuResponseLists = [];
                                                    complementaryList = [];
                                                    for (int i = 0;
                                                        i < controllers.length;
                                                        i++) {
                                                      if (controllers[i]
                                                              .text
                                                              .isNotEmpty &&
                                                          controllers[i].text !=
                                                              '0') {
                                                        singleQuantity =
                                                            int.parse(
                                                                controllers[i]
                                                                    .text);
                                                        price = price +
                                                            (int.parse(
                                                                    controllers[
                                                                            i]
                                                                        .text) *
                                                                int.parse(
                                                                    skuResponse
                                                                        .data![
                                                                            i]
                                                                        .sKUMRP!));
                                                        singlePrice = int.parse(
                                                                controllers[i]
                                                                    .text) *
                                                            int.parse(
                                                                skuResponse
                                                                    .data![i]
                                                                    .sKUMRP!);
                                                        skuResponseList.add(
                                                            skuResponse
                                                                .data![i]);
                                                        Journey.skuDataList =
                                                            skuResponseList;
                                                        Quoteinfo quoteinfo =
                                                            Quoteinfo();
                                                        quoteinfo.totalqty =
                                                            '$singleQuantity';
                                                        quoteinfo.totalprice =
                                                            '$singlePrice';
                                                        quoteInfoList
                                                            .add(quoteinfo);
                                                        if ((skuResponse
                                                                    .data?[i]
                                                                    .complementary ??
                                                                [])
                                                            .isNotEmpty) {
                                                          for (int j = 0;
                                                              j <
                                                                  (skuResponse.data?[i]
                                                                              .complementary ??
                                                                          [])
                                                                      .length;
                                                              j++) {
                                                            COMPLEMENTARY
                                                                complementary =
                                                                COMPLEMENTARY();
                                                            complementary
                                                                .cMPSRP = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPSRP ??
                                                                '';
                                                            complementary
                                                                .cMPUSP = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPUSP ??
                                                                '';
                                                            complementary
                                                                .cMPMR = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPMR ??
                                                                '';
                                                            complementary
                                                                .cMPDESCRIPTION = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPDESCRIPTION ??
                                                                '';
                                                            complementary
                                                                .cMPDRAWING = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPDRAWING ??
                                                                '';
                                                            complementary
                                                                .cMPRANGE = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPRANGE ??
                                                                '';
                                                            complementary
                                                                .cMPPRODUCTCAT = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPPRODUCTCAT ??
                                                                '';
                                                            complementary
                                                                .cMPSKUCODE = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPSKUCODE ??
                                                                '';
                                                            complementary
                                                                .cMPBRAND = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPBRAND ??
                                                                '';
                                                            complementary
                                                                .cMPSKUTYPE = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPSKUTYPE ??
                                                                '';
                                                            complementary
                                                                .cMPIMAGE = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPIMAGE ??
                                                                '';
                                                            complementary
                                                                .cMPCATCODE = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPCATCODE ??
                                                                '';
                                                            complementary
                                                                .cMPCATEGORY = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPCATEGORY ??
                                                                '';
                                                            complementaryList.add(
                                                                complementary);
                                                          }
                                                        }

                                                        skuResponse.data?[i]
                                                                .quantity =
                                                            controllers[i].text;

                                                        skuResponse.data?[i]
                                                            .totalPrice = int
                                                                .parse(
                                                                    controllers[
                                                                            i]
                                                                        .text) *
                                                            int.parse(
                                                                skuResponse
                                                                    .data![i]
                                                                    .sKUMRP!);
                                                        skuResponse.data?[i]
                                                                .totalPriceAfterDiscount =
                                                            singlePrice;

                                                        skuResponse.data?[i]
                                                            .discount = 0;

                                                        if (!skuResponseLists
                                                            .contains(
                                                                skuResponse
                                                                        .data?[
                                                                    i])) {
                                                          logger(
                                                              "In if condition:::");
                                                          skuResponseLists.add(
                                                              (skuResponse
                                                                      .data ??
                                                                  [])[i]);
                                                        }

                                                        if (!Journey
                                                            .skuResponseLists
                                                            .contains(
                                                                skuResponse
                                                                        .data?[
                                                                    i])) {
                                                          logger(
                                                              "In if condition:::");

                                                          Journey
                                                              .skuResponseLists
                                                              .add((skuResponse
                                                                      .data ??
                                                                  [])[i]);
                                                        }
                                                      } else {
                                                        if (Journey
                                                            .skuResponseLists
                                                            .isNotEmpty) {
                                                          Journey
                                                              .skuResponseLists
                                                              .remove((skuResponse
                                                                      .data ??
                                                                  [])[i]);
                                                        }
                                                      }
                                                    }

                                                    skuRequestBody.quoteinfo =
                                                        quoteInfoList;

                                                    Journey.skuRequestBody =
                                                        skuRequestBody;
                                                    Journey.totalQuantity =
                                                        quantity;
                                                    Journey.totalPrice = price;

                                                    _secureStorageProvider
                                                        .saveQuoteToDisk(Journey
                                                            .skuResponseLists);
                                                    _secureStorageProvider
                                                        .saveCartDetails(
                                                            skuResponseLists);
                                                    _secureStorageProvider
                                                        .saveCategory(
                                                            widget.category);
                                                    _secureStorageProvider
                                                        .saveBrand(
                                                            widget.brand);
                                                    _secureStorageProvider
                                                        .saveRange(
                                                            widget.range);
                                                    _secureStorageProvider
                                                        .saveTotalPrice(
                                                            price.toString());

                                                    logger(
                                                        'Quantity: $quantity');
                                                    setState(
                                                      () {
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
                                                      },
                                                    );

                                                    quantity = 0;
                                                    price = 0;

                                                    for (int i = 0;
                                                        i < controllers.length;
                                                        i++) {
                                                      if (controllers[i]
                                                          .text
                                                          .isNotEmpty) {
                                                        quantity = quantity +
                                                            int.parse(
                                                                controllers[i]
                                                                    .text);

                                                        price = price +
                                                            (int.parse(
                                                                    controllers[
                                                                            i]
                                                                        .text) *
                                                                int.parse(
                                                                    skuResponse
                                                                        .data![
                                                                            i]
                                                                        .sKUMRP!));
                                                        totPrice = price;
                                                      }
                                                    }
                                                  }
                                                },
                                                onChanged: (value) {
                                                  int quantity = 0;
                                                  FocusScope.of(context)
                                                      .requestFocus();

                                                  price = 0;
                                                  skuResponseLists = [];
                                                  complementaryList = [];
                                                  for (int i = 0;
                                                      i < controllers.length;
                                                      i++) {
                                                    if (controllers[i]
                                                            .text
                                                            .isNotEmpty &&
                                                        controllers[i].text !=
                                                            '0') {
                                                      singleQuantity =
                                                          int.parse(
                                                              controllers[i]
                                                                  .text);
                                                      price = price +
                                                          (int.parse(
                                                                  controllers[i]
                                                                      .text) *
                                                              int.parse(
                                                                  skuResponse
                                                                      .data![i]
                                                                      .sKUMRP!));
                                                      singlePrice = int.parse(
                                                              controllers[i]
                                                                  .text) *
                                                          int.parse(skuResponse
                                                              .data![i]
                                                              .sKUMRP!);
                                                      skuResponseList.add(
                                                          skuResponse.data![i]);
                                                      Journey.skuDataList =
                                                          skuResponseList;
                                                      Quoteinfo quoteinfo =
                                                          Quoteinfo();
                                                      quoteinfo.totalqty =
                                                          '$singleQuantity';
                                                      quoteinfo.totalprice =
                                                          '$singlePrice';
                                                      quoteInfoList
                                                          .add(quoteinfo);
                                                      if ((skuResponse.data?[i]
                                                                  .complementary ??
                                                              [])
                                                          .isNotEmpty) {
                                                        for (int j = 0;
                                                            j <
                                                                (skuResponse.data?[i]
                                                                            .complementary ??
                                                                        [])
                                                                    .length;
                                                            j++) {
                                                          COMPLEMENTARY
                                                              complementary =
                                                              COMPLEMENTARY();
                                                          complementary
                                                              .cMPSRP = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPSRP ??
                                                              '';
                                                          complementary
                                                              .cMPUSP = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPUSP ??
                                                              '';
                                                          complementary
                                                              .cMPMR = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPMR ??
                                                              '';
                                                          complementary
                                                              .cMPDESCRIPTION = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPDESCRIPTION ??
                                                              '';
                                                          complementary
                                                              .cMPDRAWING = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPDRAWING ??
                                                              '';
                                                          complementary
                                                              .cMPRANGE = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPRANGE ??
                                                              '';
                                                          complementary
                                                              .cMPPRODUCTCAT = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPPRODUCTCAT ??
                                                              '';
                                                          complementary
                                                              .cMPSKUCODE = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPSKUCODE ??
                                                              '';
                                                          complementary
                                                              .cMPBRAND = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPBRAND ??
                                                              '';
                                                          complementary
                                                              .cMPSKUTYPE = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPSKUTYPE ??
                                                              '';
                                                          complementary
                                                              .cMPIMAGE = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPIMAGE ??
                                                              '';
                                                          complementary
                                                              .cMPCATCODE = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPCATCODE ??
                                                              '';
                                                          complementary
                                                              .cMPCATEGORY = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPCATEGORY ??
                                                              '';
                                                          complementaryList.add(
                                                              complementary);
                                                        }
                                                      }

                                                      skuResponse.data?[i]
                                                              .quantity =
                                                          controllers[i].text;

                                                      skuResponse.data?[i]
                                                              .totalPrice =
                                                          int.parse(
                                                                  controllers[i]
                                                                      .text) *
                                                              int.parse(
                                                                  skuResponse
                                                                      .data![i]
                                                                      .sKUMRP!);
                                                      skuResponse.data?[i]
                                                              .totalPriceAfterDiscount =
                                                          singlePrice;

                                                      skuResponse.data?[i]
                                                          .discount = 0;

                                                      if (!skuResponseLists
                                                          .contains(skuResponse
                                                              .data?[i])) {
                                                        logger(
                                                            "In if condition:::");
                                                        skuResponseLists.add(
                                                            (skuResponse.data ??
                                                                [])[i]);
                                                      }

                                                      if (!Journey
                                                          .skuResponseLists
                                                          .contains(skuResponse
                                                              .data?[i])) {
                                                        logger(
                                                            "In if condition:::");

                                                        Journey.skuResponseLists
                                                            .add((skuResponse
                                                                    .data ??
                                                                [])[i]);
                                                      }
                                                    } else {
                                                      if (Journey
                                                          .skuResponseLists
                                                          .isNotEmpty) {
                                                        Journey.skuResponseLists
                                                            .remove((skuResponse
                                                                    .data ??
                                                                [])[i]);
                                                      }
                                                    }
                                                  }

                                                  skuRequestBody.quoteinfo =
                                                      quoteInfoList;

                                                  Journey.skuRequestBody =
                                                      skuRequestBody;
                                                  Journey.totalQuantity =
                                                      quantity;
                                                  Journey.totalPrice = price;

                                                  _secureStorageProvider
                                                      .saveQuoteToDisk(Journey
                                                          .skuResponseLists);
                                                  _secureStorageProvider
                                                      .saveCartDetails(
                                                          skuResponseLists);
                                                  _secureStorageProvider
                                                      .saveCategory(
                                                          widget.category);
                                                  _secureStorageProvider
                                                      .saveBrand(widget.brand);
                                                  _secureStorageProvider
                                                      .saveRange(widget.range);
                                                  _secureStorageProvider
                                                      .saveTotalPrice(
                                                          price.toString());

                                                  logger('Quantity: $quantity');
                                                  setState(
                                                    () {
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
                                                    },
                                                  );

                                                  quantity = 0;
                                                  price = 0;

                                                  for (int i = 0;
                                                      i < controllers.length;
                                                      i++) {
                                                    if (controllers[i]
                                                        .text
                                                        .isNotEmpty) {
                                                      quantity = quantity +
                                                          int.parse(
                                                              controllers[i]
                                                                  .text);

                                                      price = price +
                                                          (int.parse(
                                                                  controllers[i]
                                                                      .text) *
                                                              int.parse(
                                                                  skuResponse
                                                                      .data![i]
                                                                      .sKUMRP!));
                                                      totPrice = price;
                                                    }
                                                  }
                                                },
                                                onSubmitted: (value) {
                                                  int quantity = 0;
                                                  price = 0;
                                                  List<SKUData> skuList = [];
                                                  for (int i = 0;
                                                      i < controllers.length;
                                                      i++) {
                                                    if (controllers[i]
                                                        .text
                                                        .isNotEmpty) {
                                                      price = price +
                                                          (int.parse(
                                                                  controllers[i]
                                                                      .text) *
                                                              int.parse(
                                                                  skuResponse
                                                                      .data![i]
                                                                      .sKUMRP!));
                                                    }
                                                  }
                                                  logger(
                                                      "Response Length: ${skuResponseLists.length}");
                                                  skuRequestBody.quoteinfo =
                                                      quoteInfoList;

                                                  Journey.skuRequestBody =
                                                      skuRequestBody;
                                                  Journey.totalQuantity =
                                                      quantity;
                                                  Journey.totalPrice = price;

                                                  logger('Quantity: $quantity');

                                                  int val = int.parse(value) *
                                                      int.parse(skuResponse
                                                          .data![index]
                                                          .sKUMRP!);

                                                  // _secureStorageProvider
                                                  //     .saveQuoteToDisk(
                                                  //         skuResponseLists);
                                                  if (complementaryList
                                                      .isNotEmpty) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return showCompSkuDialog(
                                                            complementaryList);
                                                      },
                                                    );
                                                  }

                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      FlutterToastProvider().show(
                                                          message:
                                                              "Successfully added SKU's to Quote!!");
                                                      // Navigator.pop(context);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ViewQuote(
                                                            catIndex: 0,
                                                            brandIndex: 0,
                                                            rangeIndex: 0,
                                                            category:
                                                                widget.category,
                                                            brand: widget.brand,
                                                            range: widget.range,
                                                            quantity: '',
                                                            skuResponseList: Journey
                                                                .skuResponseLists,
                                                            fromFlip:
                                                                widget.fromFlip,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(35.0),
                                                      ),
                                                      backgroundColor:
                                                          AsianPaintColors
                                                              .buttonColor,
                                                      shadowColor:
                                                          AsianPaintColors
                                                              .buttonBorderColor,
                                                      textStyle: TextStyle(
                                                        color: AsianPaintColors
                                                            .buttonTextColor,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishRegular,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'View Quote',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishBold,
                                                        color: AsianPaintColors
                                                            .whiteColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              SkuListBloc skuListBloc = context.read<SkuListBloc>();
              if (state is SkuInitial) {
                const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is SkuLoading) {
                const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is SkuLoaded || state is SkuReLoaded) {
                List<SKUData> skuResponseList = [];
                List<Quoteinfo> quoteInfoList = [];
                SkuRequestBody skuRequestBody = SkuRequestBody();
                int singleQuantity = 0;
                int singlePrice = 0;

                controllers = [];

                areas.add('ALL');
                (widget.skuResponse ?? []).isNotEmpty
                    ? skuListBloc.skuResponse?.data = widget.skuResponse
                    : skuListBloc.skuResponse?.data;
                for (int i = 0;
                    i < (skuListBloc.skuResponse?.data ?? []).length;
                    i++) {
                  controllers.add(TextEditingController());
                  for (int j = 0;
                      j <
                          (skuListBloc.skuResponse?.data?[i].aREAINFO ?? [])
                              .length;
                      j++) {
                    areas.add(skuListBloc.skuResponse?.data?[i].aREAINFO?[j] ??
                        'SHOWER_AREA');
                  }
                }

                logger(
                    'Widget SKU Response Length: ${widget.skuResponse?.length}');
                logger('Sku Areas: ${areas}');
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(48, 30, 0, 0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                AppLocalizations.of(context).sku,
                                style: TextStyle(
                                  color: AsianPaintColors.projectUserNameColor,
                                  fontFamily: AsianPaintsFonts.bathSansRegular,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(45, 5, 0, 0),
                            height: 40,
                            child: ChipsFilter(
                              selected: Journey
                                  .selectedIndex, // Select the second filter as default
                              filters: [
                                for (var i in areas)
                                  Filter(
                                    category: widget.category,
                                    brand: widget.brand,
                                    range: widget.range,
                                    limit: 1,
                                    bloc: bloc,
                                    label: i,
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                width: 140,
                                height: 30,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    int quantity = 0;
                                    price = 0;
                                    List<SKUData> skuList = [];
                                    for (int i = 0;
                                        i < controllers.length;
                                        i++) {
                                      if (controllers[i].text.isNotEmpty) {
                                        quantity = quantity +
                                            int.parse(controllers[i].text);
                                        singleQuantity =
                                            int.parse(controllers[i].text);
                                        price = price +
                                            (int.parse(controllers[i].text) *
                                                int.parse(skuListBloc
                                                        .skuResponse!
                                                        .data![i]
                                                        .sKUMRP ??
                                                    '0'));
                                        logger("In if condition::: $price");
                                        singlePrice =
                                            int.parse(controllers[i].text) *
                                                int.parse(skuListBloc
                                                    .skuResponse!
                                                    .data![i]
                                                    .sKUMRP!);
                                        skuResponseList.add(
                                            skuListBloc.skuResponse!.data![i]);
                                        Journey.skuDataList = skuResponseList;
                                        Quoteinfo quoteinfo = Quoteinfo();
                                        quoteinfo.totalqty = '$singleQuantity';
                                        quoteinfo.totalprice = '$singlePrice';
                                        quoteInfoList.add(quoteinfo);

                                        skuListBloc.skuResponse!.data?[i]
                                            .quantity = controllers[i].text;
                                        skuListBloc.skuResponse!.data?[i]
                                                .totalPrice =
                                            int.parse(controllers[i].text) *
                                                int.parse(skuListBloc
                                                    .skuResponse!
                                                    .data![i]
                                                    .sKUMRP!);
                                        skuListBloc.skuResponse!.data?[i]
                                                .totalPriceAfterDiscount =
                                            singlePrice;
                                        // skuListBloc.skuResponse!.data?[i]
                                        //     .totalAmount = price;
                                        skuListBloc
                                            .skuResponse!.data?[i].discount = 0;

                                        if (!Journey.skuResponseLists.contains(
                                            skuListBloc
                                                .skuResponse!.data?[i])) {
                                          Journey.skuResponseLists.add(
                                              (skuListBloc.skuResponse?.data ??
                                                  [])[i]);
                                        }
                                      }
                                    }
                                    logger(
                                        "Response Length: ${skuResponseLists.length}");
                                    skuRequestBody.quoteinfo = quoteInfoList;

                                    Journey.skuRequestBody = skuRequestBody;
                                    Journey.totalQuantity = quantity;
                                    Journey.totalPrice = price;

                                    _secureStorageProvider
                                        .saveTotalPrice(price.toString());
                                    _secureStorageProvider.saveQuoteToDisk(
                                        Journey.skuResponseLists);
                                    _secureStorageProvider
                                        .saveCartDetails(skuResponseLists);
                                    _secureStorageProvider
                                        .saveCategory(widget.category);
                                    _secureStorageProvider
                                        .saveBrand(widget.brand);
                                    _secureStorageProvider
                                        .saveRange(widget.range);

                                    if (Journey.skuResponseLists.isNotEmpty) {
                                      FlutterToastProvider().show(
                                          message:
                                              "Successfully added SKU's to Quote!!");
                                      // Navigator.pop(context);
                                      Future.delayed(
                                          const Duration(seconds: 0));
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewQuote(
                                            catIndex: widget.catIndex,
                                            brandIndex: widget.brandIndex,
                                            rangeIndex: widget.rangeIndex,
                                            category: widget.category,
                                            brand: widget.brand,
                                            range: widget.range,
                                            quantity: '',
                                            skuResponseList:
                                                Journey.skuResponseLists,
                                            fromFlip: widget.fromFlip,
                                          ),
                                        ),
                                      );
                                    } else {
                                      FlutterToastProvider()
                                          .show(message: "Please add SKU!");
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35.0),
                                    ),
                                    backgroundColor:
                                        AsianPaintColors.buttonColor,
                                    shadowColor:
                                        AsianPaintColors.buttonBorderColor,
                                    textStyle: TextStyle(
                                      color: AsianPaintColors.buttonTextColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily:
                                          AsianPaintsFonts.mulishRegular,
                                    ),
                                  ),
                                  child: Text(
                                    'View Quote',
                                    style: TextStyle(
                                      fontFamily: AsianPaintsFonts.mulishBold,
                                      color: AsianPaintColors.whiteColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(37, 5, 0, 0),
                          child: GridView.builder(
                              // shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                childAspectRatio: 3 / 3,
                                // mainAxisSpacing: 14,
                                // crossAxisSpacing: 14,
                              ),
                              itemCount:
                                  skuListBloc.skuResponse!.data?.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                // controllers.add(TextEditingController());
                                if (skuListBloc.skuResponse!.data!.isEmpty) {
                                  return const Center(
                                    child: Text('No data available'),
                                  );
                                } else {
                                  return singleItemListWeb(
                                      skuListBloc.skuResponse!,
                                      index,
                                      controllers[index],
                                      controllers);
                                }
                              }),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is SkuFailure) {
                return SkuListBloc().loadingStatus == true
                    ? SizedBox(
                        height: displayHeight(context) * 0.65,
                        width: displayWidth(context),
                        child: const Center(child: CircularProgressIndicator()))
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
            listener: (context, state) {},
          ),
        ),
      ),
      mobile: Scaffold(
        appBar: AppBarTemplate(
          header: AppLocalizations.of(context).sku,
          isVisible: true,
          cartBadgeAmount: cartCount,
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => SkuListBloc()
                ..getSkuList(
                  category: widget.category,
                  brand: widget.brand,
                  range: widget.range,
                  area: '',
                  limit: 1,
                ),
            ),
          ],
          child: BlocConsumer<SkuListBloc, SkuState>(
            builder: (context, state) {
              Widget compItemList(
                  List<COMPLEMENTARY> compData,
                  int index,
                  TextEditingController compController,
                  List<TextEditingController> compControllers) {
                int singleQuantity = 0;
                int singlePrice = 0;
                return Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: AsianPaintColors.appBackgroundColor,
                    ),
                  ),
                  child: ListTile(
                    leading: Image.network((compData[index].cMPIMAGE ?? '')
                            .isEmpty
                        ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
                        : compData[index].cMPIMAGE ?? ''),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              complementaryList[index].cMPCATCODE ?? '',
                              style: TextStyle(
                                color: AsianPaintColors.chooseYourAccountColor,
                                fontFamily: AsianPaintsFonts.mulishBold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 220,
                              child: Text(
                                compData[index].cMPDESCRIPTION ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AsianPaintColors.skuDescriptionColor,
                                  fontFamily: AsianPaintsFonts.mulishRegular,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\u{20B9} ${compData[index].cMPMR}',
                              style: TextStyle(
                                color: AsianPaintColors.forgotPasswordTextColor,
                                fontFamily: AsianPaintsFonts.mulishSemiBold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(
                              width: 55,
                              height: 25,
                              child: TextFormField(
                                  //enableInteractiveSelection: false,
                                  enableInteractiveSelection: false,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: true, decimal: true),
                                  controller: compController,
                                  // autofocus: true,
                                  // focusNode: FocusNode.,
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
                                  textAlignVertical: TextAlignVertical.center,
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]'),
                                    ),
                                    FilteringTextInputFormatter.deny(
                                      RegExp(
                                          r'^0+'), //users can't type 0 at 1st position
                                    ),
                                    // FilteringTextInputFormatter
                                    //     .allow(RegExp("[0-9]"))
                                  ],
                                  decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AsianPaintColors.kPrimaryColor,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AsianPaintColors.kPrimaryColor,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AsianPaintColors.kPrimaryColor,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      filled: true,
                                      hintStyle:
                                          TextStyle(color: Colors.grey[800]),
                                      labelText: "+Add",
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      fillColor: Colors.white70),
                                  // onTap: () {
                                  //   if (compController.text.isEmpty) {
                                  //     compController.text = '1';
                                  //   }
                                  // },
                                  // onChanged: (value) {
                                  //   int quantity = 0;

                                  //   int price = 0;

                                  //   logger(
                                  //       'Complementary Length: ${compData.length}');

                                  //   for (int i = 0; i < compData.length; i++) {
                                  //     logger(
                                  //         "In if condition i::: ${compControllers[i].text}");
                                  //     logger(
                                  //         "In if condition index::: ${compControllers[index].text}");

                                  //     if ((compControllers[i].text)
                                  //         .isNotEmpty) {
                                  //       singleQuantity =
                                  //           int.parse(compControllers[i].text);
                                  //       price = price +
                                  //           (int.parse(
                                  //                   compControllers[i].text) *
                                  //               int.parse(compData[i].cMPMR!));
                                  //       singlePrice =
                                  //           int.parse(compControllers[i].text) *
                                  //               int.parse(compData[i].cMPMR!);

                                  //       SKUData skuData = SKUData();
                                  //       skuData.sKURANGE =
                                  //           compData[i].cMPRANGE ?? '';
                                  //       skuData.sKUIMAGE =
                                  //           compData[i].cMPIMAGE ?? '';
                                  //       skuData.sKUCATEGORY =
                                  //           compData[i].cMPCATEGORY ?? '';
                                  //       skuData.sKUUSP =
                                  //           compData[i].cMPUSP ?? '';
                                  //       skuData.sKUPRODUCTCAT =
                                  //           compData[i].cMPPRODUCTCAT ?? '';
                                  //       skuData.sKUDESCRIPTION =
                                  //           compData[i].cMPDESCRIPTION ?? '';
                                  //       skuData.complementary = [];
                                  //       skuData.sKUMRP =
                                  //           compData[i].cMPMR ?? '';
                                  //       skuData.sKUCODE =
                                  //           compData[i].cMPSKUCODE ?? '';
                                  //       skuData.sKUSRP =
                                  //           compData[i].cMPSRP ?? '';
                                  //       skuData.sKUDRAWING =
                                  //           compData[i].cMPDRAWING ?? '';
                                  //       skuData.sKUBRAND =
                                  //           compData[i].cMPBRAND ?? '';
                                  //       skuData.aREAINFO = [];
                                  //       skuData.skuCatCode =
                                  //           compData[i].cMPCATCODE ?? '';
                                  //       skuData.sKUTYPE =
                                  //           compData[i].cMPSKUTYPE ?? '';
                                  //       skuData.discount = 0;
                                  //       skuData.quantity =
                                  //           compControllers[i].text;
                                  //       skuData.totalPrice =
                                  //           int.parse(compControllers[i].text) *
                                  //               int.parse(compData[i].cMPMR!);
                                  //       skuData.totalPriceAfterDiscount =
                                  //           singlePrice;
                                  //       skuData.index = 0;

                                  //       skuData.areaInfo = [];
                                  //       skuData.skuTypeExpanded = '';
                                  //       skuData.productCardDescriptior = '';
                                  //       price +=
                                  //           skuData.totalPriceAfterDiscount ??
                                  //               0;

                                  //       if (!Journey.skuResponseLists
                                  //           .contains(skuData)) {
                                  //         logger("In if condition:::");
                                  //         Journey.skuResponseLists.add(skuData);
                                  //       }
                                  //     }
                                  //   }

                                  //   // skuRequestBody.quoteinfo = quoteInfoList;

                                  //   // Journey.skuRequestBody = skuRequestBody;
                                  //   Journey.totalQuantity = quantity;
                                  //   Journey.totalPrice = price;

                                  //   _secureStorageProvider.saveQuoteToDisk(
                                  //       Journey.skuResponseLists);
                                  //   _secureStorageProvider
                                  //       .saveCartDetails(skuResponseLists);
                                  //   _secureStorageProvider
                                  //       .saveCategory(widget.category);
                                  //   _secureStorageProvider
                                  //       .saveBrand(widget.brand);
                                  //   _secureStorageProvider
                                  //       .saveRange(widget.range);
                                  //   _secureStorageProvider
                                  //       .saveTotalPrice(price.toString());

                                  //   logger('Quantity: $quantity');
                                  //   setState(
                                  //     () {
                                  //       cartCount =
                                  //           Journey.skuResponseLists.length;
                                  //       _secureStorageProvider
                                  //           .saveCartCount(cartCount);
                                  //       logger('Cart count: $cartCount');
                                  //       logger('Quantity: $quantity');
                                  //     },
                                  //   );

                                  //   // quantity = 0;
                                  //   // price = 0;

                                  //   // for (int i = 0;
                                  //   //     i < Journey.skuResponseLists.length;
                                  //   //     i++) {
                                  //   //   // if (compControllers[i].text.isNotEmpty) {

                                  //   //   setState(() {
                                  //   //     quantity = quantity +
                                  //   //         int.parse(Journey
                                  //   //                 .skuResponseLists[i]
                                  //   //                 .quantity ??
                                  //   //             '0');

                                  //   //     price = price +
                                  //   //         (int.parse(Journey
                                  //   //                     .skuResponseLists[i]
                                  //   //                     .quantity ??
                                  //   //                 '0') *
                                  //   //             int.parse(Journey
                                  //   //                     .skuResponseLists[i]
                                  //   //                     .sKUMRP ??
                                  //   //                 '0'));
                                  //   //     totPrice = price;
                                  //   //   });

                                  //   //   // }
                                  //   // }
                                  // },
                                  onTap: () {
                                    if (compController.text.isEmpty) {
                                      compController.text = '1';
                                      // int quantity = 0;

                                      // int price = 0;
                                      // List<Area> areas = [];
                                      // List<String> area = [];

                                      // logger(
                                      //     'Complementary Length: ${compData.length}');

                                      // for (int i = 0;
                                      //     i < compData.length;
                                      //     i++) {
                                      //   logger(
                                      //       "In if condition i::: ${compControllers[i].text}");
                                      //   logger(
                                      //       "In if condition index::: ${compControllers[index].text}");

                                      //   if ((compControllers[i].text)
                                      //       .isNotEmpty) {
                                      //     singleQuantity = int.parse(
                                      //         compControllers[i].text);
                                      //     price = price +
                                      //         (int.parse(
                                      //                 compControllers[i].text) *
                                      //             int.parse(
                                      //                 compData[i].cMPMR!));
                                      //     singlePrice = int.parse(
                                      //             compControllers[i].text) *
                                      //         int.parse(compData[i].cMPMR!);

                                      //     SKUData skuData = SKUData();
                                      //     skuData.sKURANGE =
                                      //         compData[i].cMPRANGE ?? '';
                                      //     skuData.sKUIMAGE =
                                      //         compData[i].cMPIMAGE ?? '';
                                      //     skuData.sKUCATEGORY =
                                      //         compData[i].cMPCATEGORY ?? '';
                                      //     skuData.sKUUSP =
                                      //         compData[i].cMPUSP ?? '';
                                      //     skuData.sKUPRODUCTCAT =
                                      //         compData[i].cMPPRODUCTCAT ?? '';
                                      //     skuData.sKUDESCRIPTION =
                                      //         compData[i].cMPDESCRIPTION ?? '';
                                      //     skuData.complementary = [];
                                      //     skuData.sKUMRP =
                                      //         compData[i].cMPMR ?? '';
                                      //     skuData.sKUCODE =
                                      //         compData[i].cMPSKUCODE ?? '';
                                      //     skuData.sKUSRP =
                                      //         compData[i].cMPSRP ?? '';
                                      //     skuData.sKUDRAWING =
                                      //         compData[i].cMPDRAWING ?? '';
                                      //     skuData.sKUBRAND =
                                      //         compData[i].cMPBRAND ?? '';
                                      //     area = [];
                                      //     area.add('SHOWER_AREA');
                                      //     skuData.aREAINFO = area;
                                      //     logger(
                                      //         'Comp Area: ${json.encode(skuData.aREAINFO)}');
                                      //     skuData.skuCatCode =
                                      //         compData[i].cMPCATCODE ?? '';
                                      //     skuData.sKUTYPE =
                                      //         compData[i].cMPSKUTYPE ?? '';
                                      //     skuData.discount = 0;
                                      //     skuData.quantity =
                                      //         compControllers[i].text;
                                      //     skuData.totalPrice = int.parse(
                                      //             compControllers[i].text) *
                                      //         int.parse(compData[i].cMPMR!);
                                      //     skuData.totalPriceAfterDiscount =
                                      //         singlePrice;
                                      //     skuData.index = 0;
                                      //     areas = [];
                                      //     areas.add(Area(
                                      //         areaname: 'SHOWER_AREA',
                                      //         areaqty: '1'));

                                      //     skuData.areaInfo = areas;
                                      //     logger(
                                      //         'Comp Area Info: ${json.encode(skuData.areaInfo)}');
                                      //     skuData.skuTypeExpanded = '';
                                      //     skuData.productCardDescriptior = '';
                                      //     price +=
                                      //         skuData.totalPriceAfterDiscount ??
                                      //             0;

                                      //     if (!Journey.skuResponseLists
                                      //         .contains(skuData)) {
                                      //       logger("In if condition:::");
                                      //       Journey.skuResponseLists
                                      //           .add(skuData);
                                      //     }
                                      //   }
                                      // }

                                      // // skuRequestBody.quoteinfo = quoteInfoList;

                                      // // Journey.skuRequestBody = skuRequestBody;
                                      // Journey.totalQuantity = quantity;
                                      // Journey.totalPrice = price;

                                      // _secureStorageProvider.saveQuoteToDisk(
                                      //     Journey.skuResponseLists);
                                      // _secureStorageProvider
                                      //     .saveCartDetails(skuResponseLists);
                                      // _secureStorageProvider
                                      //     .saveCategory(widget.category);
                                      // _secureStorageProvider
                                      //     .saveBrand(widget.brand);
                                      // _secureStorageProvider
                                      //     .saveRange(widget.range);
                                      // _secureStorageProvider
                                      //     .saveTotalPrice(price.toString());

                                      // logger('Quantity: $quantity');
                                      // setState(
                                      //   () {
                                      //     cartCount =
                                      //         Journey.skuResponseLists.length;
                                      //     _secureStorageProvider
                                      //         .saveCartCount(cartCount);
                                      //     logger('Cart count: $cartCount');
                                      //     logger('Quantity: $quantity');
                                      //   },
                                      // );

                                      // quantity = 0;
                                      // price = 0;

                                      // for (int i = 0;
                                      //     i < Journey.skuResponseLists.length;
                                      //     i++) {
                                      //   // if (compControllers[i].text.isNotEmpty) {
                                      //   quantity = quantity +
                                      //       int.parse(Journey
                                      //               .skuResponseLists[i]
                                      //               .quantity ??
                                      //           '0');

                                      //   price = price +
                                      //       (int.parse(Journey
                                      //                   .skuResponseLists[i]
                                      //                   .quantity ??
                                      //               '0') *
                                      //           int.parse(Journey
                                      //                   .skuResponseLists[i]
                                      //                   .sKUMRP ??
                                      //               '0'));
                                      //   totPrice = price;
                                      //   // }
                                      // }
                                    }
                                  },
                                  onFieldSubmitted: (value) {
                                    int quantity = 0;

                                    int price = 0;
                                    List<Area> areas = [];
                                    List<String> area = [];

                                    logger(
                                        'Complementary Length: ${compData.length}');

                                    for (int i = 0; i < compData.length; i++) {
                                      logger(
                                          "In if condition i::: ${compControllers[i].text}");
                                      logger(
                                          "In if condition index::: ${compControllers[index].text}");

                                      if ((compControllers[i].text)
                                          .isNotEmpty) {
                                        singleQuantity =
                                            int.parse(compControllers[i].text);
                                        price = price +
                                            (int.parse(
                                                    compControllers[i].text) *
                                                int.parse(compData[i].cMPMR!));
                                        singlePrice =
                                            int.parse(compControllers[i].text) *
                                                int.parse(compData[i].cMPMR!);

                                        SKUData skuData = SKUData();
                                        skuData.sKURANGE =
                                            compData[i].cMPRANGE ?? '';
                                        skuData.sKUIMAGE =
                                            compData[i].cMPIMAGE ?? '';
                                        skuData.sKUCATEGORY =
                                            compData[i].cMPCATEGORY ?? '';
                                        skuData.sKUUSP =
                                            compData[i].cMPUSP ?? '';
                                        skuData.sKUPRODUCTCAT =
                                            compData[i].cMPPRODUCTCAT ?? '';
                                        skuData.sKUDESCRIPTION =
                                            compData[i].cMPDESCRIPTION ?? '';
                                        skuData.complementary = [];
                                        skuData.sKUMRP =
                                            compData[i].cMPMR ?? '';
                                        skuData.sKUCODE =
                                            compData[i].cMPSKUCODE ?? '';
                                        skuData.sKUSRP =
                                            compData[i].cMPSRP ?? '';
                                        skuData.sKUDRAWING =
                                            compData[i].cMPDRAWING ?? '';
                                        skuData.sKUBRAND =
                                            compData[i].cMPBRAND ?? '';
                                        area = [];
                                        area.add('SHOWER_AREA');
                                        skuData.aREAINFO = area;
                                        logger(
                                            'Comp Area: ${json.encode(skuData.aREAINFO)}');
                                        skuData.skuCatCode =
                                            compData[i].cMPCATCODE ?? '';
                                        skuData.sKUTYPE =
                                            compData[i].cMPSKUTYPE ?? '';
                                        skuData.discount = 0;
                                        skuData.quantity =
                                            compControllers[i].text;
                                        skuData.totalPrice =
                                            int.parse(compControllers[i].text) *
                                                int.parse(compData[i].cMPMR!);
                                        skuData.totalPriceAfterDiscount =
                                            singlePrice;
                                        skuData.index = 0;
                                        areas = [];
                                        areas.add(Area(
                                            areaname: 'SHOWER_AREA',
                                            areaqty: '1'));

                                        skuData.areaInfo = areas;
                                        logger(
                                            'Comp Area Info: ${json.encode(skuData.areaInfo)}');
                                        skuData.skuTypeExpanded = '';
                                        skuData.productCardDescriptior = '';
                                        price +=
                                            skuData.totalPriceAfterDiscount ??
                                                0;

                                        if (!Journey.skuResponseLists
                                            .contains(skuData)) {
                                          logger("In if condition:::");
                                          Journey.skuResponseLists.add(skuData);
                                        }
                                      }
                                    }

                                    // skuRequestBody.quoteinfo = quoteInfoList;

                                    // Journey.skuRequestBody = skuRequestBody;
                                    Journey.totalQuantity = quantity;
                                    Journey.totalPrice = price;

                                    _secureStorageProvider.saveQuoteToDisk(
                                        Journey.skuResponseLists);
                                    _secureStorageProvider
                                        .saveCartDetails(skuResponseLists);
                                    _secureStorageProvider
                                        .saveCategory(widget.category);
                                    _secureStorageProvider
                                        .saveBrand(widget.brand);
                                    _secureStorageProvider
                                        .saveRange(widget.range);
                                    _secureStorageProvider
                                        .saveTotalPrice(price.toString());

                                    logger('Quantity: $quantity');
                                    setState(
                                      () {
                                        cartCount =
                                            Journey.skuResponseLists.length;
                                        _secureStorageProvider
                                            .saveCartCount(cartCount);
                                        logger('Cart count: $cartCount');
                                        logger('Quantity: $quantity');
                                      },
                                    );

                                    quantity = 0;
                                    price = 0;

                                    for (int i = 0;
                                        i < Journey.skuResponseLists.length;
                                        i++) {
                                      // if (compControllers[i].text.isNotEmpty) {
                                      quantity = quantity +
                                          int.parse(Journey.skuResponseLists[i]
                                                  .quantity ??
                                              '0');

                                      price = price +
                                          (int.parse(Journey.skuResponseLists[i]
                                                      .quantity ??
                                                  '0') *
                                              int.parse(Journey
                                                      .skuResponseLists[i]
                                                      .sKUMRP ??
                                                  '0'));
                                      totPrice = price;
                                      // }
                                    }
                                  }),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              Widget singleItemList(
                  SKUResponse skuResponse,
                  int index,
                  TextEditingController controller,
                  List<TextEditingController> controllers) {
                List<SKUData> skuResponseList = [];
                List<Quoteinfo> quoteInfoList = [];
                SkuRequestBody skuRequestBody = SkuRequestBody();
                int singleQuantity = 0;
                int singlePrice = 0;

                if (Journey.skuResponseLists.isNotEmpty) {
                  for (SKUData skuData in Journey.skuResponseLists) {
                    if (skuData == skuResponse.data?[index]) {
                      controller.text = skuData.quantity ?? '';
                    }
                  }
                }

                return StatefulBuilder(
                  builder: (context, setState) {
                    return InkWell(
                      onTap: () async {
                        Journey.skuIndex = index;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SKUDescriptionPage(
                              quantity: controller.text,
                              key: Key(skuResponse.data!.length.toString()),
                              catIndex: widget.catIndex,
                              brandIndex: widget.brandIndex,
                              rangeIndex: widget.rangeIndex,
                              category: widget.category,
                              brand: widget.brand,
                              range: widget.range,
                              skuData: skuResponse.data![index],
                            ),
                          ),
                        ).then((value) => setState(() {
                              logger(value);
                              controller.text = value;

                              if (value.toString().isNotEmpty) {
                                FlutterToastProvider()
                                    .show(message: 'SKU added successfully!!');
                              }
                            }));

                        logger('Controller value: ${controller.text}');
                        logger('Result: ${Journey.att[0]}');
                        logger({skuResponse.data![index].sKUCODE!});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Image.network(
                                      (skuResponse.data![index].sKUIMAGE ?? '')
                                              .isEmpty
                                          ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
                                          : skuResponse.data![index].sKUIMAGE!,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.13,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 15, 0, 0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          skuResponse.data![index].skuCatCode!,
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
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 5, 0, 0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          skuResponse
                                              .data![index].sKUDESCRIPTION!,
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
                                          skuResponse.data![index]
                                              .productCardDescriptior!,
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
                                    const SizedBox(
                                      height: 0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 0, 5),
                                          child: Text(
                                            textAlign: TextAlign.start,
                                            '\u{20B9} ${skuResponse.data![index].sKUMRP!}',
                                            style: TextStyle(
                                                color: AsianPaintColors
                                                    .forgotPasswordTextColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: AsianPaintsFonts
                                                    .mulishBold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 5),
                                          child: SizedBox(
                                            width: 50,
                                            height: 25,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child:
                                                  // Text(controller.text),
                                                  TextFormField(
                                                enableInteractiveSelection:
                                                    false,
                                                keyboardType:
                                                    const TextInputType
                                                            .numberWithOptions(
                                                        signed: true,
                                                        decimal: true),
                                                controller: controller,
                                                // autofocus: true,
                                                // focusNode: FocusNode.,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                                textAlignVertical:
                                                    TextAlignVertical.center,
                                                textAlign: TextAlign.center,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(r'[0-9]'),
                                                  ),
                                                  FilteringTextInputFormatter
                                                      .deny(
                                                    RegExp(
                                                        r'^0+'), //users can't type 0 at 1st position
                                                  ),
                                                  // FilteringTextInputFormatter
                                                  //     .allow(RegExp("[0-9]"))
                                                ],

                                                decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets
                                                                .fromLTRB(10.0,
                                                            5.0, 10.0, 5.0),
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AsianPaintColors
                                                            .kPrimaryColor,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AsianPaintColors
                                                            .kPrimaryColor,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AsianPaintColors
                                                            .kPrimaryColor,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    filled: true,
                                                    hintStyle: TextStyle(
                                                        color:
                                                            Colors.grey[800]),
                                                    labelText: "+Add",
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .never,
                                                    fillColor: Colors.white70),
                                                onTap: () {
                                                  if (controller.text.isEmpty) {
                                                    controller.text = '1';
                                                    int quantity = 0;
                                                    FocusScope.of(context)
                                                        .requestFocus();

                                                    price = 0;
                                                    skuResponseLists = [];
                                                    complementaryList = [];
                                                    for (int i = 0;
                                                        i < controllers.length;
                                                        i++) {
                                                      if (controllers[i]
                                                              .text
                                                              .isNotEmpty &&
                                                          controllers[i].text !=
                                                              '0') {
                                                        singleQuantity =
                                                            int.parse(
                                                                controllers[i]
                                                                    .text);
                                                        price = price +
                                                            (int.parse(
                                                                    controllers[
                                                                            i]
                                                                        .text) *
                                                                int.parse(
                                                                    skuResponse
                                                                        .data![
                                                                            i]
                                                                        .sKUMRP!));
                                                        singlePrice = int.parse(
                                                                controllers[i]
                                                                    .text) *
                                                            int.parse(
                                                                skuResponse
                                                                    .data![i]
                                                                    .sKUMRP!);
                                                        skuResponseList.add(
                                                            skuResponse
                                                                .data![i]);
                                                        Journey.skuDataList =
                                                            skuResponseList;
                                                        Quoteinfo quoteinfo =
                                                            Quoteinfo();
                                                        quoteinfo.totalqty =
                                                            '$singleQuantity';
                                                        quoteinfo.totalprice =
                                                            '$singlePrice';
                                                        quoteInfoList
                                                            .add(quoteinfo);
                                                        if ((skuResponse
                                                                    .data?[i]
                                                                    .complementary ??
                                                                [])
                                                            .isNotEmpty) {
                                                          for (int j = 0;
                                                              j <
                                                                  (skuResponse.data?[i]
                                                                              .complementary ??
                                                                          [])
                                                                      .length;
                                                              j++) {
                                                            COMPLEMENTARY
                                                                complementary =
                                                                COMPLEMENTARY();
                                                            complementary
                                                                .cMPSRP = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPSRP ??
                                                                '';
                                                            complementary
                                                                .cMPUSP = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPUSP ??
                                                                '';
                                                            complementary
                                                                .cMPMR = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPMR ??
                                                                '';
                                                            complementary
                                                                .cMPDESCRIPTION = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPDESCRIPTION ??
                                                                '';
                                                            complementary
                                                                .cMPDRAWING = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPDRAWING ??
                                                                '';
                                                            complementary
                                                                .cMPRANGE = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPRANGE ??
                                                                '';
                                                            complementary
                                                                .cMPPRODUCTCAT = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPPRODUCTCAT ??
                                                                '';
                                                            complementary
                                                                .cMPSKUCODE = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPSKUCODE ??
                                                                '';
                                                            complementary
                                                                .cMPBRAND = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPBRAND ??
                                                                '';
                                                            complementary
                                                                .cMPSKUTYPE = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPSKUTYPE ??
                                                                '';
                                                            complementary
                                                                .cMPIMAGE = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPIMAGE ??
                                                                '';
                                                            complementary
                                                                .cMPCATCODE = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPCATCODE ??
                                                                '';
                                                            complementary
                                                                .cMPCATEGORY = skuResponse
                                                                    .data?[i]
                                                                    .complementary?[
                                                                        j]
                                                                    .cMPCATEGORY ??
                                                                '';
                                                            complementaryList.add(
                                                                complementary);
                                                          }
                                                        }

                                                        skuResponse.data?[i]
                                                                .quantity =
                                                            controllers[i].text;

                                                        skuResponse.data?[i]
                                                            .totalPrice = int
                                                                .parse(
                                                                    controllers[
                                                                            i]
                                                                        .text) *
                                                            int.parse(
                                                                skuResponse
                                                                    .data![i]
                                                                    .sKUMRP!);
                                                        skuResponse.data?[i]
                                                                .totalPriceAfterDiscount =
                                                            singlePrice;

                                                        skuResponse.data?[i]
                                                            .discount = 0;

                                                        if (!skuResponseLists
                                                            .contains(
                                                                skuResponse
                                                                        .data?[
                                                                    i])) {
                                                          logger(
                                                              "In if condition:::");
                                                          skuResponseLists.add(
                                                              (skuResponse
                                                                      .data ??
                                                                  [])[i]);
                                                        }

                                                        if (!Journey
                                                            .skuResponseLists
                                                            .contains(
                                                                skuResponse
                                                                        .data?[
                                                                    i])) {
                                                          logger(
                                                              "In if condition:::");

                                                          Journey
                                                              .skuResponseLists
                                                              .add((skuResponse
                                                                      .data ??
                                                                  [])[i]);
                                                        }
                                                      } else {
                                                        if (Journey
                                                            .skuResponseLists
                                                            .isNotEmpty) {
                                                          Journey
                                                              .skuResponseLists
                                                              .remove((skuResponse
                                                                      .data ??
                                                                  [])[i]);
                                                        }
                                                      }
                                                    }

                                                    skuRequestBody.quoteinfo =
                                                        quoteInfoList;

                                                    Journey.skuRequestBody =
                                                        skuRequestBody;
                                                    Journey.totalQuantity =
                                                        quantity;
                                                    Journey.totalPrice = price;

                                                    _secureStorageProvider
                                                        .saveQuoteToDisk(Journey
                                                            .skuResponseLists);
                                                    _secureStorageProvider
                                                        .saveCartDetails(
                                                            skuResponseLists);
                                                    _secureStorageProvider
                                                        .saveCategory(
                                                            widget.category);
                                                    _secureStorageProvider
                                                        .saveBrand(
                                                            widget.brand);
                                                    _secureStorageProvider
                                                        .saveRange(
                                                            widget.range);
                                                    _secureStorageProvider
                                                        .saveTotalPrice(
                                                            price.toString());

                                                    logger(
                                                        'Quantity: $quantity');
                                                    setState(
                                                      () {
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
                                                      },
                                                    );

                                                    quantity = 0;
                                                    price = 0;

                                                    for (int i = 0;
                                                        i < controllers.length;
                                                        i++) {
                                                      if (controllers[i]
                                                          .text
                                                          .isNotEmpty) {
                                                        quantity = quantity +
                                                            int.parse(
                                                                controllers[i]
                                                                    .text);

                                                        price = price +
                                                            (int.parse(
                                                                    controllers[
                                                                            i]
                                                                        .text) *
                                                                int.parse(
                                                                    skuResponse
                                                                        .data![
                                                                            i]
                                                                        .sKUMRP!));
                                                        totPrice = price;
                                                      }
                                                    }

                                                    showBottomSheet(
                                                        context: context,
                                                        backgroundColor:
                                                            Colors.white,
                                                        elevation: 0,
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              color: AsianPaintColors
                                                                  .bottomTextColor),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .vertical(
                                                            top:
                                                                Radius.circular(
                                                                    25.0),
                                                          ),
                                                        ),
                                                        builder: (BuildContext
                                                            context) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        5),
                                                            child: SizedBox(
                                                              height: 100,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            5),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          "${Journey.skuResponseLists.length} SKU's added to Quote",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                AsianPaintColors.chooseYourAccountColor,
                                                                            fontFamily:
                                                                                AsianPaintsFonts.mulishBold,
                                                                            // fontWeight: FontWeight.w400,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          '\u{20B9} $price',
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                AsianPaintsFonts.mulishBold,
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                AsianPaintColors.forgotPasswordTextColor,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  Center(
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          45,
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      child:
                                                                          ElevatedButton(
                                                                        onPressed:
                                                                            () async {
                                                                          FlutterToastProvider()
                                                                              .show(message: "Successfully added SKU's to Quote!!");
                                                                          // Navigator.pop(
                                                                          //     context);
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => ViewQuote(
                                                                                catIndex: widget.catIndex,
                                                                                brandIndex: widget.brandIndex,
                                                                                rangeIndex: widget.rangeIndex,
                                                                                category: widget.category,
                                                                                brand: widget.brand,
                                                                                range: widget.range,
                                                                                quantity: controller.text,
                                                                                skuResponseList: skuResponseLists,
                                                                                fromFlip: widget.fromFlip,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(35.0),
                                                                          ),
                                                                          backgroundColor:
                                                                              AsianPaintColors.buttonColor,
                                                                          shadowColor:
                                                                              AsianPaintColors.buttonBorderColor,
                                                                          textStyle:
                                                                              TextStyle(
                                                                            color:
                                                                                AsianPaintColors.buttonTextColor,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                AsianPaintsFonts.mulishRegular,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          'View Quote',
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                AsianPaintsFonts.mulishBold,
                                                                            color:
                                                                                AsianPaintColors.whiteColor,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  }
                                                },

                                                onChanged: (value) {
                                                  int quantity = 0;
                                                  FocusScope.of(context)
                                                      .requestFocus();

                                                  price = 0;
                                                  skuResponseLists = [];
                                                  complementaryList = [];
                                                  for (int i = 0;
                                                      i < controllers.length;
                                                      i++) {
                                                    if (controllers[i]
                                                            .text
                                                            .isNotEmpty &&
                                                        controllers[i].text !=
                                                            '0') {
                                                      singleQuantity =
                                                          int.parse(
                                                              controllers[i]
                                                                  .text);
                                                      price = price +
                                                          (int.parse(
                                                                  controllers[i]
                                                                      .text) *
                                                              int.parse(
                                                                  skuResponse
                                                                      .data![i]
                                                                      .sKUMRP!));
                                                      singlePrice = int.parse(
                                                              controllers[i]
                                                                  .text) *
                                                          int.parse(skuResponse
                                                              .data![i]
                                                              .sKUMRP!);
                                                      skuResponseList.add(
                                                          skuResponse.data![i]);
                                                      Journey.skuDataList =
                                                          skuResponseList;
                                                      Quoteinfo quoteinfo =
                                                          Quoteinfo();
                                                      quoteinfo.totalqty =
                                                          '$singleQuantity';
                                                      quoteinfo.totalprice =
                                                          '$singlePrice';
                                                      quoteInfoList
                                                          .add(quoteinfo);
                                                      if ((skuResponse.data?[i]
                                                                  .complementary ??
                                                              [])
                                                          .isNotEmpty) {
                                                        for (int j = 0;
                                                            j <
                                                                (skuResponse.data?[i]
                                                                            .complementary ??
                                                                        [])
                                                                    .length;
                                                            j++) {
                                                          COMPLEMENTARY
                                                              complementary =
                                                              COMPLEMENTARY();
                                                          complementary
                                                              .cMPSRP = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPSRP ??
                                                              '';
                                                          complementary
                                                              .cMPUSP = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPUSP ??
                                                              '';
                                                          complementary
                                                              .cMPMR = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPMR ??
                                                              '';
                                                          complementary
                                                              .cMPDESCRIPTION = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPDESCRIPTION ??
                                                              '';
                                                          complementary
                                                              .cMPDRAWING = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPDRAWING ??
                                                              '';
                                                          complementary
                                                              .cMPRANGE = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPRANGE ??
                                                              '';
                                                          complementary
                                                              .cMPPRODUCTCAT = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPPRODUCTCAT ??
                                                              '';
                                                          complementary
                                                              .cMPSKUCODE = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPSKUCODE ??
                                                              '';
                                                          complementary
                                                              .cMPBRAND = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPBRAND ??
                                                              '';
                                                          complementary
                                                              .cMPSKUTYPE = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPSKUTYPE ??
                                                              '';
                                                          complementary
                                                              .cMPIMAGE = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPIMAGE ??
                                                              '';
                                                          complementary
                                                              .cMPCATCODE = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPCATCODE ??
                                                              '';
                                                          complementary
                                                              .cMPCATEGORY = skuResponse
                                                                  .data?[i]
                                                                  .complementary?[
                                                                      j]
                                                                  .cMPCATEGORY ??
                                                              '';
                                                          complementaryList.add(
                                                              complementary);
                                                        }
                                                      }

                                                      skuResponse.data?[i]
                                                              .quantity =
                                                          controllers[i].text;

                                                      skuResponse.data?[i]
                                                              .totalPrice =
                                                          int.parse(
                                                                  controllers[i]
                                                                      .text) *
                                                              int.parse(
                                                                  skuResponse
                                                                      .data![i]
                                                                      .sKUMRP!);
                                                      skuResponse.data?[i]
                                                              .totalPriceAfterDiscount =
                                                          singlePrice;

                                                      skuResponse.data?[i]
                                                          .discount = 0;

                                                      if (!skuResponseLists
                                                          .contains(skuResponse
                                                              .data?[i])) {
                                                        logger(
                                                            "In if condition:::");
                                                        skuResponseLists.add(
                                                            (skuResponse.data ??
                                                                [])[i]);
                                                      }

                                                      if (!Journey
                                                          .skuResponseLists
                                                          .contains(skuResponse
                                                              .data?[i])) {
                                                        logger(
                                                            "In if condition:::");

                                                        Journey.skuResponseLists
                                                            .add((skuResponse
                                                                    .data ??
                                                                [])[i]);
                                                      }
                                                    } else {
                                                      if (Journey
                                                          .skuResponseLists
                                                          .isNotEmpty) {
                                                        Journey.skuResponseLists
                                                            .remove((skuResponse
                                                                    .data ??
                                                                [])[i]);
                                                      }
                                                    }
                                                  }

                                                  skuRequestBody.quoteinfo =
                                                      quoteInfoList;

                                                  Journey.skuRequestBody =
                                                      skuRequestBody;
                                                  Journey.totalQuantity =
                                                      quantity;
                                                  Journey.totalPrice = price;

                                                  _secureStorageProvider
                                                      .saveQuoteToDisk(Journey
                                                          .skuResponseLists);
                                                  _secureStorageProvider
                                                      .saveCartDetails(
                                                          skuResponseLists);
                                                  _secureStorageProvider
                                                      .saveCategory(
                                                          widget.category);
                                                  _secureStorageProvider
                                                      .saveBrand(widget.brand);
                                                  _secureStorageProvider
                                                      .saveRange(widget.range);
                                                  _secureStorageProvider
                                                      .saveTotalPrice(
                                                          price.toString());

                                                  logger('Quantity: $quantity');
                                                  setState(
                                                    () {
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
                                                    },
                                                  );

                                                  quantity = 0;
                                                  price = 0;

                                                  for (int i = 0;
                                                      i < controllers.length;
                                                      i++) {
                                                    if (controllers[i]
                                                        .text
                                                        .isNotEmpty) {
                                                      quantity = quantity +
                                                          int.parse(
                                                              controllers[i]
                                                                  .text);

                                                      price = price +
                                                          (int.parse(
                                                                  controllers[i]
                                                                      .text) *
                                                              int.parse(
                                                                  skuResponse
                                                                      .data![i]
                                                                      .sKUMRP!));
                                                      totPrice = price;
                                                    }
                                                  }

                                                  showBottomSheet(
                                                      context: context,
                                                      backgroundColor:
                                                          Colors.white,
                                                      elevation: 0,
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            color: AsianPaintColors
                                                                .bottomTextColor),
                                                        borderRadius:
                                                            const BorderRadius
                                                                .vertical(
                                                          top: Radius.circular(
                                                              25.0),
                                                        ),
                                                      ),
                                                      builder: (BuildContext
                                                          context) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      20,
                                                                  vertical: 5),
                                                          child: SizedBox(
                                                            height: 100,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          5),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        "${Journey.skuResponseLists.length} SKU's added to Quote",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              AsianPaintColors.chooseYourAccountColor,
                                                                          fontFamily:
                                                                              AsianPaintsFonts.mulishBold,
                                                                          // fontWeight: FontWeight.w400,
                                                                          fontSize:
                                                                              12,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        '\u{20B9} $price',
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              AsianPaintsFonts.mulishBold,
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              AsianPaintColors.forgotPasswordTextColor,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Center(
                                                                  child:
                                                                      SizedBox(
                                                                    height: 45,
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () async {
                                                                        FlutterToastProvider().show(
                                                                            message:
                                                                                "Successfully added SKU's to Quote!!");
                                                                        // Navigator.pop(
                                                                        //     context);
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ViewQuote(
                                                                              catIndex: widget.catIndex,
                                                                              brandIndex: widget.brandIndex,
                                                                              rangeIndex: widget.rangeIndex,
                                                                              category: widget.category,
                                                                              brand: widget.brand,
                                                                              range: widget.range,
                                                                              quantity: controller.text,
                                                                              skuResponseList: skuResponseLists,
                                                                              fromFlip: widget.fromFlip,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(35.0),
                                                                        ),
                                                                        backgroundColor:
                                                                            AsianPaintColors.buttonColor,
                                                                        shadowColor:
                                                                            AsianPaintColors.buttonBorderColor,
                                                                        textStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              AsianPaintColors.buttonTextColor,
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontFamily:
                                                                              AsianPaintsFonts.mulishRegular,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        'View Quote',
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              AsianPaintsFonts.mulishBold,
                                                                          color:
                                                                              AsianPaintColors.whiteColor,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                },
                                                onFieldSubmitted: (value) {
                                                  int quantity = 0;
                                                  int compQuantity = 0;
                                                  price = 0;

                                                  for (int i = 0;
                                                      i < controllers.length;
                                                      i++) {
                                                    if (controllers[i]
                                                        .text
                                                        .isNotEmpty) {
                                                      quantity = quantity +
                                                          int.parse(
                                                              controllers[i]
                                                                  .text);

                                                      price = price +
                                                          (int.parse(
                                                                  controllers[i]
                                                                      .text) *
                                                              int.parse(
                                                                  skuResponse
                                                                      .data![i]
                                                                      .sKUMRP!));
                                                      totPrice = price;
                                                    }
                                                  }
                                                  logger(
                                                      'Quantity before comp: ${Journey.skuResponseLists.length}');

                                                  complementaryList.isNotEmpty
                                                      ? showModalBottomSheet(
                                                          isScrollControlled:
                                                              true,
                                                          context: context,
                                                          useSafeArea: true,
                                                          backgroundColor:
                                                              Colors.white,
                                                          elevation: 0,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: AsianPaintColors
                                                                    .bottomTextColor),
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      25.0),
                                                            ),
                                                          ),
                                                          builder: (BuildContext
                                                              context) {
                                                            return Builder(
                                                                builder:
                                                                    (context) {
                                                              return Padding(
                                                                padding: MediaQuery.of(
                                                                        context)
                                                                    .viewInsets,
                                                                child:
                                                                    Container(
                                                                  height: 350,
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          5),
                                                                  child:
                                                                      SizedBox(
                                                                    height: 100,
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(horizontal: 5),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                "Complementary SKU's",
                                                                                style: TextStyle(
                                                                                  color: AsianPaintColors.buttonTextColor,
                                                                                  fontFamily: AsianPaintsFonts.bathSansRegular,
                                                                                  // fontWeight: FontWeight.w400,
                                                                                  fontSize: 20,
                                                                                ),
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  Navigator.of(context).pop(context);
                                                                                },
                                                                                child: Image.asset(
                                                                                  'assets/images/cancel.png',
                                                                                  width: 18,
                                                                                  height: 18,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Expanded(
                                                                            child:
                                                                                Scrollbar(
                                                                          thumbVisibility:
                                                                              true,
                                                                          child:
                                                                              ListView.separated(
                                                                            itemBuilder:
                                                                                (BuildContext context, int index) {
                                                                              compControllers.add(TextEditingController(text: ''));
                                                                              if (complementaryList.isEmpty) {
                                                                                return const Center(
                                                                                  child: Text('No data available'),
                                                                                );
                                                                              } else {
                                                                                return compItemList(complementaryList, index, compControllers[index], compControllers);
                                                                              }
                                                                            },
                                                                            separatorBuilder:
                                                                                (BuildContext context, int index) {
                                                                              return const Divider(
                                                                                color: Colors.white,
                                                                              );
                                                                            },
                                                                            itemCount:
                                                                                complementaryList.length,
                                                                          ),
                                                                        )),
                                                                        const SizedBox(
                                                                            height:
                                                                                10),
                                                                        Container(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 8, right: 8),
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text(
                                                                                  "${Journey.skuResponseLists.length} SKU's added to quote",
                                                                                  style: TextStyle(
                                                                                    fontFamily: AsianPaintsFonts.mulishBold,
                                                                                    fontSize: 12,
                                                                                    color: AsianPaintColors.chooseYourAccountColor,
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  "\u{20B9} $totPrice",
                                                                                  style: TextStyle(
                                                                                    fontFamily: AsianPaintsFonts.mulishBlack,
                                                                                    fontSize: 14,
                                                                                    color: AsianPaintColors.forgotPasswordTextColor,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            )),
                                                                        const SizedBox(
                                                                          height:
                                                                              15,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              double.infinity,
                                                                          child:
                                                                              ElevatedButton(
                                                                            onPressed:
                                                                                () async {
                                                                              Navigator.pop(context);
                                                                              _secureStorageProvider.saveQuoteToDisk(Journey.skuResponseLists);
                                                                              _secureStorageProvider.saveCartDetails(skuResponseLists);
                                                                              _secureStorageProvider.saveCategory(widget.category);
                                                                              _secureStorageProvider.saveBrand(widget.brand);
                                                                              _secureStorageProvider.saveRange(widget.range);
                                                                              _secureStorageProvider.saveTotalPrice(price.toString());
                                                                              showBottomSheet(
                                                                                  context: context,
                                                                                  // useSafeArea: true,
                                                                                  backgroundColor: Colors.white,
                                                                                  elevation: 0,
                                                                                  shape: RoundedRectangleBorder(
                                                                                    side: BorderSide(color: AsianPaintColors.bottomTextColor),
                                                                                    borderRadius: const BorderRadius.vertical(
                                                                                      top: Radius.circular(25.0),
                                                                                    ),
                                                                                  ),
                                                                                  builder: (BuildContext context) {
                                                                                    return Padding(
                                                                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                                                      child: SizedBox(
                                                                                        height: 100,
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          children: [
                                                                                            const SizedBox(
                                                                                              height: 10,
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                              child: Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                children: [
                                                                                                  Text(
                                                                                                    "${Journey.skuResponseLists.length} SKU's added to Quote",
                                                                                                    style: TextStyle(
                                                                                                      color: AsianPaintColors.chooseYourAccountColor,
                                                                                                      fontFamily: AsianPaintsFonts.mulishBold,
                                                                                                      // fontWeight: FontWeight.w400,
                                                                                                      fontSize: 12,
                                                                                                    ),
                                                                                                  ),
                                                                                                  Text(
                                                                                                    '\u{20B9} $totPrice',
                                                                                                    style: TextStyle(
                                                                                                      fontFamily: AsianPaintsFonts.mulishBold,
                                                                                                      fontSize: 12,
                                                                                                      color: AsianPaintColors.forgotPasswordTextColor,
                                                                                                    ),
                                                                                                  )
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            const SizedBox(
                                                                                              height: 15,
                                                                                            ),
                                                                                            Center(
                                                                                              child: SizedBox(
                                                                                                height: 45,
                                                                                                width: MediaQuery.of(context).size.width,
                                                                                                child: ElevatedButton(
                                                                                                  onPressed: () async {
                                                                                                    FlutterToastProvider().show(message: "Successfully added SKU's to Quote!!");
                                                                                                    // Navigator.pop(
                                                                                                    //     context);
                                                                                                    Navigator.push(
                                                                                                      context,
                                                                                                      MaterialPageRoute(
                                                                                                        builder: (context) => ViewQuote(
                                                                                                          catIndex: widget.catIndex,
                                                                                                          brandIndex: widget.brandIndex,
                                                                                                          rangeIndex: widget.rangeIndex,
                                                                                                          category: widget.category,
                                                                                                          brand: widget.brand,
                                                                                                          range: widget.range,
                                                                                                          quantity: controller.text,
                                                                                                          skuResponseList: skuResponseLists,
                                                                                                          fromFlip: widget.fromFlip,
                                                                                                        ),
                                                                                                      ),
                                                                                                    );
                                                                                                  },
                                                                                                  style: ElevatedButton.styleFrom(
                                                                                                    shape: RoundedRectangleBorder(
                                                                                                      borderRadius: BorderRadius.circular(35.0),
                                                                                                    ),
                                                                                                    backgroundColor: AsianPaintColors.buttonColor,
                                                                                                    shadowColor: AsianPaintColors.buttonBorderColor,
                                                                                                    textStyle: TextStyle(
                                                                                                      color: AsianPaintColors.buttonTextColor,
                                                                                                      fontSize: 12,
                                                                                                      fontWeight: FontWeight.bold,
                                                                                                      fontFamily: AsianPaintsFonts.mulishRegular,
                                                                                                    ),
                                                                                                  ),
                                                                                                  child: Text(
                                                                                                    'View Quote',
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
                                                                                    );
                                                                                  });
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
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontFamily: AsianPaintsFonts.mulishRegular,
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              'Save & Return',
                                                                              style: TextStyle(
                                                                                fontFamily: AsianPaintsFonts.mulishBold,
                                                                                color: AsianPaintColors.whiteColor,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                          },
                                                        )
                                                      : null;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              SkuListBloc skuListBloc = context.read<SkuListBloc>();
              if (state is SkuInitial) {
                const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is SkuLoading) {
                const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is SkuLoaded || state is SkuReLoaded) {
                controllers = [];

                areas.add('ALL');
                (widget.skuResponse ?? []).isNotEmpty
                    ? skuListBloc.skuResponse?.data = widget.skuResponse
                    : skuListBloc.skuResponse?.data;
                for (int i = 0;
                    i < (skuListBloc.skuResponse?.data ?? []).length;
                    i++) {
                  controllers.add(TextEditingController());
                  for (int j = 0;
                      j <
                          (skuListBloc.skuResponse?.data?[i].aREAINFO ?? [])
                              .length;
                      j++) {
                    areas.add(skuListBloc.skuResponse?.data?[i].aREAINFO?[j] ??
                        'SHOWER_AREA');
                  }
                }

                logger(
                    'Widget SKU Response Length: ${widget.skuResponse?.length}');
                logger('Sku Areas: ${areas}');
                return Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      height: 40,
                      child: ChipsFilter(
                        selected: Journey
                            .selectedIndex, // Select the second filter as default
                        filters: [
                          for (var i in areas)
                            Filter(
                              category: widget.category,
                              brand: widget.brand,
                              range: widget.range,
                              limit: 1,
                              bloc: bloc,
                              label: i,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 120),
                          child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3 / 4.0,
                              ),
                              itemCount:
                                  skuListBloc.skuResponse?.data?.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                if (skuListBloc.skuResponse!.data!.isEmpty) {
                                  return const Center(
                                    child: Text('No data available'),
                                  );
                                } else {
                                  return singleItemList(
                                      skuListBloc.skuResponse!,
                                      index,
                                      controllers[index],
                                      controllers);
                                }
                              }),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (state is SkuFailure) {
                return SkuListBloc().loadingStatus == true
                    ? SizedBox(
                        height: displayHeight(context) * 0.65,
                        width: displayWidth(context),
                        child: const Center(child: CircularProgressIndicator()))
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
            listener: (context, state) {},
          ),
        ),
      ),
      tablet: const Scaffold(),
    );
  }
}

class Filter {
  final String label;
  final SkuListBloc bloc;
  final String? category;
  final String? brand;
  final String? range;
  final int limit;

  const Filter(
      {required this.category,
      required this.brand,
      required this.range,
      required this.limit,
      required this.bloc,
      required this.label});
}

class ChipsFilter extends StatefulWidget {
  ///
  /// The list of the filters
  ///
  final List<Filter> filters;

  ///
  /// The default selected index starting with 0
  ///
  final int selected;

  const ChipsFilter({Key? key, required this.filters, required this.selected})
      : super(key: key);

  @override
  ChipsFilterState createState() => ChipsFilterState();
}

class ChipsFilterState extends State<ChipsFilter> {
  ///
  /// Currently selected index
  ///
  late int selectedIndex;

  @override
  void initState() {
    // When [widget.selected] is defined, check the value and set it as
    // [selectedIndex]
    if (widget.selected >= 0 && widget.selected < widget.filters.length) {
      selectedIndex = widget.selected;
    } else {
      selectedIndex = 0;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: chipBuilder,
      itemCount: widget.filters.length,
      scrollDirection: Axis.horizontal,
    );
  }

  ///
  /// Build a single chip
  ///
  Widget chipBuilder(context, currentIndex) {
    Filter filter = widget.filters[currentIndex];
    bool isActive = selectedIndex == currentIndex;
    return GestureDetector(
      onTap: () {
        Journey.area = filter.label;
        Journey.selectedIndex = currentIndex;
        setState(() {
          selectedIndex = currentIndex;

          BlocProvider.of<SkuListBloc>(context).add(
            GetSkuEvent(
              category: filter.category,
              brand: filter.brand,
              range: filter.range,
              area: filter.label != 'ALL' ? "${filter.label}" : filter.label,
              limit: 1,
            ),
          );
          // filter.bloc.getRefreshSkuList(
          //     category: filter.category,
          //     brand: filter.brand,
          //     range: filter.range,
          //     area: filter.label,
          //     limit: 1);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 17),
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          color: isActive ? AsianPaintColors.buttonTextColor : Colors.white,
          border: Border.all(color: AsianPaintColors.buttonTextColor),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              filter.label,
              style: TextStyle(
                color: isActive
                    ? AsianPaintColors.whiteColor
                    : AsianPaintColors.buttonTextColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
