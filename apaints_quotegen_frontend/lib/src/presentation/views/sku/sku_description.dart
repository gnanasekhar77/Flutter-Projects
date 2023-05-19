import 'dart:convert';

import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/sku_request_model.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/sku_list.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/view_quote.dart';
import 'package:APaints_QGen/src/presentation/widgets/app_bar.dart';
import 'package:APaints_QGen/src/routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SKUDescriptionPage extends StatefulWidget {
  static const routeName = Routes.SKUDescriptionScreen;
  SKUData? skuData;
  final int catIndex, brandIndex, rangeIndex;
  final String? category, brand, range, quantity;
  SKUDescriptionPage(
      {super.key,
      this.skuData,
      required this.catIndex,
      required this.brandIndex,
      required this.rangeIndex,
      this.quantity,
      this.category,
      this.brand,
      this.range});

  @override
  State<SKUDescriptionPage> createState() => _SKUDescriptionPageState();
}

class _SKUDescriptionPageState extends State<SKUDescriptionPage> {
  final TextEditingController qty = TextEditingController();
  ScrollController _scrollController = ScrollController();

  // final List<PhotoItem> _items = [
  //   PhotoItem(
  //       "https://images.pexels.com/photos/1772973/pexels-photo-1772973.png?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
  //       "Stephan Seeber"),
  //   PhotoItem(
  //       "https://images.pexels.com/photos/1758531/pexels-photo-1758531.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
  //       "Liam Gant"),
  //   PhotoItem(
  //       "https://images.unsplash.com/photo-1524419986249-348e8fa6ad4a?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHNhbXBsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60",
  //       "Stephan Seeber"),
  //   PhotoItem(
  //       "https://images.unsplash.com/photo-1558383331-f520f2888351?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OHx8c2FtcGxlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60",
  //       "Liam Gant"),
  //   PhotoItem(
  //       "https://images.unsplash.com/photo-1613467663837-e4a6be2014b6?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTd8fHNhbXBsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60",
  //       "Stephan Seeber"),
  //   PhotoItem(
  //       "https://images.unsplash.com/photo-1602866813929-6bc4933c7013?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTV8fHNhbXBsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60",
  //       "Liam Gant"),
  //   PhotoItem(
  //       "https://images.unsplash.com/photo-1531361171768-37170e369163?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fHNhbXBsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60",
  //       "Stephan Seeber"),
  //   PhotoItem(
  //       "https://images.unsplash.com/photo-1673848642462-57c3be04f58c?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=900&q=60",
  //       "Liam Gant"),
  //   PhotoItem(
  //       "https://images.unsplash.com/photo-1643746620166-2a890600af6b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwyfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=900&q=60",
  //       "Stephan Seeber"),
  //   PhotoItem(
  //       "https://images.unsplash.com/photo-1673847388812-c53e4873bffe?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw5fHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=900&q=60",
  //       "Liam Gant"),
  //   PhotoItem(
  //       "https://images.unsplash.com/photo-1673809758231-d864d9e35307?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwxNXx8fGVufDB8fHx8&auto=format&fit=crop&w=900&q=60",
  //       "Stephan Seeber"),
  //   PhotoItem(
  //       "https://images.unsplash.com/photo-1673810499402-3bcd8857df5d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwxN3x8fGVufDB8fHx8&auto=format&fit=crop&w=900&q=60",
  //       "Liam Gant"),
  //   PhotoItem(
  //       "https://images.unsplash.com/photo-1673794784636-2e69436d3eee?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2128&q=80",
  //       "Stephan Seeber"),
  //   PhotoItem(
  //       "https://images.unsplash.com/photo-1673512003616-5bf76a4cbea1?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzMHx8fGVufDB8fHx8&auto=format&fit=crop&w=900&q=60",
  //       "Liam Gant"),
  // ];

  List<SKUData> skuResponseLists = [];
  List<COMPLEMENTARY> complementaryList = [];
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  int cartCount = 0;

  @override
  void initState() {
    List<String?> images = [widget.skuData!.sKUIMAGE!];
    qty.text = widget.quantity!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var formKey = GlobalKey<FormState>();

    // 4 text editing controllers that associate with the 4 input fields

    return Responsive(
      desktop: Scaffold(
        appBar: AppBarTemplate(
          isVisible: true,
          header: AppLocalizations.of(context).sku,
        ),
        body: Container(
            color: AsianPaintColors.appBackgroundColor,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 80, top: 40),
                      child: Text(
                        AppLocalizations.of(context).sku,
                        //AppLocalizations.of(context).sku,
                        style: TextStyle(
                          fontFamily: AsianPaintsFonts.bathSansRegular,
                          fontSize: 15,
                          color: AsianPaintColors.projectUserNameColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.55,
                      width: MediaQuery.of(context).size.width * 0.40,
                      margin: const EdgeInsets.all(10),
                      //padding:EdgeInsets.only(left:),
                      child: Carousel(skuData: widget.skuData),
                    ),
                  ],
                ),
                const SizedBox(width: 120),
                SizedBox(
                  width: 350,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 100),
                        child: Text(widget.skuData!.skuCatCode!,
                            //AppLocalizations.of(context).grbm101,
                            style: TextStyle(
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AsianPaintColors.projectUserNameColor,
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        widget.skuData!.sKUDESCRIPTION!,
                        //AppLocalizations.of(context).angle_cock,
                        style: TextStyle(
                          fontFamily: AsianPaintsFonts.mulishRegular,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            //textAlign: TextAlign.justify,
                            '\u{20B9} ${widget.skuData!.sKUMRP!}',
                            style: TextStyle(
                                fontFamily: AsianPaintsFonts.mulishRegular,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    AsianPaintColors.forgotPasswordTextColor),
                          ),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context).qty,
                                //AppLocalizations.of(context).qty,
                                style: TextStyle(
                                  fontFamily: AsianPaintsFonts.mulishBold,
                                  color:
                                      AsianPaintColors.resetPasswordLabelColor,
                                  fontSize: 11,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: SizedBox(
                                  width: 70,
                                  height: 32,
                                  child: TextField(
                                    enableInteractiveSelection: false,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[0-9]+')),
                                      LengthLimitingTextInputFormatter(5),
                                    ],
                                    textAlign: TextAlign.center,
                                    controller: qty,
                                    cursorColor: AsianPaintColors.kPrimaryColor,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.only(bottom: 4),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color:
                                                AsianPaintColors.kPrimaryColor),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color:
                                                AsianPaintColors.kPrimaryColor),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color:
                                                AsianPaintColors.kPrimaryColor),
                                      ),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                          borderSide: BorderSide(
                                            width: 1,
                                          )),
                                      errorBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(30)),
                                          borderSide: BorderSide(
                                              width: 1,
                                              color: AsianPaintColors
                                                  .kPrimaryColor)),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color:
                                                AsianPaintColors.kPrimaryColor),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Align(
                        //alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                // List<Area> areas = [
                                //   Area(
                                //     areaname: "Shower",
                                //     areaqty: qty.text,
                                //   )
                                // ];
                                // String areastr = jsonEncode(areas);

                                // var skuPrice =
                                //     int.parse(widget.skuData!.sKUMRP!);
                                // // assert(skuPrice is int);
                                // var skuQty = int.parse(qty.text);
                                // // assert(skuQty is int);
                                // int totalPrice = skuPrice * skuQty;
                                // List<Quoteinfo> quoteInfoList = [
                                //   Quoteinfo(
                                //     area: areas,
                                //     skuid: widget.skuData!.sKUCODE!,
                                //     discount: '0',
                                //     totalqty: qty.text,
                                //     totalprice: "$totalPrice",
                                //     bundletype: "",
                                //   )
                                // ];
                                // var skuPrice = int.parse(widget.skuData!.sKUMRP!);
                                //     assert(skuPrice is int);
                                //     var skuQty = int.parse(qty.text);
                                //     assert(skuQty is int);
                                int totalPrice = 0;
                                // String quoteInfo = jsonEncode(quoteInfoList);
                                // SkuRequestBody skuRequestBody = SkuRequestBody(
                                //   quoteinfo: quoteInfoList,
                                //   discountamount: '0',
                                //   totalpricewithgst: "$totalPrice",
                                //   quotename: "",
                                //   projectid: "",
                                //   quotetype: "",
                                //   isExist: false,
                                //   projectName: "",
                                //   contactPerson: "Sravan",
                                //   mobileNumber: "",
                                //   siteAddress: "",
                                //   noOfBathRooms: "2",
                                // );
                                // String skuRequest = jsonEncode(skuRequestBody);
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => ViewQuote(
                                //       catIndex: widget.catIndex,
                                //       brandIndex: widget.brandIndex,
                                //       rangeIndex: widget.rangeIndex,
                                //       category: widget.category,
                                //       brand: widget.brand,
                                //       range: widget.range,
                                //       skuData: widget.skuData,
                                //       quantity: qty.text,
                                //       totalPrice: totalPrice,
                                //     ),
                                //   ),
                                // );
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => SKUList(
                                //       catIndex: widget.catIndex,
                                //       brandIndex: widget.brandIndex,
                                //       rangeIndex: widget.rangeIndex,
                                //       category: widget.category,
                                //       brand: widget.brand,
                                //       range: widget.range,
                                //       skuCode: widget.skuData!.sKUCODE,
                                //       skuQty: qty.text,
                                //     ),
                                //   ),
                                // );
                                Journey.att = [
                                  qty.text,
                                  widget.skuData!.skuCatCode!
                                ];
                                Journey.quantity = qty.text;
                                Navigator.pop(context, qty.text);
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    AsianPaintColors.resetPasswordLabelColor),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    side: BorderSide(
                                        color:
                                            AsianPaintColors.buttonBorderColor),
                                  ),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context).add_to_quote,
                                //AppLocalizations.of(context).add_to_quote,
                                style: TextStyle(
                                  fontFamily: AsianPaintsFonts.mulishRegular,
                                  fontSize: 12,
                                  color: AsianPaintColors.whiteColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
      tablet: const Scaffold(),
      mobile: Scaffold(
        appBar: AppBarTemplate(
          isVisible: true,
          header: AppLocalizations.of(context).sku,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  // mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Carousel(
                    //   skuData: widget.skuData,
                    // ),

                    Image.network((widget.skuData!.sKUIMAGE ?? '').isEmpty
                        ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
                        : widget.skuData!.sKUIMAGE!),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 15, 0, 0),
                      child: Text(
                        widget.skuData!.skuCatCode!,
                        style: TextStyle(
                          fontFamily: AsianPaintsFonts.mulishBold,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AsianPaintColors.chooseYourAccountColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Text(
                        widget.skuData!.sKUDESCRIPTION!,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: AsianPaintsFonts.mulishRegular,
                          color: AsianPaintColors.skuDescriptionColor,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Text(
                            textAlign: TextAlign.justify,
                            '\u{20B9} ${widget.skuData!.sKUMRP!}',
                            style: TextStyle(
                              color: AsianPaintColors.forgotPasswordTextColor,
                              fontSize: 18,
                              fontFamily: AsianPaintsFonts.mulishBold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  textAlign: TextAlign.end,
                                  AppLocalizations.of(context).qty,
                                  style: TextStyle(
                                    color: AsianPaintColors.kPrimaryColor,
                                    fontSize: 14,
                                    fontFamily: AsianPaintsFonts.mulishBold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: SizedBox(
                                      width: 90,
                                      height: 40,
                                      child: TextFormField(
                                        enableInteractiveSelection: false,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp('[0-9]+')),
                                          LengthLimitingTextInputFormatter(5),
                                        ],
                                        keyboardType: const TextInputType
                                                .numberWithOptions(
                                            signed: true, decimal: true),
                                        controller: qty,
                                        textAlign: TextAlign.center,
                                        textAlignVertical:
                                            TextAlignVertical.top,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                AsianPaintColors.kPrimaryColor,
                                            fontFamily:
                                                AsianPaintsFonts.mulishBold),
                                        cursorColor:
                                            AsianPaintColors.kPrimaryColor,
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(30)),
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: AsianPaintColors
                                                    .kPrimaryColor),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(30)),
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: AsianPaintColors
                                                    .kPrimaryColor),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(30)),
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: AsianPaintColors
                                                    .kPrimaryColor),
                                          ),
                                          border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide: BorderSide(
                                                width: 1,
                                              )),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color: AsianPaintColors
                                                      .kPrimaryColor)),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(30)),
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: AsianPaintColors
                                                    .kPrimaryColor),
                                          ),
                                        ),
                                        onTap: () {
                                          if (qty.text.isEmpty) {
                                            qty.text = '1';
                                            int quantity = 0;
                                            FocusScope.of(context)
                                                .requestFocus();

                                            int price = 0;
                                            skuResponseLists = [];
                                            complementaryList = [];
                                            int singleQuantity = 0;
                                            int singlePrice = 0;
                                            if (qty.text.isNotEmpty) {
                                              singleQuantity =
                                                  int.parse(qty.text);
                                              price = price +
                                                  (int.parse(qty.text) *
                                                      int.parse(widget.skuData!
                                                              .sKUMRP ??
                                                          '0'));
                                              singlePrice =
                                                  int.parse(qty.text) *
                                                      int.parse(widget.skuData!
                                                              .sKUMRP ??
                                                          '0');

                                              Quoteinfo quoteinfo = Quoteinfo();
                                              quoteinfo.totalqty =
                                                  '$singleQuantity';
                                              quoteinfo.totalprice =
                                                  '$singlePrice';
                                              // quoteInfoList
                                              //     .add(quoteinfo);
                                              if ((widget.skuData!
                                                          .complementary ??
                                                      [])
                                                  .isNotEmpty) {
                                                for (int j = 0;
                                                    j <
                                                        (widget.skuData!
                                                                    .complementary ??
                                                                [])
                                                            .length;
                                                    j++) {
                                                  COMPLEMENTARY complementary =
                                                      COMPLEMENTARY();
                                                  complementary.cMPSRP = widget
                                                          .skuData!
                                                          .complementary?[j]
                                                          .cMPSRP ??
                                                      '';
                                                  complementary.cMPUSP = widget
                                                          .skuData!
                                                          .complementary?[j]
                                                          .cMPUSP ??
                                                      '';
                                                  complementary.cMPMR = widget
                                                          .skuData!
                                                          .complementary?[j]
                                                          .cMPMR ??
                                                      '';
                                                  complementary.cMPDESCRIPTION =
                                                      widget
                                                              .skuData!
                                                              .complementary?[j]
                                                              .cMPDESCRIPTION ??
                                                          '';
                                                  complementary.cMPDRAWING =
                                                      widget
                                                              .skuData!
                                                              .complementary?[j]
                                                              .cMPDRAWING ??
                                                          '';
                                                  complementary.cMPRANGE =
                                                      widget
                                                              .skuData!
                                                              .complementary?[j]
                                                              .cMPRANGE ??
                                                          '';
                                                  complementary.cMPPRODUCTCAT =
                                                      widget
                                                              .skuData!
                                                              .complementary?[j]
                                                              .cMPPRODUCTCAT ??
                                                          '';
                                                  complementary.cMPSKUCODE =
                                                      widget
                                                              .skuData!
                                                              .complementary?[j]
                                                              .cMPSKUCODE ??
                                                          '';
                                                  complementary.cMPBRAND =
                                                      widget
                                                              .skuData!
                                                              .complementary?[j]
                                                              .cMPBRAND ??
                                                          '';
                                                  complementary.cMPSKUTYPE =
                                                      widget
                                                              .skuData!
                                                              .complementary?[j]
                                                              .cMPSKUTYPE ??
                                                          '';
                                                  complementary.cMPIMAGE =
                                                      widget
                                                              .skuData!
                                                              .complementary?[j]
                                                              .cMPIMAGE ??
                                                          '';
                                                  complementary.cMPCATCODE =
                                                      widget
                                                              .skuData!
                                                              .complementary?[j]
                                                              .cMPCATCODE ??
                                                          '';
                                                  complementary.cMPCATEGORY =
                                                      widget
                                                              .skuData!
                                                              .complementary?[j]
                                                              .cMPCATEGORY ??
                                                          '';
                                                  complementaryList
                                                      .add(complementary);
                                                }
                                              }

                                              widget.skuData!.quantity =
                                                  qty.text;

                                              widget.skuData!.totalPrice =
                                                  int.parse(qty.text) *
                                                      int.parse(widget.skuData!
                                                              .sKUMRP ??
                                                          '0');
                                              widget.skuData!
                                                      .totalPriceAfterDiscount =
                                                  singlePrice;

                                              widget.skuData!.discount = 0;

                                              if (!skuResponseLists
                                                  .contains(widget.skuData)) {
                                                logger("In if condition:::");
                                                skuResponseLists
                                                    .add((widget.skuData!));
                                              }

                                              if (!Journey.skuResponseLists
                                                  .contains(widget.skuData)) {
                                                logger("In if condition:::");

                                                Journey.skuResponseLists
                                                    .add(widget.skuData!);
                                              }
                                            }

                                            // skuRequestBody.quoteinfo =
                                            //     quoteInfoList;

                                            // Journey.skuRequestBody =
                                            //     skuRequestBody;
                                            Journey.totalQuantity = quantity;
                                            Journey.totalPrice = price;

                                            _secureStorageProvider
                                                .saveQuoteToDisk(
                                                    Journey.skuResponseLists);
                                            _secureStorageProvider
                                                .saveCartDetails(
                                                    skuResponseLists);
                                            _secureStorageProvider
                                                .saveCategory(widget.category);
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
                                                    .skuResponseLists.length;
                                                _secureStorageProvider
                                                    .saveCartCount(cartCount);
                                                logger(
                                                    'Cart count: $cartCount');
                                                logger('Quantity: $quantity');
                                              },
                                            );
                                          }
                                        },
                                        onChanged: (value) {
                                          if (qty.text == '0') {
                                            qty.text = '1';
                                          }
                                          int quantity = 0;
                                          FocusScope.of(context).requestFocus();

                                          int price = 0;
                                          skuResponseLists = [];
                                          complementaryList = [];
                                          int singleQuantity = 0;
                                          int singlePrice = 0;
                                          if (qty.text.isNotEmpty &&
                                              qty.text != '0') {
                                            singleQuantity =
                                                int.parse(qty.text);
                                            price = price +
                                                (int.parse(qty.text) *
                                                    int.parse(widget
                                                            .skuData!.sKUMRP ??
                                                        '0'));
                                            singlePrice = int.parse(qty.text) *
                                                int.parse(
                                                    widget.skuData!.sKUMRP ??
                                                        '0');

                                            Quoteinfo quoteinfo = Quoteinfo();
                                            quoteinfo.totalqty =
                                                '$singleQuantity';
                                            quoteinfo.totalprice =
                                                '$singlePrice';
                                            // quoteInfoList
                                            //     .add(quoteinfo);
                                            if ((widget.skuData!
                                                        .complementary ??
                                                    [])
                                                .isNotEmpty) {
                                              for (int j = 0;
                                                  j <
                                                      (widget.skuData!
                                                                  .complementary ??
                                                              [])
                                                          .length;
                                                  j++) {
                                                COMPLEMENTARY complementary =
                                                    COMPLEMENTARY();
                                                complementary.cMPSRP = widget
                                                        .skuData!
                                                        .complementary?[j]
                                                        .cMPSRP ??
                                                    '';
                                                complementary.cMPUSP = widget
                                                        .skuData!
                                                        .complementary?[j]
                                                        .cMPUSP ??
                                                    '';
                                                complementary.cMPMR = widget
                                                        .skuData!
                                                        .complementary?[j]
                                                        .cMPMR ??
                                                    '';
                                                complementary.cMPDESCRIPTION =
                                                    widget
                                                            .skuData!
                                                            .complementary?[j]
                                                            .cMPDESCRIPTION ??
                                                        '';
                                                complementary.cMPDRAWING =
                                                    widget
                                                            .skuData!
                                                            .complementary?[j]
                                                            .cMPDRAWING ??
                                                        '';
                                                complementary.cMPRANGE = widget
                                                        .skuData!
                                                        .complementary?[j]
                                                        .cMPRANGE ??
                                                    '';
                                                complementary.cMPPRODUCTCAT =
                                                    widget
                                                            .skuData!
                                                            .complementary?[j]
                                                            .cMPPRODUCTCAT ??
                                                        '';
                                                complementary.cMPSKUCODE =
                                                    widget
                                                            .skuData!
                                                            .complementary?[j]
                                                            .cMPSKUCODE ??
                                                        '';
                                                complementary.cMPBRAND = widget
                                                        .skuData!
                                                        .complementary?[j]
                                                        .cMPBRAND ??
                                                    '';
                                                complementary.cMPSKUTYPE =
                                                    widget
                                                            .skuData!
                                                            .complementary?[j]
                                                            .cMPSKUTYPE ??
                                                        '';
                                                complementary.cMPIMAGE = widget
                                                        .skuData!
                                                        .complementary?[j]
                                                        .cMPIMAGE ??
                                                    '';
                                                complementary.cMPCATCODE =
                                                    widget
                                                            .skuData!
                                                            .complementary?[j]
                                                            .cMPCATCODE ??
                                                        '';
                                                complementary.cMPCATEGORY =
                                                    widget
                                                            .skuData!
                                                            .complementary?[j]
                                                            .cMPCATEGORY ??
                                                        '';
                                                complementaryList
                                                    .add(complementary);
                                              }
                                            }

                                            widget.skuData!.quantity = qty.text;

                                            widget.skuData!.totalPrice =
                                                int.parse(qty.text) *
                                                    int.parse(widget
                                                            .skuData!.sKUMRP ??
                                                        '0');
                                            widget.skuData!
                                                    .totalPriceAfterDiscount =
                                                singlePrice;

                                            widget.skuData!.discount = 0;

                                            if (!skuResponseLists
                                                .contains(widget.skuData)) {
                                              logger("In if condition:::");
                                              skuResponseLists
                                                  .add((widget.skuData!));
                                            }

                                            if (!Journey.skuResponseLists
                                                .contains(widget.skuData)) {
                                              logger("In if condition:::");

                                              Journey.skuResponseLists
                                                  .add(widget.skuData!);
                                            }
                                          }

                                          // skuRequestBody.quoteinfo =
                                          //     quoteInfoList;

                                          // Journey.skuRequestBody =
                                          //     skuRequestBody;
                                          Journey.totalQuantity = quantity;
                                          Journey.totalPrice = price;

                                          _secureStorageProvider
                                              .saveQuoteToDisk(
                                                  Journey.skuResponseLists);
                                          _secureStorageProvider
                                              .saveCartDetails(
                                                  skuResponseLists);
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
                                              cartCount = Journey
                                                  .skuResponseLists.length;
                                              _secureStorageProvider
                                                  .saveCartCount(cartCount);
                                              logger('Cart count: $cartCount');
                                              logger('Quantity: $quantity');
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      List<Area> areas = [
                        Area(
                          areaname: "Shower",
                          areaqty: qty.text,
                        )
                      ];
                      String areastr = jsonEncode(areas);
                      int totalPrice = 0;
                      if (qty.text != '') {
                        var skuPrice = int.parse(widget.skuData!.sKUMRP!);
                        assert(skuPrice is int);
                        var skuQty = int.parse(qty.text);
                        assert(skuQty is int);
                        totalPrice = skuPrice * skuQty;
                      }
                      List<Quoteinfo> quoteInfoList = [
                        Quoteinfo(
                          area: areas,
                          skuid: widget.skuData!.skuCatCode!,
                          discount: '0',
                          totalqty: qty.text,
                          totalprice: "$totalPrice",
                          bundletype: "",
                        )
                      ];

                      Journey.qtyMap = {widget.skuData!.skuCatCode!: qty.text};

                      Journey.skuCode = widget.skuData!.sKUCODE!;
                      Journey.quantity = qty.text;

                      String quoteInfo = jsonEncode(quoteInfoList);
                      SkuRequestBody skuRequestBody = SkuRequestBody(
                        quoteinfo: quoteInfoList,
                        discountamount: '0',
                        totalpricewithgst: "$totalPrice",
                        quotename: "",
                        projectid: "",
                        quotetype: "",
                        isExist: false,
                        projectName: "",
                        contactPerson: "Sravan",
                        mobileNumber: "",
                        siteAddress: "",
                        noOfBathRooms: "2",
                      );
                      String skuRequest = jsonEncode(skuRequestBody);

                      Journey.att = [qty.text, widget.skuData!.skuCatCode!];
                      Journey.quantity = qty.text;
                      Navigator.pop(context, qty.text);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => SKUList(
                      //       catIndex: widget.catIndex,
                      //       brandIndex: widget.brandIndex,
                      //       rangeIndex: widget.rangeIndex,
                      //       category: widget.category,
                      //       brand: widget.brand,
                      //       range: widget.range,
                      //       skuCode: widget.skuData!.sKUCODE,
                      //       skuQty: qty.text,
                      //     ),
                      //   ),
                      // );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          AsianPaintColors.kPrimaryColor),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(
                              color: AsianPaintColors.buttonBorderColor),
                        ),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).add_to_quote,
                      style: TextStyle(
                        fontFamily: AsianPaintsFonts.mulishRegular,
                        fontSize: 13,
                        color: AsianPaintColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        //   body: SingleChildScrollView(
        //     dragStartBehavior: DragStartBehavior.down,
        //     scrollDirection: Axis.vertical,
        //     child: Column(
        //       children: [
        //         Container(
        //           child: Padding(
        //             padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
        //             child: Column(
        //               // mainAxisAlignment: MainAxisAlignment.end,
        //               // mainAxisSize: MainAxisSize.min,
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: <Widget>[
        //                 // Carousel(
        //                 //   skuData: widget.skuData,
        //                 // ),

        //                 Image.network((widget.skuData!.sKUIMAGE ?? '').isEmpty
        //                     ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
        //                     : widget.skuData!.sKUIMAGE!),
        //                 Padding(
        //                   padding: const EdgeInsets.fromLTRB(10, 15, 0, 0),
        //                   child: Text(
        //                     widget.skuData!.skuCatCode!,
        //                     style: TextStyle(
        //                       fontFamily: AsianPaintsFonts.mulishBold,
        //                       fontWeight: FontWeight.bold,
        //                       fontSize: 15,
        //                       color: AsianPaintColors.chooseYourAccountColor,
        //                     ),
        //                   ),
        //                 ),
        //                 Padding(
        //                   padding: const EdgeInsets.symmetric(
        //                       horizontal: 10, vertical: 10),
        //                   child: Text(
        //                     widget.skuData!.sKUDESCRIPTION!,
        //                     style: TextStyle(
        //                       fontSize: 13,
        //                       fontFamily: AsianPaintsFonts.mulishRegular,
        //                       color: AsianPaintColors.skuDescriptionColor,
        //                     ),
        //                   ),
        //                 ),
        //                 const SizedBox(
        //                   height: 20,
        //                 ),
        //                 Row(
        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   children: <Widget>[
        //                     Padding(
        //                       padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        //                       child: Text(
        //                         textAlign: TextAlign.justify,
        //                         '\u{20B9} ${widget.skuData!.sKUMRP!}',
        //                         style: TextStyle(
        //                           color: AsianPaintColors.forgotPasswordTextColor,
        //                           fontSize: 18,
        //                           fontFamily: AsianPaintsFonts.mulishBold,
        //                           fontWeight: FontWeight.bold,
        //                         ),
        //                       ),
        //                     ),
        //                     Expanded(
        //                       flex: 1,
        //                       child: Padding(
        //                         padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        //                         child: Row(
        //                           mainAxisAlignment: MainAxisAlignment.end,
        //                           children: <Widget>[
        //                             Text(
        //                               textAlign: TextAlign.end,
        //                               AppLocalizations.of(context).qty,
        //                               style: TextStyle(
        //                                 color: AsianPaintColors.kPrimaryColor,
        //                                 fontSize: 14,
        //                                 fontFamily: AsianPaintsFonts.mulishBold,
        //                                 fontWeight: FontWeight.bold,
        //                               ),
        //                             ),
        //                             Flexible(
        //                               child: Padding(
        //                                 padding:
        //                                     const EdgeInsets.fromLTRB(8, 0, 0, 0),
        //                                 child: SizedBox(
        //                                   width: 90,
        //                                   height: 40,
        //                                   child: TextFormField(
        //                                     enableInteractiveSelection: false,
        //                                     inputFormatters: <TextInputFormatter>[
        //                                       FilteringTextInputFormatter.allow(
        //                                           RegExp('[0-9]+')),
        //                                       LengthLimitingTextInputFormatter(5),
        //                                     ],
        //                                     keyboardType: const TextInputType
        //                                             .numberWithOptions(
        //                                         signed: true, decimal: true),
        //                                     controller: qty,
        //                                     textAlign: TextAlign.center,
        //                                     textAlignVertical:
        //                                         TextAlignVertical.top,
        //                                     style: TextStyle(
        //                                         fontSize: 14,
        //                                         color: AsianPaintColors
        //                                             .kPrimaryColor,
        //                                         fontFamily:
        //                                             AsianPaintsFonts.mulishBold),
        //                                     cursorColor:
        //                                         AsianPaintColors.kPrimaryColor,
        //                                     decoration: InputDecoration(
        //                                       focusedBorder: OutlineInputBorder(
        //                                         borderRadius:
        //                                             const BorderRadius.all(
        //                                                 Radius.circular(30)),
        //                                         borderSide: BorderSide(
        //                                             width: 1,
        //                                             color: AsianPaintColors
        //                                                 .kPrimaryColor),
        //                                       ),
        //                                       disabledBorder: OutlineInputBorder(
        //                                         borderRadius:
        //                                             const BorderRadius.all(
        //                                                 Radius.circular(30)),
        //                                         borderSide: BorderSide(
        //                                             width: 1,
        //                                             color: AsianPaintColors
        //                                                 .kPrimaryColor),
        //                                       ),
        //                                       enabledBorder: OutlineInputBorder(
        //                                         borderRadius:
        //                                             const BorderRadius.all(
        //                                                 Radius.circular(30)),
        //                                         borderSide: BorderSide(
        //                                             width: 1,
        //                                             color: AsianPaintColors
        //                                                 .kPrimaryColor),
        //                                       ),
        //                                       border: const OutlineInputBorder(
        //                                           borderRadius: BorderRadius.all(
        //                                               Radius.circular(30)),
        //                                           borderSide: BorderSide(
        //                                             width: 1,
        //                                           )),
        //                                       errorBorder: OutlineInputBorder(
        //                                           borderRadius:
        //                                               const BorderRadius.all(
        //                                                   Radius.circular(30)),
        //                                           borderSide: BorderSide(
        //                                               width: 1,
        //                                               color: AsianPaintColors
        //                                                   .kPrimaryColor)),
        //                                       focusedErrorBorder:
        //                                           OutlineInputBorder(
        //                                         borderRadius:
        //                                             const BorderRadius.all(
        //                                                 Radius.circular(30)),
        //                                         borderSide: BorderSide(
        //                                             width: 1,
        //                                             color: AsianPaintColors
        //                                                 .kPrimaryColor),
        //                                       ),
        //                                     ),
        //                                     onTap: () {
        //                                       if (qty.text.isEmpty) {
        //                                         qty.text = '1';
        //                                         int quantity = 0;
        //                                         FocusScope.of(context)
        //                                             .requestFocus();

        //                                         int price = 0;
        //                                         skuResponseLists = [];
        //                                         complementaryList = [];
        //                                         int singleQuantity = 0;
        //                                         int singlePrice = 0;
        //                                         if (qty.text.isNotEmpty) {
        //                                           singleQuantity =
        //                                               int.parse(qty.text);
        //                                           price = price +
        //                                               (int.parse(qty.text) *
        //                                                   int.parse(widget
        //                                                           .skuData!
        //                                                           .sKUMRP ??
        //                                                       '0'));
        //                                           singlePrice =
        //                                               int.parse(qty.text) *
        //                                                   int.parse(widget
        //                                                           .skuData!
        //                                                           .sKUMRP ??
        //                                                       '0');

        //                                           Quoteinfo quoteinfo =
        //                                               Quoteinfo();
        //                                           quoteinfo.totalqty =
        //                                               '$singleQuantity';
        //                                           quoteinfo.totalprice =
        //                                               '$singlePrice';
        //                                           // quoteInfoList
        //                                           //     .add(quoteinfo);
        //                                           if ((widget.skuData!
        //                                                       .complementary ??
        //                                                   [])
        //                                               .isNotEmpty) {
        //                                             for (int j = 0;
        //                                                 j <
        //                                                     (widget.skuData!
        //                                                                 .complementary ??
        //                                                             [])
        //                                                         .length;
        //                                                 j++) {
        //                                               COMPLEMENTARY
        //                                                   complementary =
        //                                                   COMPLEMENTARY();
        //                                               complementary
        //                                                   .cMPSRP = widget
        //                                                       .skuData!
        //                                                       .complementary?[j]
        //                                                       .cMPSRP ??
        //                                                   '';
        //                                               complementary
        //                                                   .cMPUSP = widget
        //                                                       .skuData!
        //                                                       .complementary?[j]
        //                                                       .cMPUSP ??
        //                                                   '';
        //                                               complementary.cMPMR = widget
        //                                                       .skuData!
        //                                                       .complementary?[j]
        //                                                       .cMPMR ??
        //                                                   '';
        //                                               complementary
        //                                                   .cMPDESCRIPTION = widget
        //                                                       .skuData!
        //                                                       .complementary?[j]
        //                                                       .cMPDESCRIPTION ??
        //                                                   '';
        //                                               complementary
        //                                                   .cMPDRAWING = widget
        //                                                       .skuData!
        //                                                       .complementary?[j]
        //                                                       .cMPDRAWING ??
        //                                                   '';
        //                                               complementary
        //                                                   .cMPRANGE = widget
        //                                                       .skuData!
        //                                                       .complementary?[j]
        //                                                       .cMPRANGE ??
        //                                                   '';
        //                                               complementary
        //                                                   .cMPPRODUCTCAT = widget
        //                                                       .skuData!
        //                                                       .complementary?[j]
        //                                                       .cMPPRODUCTCAT ??
        //                                                   '';
        //                                               complementary
        //                                                   .cMPSKUCODE = widget
        //                                                       .skuData!
        //                                                       .complementary?[j]
        //                                                       .cMPSKUCODE ??
        //                                                   '';
        //                                               complementary
        //                                                   .cMPBRAND = widget
        //                                                       .skuData!
        //                                                       .complementary?[j]
        //                                                       .cMPBRAND ??
        //                                                   '';
        //                                               complementary
        //                                                   .cMPSKUTYPE = widget
        //                                                       .skuData!
        //                                                       .complementary?[j]
        //                                                       .cMPSKUTYPE ??
        //                                                   '';
        //                                               complementary
        //                                                   .cMPIMAGE = widget
        //                                                       .skuData!
        //                                                       .complementary?[j]
        //                                                       .cMPIMAGE ??
        //                                                   '';
        //                                               complementary
        //                                                   .cMPCATCODE = widget
        //                                                       .skuData!
        //                                                       .complementary?[j]
        //                                                       .cMPCATCODE ??
        //                                                   '';
        //                                               complementary
        //                                                   .cMPCATEGORY = widget
        //                                                       .skuData!
        //                                                       .complementary?[j]
        //                                                       .cMPCATEGORY ??
        //                                                   '';
        //                                               complementaryList
        //                                                   .add(complementary);
        //                                             }
        //                                           }

        //                                           widget.skuData!.quantity =
        //                                               qty.text;

        //                                           widget.skuData!.totalPrice =
        //                                               int.parse(qty.text) *
        //                                                   int.parse(widget
        //                                                           .skuData!
        //                                                           .sKUMRP ??
        //                                                       '0');
        //                                           widget.skuData!
        //                                                   .totalPriceAfterDiscount =
        //                                               singlePrice;

        //                                           widget.skuData!.discount = 0;

        //                                           if (!skuResponseLists
        //                                               .contains(widget.skuData)) {
        //                                             logger("In if condition:::");
        //                                             skuResponseLists
        //                                                 .add((widget.skuData!));
        //                                           }

        //                                           if (!Journey.skuResponseLists
        //                                               .contains(widget.skuData)) {
        //                                             logger("In if condition:::");

        //                                             Journey.skuResponseLists
        //                                                 .add(widget.skuData!);
        //                                           }
        //                                         }

        //                                         // skuRequestBody.quoteinfo =
        //                                         //     quoteInfoList;

        //                                         // Journey.skuRequestBody =
        //                                         //     skuRequestBody;
        //                                         Journey.totalQuantity = quantity;
        //                                         Journey.totalPrice = price;

        //                                         _secureStorageProvider
        //                                             .saveQuoteToDisk(
        //                                                 Journey.skuResponseLists);
        //                                         _secureStorageProvider
        //                                             .saveCartDetails(
        //                                                 skuResponseLists);
        //                                         _secureStorageProvider
        //                                             .saveCategory(
        //                                                 widget.category);
        //                                         _secureStorageProvider
        //                                             .saveBrand(widget.brand);
        //                                         _secureStorageProvider
        //                                             .saveRange(widget.range);
        //                                         _secureStorageProvider
        //                                             .saveTotalPrice(
        //                                                 price.toString());

        //                                         logger('Quantity: $quantity');
        //                                         setState(
        //                                           () {
        //                                             cartCount = Journey
        //                                                 .skuResponseLists.length;
        //                                             _secureStorageProvider
        //                                                 .saveCartCount(cartCount);
        //                                             logger(
        //                                                 'Cart count: $cartCount');
        //                                             logger('Quantity: $quantity');
        //                                           },
        //                                         );
        //                                       }
        //                                     },
        //                                     onChanged: (value) {
        //                                       if (qty.text == '0') {
        //                                         qty.text = '1';
        //                                       }
        //                                       int quantity = 0;
        //                                       FocusScope.of(context)
        //                                           .requestFocus();

        //                                       int price = 0;
        //                                       skuResponseLists = [];
        //                                       complementaryList = [];
        //                                       int singleQuantity = 0;
        //                                       int singlePrice = 0;
        //                                       if (qty.text.isNotEmpty &&
        //                                           qty.text != '0') {
        //                                         singleQuantity =
        //                                             int.parse(qty.text);
        //                                         price = price +
        //                                             (int.parse(qty.text) *
        //                                                 int.parse(widget.skuData!
        //                                                         .sKUMRP ??
        //                                                     '0'));
        //                                         singlePrice =
        //                                             int.parse(qty.text) *
        //                                                 int.parse(widget.skuData!
        //                                                         .sKUMRP ??
        //                                                     '0');

        //                                         Quoteinfo quoteinfo = Quoteinfo();
        //                                         quoteinfo.totalqty =
        //                                             '$singleQuantity';
        //                                         quoteinfo.totalprice =
        //                                             '$singlePrice';
        //                                         // quoteInfoList
        //                                         //     .add(quoteinfo);
        //                                         if ((widget.skuData!
        //                                                     .complementary ??
        //                                                 [])
        //                                             .isNotEmpty) {
        //                                           for (int j = 0;
        //                                               j <
        //                                                   (widget.skuData!
        //                                                               .complementary ??
        //                                                           [])
        //                                                       .length;
        //                                               j++) {
        //                                             COMPLEMENTARY complementary =
        //                                                 COMPLEMENTARY();
        //                                             complementary.cMPSRP = widget
        //                                                     .skuData!
        //                                                     .complementary?[j]
        //                                                     .cMPSRP ??
        //                                                 '';
        //                                             complementary.cMPUSP = widget
        //                                                     .skuData!
        //                                                     .complementary?[j]
        //                                                     .cMPUSP ??
        //                                                 '';
        //                                             complementary.cMPMR = widget
        //                                                     .skuData!
        //                                                     .complementary?[j]
        //                                                     .cMPMR ??
        //                                                 '';
        //                                             complementary.cMPDESCRIPTION =
        //                                                 widget
        //                                                         .skuData!
        //                                                         .complementary?[j]
        //                                                         .cMPDESCRIPTION ??
        //                                                     '';
        //                                             complementary.cMPDRAWING =
        //                                                 widget
        //                                                         .skuData!
        //                                                         .complementary?[j]
        //                                                         .cMPDRAWING ??
        //                                                     '';
        //                                             complementary.cMPRANGE =
        //                                                 widget
        //                                                         .skuData!
        //                                                         .complementary?[j]
        //                                                         .cMPRANGE ??
        //                                                     '';
        //                                             complementary.cMPPRODUCTCAT =
        //                                                 widget
        //                                                         .skuData!
        //                                                         .complementary?[j]
        //                                                         .cMPPRODUCTCAT ??
        //                                                     '';
        //                                             complementary.cMPSKUCODE =
        //                                                 widget
        //                                                         .skuData!
        //                                                         .complementary?[j]
        //                                                         .cMPSKUCODE ??
        //                                                     '';
        //                                             complementary.cMPBRAND =
        //                                                 widget
        //                                                         .skuData!
        //                                                         .complementary?[j]
        //                                                         .cMPBRAND ??
        //                                                     '';
        //                                             complementary.cMPSKUTYPE =
        //                                                 widget
        //                                                         .skuData!
        //                                                         .complementary?[j]
        //                                                         .cMPSKUTYPE ??
        //                                                     '';
        //                                             complementary.cMPIMAGE =
        //                                                 widget
        //                                                         .skuData!
        //                                                         .complementary?[j]
        //                                                         .cMPIMAGE ??
        //                                                     '';
        //                                             complementary.cMPCATCODE =
        //                                                 widget
        //                                                         .skuData!
        //                                                         .complementary?[j]
        //                                                         .cMPCATCODE ??
        //                                                     '';
        //                                             complementary.cMPCATEGORY =
        //                                                 widget
        //                                                         .skuData!
        //                                                         .complementary?[j]
        //                                                         .cMPCATEGORY ??
        //                                                     '';
        //                                             complementaryList
        //                                                 .add(complementary);
        //                                           }
        //                                         }

        //                                         widget.skuData!.quantity =
        //                                             qty.text;

        //                                         widget.skuData!.totalPrice =
        //                                             int.parse(qty.text) *
        //                                                 int.parse(widget.skuData!
        //                                                         .sKUMRP ??
        //                                                     '0');
        //                                         widget.skuData!
        //                                                 .totalPriceAfterDiscount =
        //                                             singlePrice;

        //                                         widget.skuData!.discount = 0;

        //                                         if (!skuResponseLists
        //                                             .contains(widget.skuData)) {
        //                                           logger("In if condition:::");
        //                                           skuResponseLists
        //                                               .add((widget.skuData!));
        //                                         }

        //                                         if (!Journey.skuResponseLists
        //                                             .contains(widget.skuData)) {
        //                                           logger("In if condition:::");

        //                                           Journey.skuResponseLists
        //                                               .add(widget.skuData!);
        //                                         }
        //                                       }

        //                                       // skuRequestBody.quoteinfo =
        //                                       //     quoteInfoList;

        //                                       // Journey.skuRequestBody =
        //                                       //     skuRequestBody;
        //                                       Journey.totalQuantity = quantity;
        //                                       Journey.totalPrice = price;

        //                                       _secureStorageProvider
        //                                           .saveQuoteToDisk(
        //                                               Journey.skuResponseLists);
        //                                       _secureStorageProvider
        //                                           .saveCartDetails(
        //                                               skuResponseLists);
        //                                       _secureStorageProvider
        //                                           .saveCategory(widget.category);
        //                                       _secureStorageProvider
        //                                           .saveBrand(widget.brand);
        //                                       _secureStorageProvider
        //                                           .saveRange(widget.range);
        //                                       _secureStorageProvider
        //                                           .saveTotalPrice(
        //                                               price.toString());

        //                                       logger('Quantity: $quantity');
        //                                       setState(
        //                                         () {
        //                                           cartCount = Journey
        //                                               .skuResponseLists.length;
        //                                           _secureStorageProvider
        //                                               .saveCartCount(cartCount);
        //                                           logger(
        //                                               'Cart count: $cartCount');
        //                                           logger('Quantity: $quantity');
        //                                         },
        //                                       );
        //                                     },
        //                                   ),
        //                                 ),
        //                               ),
        //                             ),
        //                           ],
        //                         ),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //         Container(
        //           child: Align(
        //             alignment: Alignment.bottomCenter,
        //             child: Padding(
        //               padding: const EdgeInsets.symmetric(
        //                   horizontal: 20, vertical: 20),
        //               child: SizedBox(
        //                 width: double.infinity,
        //                 height: 45,
        //                 child: ElevatedButton(
        //                   onPressed: () {
        //                     List<Area> areas = [
        //                       Area(
        //                         areaname: "Shower",
        //                         areaqty: qty.text,
        //                       )
        //                     ];
        //                     String areastr = jsonEncode(areas);
        //                     int totalPrice = 0;
        //                     if (qty.text != '') {
        //                       var skuPrice = int.parse(widget.skuData!.sKUMRP!);
        //                       assert(skuPrice is int);
        //                       var skuQty = int.parse(qty.text);
        //                       assert(skuQty is int);
        //                       totalPrice = skuPrice * skuQty;
        //                     }
        //                     List<Quoteinfo> quoteInfoList = [
        //                       Quoteinfo(
        //                         area: areas,
        //                         skuid: widget.skuData!.skuCatCode!,
        //                         discount: '0',
        //                         totalqty: qty.text,
        //                         totalprice: "$totalPrice",
        //                         bundletype: "",
        //                       )
        //                     ];

        //                     Journey.qtyMap = {
        //                       widget.skuData!.skuCatCode!: qty.text
        //                     };

        //                     Journey.skuCode = widget.skuData!.sKUCODE!;
        //                     Journey.quantity = qty.text;

        //                     String quoteInfo = jsonEncode(quoteInfoList);
        //                     SkuRequestBody skuRequestBody = SkuRequestBody(
        //                       quoteinfo: quoteInfoList,
        //                       discountamount: '0',
        //                       totalpricewithgst: "$totalPrice",
        //                       quotename: "",
        //                       projectid: "",
        //                       quotetype: "",
        //                       isExist: false,
        //                       projectName: "",
        //                       contactPerson: "Sravan",
        //                       mobileNumber: "",
        //                       siteAddress: "",
        //                       noOfBathRooms: "2",
        //                     );
        //                     String skuRequest = jsonEncode(skuRequestBody);

        //                     Journey.att = [qty.text, widget.skuData!.skuCatCode!];
        //                     Journey.quantity = qty.text;
        //                     Navigator.pop(context, qty.text);
        //                     // Navigator.push(
        //                     //   context,
        //                     //   MaterialPageRoute(
        //                     //     builder: (context) => SKUList(
        //                     //       catIndex: widget.catIndex,
        //                     //       brandIndex: widget.brandIndex,
        //                     //       rangeIndex: widget.rangeIndex,
        //                     //       category: widget.category,
        //                     //       brand: widget.brand,
        //                     //       range: widget.range,
        //                     //       skuCode: widget.skuData!.sKUCODE,
        //                     //       skuQty: qty.text,
        //                     //     ),
        //                     //   ),
        //                     // );
        //                   },
        //                   style: ButtonStyle(
        //                     backgroundColor: MaterialStatePropertyAll(
        //                         AsianPaintColors.kPrimaryColor),
        //                     shape:
        //                         MaterialStateProperty.all<RoundedRectangleBorder>(
        //                       RoundedRectangleBorder(
        //                         borderRadius: BorderRadius.circular(25.0),
        //                         side: BorderSide(
        //                             color: AsianPaintColors.buttonBorderColor),
        //                       ),
        //                     ),
        //                   ),
        //                   child: Text(
        //                     AppLocalizations.of(context).add_to_quote,
        //                     style: TextStyle(
        //                       fontFamily: AsianPaintsFonts.mulishRegular,
        //                       fontSize: 13,
        //                       color: AsianPaintColors.whiteColor,
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //         )
        //       ],
        //     ),
        //   ),
      ),
    );
  }
}

class Carousel extends StatefulWidget {
  SKUData? skuData;
  Carousel({
    super.key,
    required this.skuData,
  });

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late PageController _pageController;
  late List<String> images;

  // List<String> images = [
  //   "https://5.imimg.com/data5/ZA/MM/NN/SELLER-90259661/jaquar-cp-fittings-500x500.jpg",
  //   "https://m.media-amazon.com/images/I/51zbezTwIUL.jpg",
  // ];

  int activePage = 1;

  @override
  void initState() {
    super.initState();
    images = [widget.skuData!.sKUIMAGE!];
    _pageController = PageController(viewportFraction: 1, initialPage: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.height * 0.5,
          child: PageView.builder(
              itemCount: images.length,
              pageSnapping: true,
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  activePage = page;
                });
              },
              itemBuilder: (context, pagePosition) {
                bool active = pagePosition == activePage;
                return slider(images, pagePosition, active);
              }),
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: indicators(images.length, activePage))
      ],
    );
  }
}

AnimatedContainer slider(images, pagePosition, active) {
  double margin = active ? 10 : 20;

  return AnimatedContainer(
    height: 500,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOutCubic,
    margin: EdgeInsets.all(margin),
    decoration: BoxDecoration(
      image: DecorationImage(
        fit: BoxFit.fitHeight,
        image: NetworkImage(
          images[pagePosition],
        ),
      ),
    ),
  );
}

imageAnimation(PageController animation, images, pagePosition) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, widget) {
      print(pagePosition);

      return SizedBox(
        width: 400,
        height: 500,
        child: widget,
      );
    },
    child: Container(
      margin: const EdgeInsets.all(10),
      child: Image.network((images[pagePosition] ?? '').toString().isEmpty
          ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
          : images[pagePosition]),
    ),
  );
}

List<Widget> indicators(imagesLength, currentIndex) {
  return List<Widget>.generate(imagesLength, (index) {
    return Container(
      margin: const EdgeInsets.all(3),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
          color: currentIndex == index
              ? const Color.fromRGBO(199, 132, 22, 100)
              : Colors.white,
          shape: BoxShape.circle),
    );
  });
}

class PhotoItem {
  final String image;
  final String name;
  PhotoItem(this.image, this.name);
}
