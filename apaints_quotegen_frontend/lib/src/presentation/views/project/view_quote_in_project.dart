import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/arguments.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/enums/create_existing_flip.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/flip_quote_response_model.dart';
import 'package:APaints_QGen/src/data/models/project_description_response_model.dart';
import 'package:APaints_QGen/src/data/models/sku_request_model.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/presentation/blocs/copy_quote/copy_quote_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/copy_quote/copy_quote_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/email_template/email_template_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/email_template/email_template_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/create_quote/create_quote_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/create_quote/create_quote_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/delete_sku_from_quote/delete_sku_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/delete_sku_from_quote/delete_sku_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/export_project/export_project_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/export_project/export_project_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/flip_quote/flip_quote_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/flip_quote/flip_quote_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/project_description.dart/project_description_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/project_description.dart/project_description_state.dart';
import 'package:APaints_QGen/src/presentation/views/project/create_project.dart';
import 'package:APaints_QGen/src/presentation/views/project/project_description.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/sku_list.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/view_quote.dart';
import 'package:APaints_QGen/src/presentation/widgets/app_bar.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/elevated_button.dart';
import 'package:APaints_QGen/src/presentation/widgets/pdf_cache_url.dart';
import 'package:APaints_QGen/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewQuoteInProject extends StatefulWidget {
  static const routeName = Routes.ViewQuoteScreen;
  final SKUData? skuData;
  final String? quantity;
  final int? totalPrice;
  final List<SKUData>? skuResponseList;
  final List<Projectdetails>? projectDetailsList;
  final List<String>? flipRange;
  final String? projectID;
  final String? quoteID;
  final String? discountAmount;
  final String? totalAfterGst;
  final String? projectName;
  final String? contactPerson;
  final String? mobileNumber;
  final String? siteAddress;
  final String? noOfBathrooms;
  final String? quoteName;
  final int? index;
  final bool? isFlipAvailable;

  final int catIndex, brandIndex, rangeIndex;
  final String? category, brand, range;

  const ViewQuoteInProject(
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
      this.flipRange,
      this.projectID,
      this.quoteID,
      this.totalAfterGst,
      this.discountAmount,
      this.projectName,
      this.contactPerson,
      this.mobileNumber,
      this.siteAddress,
      this.noOfBathrooms,
      this.quoteName,
      this.index,
      this.isFlipAvailable});

  @override
  State<ViewQuoteInProject> createState() => _ViewQuoteInProjectState();
}

class _ViewQuoteInProjectState extends State<ViewQuoteInProject> {
  List<TextEditingController> discountControllers = [];
  List<TextEditingController> qtyControllers = [];
  bool isFirstTime = true;
  List<String> areas = [
    'SHOWER',
    'KITCHEN_REFUGE',
    'BASIN',
    'WC',
  ];
  Map<int, int> quantities = {};
  List<String> isChecked = [];
  late Arguments arguments;
  String dropdownValue = '';

  int price = 0;

  var formKey = GlobalKey<FormState>();
  Future<void> getTotal() async {}
  List<Projectdetails>? projectDetailsList = [];

  @override
  void initState() {
    super.initState();
    // Future<ProjectDataModel?> calculate() async {

    // ProjectDataModel projectDataModel = ProjectDataModel();
    // projectDataModel.setTotalBeforeGST = totalBeforeGST;
    // projectDataModel.setTotalAfterGST = totalAfterGST;
    // projectDataModel.setTotalDiscountAmount = totalDiscountAmount;

    // return projectDataModel;
    // }
  }

  int? catIndex, brandIndex, rangeIndex;
  String? category, brand, range;
  bool? isDelete;

  @override
  Widget build(BuildContext context) {
    logger("Quote ID in widget: ${widget.quoteID}");
    bool _value = false;
    List<String> areas = [];
    Map<int, String> areaData = {};
    List<Area> areaInfo = [];
    double totalAfterGST = 0;
    double totalBeforeGST = 0;
    int totalDiscountAmount = 0;

    // late ProjectDescriptionBloc projectDescriptionBloc;

    showLoaderDialog(BuildContext context, String message) {
      AlertDialog alert = AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            Container(
                margin: const EdgeInsets.only(left: 7),
                child: Text(
                  message,
                  style: TextStyle(
                      fontSize: 12, fontFamily: AsianPaintsFonts.mulishRegular),
                )),
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

    void shareMail(BuildContext context) {
      bool isValidEmail(String email) {
        final bool emailValid = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(email);
        return emailValid;
      }

      TextEditingController mailController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: BlocConsumer<EmailTemplateBloc, EmailTemplateState>(
                  listener: (context, state) {
                    if (state is EmailTemplateLoading) {
                      showLoaderDialog(context, 'Sending mail....');
                    }
                    if (state is EmailTemplateLoaded) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      FlutterToastProvider().show(message: 'Email sent');
                    }
                  },
                  builder: (context, state) {
                    EmailTemplateBloc emailTemplateBloc =
                        context.read<EmailTemplateBloc>();
                    return SizedBox(
                      height: 200,
                      width: 250,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 18, 0, 0),
                                child: Text(
                                  "Share Quotation",
                                  style: TextStyle(
                                    fontFamily:
                                        AsianPaintsFonts.bathSansRegular,
                                    color: AsianPaintColors.buttonTextColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 18, 20, 0),
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
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: SizedBox(
                                  height: 45,
                                  width: MediaQuery.of(context).size.width,
                                  child: TextFormField(
                                    enableInteractiveSelection: false,
                                    validator: (value) {
                                      if ((value ?? '').isEmpty ||
                                          !isValidEmail(value ?? '')) {
                                        FlutterToastProvider().show(
                                            message:
                                                'Please enter a valid email id');
                                      }
                                      return value;
                                    },
                                    controller: mailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textAlign: TextAlign.start,
                                    textAlignVertical: TextAlignVertical.center,
                                    cursorColor: AsianPaintColors
                                        .createProjectLabelColor,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontFamily:
                                            AsianPaintsFonts.mulishRegular,
                                        color: AsianPaintColors
                                            .createProjectLabelColor),
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AsianPaintColors
                                                    .createProjectTextBorder)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: AsianPaintColors
                                              .createProjectTextBorder,
                                        )),
                                        filled: true,
                                        focusColor: AsianPaintColors
                                            .createProjectTextBorder,
                                        fillColor: AsianPaintColors.whiteColor,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                strokeAlign: 1,
                                                color: AsianPaintColors
                                                    .createProjectTextBorder)),
                                        labelText:
                                            'Enter email id', //AppLocalizations.of(context).user_id,
                                        labelStyle: TextStyle(
                                            fontFamily:
                                                AsianPaintsFonts.mulishMedium,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            color: AsianPaintColors
                                                .chooseYourAccountColor),
                                        floatingLabelStyle: TextStyle(
                                            color: AsianPaintColors
                                                .chooseYourAccountColor,
                                            fontSize: 12,
                                            fontFamily:
                                                AsianPaintsFonts.mulishMedium)),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
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
                                            if (mailController.text.isEmpty ||
                                                !isValidEmail(
                                                    mailController.text)) {
                                              FlutterToastProvider().show(
                                                  message:
                                                      'Please enter a valid email id');
                                            } else {
                                              Navigator.pop(context);
                                              emailTemplateBloc
                                                  .getEmailTemplateList(
                                                      projectID:
                                                          widget.projectID,
                                                      quoteID: widget.quoteID,
                                                      email:
                                                          mailController.text,
                                                      category: category,
                                                      total: totalAfterGST
                                                          .round()
                                                          .toString(),
                                                      userName:
                                                          Journey.username);
                                            }
                                          },
                                          label: Text(
                                            "Share",
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      );
    }

    void showExportPopupMenu(Offset offset) async {
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
              child: GestureDetector(
                onTap: () {
                  shareMail(context);
                },
                child: Row(
                  children: [
                    SvgPicture.asset(
                      './assets/images/share.svg',
                      height: 12,
                      width: 12,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      //width: 120,
                      child: Text(
                        "Share to other mail",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: AsianPaintsFonts.mulishRegular,
                          fontWeight: FontWeight.w400,
                          color: AsianPaintColors.skuDescriptionColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          PopupMenuItem(
              value: 2,
              child: BlocConsumer<EmailTemplateBloc, EmailTemplateState>(
                listener: (context, state) {
                  if (state is EmailTemplateLoading) {
                    showLoaderDialog(context, 'Sending mail....');
                  }
                  if (state is EmailTemplateLoaded) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    FlutterToastProvider().show(message: 'Email sent');
                  }
                },
                builder: (context, state) {
                  EmailTemplateBloc emailTemplateBloc =
                      context.read<EmailTemplateBloc>();
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      emailTemplateBloc.getEmailTemplateList(
                          projectID: widget.projectID,
                          quoteID: widget.quoteID,
                          email: Journey.email,
                          category: category,
                          total: totalAfterGST.round().toString(),
                          userName: Journey.username);
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          './assets/images/share.svg',
                          height: 12,
                          width: 12,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          //width: 120,
                          child: Text(
                            "Share to my mail",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              fontWeight: FontWeight.w400,
                              color: AsianPaintColors.skuDescriptionColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )),
          PopupMenuItem(
              value: 3,
              child: Row(
                children: [
                  SvgPicture.asset('./assets/images/excel.svg',
                      width: 15, height: 15),
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
              value: 4,
              child: BlocConsumer<ExportProjectBloc, ExportProjectState>(
                builder: (context, state) {
                  ExportProjectBloc exportProjectBloc =
                      context.read<ExportProjectBloc>();
                  return InkWell(
                    onTap: () async {
                      var appDir = (await getTemporaryDirectory()).path;
                      Directory(appDir).delete(recursive: true);
                      exportProjectBloc.getExportProject(
                          projectID: widget.projectID ?? '',
                          quoteID: widget.quoteID ?? '');
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset('./assets/images/pdf.svg',
                            width: 18, height: 18),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
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
                    showLoaderDialog(
                        context, "Quotation is preparing... Please wait...");
                  }
                  if (state is ExportProjectLoaded) {
                    Navigator.pop(context);
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (_) => PDFViewerCachedFromUrl(
                          url: exportProjectBloc
                                  .exportProjectResponseModel?.pdfurl ??
                              '',
                          name: widget.projectID ?? 'Quote',
                          allowShare: true,
                          subject: 'Bathsense by Asian Paints | $category',
                          totalPrice: totalAfterGST.toString(),
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

    void showExportPopupMenuWeb(Offset offset) async {
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
              child: GestureDetector(
                onTap: () {
                  shareMail(context);
                },
                child: Row(
                  children: [
                    SvgPicture.asset(
                      './assets/images/share.svg',
                      height: 12,
                      width: 12,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      //width: 120,
                      child: Text(
                        "Share to other mail",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: AsianPaintsFonts.mulishRegular,
                          fontWeight: FontWeight.w400,
                          color: AsianPaintColors.skuDescriptionColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          PopupMenuItem(
              value: 2,
              child: BlocConsumer<EmailTemplateBloc, EmailTemplateState>(
                listener: (context, state) {
                  if (state is EmailTemplateLoading) {
                    showLoaderDialog(context, 'Sending mail....');
                  }
                  if (state is EmailTemplateLoaded) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    FlutterToastProvider().show(message: 'Email sent');
                  }
                },
                builder: (context, state) {
                  EmailTemplateBloc emailTemplateBloc =
                      context.read<EmailTemplateBloc>();
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      emailTemplateBloc.getEmailTemplateList(
                          projectID: widget.projectID,
                          quoteID: widget.quoteID,
                          email: Journey.email,
                          category: category,
                          total: totalAfterGST.toString(),
                          userName: Journey.username);
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          './assets/images/share.svg',
                          height: 12,
                          width: 12,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          //width: 120,
                          child: Text(
                            "Share to my mail",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              fontWeight: FontWeight.w400,
                              color: AsianPaintColors.skuDescriptionColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
                      // var appDir = (await getTemporaryDirectory()).path;
                      // Directory(appDir).delete(recursive: true);
                      exportProjectBloc.getExportProject(
                          projectID: widget.projectID ?? '',
                          quoteID: widget.quoteID ?? '');
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

                  if (state is ExportProjectLoaded) {
                    downloadFile(
                        exportProjectBloc.exportProjectResponseModel?.pdfurl ??
                            "");
                  }
                },
              )),
        ],
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Responsive(
        mobile: SafeArea(
          child: Scaffold(
            backgroundColor: AsianPaintColors.appBackgroundColor,
            appBar: AppBarTemplate(
              isVisible: true,
              header: AppLocalizations.of(context).quote,
            ),
            body: BlocProvider<ProjectDescriptionBloc>(
              create: (context) => ProjectDescriptionBloc()
                ..getProjectDescription(
                    projectID: widget.projectID ?? '', quoteID: widget.quoteID),
              child: BlocConsumer<ProjectDescriptionBloc,
                  ProjectsDescriptionState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is ProjectDescriptionLoading) {
                    return const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (state is ProjectDescriptionLoaded) {
                    ProjectDescriptionBloc projectDescriptionBloc =
                        context.read<ProjectDescriptionBloc>();
                    projectDetailsList = projectDescriptionBloc
                        .getProjectDescriptionModel
                        ?.data?[0]
                        .qUOTEINFO?[0]
                        .projectdetails;
                    logger(
                        "Projects details list length: ${projectDetailsList?.length}");
                    price = 0;

                    projectDetailsList?.forEach((element) {
                      element.totalPrice =
                          '${int.parse(element.tOTALQTY ?? '0') * int.parse((element.sKUMRP ?? '0').isEmpty ? '0' : element.sKUMRP ?? '0')}';
                      double values = double.parse('${element.totalPrice}') *
                          double.parse('${element.SKUPREDISCOUNT}');
                      double discountAmount = double.parse('${values / 100}');
                      logger('Discount amount: $discountAmount');
                      // element.totalPrice =
                      //     '${int.parse(element.tOTALQTY ?? '0') * int.parse(element.sKUMRP ?? '')}';
                      element.totalPriceAfterDiscount = int.parse(
                              (element.totalPrice ?? '0').isEmpty
                                  ? '0'
                                  : (element.totalPrice) ?? '0') -
                          discountAmount.round();
                      element.discPrice = int.parse(
                              (element.totalPrice ?? '0').isEmpty
                                  ? '0'
                                  : (element.totalPrice) ?? '0') -
                          discountAmount;
                      totalDiscountAmount += ((int.parse(
                                      (element.totalPrice ?? '0').isEmpty
                                          ? '0'
                                          : element.totalPrice ?? '0') *
                                  double.parse(element.SKUPREDISCOUNT ?? '0')) /
                              100)
                          .round();
                      totalAfterGST += (element.discPrice ?? 0);
                      logger('Total after gst: $totalAfterGST');
                    });
                    totalAfterGST += ((totalAfterGST * 18) / 100).round();
                    logger('Discount Amount: $totalDiscountAmount');

                    List<String> ranges = [];
                    for (int i = 0;
                        i < (projectDetailsList ?? []).length;
                        i++) {
                      ranges.add((projectDetailsList?[i].sKURANGE ?? '').isEmpty
                          ? 'Diverters'
                          : projectDetailsList?[i].sKURANGE ?? 'Diverters');
                    }
                    // logger('Ranges: ${json.encode(ranges)}');
                    var map = {};

                    for (var x in ranges) {
                      map[x] = !map.containsKey(x) ? (1) : (map[x] + 1);
                    }
                    logger('Ranges: ${ranges}');

                    // Count occurrences of each item
                    final folded = ranges.fold({}, (acc, curr) {
                      acc[curr] = (acc[curr] ?? 0) + 1;
                      return acc;
                    });

                    // Sort the keys (your values) by its occurrences
                    final sortedKeys = folded.keys.toList()
                      ..sort((a, b) => folded[b].compareTo(folded[a]));

                    category = '';
                    brand = '';
                    range = sortedKeys.isNotEmpty ? sortedKeys.first : '';
                    for (int i = 0;
                        i < (projectDetailsList ?? []).length;
                        i++) {
                      if ((projectDetailsList)?[i].sKURANGE == range) {
                        category = projectDetailsList?[i].sKUCATEGORY ?? '';
                        brand = projectDetailsList?[i].sKUBRAND ?? '';
                      }
                    }
                    catIndex = (Journey.catagoriesData ?? []).indexWhere(
                      (element) => element.category == category,
                    );
                    brandIndex =
                        ((Journey.catagoriesData ?? [])[catIndex ?? 0].list ??
                                [])
                            .indexWhere((element) => element.brand == brand);
                    rangeIndex =
                        (((Journey.catagoriesData ?? [])[catIndex ?? 0].list ??
                                        [])[brandIndex ?? 0]
                                    .range ??
                                [])
                            .indexWhere((element) => element.skuRange == range);
                    return StatefulBuilder(builder: (context, setState) {
                      logger(
                          "Project list length in state: ${projectDetailsList?.length}");
                      if (isDelete ?? false) {
                        price = 0;
                        totalAfterGST = 0;
                        totalBeforeGST = 0;
                        totalDiscountAmount = 0;

                        projectDetailsList?.forEach((element) {
                          element.totalPrice =
                              '${int.parse(element.tOTALQTY ?? '0') * int.parse((element.sKUMRP ?? '0').isEmpty ? '0' : element.sKUMRP ?? '0')}';
                          double values =
                              double.parse('${element.totalPrice}') *
                                  double.parse('${element.SKUPREDISCOUNT}');
                          double discountAmount =
                              double.parse('${values / 100}');
                          logger('Discount amount: $discountAmount');
                          // element.totalPrice =
                          //     '${int.parse(element.tOTALQTY ?? '0') * int.parse(element.sKUMRP ?? '')}';
                          element.totalPriceAfterDiscount = int.parse(
                                  (element.totalPrice ?? '0').isEmpty
                                      ? '0'
                                      : (element.totalPrice) ?? '0') -
                              discountAmount.round();
                          element.discPrice = int.parse(
                                  (element.totalPrice ?? '0').isEmpty
                                      ? '0'
                                      : (element.totalPrice) ?? '0') -
                              discountAmount;
                          totalDiscountAmount += ((int.parse(
                                          (element.totalPrice ?? '0').isEmpty
                                              ? '0'
                                              : element.totalPrice ?? '0') *
                                      double.parse(
                                          element.SKUPREDISCOUNT ?? '0')) /
                                  100)
                              .round();
                          totalAfterGST += (element.discPrice ?? 0);
                          logger('Total after gst: $totalAfterGST');
                        });
                        totalAfterGST += ((totalAfterGST * 18) / 100).round();
                        logger('Discount Amount: $totalDiscountAmount');

                        List<String> ranges = [];
                        for (int i = 0;
                            i < (projectDetailsList ?? []).length;
                            i++) {
                          ranges.add(projectDetailsList?[i].sKURANGE ?? '');
                        }
                        // logger('Ranges: ${json.encode(ranges)}');
                        var map = {};

                        for (var x in ranges) {
                          map[x] = !map.containsKey(x) ? (1) : (map[x] + 1);
                        }
                        logger('Ranges: ${ranges}');

                        // Count occurrences of each item
                        final folded = ranges.fold({}, (acc, curr) {
                          acc[curr] = (acc[curr] ?? 0) + 1;
                          return acc;
                        });

                        // Sort the keys (your values) by its occurrences
                        final sortedKeys = folded.keys.toList()
                          ..sort((a, b) => folded[b].compareTo(folded[a]));

                        category = '';
                        brand = '';
                        range = sortedKeys.isNotEmpty ? sortedKeys.first : '';
                        for (int i = 0;
                            i < (projectDetailsList ?? []).length;
                            i++) {
                          if ((projectDetailsList)?[i].sKURANGE == range) {
                            category = projectDetailsList?[i].sKUCATEGORY ?? '';
                            brand = projectDetailsList?[i].sKUBRAND ?? '';
                          }
                        }
                        catIndex = (Journey.catagoriesData ?? []).indexWhere(
                          (element) => element.category == category,
                        );
                        brandIndex = ((Journey.catagoriesData ??
                                        [])[catIndex ?? 0]
                                    .list ??
                                [])
                            .indexWhere((element) => element.brand == brand);
                        rangeIndex = (((Journey.catagoriesData ??
                                                [])[catIndex ?? 0]
                                            .list ??
                                        [])[brandIndex ?? 0]
                                    .range ??
                                [])
                            .indexWhere((element) => element.skuRange == range);
                        isDelete = false;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
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
                                  itemCount: projectDetailsList?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    if ((projectDetailsList ?? []).isEmpty) {
                                      return const Center(
                                        child: Text('No data available'),
                                      );
                                    } else {
                                      projectDetailsList?[index].discount =
                                          int.parse((projectDetailsList?[index]
                                                          .sKUDISCOUNT ??
                                                      '0')
                                                  .isEmpty
                                              ? '0'
                                              : projectDetailsList?[index]
                                                      .sKUDISCOUNT ??
                                                  '0');

                                      projectDetailsList?[index].quantity =
                                          projectDetailsList?[index].tOTALQTY ??
                                              '0';

                                      return Card(
                                        shadowColor:
                                            AsianPaintColors.bottomTextColor,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: AsianPaintColors
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
                                          leading: SizedBox(
                                            width: 60,
                                            height: 60,
                                            child: Image.network(
                                              (projectDetailsList?[index]
                                                              .sKUIMAGE ??
                                                          '')
                                                      .isEmpty
                                                  ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
                                                  : projectDetailsList?[index]
                                                          .sKUIMAGE ??
                                                      '',
                                            ),
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
                                                    projectDetailsList?[index]
                                                            .sKUCATCODE ??
                                                        '',
                                                    style: TextStyle(
                                                        color: AsianPaintColors
                                                            .projectUserNameColor,
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishMedium,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14),
                                                  ),
                                                  BlocConsumer<DelSkuBloc,
                                                      DeleteSkuState>(
                                                    listener: (context, state) {
                                                      if (state
                                                          is DeleteSkuStateLoading) {
                                                        showLoaderDialog(
                                                            context,
                                                            'Deleting sku.. Please wait..');
                                                      }
                                                      if (state
                                                          is DeleteSkuStateLoaded) {
                                                        Navigator.pop(context);
                                                        logger('Index: $index');

                                                        setState(() {
                                                          FlutterToastProvider()
                                                              .show(
                                                                  message:
                                                                      'Sku Deleted Successfully!!');
                                                        });
                                                      }
                                                    },
                                                    builder: (context, state) {
                                                      DelSkuBloc delSkuBloc =
                                                          context.read<
                                                              DelSkuBloc>();
                                                      return InkWell(
                                                        onTap: () {
                                                          isDelete = true;
                                                          delSkuBloc.deleteSku(
                                                              quoteID: widget
                                                                  .quoteID,
                                                              skuID: projectDetailsList?[
                                                                      index]
                                                                  .qUOTESKUID);
                                                          (projectDetailsList ??
                                                                  [])
                                                              .removeWhere((element) =>
                                                                  element
                                                                      .sKUCATCODE ==
                                                                  projectDetailsList?[
                                                                          index]
                                                                      .sKUCATCODE);
                                                        },
                                                        child: Image.asset(
                                                          'assets/images/cancel.png',
                                                          width: 12,
                                                          height: 12,
                                                        ),
                                                      );
                                                    },
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      projectDetailsList?[index]
                                                              .sKUDESCRIPTION ??
                                                          '',
                                                      textAlign:
                                                          TextAlign.justify,
                                                      maxLines: 2,
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
                                              ((Journey.isExist ?? true))
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              AppLocalizations.of(
                                                                      context)
                                                                  .add_discount,
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
                                                              width: 60,
                                                              height: 25,
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child:
                                                                    TextFormField(
                                                                  enableInteractiveSelection:
                                                                      false,
                                                                  inputFormatters: <
                                                                      TextInputFormatter>[
                                                                    LengthLimitingTextInputFormatter(
                                                                        2),
                                                                    FilteringTextInputFormatter
                                                                        .allow(RegExp(
                                                                            '[0-9]+')),
                                                                  ],
                                                                  controller: TextEditingController.fromValue(TextEditingValue(
                                                                      text: (projectDetailsList?[index].sKUDISCOUNT ??
                                                                              '0')
                                                                          .toString(),
                                                                      selection: TextSelection.fromPosition(TextPosition(
                                                                          offset: (projectDetailsList?[index].sKUDISCOUNT ?? '0')
                                                                              .toString()
                                                                              .length)))),
                                                                  keyboardType: const TextInputType
                                                                          .numberWithOptions(
                                                                      signed:
                                                                          true,
                                                                      decimal:
                                                                          true),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  cursorColor:
                                                                      AsianPaintColors
                                                                          .kPrimaryColor,
                                                                  style: TextStyle(
                                                                      backgroundColor:
                                                                          AsianPaintColors
                                                                              .whiteColor,
                                                                      fontSize:
                                                                          10,
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
                                                                          10,
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
                                                                  onFieldSubmitted:
                                                                      (value) {
                                                                    if (isFirstTime &&
                                                                        value !=
                                                                            '0') {
                                                                      for (int i =
                                                                              0;
                                                                          i < projectDetailsList!.length;
                                                                          i++) {
                                                                        setState(
                                                                          () {
                                                                            projectDetailsList?[i].sKUDISCOUNT =
                                                                                value;
                                                                            projectDetailsList?[i].SKUPREDISCOUNT =
                                                                                ((((int.parse(projectDetailsList?[i].sKUDISCOUNT ?? '0') / 100) + 0.18) / 1.18) * 100).toStringAsFixed(5);
                                                                          },
                                                                        );
                                                                        value.isNotEmpty || value != "0"
                                                                            ? (projectDetailsList?[index].sKUDISCOUNT =
                                                                                value)
                                                                            : (projectDetailsList?[index].sKUDISCOUNT =
                                                                                '0');

                                                                        totalAfterGST =
                                                                            0;
                                                                        totalDiscountAmount =
                                                                            0;

                                                                        setState(
                                                                          () {
                                                                            double
                                                                                values =
                                                                                double.parse('${projectDetailsList?[i].totalPrice}') * double.parse('${projectDetailsList?[i].SKUPREDISCOUNT}');
                                                                            double
                                                                                discountAmount =
                                                                                double.parse('${values / 100}');
                                                                            projectDetailsList?[i].totalPriceAfterDiscount =
                                                                                int.parse((projectDetailsList?[i].totalPrice) ?? '0') - discountAmount.round();
                                                                            projectDetailsList?[i].discPrice =
                                                                                int.parse((projectDetailsList?[i].totalPrice) ?? '0') - discountAmount;
                                                                            logger('Total price amount: ${projectDetailsList?[i].totalPriceAfterDiscount}');
                                                                            projectDetailsList?.forEach((element) {
                                                                              totalDiscountAmount += ((int.parse(element.totalPrice ?? '0') * double.parse(element.SKUPREDISCOUNT ?? '0')) / 100).round();
                                                                              totalAfterGST += (element.discPrice ?? 0);

                                                                              logger(totalDiscountAmount);
                                                                            });
                                                                            // snapshot.data?.forEach((element) {
                                                                            //   totalDiscountAmount += ((element.totalPrice! * double.parse(element.netDiscount ?? '0')) / 100).round();
                                                                            //   totalAfterGST += element.totalPriceAfterDiscount ?? 0;

                                                                            //   logger(totalDiscountAmount);
                                                                            // });
                                                                            totalAfterGST +=
                                                                                ((totalAfterGST * 18) / 100).round();
                                                                            logger(totalAfterGST);
                                                                          },
                                                                        );
                                                                      }

                                                                      isFirstTime =
                                                                          false;
                                                                      // Journey.skuResponseLists =
                                                                      //     projectDetailsList ?? [];
                                                                      // secureStorageProvider.saveQuoteToDisk(snapshot.data ??
                                                                      //     []);
                                                                    }
                                                                  },
                                                                  onChanged:
                                                                      (value) async {
                                                                    // if (value
                                                                    //     .isEmpty) {
                                                                    //   value =
                                                                    //       '0';
                                                                    // }
                                                                    projectDetailsList?[
                                                                            index]
                                                                        .sKUDISCOUNT = value
                                                                            .isEmpty
                                                                        ? '0'
                                                                        : value;
                                                                    projectDetailsList?[
                                                                            index]
                                                                        .SKUPREDISCOUNT = ((((int.parse((projectDetailsList?[index].sKUDISCOUNT ?? '0').isEmpty ? '0' : projectDetailsList?[index].sKUDISCOUNT ?? '0') / 100) + 0.18) /
                                                                                1.18) *
                                                                            100)
                                                                        .toStringAsFixed(
                                                                            5);

                                                                    for (int i =
                                                                            0;
                                                                        i < (projectDetailsList ?? []).length;
                                                                        i++) {
                                                                      value.isNotEmpty ||
                                                                              value !=
                                                                                  "0"
                                                                          ? (projectDetailsList?[index].sKUDISCOUNT =
                                                                              value)
                                                                          : (projectDetailsList?[index].sKUDISCOUNT =
                                                                              '0');
                                                                      projectDetailsList?[index]
                                                                              .totalPrice =
                                                                          '${int.parse(projectDetailsList?[index].tOTALQTY ?? '0') * int.parse(projectDetailsList?[index].sKUMRP ?? '')}';

                                                                      totalAfterGST =
                                                                          0;
                                                                      totalDiscountAmount =
                                                                          0;
                                                                      // snapshot.data?[index].netDiscount = '${((((snapshot.data?[index].discount ?? 0) + 0.18) / 1.18) * 100).round()}';

                                                                      setState(
                                                                        () {
                                                                          double
                                                                              values =
                                                                              double.parse('${projectDetailsList?[i].totalPrice}') * double.parse('${projectDetailsList?[i].SKUPREDISCOUNT}');
                                                                          double
                                                                              discountAmount =
                                                                              double.parse('${values / 100}');
                                                                          logger(
                                                                              'Discount amount: $discountAmount');
                                                                          projectDetailsList?[i]
                                                                              .totalPriceAfterDiscount = int.parse((projectDetailsList?[i].totalPrice) ??
                                                                                  '0') -
                                                                              discountAmount.round();
                                                                          projectDetailsList?[i]
                                                                              .discPrice = int.parse((projectDetailsList?[i].totalPrice) ??
                                                                                  '0') -
                                                                              discountAmount;
                                                                          logger(
                                                                              'Total price amount: ${projectDetailsList?[i].totalPriceAfterDiscount}');
                                                                          projectDetailsList
                                                                              ?.forEach((element) {
                                                                            totalDiscountAmount +=
                                                                                ((int.parse(element.totalPrice ?? '0') * double.parse(element.SKUPREDISCOUNT ?? '0')) / 100).round();
                                                                            totalAfterGST +=
                                                                                (element.discPrice ?? 0);
                                                                          });
                                                                          totalAfterGST +=
                                                                              ((totalAfterGST * 18) / 100).round();
                                                                          logger(
                                                                              "TotalAfterGST:  $totalAfterGST");
                                                                        },
                                                                      );
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        Row(
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
                                                              // width: 45,
                                                              height: 30,
                                                              child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(
                                                                    '${double.parse(projectDetailsList?[index].SKUPREDISCOUNT ?? '0').toStringAsFixed(2)} %',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            11),
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
                                                  Row(children: [
                                                    Text(
                                                      "MRP: ",
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
                                                      ' \u{20B9} ${projectDetailsList?[index].sKUMRP ?? ''}',
                                                      textAlign:
                                                          TextAlign.justify,
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
                                                      '\u{20B9} ${projectDetailsList?[index].totalPriceAfterDiscount}',
                                                      style: TextStyle(
                                                          color: AsianPaintColors
                                                              .forgotPasswordTextColor,
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishBold,
                                                          fontWeight:
                                                              FontWeight.w600,
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
                                                    AppLocalizations.of(context)
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
                                                    width: 45,
                                                    height: 25,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: TextFormField(
                                                        enableInteractiveSelection:
                                                            false,
                                                        inputFormatters: <
                                                            TextInputFormatter>[
                                                          LengthLimitingTextInputFormatter(
                                                              3),
                                                          FilteringTextInputFormatter
                                                              .allow(RegExp(
                                                                  '[0-9]+'))
                                                        ],
                                                        controller: TextEditingController.fromValue(TextEditingValue(
                                                            text: (projectDetailsList?[
                                                                            index]
                                                                        .tOTALQTY ??
                                                                    0)
                                                                .toString(),
                                                            selection: TextSelection
                                                                .fromPosition(TextPosition(
                                                                    offset: (projectDetailsList?[index].tOTALQTY ??
                                                                            0)
                                                                        .toString()
                                                                        .length)))),
                                                        keyboardType:
                                                            const TextInputType
                                                                    .numberWithOptions(
                                                                signed: true,
                                                                decimal: true),
                                                        textAlign:
                                                            TextAlign.center,
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
                                                        onChanged: (value) {
                                                          if (value == '0') {
                                                            value = '1';
                                                          }

                                                          if (value != '0') {
                                                            projectDetailsList?[
                                                                        index]
                                                                    .tOTALQTY =
                                                                value;

                                                            for (int i = 0;
                                                                i <
                                                                    (projectDetailsList ??
                                                                            [])
                                                                        .length;
                                                                i++) {
                                                              value.isNotEmpty ||
                                                                      value !=
                                                                          "0"
                                                                  ? (projectDetailsList?[
                                                                              index]
                                                                          .tOTALQTY =
                                                                      value)
                                                                  : (projectDetailsList?[
                                                                          index]
                                                                      .tOTALQTY = '0');
                                                              projectDetailsList?[
                                                                          index]
                                                                      .totalPrice =
                                                                  '${int.parse(projectDetailsList?[index].tOTALQTY ?? '0') * int.parse(projectDetailsList?[index].sKUMRP ?? '')}';

                                                              totalAfterGST = 0;
                                                              totalDiscountAmount =
                                                                  0;
                                                              // snapshot.data?[index].netDiscount = '${((((snapshot.data?[index].discount ?? 0) + 0.18) / 1.18) * 100).round()}';

                                                              setState(
                                                                () {
                                                                  double values = double
                                                                          .parse(
                                                                              '${projectDetailsList?[i].totalPrice}') *
                                                                      double.parse(
                                                                          '${projectDetailsList?[i].SKUPREDISCOUNT}');
                                                                  double
                                                                      discountAmount =
                                                                      double.parse(
                                                                          '${values / 100}');
                                                                  logger(
                                                                      'Discount amount: $discountAmount');
                                                                  projectDetailsList?[
                                                                          i]
                                                                      .totalPriceAfterDiscount = int.parse((projectDetailsList?[i]
                                                                              .totalPrice) ??
                                                                          '0') -
                                                                      discountAmount
                                                                          .round();
                                                                  projectDetailsList?[
                                                                          i]
                                                                      .discPrice = int.parse((projectDetailsList?[i]
                                                                              .totalPrice) ??
                                                                          '0') -
                                                                      discountAmount;
                                                                  logger(
                                                                      'Total price amount: ${projectDetailsList?[i].totalPriceAfterDiscount}');
                                                                  projectDetailsList
                                                                      ?.forEach(
                                                                          (element) {
                                                                    totalDiscountAmount +=
                                                                        ((int.parse(element.totalPrice ?? '0') * double.parse(element.SKUPREDISCOUNT ?? '0')) /
                                                                                100)
                                                                            .round();
                                                                    totalAfterGST +=
                                                                        (element.discPrice ??
                                                                            0);

                                                                    logger(
                                                                        totalDiscountAmount);
                                                                  });
                                                                  totalAfterGST +=
                                                                      ((totalAfterGST * 18) /
                                                                              100)
                                                                          .round();
                                                                  logger(
                                                                      "TotalAfterGST:  $totalAfterGST");
                                                                },
                                                              );
                                                            }
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
                                              ListView.builder(
                                                itemCount:
                                                    projectDetailsList?[index]
                                                            .aREADATA
                                                            ?.length ??
                                                        0,
                                                shrinkWrap: true,
                                                padding:
                                                    const EdgeInsets.all(0),
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemExtent: 50,
                                                itemBuilder: (context, ind) {
                                                  return (projectDetailsList?[
                                                                      index]
                                                                  .aREADATA?[
                                                                      ind]
                                                                  .areaname
                                                                  ?.toUpperCase() ??
                                                              '')
                                                          .isEmpty
                                                      ? null
                                                      : Padding(
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
                                                                      projectDetailsList?[index]
                                                                              .aREADATA?[ind]
                                                                              .areaname
                                                                              ?.toUpperCase() ??
                                                                          '',
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
                                                                              20,
                                                                              0,
                                                                              0,
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
                                                                              20,
                                                                          height:
                                                                              25,
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Text(
                                                                              projectDetailsList?[index].aREADATA?[ind].areaqty ?? '',
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
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      final Map<int, String>
                                                          data =
                                                          <int, String>{};
                                                      areas = [];
                                                      areaInfo = [];

                                                      // Dialog dialog =
                                                      showDialog(
                                                        context: context,
                                                        builder: (dcontext) {
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
                                                                    offset:
                                                                        Offset(
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
                                                                        child: Image
                                                                            .asset(
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
                                                                        color: AsianPaintColors
                                                                            .buttonTextColor,
                                                                        fontFamily:
                                                                            AsianPaintsFonts.bathSansRegular,
                                                                        fontSize:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
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
                                                                          children: <
                                                                              InlineSpan>[
                                                                            TextSpan(
                                                                              text: '${projectDetailsList?[index].tOTALQTY ?? 0}',
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
                                                                        color: AsianPaintColors
                                                                            .quantityBorder,
                                                                        endIndent:
                                                                            5,
                                                                        indent:
                                                                            5,
                                                                      ),
                                                                      itemCount:
                                                                          projectDetailsList?[index].aREADATA?.length ??
                                                                              0,
                                                                      shrinkWrap:
                                                                          true,
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              0),
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
                                                                                      projectDetailsList?[index].aREADATA?[ind].areaname ?? '',
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
                                                                                          controller: controller,
                                                                                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                                                                          textAlign: TextAlign.center,
                                                                                          style: TextStyle(backgroundColor: AsianPaintColors.whiteColor, fontSize: 10, fontFamily: AsianPaintsFonts.mulishRegular, color: AsianPaintColors.kPrimaryColor),
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
                                                                                              if (_value) {
                                                                                                data[ind] = controller.text;
                                                                                                logger(data);
                                                                                                areas.add(projectDetailsList?[index].aREADATA?[ind].areaname ?? '');
                                                                                              } else {
                                                                                                data.removeWhere((key, value) => key == ind);
                                                                                                areas.remove(projectDetailsList?[index].aREADATA?[ind].areaname ?? '');

                                                                                                logger(data);
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
                                                                                    if (!_value) {
                                                                                      data[ind] = controller.text;

                                                                                      // areas.add(widget.skuResponseList?[index].aREAINFO?[ind] ?? '');

                                                                                      logger(data);
                                                                                    } else {
                                                                                      data.removeWhere((key, value) => key == ind);
                                                                                      // areas.remove(widget.skuResponseList?[index].aREAINFO?[ind] ?? '');

                                                                                      logger(data);
                                                                                    }
                                                                                    _value = value ?? true;
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
                                                                        height:
                                                                            40,
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.5,
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            // widget
                                                                            //     .skuResponseList?[
                                                                            //         index]
                                                                            //     .aREAINFO = [];

                                                                            int quantity =
                                                                                0;
                                                                            if (data.values.isNotEmpty) {
                                                                              for (int i = 0; i < data.values.length; i++) {
                                                                                if (data.values.elementAt(i).isNotEmpty) {
                                                                                  Area area = Area();
                                                                                  area.areaname = projectDetailsList?[index].aREADATA?[i].areaname ?? '';
                                                                                  area.areaqty = data.values.elementAt(i);
                                                                                  areaInfo.add(area);
                                                                                  quantity += int.parse(data.values.elementAt(i));
                                                                                  logger(quantity);
                                                                                }
                                                                              }

                                                                              if (quantity > int.parse(projectDetailsList?[index].tOTALQTY ?? '')) {
                                                                                FlutterToastProvider().show(message: 'Entered quantity is greater than total quantity');
                                                                              } else {
                                                                                logger('Area info: ${areaInfo.length}');
                                                                                logger('Length: ${projectDetailsList?[index].aREADATA?.length}');
                                                                                Navigator.pop(context, Arguments(data));
                                                                                setState(
                                                                                  () {
                                                                                    // widget.skuResponseList?[index].aREAINFO?.add(areas[i]);
                                                                                  },
                                                                                );
                                                                              }
                                                                            } else {
                                                                              logger('In else');
                                                                              Navigator.pop(dcontext);
                                                                            }
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(35.0),
                                                                            ),
                                                                            backgroundColor:
                                                                                AsianPaintColors.buttonColor,
                                                                            shadowColor:
                                                                                AsianPaintColors.buttonBorderColor,
                                                                            textStyle:
                                                                                TextStyle(
                                                                              color: AsianPaintColors.buttonTextColor,
                                                                              fontSize: 10,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontFamily: AsianPaintsFonts.mulishRegular,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            'Save',
                                                                            style:
                                                                                TextStyle(
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
                                                      ).then((value) {
                                                        setState(
                                                          () {
                                                            arguments = value;
                                                            areaData = arguments
                                                                .dataMap;
                                                            logger(
                                                                'Selected map: ${arguments.dataMap}');
                                                          },
                                                        );
                                                      });
                                                    },
                                                    child: Visibility(
                                                      visible: (projectDetailsList?[
                                                                          index]
                                                                      .aREADATA
                                                                      ?.length ??
                                                                  0) >
                                                              1
                                                          ? false
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
                            Container(
                              padding: const EdgeInsets.fromLTRB(15, 0, 0, 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    height: 45,
                                    width: 160,
                                    child: GestureDetector(
                                      onTapDown: (TapDownDetails details) {
                                        showPopupMenu(details.globalPosition);
                                      },
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(35.0),
                                              side: BorderSide(
                                                  width: 1,
                                                  color: AsianPaintColors
                                                      .kPrimaryColor)),
                                          backgroundColor:
                                              AsianPaintColors.whiteColor,
                                          shadowColor: AsianPaintColors
                                              .buttonBorderColor,
                                          textStyle: TextStyle(
                                            color:
                                                AsianPaintColors.kPrimaryColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            fontFamily:
                                                AsianPaintsFonts.mulishBold,
                                          ),
                                        ),
                                        onPressed: () {},
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 0, 0, 0),
                                              child: Text(
                                                'Additional Options',
                                                style: TextStyle(
                                                  fontFamily: AsianPaintsFonts
                                                      .mulishBold,
                                                  color: AsianPaintColors
                                                      .kPrimaryColor,
                                                  //color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 5, 0),
                                              child: SvgPicture.asset(
                                                'assets/images/drop_down.svg',
                                                width: 6,
                                                height: 6,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 45,
                                    width: 150,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (Journey
                                            .skuResponseLists.isNotEmpty) {
                                          showCreateExistingDialogAddSku(
                                              context, 'Mobile');
                                        } else {
                                          // Journey.skuResponseLists = [];
                                          List<String> sampleArea = <String>[
                                            'Showers'
                                          ];

                                          List<SKUData> skuDataList = [];
                                          List<Area> areaInfo = [];
                                          List<String> areas = [];
                                          for (int i = 0;
                                              i < projectDetailsList!.length;
                                              i++) {
                                            SKUData skuData = SKUData();
                                            skuData.sKURANGE =
                                                projectDetailsList?[i]
                                                        .sKURANGE ??
                                                    '';
                                            skuData.sKUIMAGE =
                                                projectDetailsList?[i].sKUIMAGE;
                                            skuData.sKUCATEGORY =
                                                projectDetailsList?[i]
                                                        .sKUCATEGORY ??
                                                    '';
                                            skuData.sKUUSP =
                                                projectDetailsList?[i].sKUUSP ??
                                                    '';
                                            skuData.sKUPRODUCTCAT =
                                                projectDetailsList?[i]
                                                        .sKUPRODUCTCAT ??
                                                    '';
                                            skuData.sKUDESCRIPTION =
                                                projectDetailsList?[i]
                                                        .sKUDESCRIPTION ??
                                                    '';
                                            skuData.complementary = [];
                                            skuData.sKUMRP =
                                                projectDetailsList?[i].sKUMRP ??
                                                    '';
                                            skuData.sKUCODE =
                                                projectDetailsList?[i]
                                                        .sKUCODE ??
                                                    '';
                                            skuData.sKUSRP =
                                                projectDetailsList?[i].sKUSRP ??
                                                    '';
                                            skuData.sKUDRAWING =
                                                projectDetailsList?[i]
                                                        .sKUDRAWING ??
                                                    '';
                                            skuData.sKUBRAND =
                                                projectDetailsList?[i]
                                                        .sKUBRAND ??
                                                    '';

                                            skuData.skuCatCode =
                                                projectDetailsList?[i]
                                                        .sKUCATCODE ??
                                                    '';
                                            skuData.sKUTYPE =
                                                projectDetailsList?[i]
                                                        .sKUTYPE ??
                                                    '';
                                            skuData.discount = int.parse(
                                                projectDetailsList?[i]
                                                        .sKUDISCOUNT ??
                                                    '');
                                            skuData.netDiscount =
                                                projectDetailsList?[i]
                                                    .SKUPREDISCOUNT;
                                            skuData.quantity =
                                                projectDetailsList?[i]
                                                        .tOTALQTY ??
                                                    '';
                                            skuData.totalPrice = int.parse(
                                                projectDetailsList?[i]
                                                        .tOTALPRICE ??
                                                    '0');
                                            skuData.totalPriceAfterDiscount =
                                                int.parse(projectDetailsList?[i]
                                                        .tOTALPRICE ??
                                                    '0');

                                            areas = [];
                                            areas.add('SHOWER_AREA');
                                            skuData.aREAINFO = areas;
                                            areaInfo = [];

                                            for (Area element
                                                in (projectDetailsList?[i]
                                                        .aREADATA ??
                                                    [])) {
                                              logger(
                                                  'In Project Details: ${json.encode(projectDetailsList?[i].aREADATA)}');
                                              areaInfo.add(Area(
                                                  areaname: element.areaname,
                                                  areaqty: element.areaqty));

                                              logger(
                                                  'In Project Details: ${json.encode(skuData.aREAINFO)}');
                                            }
                                            skuData.areaInfo = areaInfo;
                                            logger(
                                                'In Project Details: ${json.encode(skuData.aREAINFO)}');

                                            skuDataList.add(skuData);
                                            price += skuData
                                                    .totalPriceAfterDiscount ??
                                                0;
                                            Journey.skuResponseLists
                                                .add(skuData);
                                          }
                                          SecureStorageProvider
                                              secureStorageProvider =
                                              getSingleton<
                                                  SecureStorageProvider>();
                                          logger(
                                              'Journey length in add sku: ${Journey.skuResponseLists.length}');
                                          secureStorageProvider.saveQuoteToDisk(
                                              Journey.skuResponseLists);
                                          secureStorageProvider
                                              .saveTotalPrice(price.toString());
                                          setState(
                                            () {
                                              int cartCount = Journey
                                                  .skuResponseLists.length;
                                              secureStorageProvider
                                                  .saveCartCount(cartCount);
                                              secureStorageProvider
                                                  .saveProjectID(
                                                      widget.projectID);
                                              logger('Cart count: $cartCount');
                                            },
                                          );

                                          Journey.fromFlip = true;

                                          Journey.quoteName =
                                              widget.quoteName ?? '';
                                          Journey.quoteID =
                                              widget.quoteID ?? '';
                                          Journey.projectID = widget.projectID;

                                          Journey.selectedIndex = 0;
                                          // Journey.skuResponseLists = snapshot.data ?? [];
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
                                          color: AsianPaintColors.whiteColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily:
                                              AsianPaintsFonts.mulishBold,
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context).add_sku,
                                        style: TextStyle(
                                          fontFamily:
                                              AsianPaintsFonts.mulishBold,
                                          color: AsianPaintColors.whiteColor,
                                          //color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            BottomSheet(
                              backgroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: AsianPaintColors.bottomTextColor),
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
                                          visible: Journey.isExist ?? true,
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
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)
                                                    .discount_amount,
                                                style: TextStyle(
                                                  color: AsianPaintColors
                                                      .chooseYourAccountColor,
                                                  fontFamily: AsianPaintsFonts
                                                      .mulishRegular,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                '\u{20B9} $totalDiscountAmount',
                                                style: TextStyle(
                                                  fontFamily: AsianPaintsFonts
                                                      .mulishRegular,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)
                                                  .total_amount_including_gst,
                                              style: TextStyle(
                                                color: AsianPaintColors
                                                    .chooseYourAccountColor,
                                                fontFamily:
                                                    AsianPaintsFonts.mulishBold,
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              '\u{20B9} ${totalAfterGST.round()}',
                                              style: TextStyle(
                                                fontFamily:
                                                    AsianPaintsFonts.mulishBold,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: AsianPaintColors
                                                    .forgotPasswordTextColor,
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            BlocConsumer<CreateQuoteBloc,
                                                CreateQuoteState>(
                                              listener: (context, state) {
                                                if (state
                                                    is CreateQuoteLoading) {
                                                  showLoaderDialog(context,
                                                      "Updating Quote, Please wait...");
                                                }
                                                if (state
                                                    is CreateQuoteLoaded) {
                                                  Navigator.pop(context);
                                                  // FlutterToastProvider().show(
                                                  //     message:
                                                  //         'Quote Update Scusseffully!!!');
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProjectDescription(
                                                        projectID:
                                                            widget.projectID,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              builder: (context, state) {
                                                return SizedBox(
                                                  height: 45,
                                                  width: 200,
                                                  child: APElevatedButton(
                                                    onPressed: () async {
                                                      CreateQuoteBloc
                                                          createProjectBloc =
                                                          context.read<
                                                              CreateQuoteBloc>();

                                                      List<Quoteinfo>
                                                          quoteInfoList = [];

                                                      for (int i = 0;
                                                          i <
                                                              (projectDetailsList ??
                                                                      [])
                                                                  .length;
                                                          i++) {
                                                        // List<String> areaStr =
                                                        List<Area> areaInfo =
                                                            [];
                                                        List<Area> areas =
                                                            projectDetailsList?[
                                                                        i]
                                                                    .aREADATA ??
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
                                                            projectDetailsList?[
                                                                    i]
                                                                .sKUCATCODE;
                                                        quoteinfo.discount =
                                                            projectDetailsList?[
                                                                    i]
                                                                .sKUDISCOUNT
                                                                .toString();
                                                        quoteinfo.netDiscount =
                                                            projectDetailsList?[
                                                                    i]
                                                                .SKUPREDISCOUNT;
                                                        quoteinfo.totalqty =
                                                            projectDetailsList?[
                                                                    i]
                                                                .tOTALQTY
                                                                .toString();
                                                        quoteinfo.area =
                                                            areaInfo;
                                                        quoteinfo.totalprice =
                                                            projectDetailsList?[
                                                                    i]
                                                                .totalPriceAfterDiscount
                                                                .toString();
                                                        quoteinfo.bundletype =
                                                            '';
                                                        quoteinfo.netDiscount =
                                                            projectDetailsList?[
                                                                        i]
                                                                    .SKUPREDISCOUNT ??
                                                                "0";
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
                                                              widget.quoteName,
                                                          projectID:
                                                              widget.projectID,
                                                          quoteType: "",
                                                          isExist: true,
                                                          quoteID:
                                                              projectDetailsList?[
                                                                      0]
                                                                  .qUOTEID,
                                                          projectName: widget
                                                              .projectName,
                                                          contactPerson: widget
                                                              .contactPerson,
                                                          mobileNumber: widget
                                                              .mobileNumber,
                                                          siteAddress: widget
                                                              .siteAddress,
                                                          noOfBathrooms: widget
                                                              .noOfBathrooms,
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
                                                            'Update Quote',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AsianPaintsFonts
                                                                      .mulishBold,
                                                              color:
                                                                  AsianPaintColors
                                                                      .whiteColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                  ),
                                                );
                                              },
                                            ),
                                            Center(
                                              child: SizedBox(
                                                height: 45,
                                                width: 160,
                                                child: GestureDetector(
                                                  onTapDown:
                                                      (TapDownDetails details) {
                                                    showExportPopupMenu(
                                                        details.globalPosition);
                                                  },
                                                  child: ElevatedButton(
                                                    onPressed: () async {},
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      35.0),
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: AsianPaintColors
                                                                  .kPrimaryColor)),
                                                      backgroundColor:
                                                          AsianPaintColors
                                                              .whiteColor,
                                                      shadowColor:
                                                          AsianPaintColors
                                                              .buttonBorderColor,
                                                      textStyle: TextStyle(
                                                        color: AsianPaintColors
                                                            .kPrimaryColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishBold,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Flexible(
                                                            flex: 1,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      20,
                                                                      0,
                                                                      0,
                                                                      0),
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topCenter,
                                                                child: Text(
                                                                  'Export',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AsianPaintsFonts
                                                                            .mulishBold,
                                                                    color: AsianPaintColors
                                                                        .kPrimaryColor,
                                                                    //color: Colors.white,
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    0,
                                                                    0,
                                                                    25,
                                                                    0),
                                                            child: SvgPicture
                                                                .asset(
                                                              'assets/images/drop_down.svg',
                                                              width: 6,
                                                              height: 6,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    });
                  }
                  return const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),
            // bottomSheet:
          ),
        ),
        desktop: BlocProvider<ProjectDescriptionBloc>(
          create: (context) => ProjectDescriptionBloc()
            ..getProjectDescription(
                projectID: widget.projectID ?? 'PRJ1', quoteID: widget.quoteID),
          child: BlocConsumer<ProjectDescriptionBloc, ProjectsDescriptionState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is ProjectDescriptionLoaded) {
                ProjectDescriptionBloc projectDescriptionBloc =
                    context.read<ProjectDescriptionBloc>();
                projectDetailsList = projectDescriptionBloc
                    .getProjectDescriptionModel
                    ?.data?[0]
                    .qUOTEINFO?[0]
                    .projectdetails;
                logger('Project details list: ${projectDetailsList?.length}');
                projectDetailsList?.forEach((element) {
                  element.totalPrice =
                      '${int.parse(element.tOTALQTY ?? '0') * int.parse((element.sKUMRP ?? '0').isEmpty ? '0' : element.sKUMRP ?? '0')}';
                  double values = double.parse('${element.totalPrice}') *
                      double.parse('${element.SKUPREDISCOUNT}');
                  double discountAmount = double.parse('${values / 100}');
                  logger('Discount amount: $discountAmount');

                  element.totalPriceAfterDiscount = int.parse(
                          (element.totalPrice ?? '0').isEmpty
                              ? '0'
                              : (element.totalPrice) ?? '0') -
                      discountAmount.round();
                  element.discPrice = int.parse(
                          (element.totalPrice ?? '0').isEmpty
                              ? '0'
                              : (element.totalPrice) ?? '0') -
                      discountAmount;
                  totalDiscountAmount += ((int.parse(
                                  (element.totalPrice ?? '0').isEmpty
                                      ? '0'
                                      : element.totalPrice ?? '0') *
                              double.parse(element.SKUPREDISCOUNT ?? '0')) /
                          100)
                      .round();
                  totalAfterGST += (element.discPrice ?? 0);
                  logger('Total after gst: $totalAfterGST');
                });
                totalBeforeGST = totalAfterGST.roundToDouble();
                totalAfterGST += ((totalAfterGST * 18) / 100).round();
                logger('Discount Amount: $totalDiscountAmount');
                List<String> ranges = [];
                for (int i = 0; i < (projectDetailsList ?? []).length; i++) {
                  ranges.add(projectDetailsList?[i].sKURANGE ?? '');
                }
                // logger('Ranges: ${json.encode(ranges)}');
                var map = {};

                for (var x in ranges) {
                  map[x] = !map.containsKey(x) ? (1) : (map[x] + 1);
                }
                logger('Ranges: ${ranges}');

                // Count occurrences of each item
                final folded = ranges.fold({}, (acc, curr) {
                  acc[curr] = (acc[curr] ?? 0) + 1;
                  return acc;
                });

                // Sort the keys (your values) by its occurrences
                final sortedKeys = folded.keys.toList()
                  ..sort((a, b) => folded[b].compareTo(folded[a]));

                category = '';
                brand = '';
                range = sortedKeys.first;
                for (int i = 0; i < (projectDetailsList ?? []).length; i++) {
                  if ((projectDetailsList)?[i].sKURANGE ==
                      map.keys.toList().first) {
                    category = projectDetailsList?[i].sKUCATEGORY ?? '';
                    brand = projectDetailsList?[i].sKUBRAND ?? '';
                  }
                }
                catIndex = (Journey.catagoriesData ?? []).indexWhere(
                  (element) => element.category == category,
                );
                brandIndex =
                    ((Journey.catagoriesData ?? [])[catIndex ?? 0].list ?? [])
                        .indexWhere((element) => element.brand == brand);
                rangeIndex =
                    (((Journey.catagoriesData ?? [])[catIndex ?? 0].list ??
                                    [])[brandIndex ?? 0]
                                .range ??
                            [])
                        .indexWhere((element) => element.skuRange == range);
                logger('Category $category, Brand $brand, Range $range');

                logger('Item List size: ${projectDetailsList?.length}');
                return StatefulBuilder(
                  builder: (context, setState) {
                    logger("Response Size: $totalBeforeGST");

                    return Scaffold(
                        backgroundColor: AsianPaintColors.appBackgroundColor,
                        appBar: AppBarTemplate(
                          isVisible: true,
                          header: AppLocalizations.of(context).sku,
                        ),
                        body: SingleChildScrollView(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.only(left: 0, top: 50),
                                    width: 600,
                                    height:
                                        MediaQuery.of(context).size.height / 8,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Quote",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AsianPaintsFonts
                                                .bathSansRegular,
                                            color: AsianPaintColors
                                                .projectUserNameColor,
                                            fontSize: 35,
                                          ),
                                        ),
                                        BlocConsumer<CreateQuoteBloc,
                                            CreateQuoteState>(
                                          listener: (context, state) {
                                            if (state is CreateQuoteLoading) {
                                              showLoaderDialog(context,
                                                  "Updating Quote, Please wait...");
                                            }
                                            if (state is CreateQuoteLoaded) {
                                              Navigator.pop(context);
                                              // FlutterToastProvider().show(
                                              //     message:
                                              //         'Quote Update Scusseffully!!!');
                                              // Navigator.pop(context);
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) =>
                                              //         ProjectDescription(
                                              //       projectID: widget.projectID,
                                              //     ),
                                              //   ),
                                              // );
                                            }
                                          },
                                          builder: (context, state) {
                                            return SizedBox(
                                              height: 30,
                                              width: 180,
                                              child: APElevatedButton(
                                                onPressed: () async {
                                                  CreateQuoteBloc
                                                      createProjectBloc =
                                                      context.read<
                                                          CreateQuoteBloc>();

                                                  List<Quoteinfo>
                                                      quoteInfoList = [];

                                                  for (int i = 0;
                                                      i <
                                                          (projectDetailsList ??
                                                                  [])
                                                              .length;
                                                      i++) {
                                                    // List<String> areaStr =
                                                    List<Area> areaInfo = [];
                                                    List<Area> areas =
                                                        projectDetailsList?[i]
                                                                .aREADATA ??
                                                            [];
                                                    for (int j = 0;
                                                        j < areas.length;
                                                        j++) {
                                                      Area area = Area();
                                                      area.areaname =
                                                          areas[j].areaname ??
                                                              '';
                                                      area.areaqty =
                                                          areas[j].areaqty ??
                                                              '';
                                                      areaInfo.add(area);
                                                    }
                                                    Quoteinfo quoteinfo =
                                                        Quoteinfo();
                                                    quoteinfo.skuid =
                                                        projectDetailsList?[i]
                                                            .sKUCATCODE;
                                                    quoteinfo.discount =
                                                        projectDetailsList?[i]
                                                            .sKUDISCOUNT
                                                            .toString();
                                                    quoteinfo.netDiscount =
                                                        projectDetailsList?[i]
                                                            .SKUPREDISCOUNT;
                                                    quoteinfo.totalqty =
                                                        projectDetailsList?[i]
                                                            .tOTALQTY
                                                            .toString();
                                                    quoteinfo.area = areaInfo;
                                                    quoteinfo.totalprice =
                                                        projectDetailsList?[i]
                                                            .totalPriceAfterDiscount
                                                            .toString();
                                                    quoteinfo.bundletype = '';
                                                    quoteinfo.netDiscount =
                                                        projectDetailsList?[i]
                                                                .SKUPREDISCOUNT ??
                                                            "0";
                                                    quoteInfoList
                                                        .add(quoteinfo);
                                                  }

                                                  if (quoteInfoList
                                                      .isNotEmpty) {
                                                    createProjectBloc
                                                        .createQuote(
                                                      quoteInfoList:
                                                          quoteInfoList,
                                                      category: widget.category,
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
                                                          widget.quoteName,
                                                      projectID:
                                                          widget.projectID,
                                                      quoteType: "",
                                                      isExist: true,
                                                      quoteID:
                                                          projectDetailsList?[0]
                                                              .qUOTEID,
                                                      projectName:
                                                          widget.projectName,
                                                      contactPerson:
                                                          widget.contactPerson,
                                                      mobileNumber:
                                                          widget.mobileNumber,
                                                      siteAddress:
                                                          widget.siteAddress,
                                                      noOfBathrooms:
                                                          widget.noOfBathrooms,
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
                                                        'Update Quote',
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
                                              ),
                                            );
                                          },
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              height: 30,
                                              width: 180,
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 0, 10, 0),
                                              child: GestureDetector(
                                                onTapDown:
                                                    (TapDownDetails details) {
                                                  showPopupMenuWeb(
                                                      details.globalPosition);
                                                },
                                                child: ElevatedButton(
                                                  onPressed: () async {},
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(35.0),
                                                        side: BorderSide(
                                                            width: 1,
                                                            color: AsianPaintColors
                                                                .kPrimaryColor)),
                                                    backgroundColor:
                                                        AsianPaintColors
                                                            .whiteColor,
                                                    shadowColor:
                                                        AsianPaintColors
                                                            .buttonBorderColor,
                                                    textStyle: TextStyle(
                                                      color: AsianPaintColors
                                                          .kPrimaryColor,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishBold,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                5, 0, 0, 0),
                                                        child: Text(
                                                          'Additional Options',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AsianPaintsFonts
                                                                    .mulishBold,
                                                            color: AsianPaintColors
                                                                .kPrimaryColor,
                                                            //color: Colors.white,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 0, 5, 0),
                                                        child: SvgPicture.asset(
                                                          'assets/images/drop_down.svg',
                                                          width: 6,
                                                          height: 6,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30,
                                              width: 120,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  if (Journey.skuResponseLists
                                                      .isNotEmpty) {
                                                    showCreateExistingDialogAddSku(
                                                        context, 'Web');
                                                  } else {
                                                    // Journey.skuResponseLists = [];
                                                    List<String> sampleArea =
                                                        <String>['Showers'];

                                                    List<SKUData> skuDataList =
                                                        [];
                                                    List<Area> areaInfo = [];
                                                    List<String> areas = [];
                                                    for (int i = 0;
                                                        i <
                                                            projectDetailsList!
                                                                .length;
                                                        i++) {
                                                      SKUData skuData =
                                                          SKUData();
                                                      skuData.sKURANGE =
                                                          projectDetailsList?[i]
                                                                  .sKURANGE ??
                                                              '';
                                                      skuData.sKUIMAGE =
                                                          projectDetailsList?[i]
                                                              .sKUIMAGE;
                                                      skuData.sKUCATEGORY =
                                                          projectDetailsList?[i]
                                                                  .sKUCATEGORY ??
                                                              '';
                                                      skuData.sKUUSP =
                                                          projectDetailsList?[i]
                                                                  .sKUUSP ??
                                                              '';
                                                      skuData.sKUPRODUCTCAT =
                                                          projectDetailsList?[i]
                                                                  .sKUPRODUCTCAT ??
                                                              '';
                                                      skuData.sKUDESCRIPTION =
                                                          projectDetailsList?[i]
                                                                  .sKUDESCRIPTION ??
                                                              '';
                                                      skuData.complementary =
                                                          [];
                                                      skuData.sKUMRP =
                                                          projectDetailsList?[i]
                                                                  .sKUMRP ??
                                                              '';
                                                      skuData.sKUCODE =
                                                          projectDetailsList?[i]
                                                                  .sKUCODE ??
                                                              '';
                                                      skuData.sKUSRP =
                                                          projectDetailsList?[i]
                                                                  .sKUSRP ??
                                                              '';
                                                      skuData.sKUDRAWING =
                                                          projectDetailsList?[i]
                                                                  .sKUDRAWING ??
                                                              '';
                                                      skuData.sKUBRAND =
                                                          projectDetailsList?[i]
                                                                  .sKUBRAND ??
                                                              '';

                                                      skuData.skuCatCode =
                                                          projectDetailsList?[i]
                                                                  .sKUCATCODE ??
                                                              '';
                                                      skuData.sKUTYPE =
                                                          projectDetailsList?[i]
                                                                  .sKUTYPE ??
                                                              '';
                                                      skuData.discount = int.parse(
                                                          projectDetailsList?[i]
                                                                  .sKUDISCOUNT ??
                                                              '');
                                                      skuData.netDiscount =
                                                          projectDetailsList?[i]
                                                              .SKUPREDISCOUNT;
                                                      skuData.quantity =
                                                          projectDetailsList?[i]
                                                                  .tOTALQTY ??
                                                              '';
                                                      skuData.totalPrice = int.parse(
                                                          projectDetailsList?[i]
                                                                  .tOTALPRICE ??
                                                              '0');
                                                      skuData.totalPriceAfterDiscount =
                                                          int.parse(
                                                              projectDetailsList?[
                                                                          i]
                                                                      .tOTALPRICE ??
                                                                  '0');

                                                      areas = [];
                                                      areas.add('SHOWER_AREA');
                                                      skuData.aREAINFO = areas;
                                                      areaInfo = [];

                                                      for (Area element
                                                          in (projectDetailsList?[
                                                                      i]
                                                                  .aREADATA ??
                                                              [])) {
                                                        logger(
                                                            'In Project Details: ${json.encode(projectDetailsList?[i].aREADATA)}');
                                                        areaInfo.add(Area(
                                                            areaname: element
                                                                .areaname,
                                                            areaqty: element
                                                                .areaqty));

                                                        logger(
                                                            'In Project Details: ${json.encode(skuData.aREAINFO)}');
                                                      }
                                                      skuData.areaInfo =
                                                          areaInfo;
                                                      logger(
                                                          'In Project Details: ${json.encode(skuData.aREAINFO)}');

                                                      // skuDataList.add(skuData);
                                                      skuDataList.add(skuData);
                                                      Journey.skuResponseLists
                                                          .add(skuData);
                                                      price += skuData
                                                              .totalPriceAfterDiscount ??
                                                          0;
                                                    }
                                                    SecureStorageProvider
                                                        secureStorageProvider =
                                                        getSingleton<
                                                            SecureStorageProvider>();

                                                    secureStorageProvider
                                                        .saveQuoteToDisk(Journey
                                                            .skuResponseLists);
                                                    secureStorageProvider
                                                        .saveTotalPrice(
                                                            price.toString());
                                                    setState(
                                                      () {
                                                        int cartCount = Journey
                                                            .skuResponseLists
                                                            .length;
                                                        secureStorageProvider
                                                            .saveCartCount(
                                                                cartCount);
                                                        secureStorageProvider
                                                            .saveProjectID(
                                                                widget
                                                                    .projectID);
                                                        logger(
                                                            'Cart count: $cartCount');
                                                      },
                                                    );

                                                    Journey.fromFlip = true;

                                                    Journey.quoteName =
                                                        widget.quoteName ?? '';
                                                    Journey.quoteID =
                                                        widget.quoteID ?? '';
                                                    Journey.projectID =
                                                        widget.projectID;

                                                    Journey.selectedIndex = 0;
                                                    // Journey.skuResponseLists = snapshot.data ?? [];
                                                    logger(
                                                        'Category $category, Brand $brand, Range $range');

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            SKUList(
                                                          brandIndex:
                                                              brandIndex ?? 0,
                                                          catIndex:
                                                              catIndex ?? 0,
                                                          brand: brand,
                                                          category: category,
                                                          range: range,
                                                          rangeIndex:
                                                              rangeIndex ?? 0,
                                                        ),
                                                      ),
                                                    );
                                                  }
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
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishRegular,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Add SKU',
                                                  //AppLocalizations.of(context).add_sku,
                                                  style: TextStyle(
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishBold,
                                                    color: AsianPaintColors
                                                        .whiteColor,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        //const SizedBox(width:350),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: 700,
                                    height: MediaQuery.of(context).size.height /
                                        1.3,
                                    padding: const EdgeInsets.only(left: 20),
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
                                      itemCount:
                                          projectDetailsList?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        if ((projectDetailsList ?? [])
                                            .isEmpty) {
                                          return const Center(
                                            child: Text('No data available'),
                                          );
                                        } else {
                                          return Card(
                                            shadowColor: AsianPaintColors
                                                .bottomTextColor,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                color: AsianPaintColors
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
                                                  const EdgeInsets.all(20),
                                              tileColor:
                                                  AsianPaintColors.whiteColor,
                                              horizontalTitleGap: 10,
                                              minLeadingWidth: 80,
                                              leading: Image.network(
                                                (projectDetailsList?[index]
                                                                .sKUIMAGE ??
                                                            '')
                                                        .isEmpty
                                                    ? 'https://apldam.blob.core.windows.net/aplms/noImageAvailable.png'
                                                    : projectDetailsList?[index]
                                                            .sKUIMAGE! ??
                                                        '',
                                                width: 150,
                                                height: 150,
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
                                                        projectDetailsList?[
                                                                    index]
                                                                .sKUCATCODE ??
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
                                                      BlocConsumer<DelSkuBloc,
                                                          DeleteSkuState>(
                                                        listener:
                                                            (context, state) {
                                                          if (state
                                                              is DeleteSkuStateLoading) {
                                                            showLoaderDialog(
                                                                context,
                                                                'Deleting sku...');
                                                          }
                                                          if (state
                                                              is DeleteSkuStateLoaded) {
                                                            Navigator.pop(
                                                                context);
                                                            setState(
                                                              () {
                                                                setState(() {
                                                                  FlutterToastProvider().show(
                                                                      message:
                                                                          'Sku Deleted Successfully!!');
                                                                });
                                                              },
                                                            );
                                                          }
                                                        },
                                                        builder:
                                                            (context, state) {
                                                          DelSkuBloc
                                                              delSkuBloc =
                                                              context.read<
                                                                  DelSkuBloc>();
                                                          return InkWell(
                                                            onTap: () {
                                                              delSkuBloc.deleteSku(
                                                                  quoteID: widget
                                                                      .quoteID,
                                                                  skuID: projectDetailsList?[
                                                                          index]
                                                                      .qUOTESKUID);
                                                            },
                                                            child: Image.asset(
                                                              'assets/images/cancel.png',
                                                              width: 15,
                                                              height: 15,
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        projectDetailsList?[
                                                                    index]
                                                                .sKUDESCRIPTION ??
                                                            '',
                                                        // AppLocalizations.of(context).angle_cock,
                                                        textAlign:
                                                            TextAlign.justify,
                                                        style: TextStyle(
                                                          color: AsianPaintColors
                                                              .skuDescriptionColor,
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishRegular,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 6,
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
                                                            width: 50,
                                                            height: 25,
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: TextField(
                                                                inputFormatters: <
                                                                    TextInputFormatter>[
                                                                  LengthLimitingTextInputFormatter(
                                                                      2),
                                                                  FilteringTextInputFormatter
                                                                      .allow(RegExp(
                                                                          "[0-9]")),
                                                                ],
                                                                enableInteractiveSelection:
                                                                    false,
                                                                controller: TextEditingController.fromValue(TextEditingValue(
                                                                    text: (projectDetailsList?[index]
                                                                                .sKUDISCOUNT ??
                                                                            0)
                                                                        .toString(),
                                                                    selection: TextSelection.fromPosition(TextPosition(
                                                                        offset: (projectDetailsList?[index].sKUDISCOUNT ??
                                                                                0)
                                                                            .toString()
                                                                            .length)))),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                cursorColor:
                                                                    AsianPaintColors
                                                                        .kPrimaryColor,
                                                                style: TextStyle(
                                                                    backgroundColor:
                                                                        AsianPaintColors
                                                                            .whiteColor,
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
                                                                      "%",
                                                                  suffixStyle:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                                  fillColor:
                                                                      AsianPaintColors
                                                                          .whiteColor,
                                                                  filled: true,
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
                                                                        i < (projectDetailsList ?? []).length;
                                                                        i++) {
                                                                      setState(
                                                                        () {
                                                                          projectDetailsList?[i].sKUDISCOUNT =
                                                                              value;
                                                                          projectDetailsList?[i].SKUPREDISCOUNT =
                                                                              ((((int.parse(projectDetailsList?[i].sKUDISCOUNT ?? '0') / 100) + 0.18) / 1.18) * 100).toStringAsFixed(5);
                                                                        },
                                                                      );
                                                                      value.isNotEmpty ||
                                                                              value !=
                                                                                  "0"
                                                                          ? (projectDetailsList?[index].sKUDISCOUNT =
                                                                              value)
                                                                          : (projectDetailsList?[index].sKUDISCOUNT =
                                                                              '0');

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
                                                                              double.parse('${projectDetailsList?[i].totalPrice}') * double.parse('${projectDetailsList?[i].SKUPREDISCOUNT}');
                                                                          double
                                                                              discountAmount =
                                                                              double.parse('${values / 100}');
                                                                          projectDetailsList?[i]
                                                                              .totalPriceAfterDiscount = int.parse((projectDetailsList?[i].totalPrice) ??
                                                                                  '0') -
                                                                              discountAmount.round();
                                                                          projectDetailsList?[i]
                                                                              .discPrice = int.parse((projectDetailsList?[i].totalPrice) ??
                                                                                  '0') -
                                                                              discountAmount;
                                                                          logger(
                                                                              'Total price amount: ${projectDetailsList?[i].totalPriceAfterDiscount}');
                                                                          projectDetailsList
                                                                              ?.forEach((element) {
                                                                            totalDiscountAmount +=
                                                                                ((int.parse(element.totalPrice ?? '0') * double.parse(element.SKUPREDISCOUNT ?? '0')) / 100).round();
                                                                            totalAfterGST +=
                                                                                (element.discPrice ?? 0);

                                                                            logger(totalDiscountAmount);
                                                                          });
                                                                          totalBeforeGST =
                                                                              totalAfterGST.roundToDouble();
                                                                          totalAfterGST +=
                                                                              ((totalAfterGST * 18) / 100).round();
                                                                          logger(
                                                                              totalAfterGST);
                                                                        },
                                                                      );
                                                                    }

                                                                    isFirstTime =
                                                                        false;
                                                                  }
                                                                },
                                                                onChanged:
                                                                    (value) async {
                                                                  projectDetailsList?[
                                                                          index]
                                                                      .sKUDISCOUNT = value
                                                                          .isEmpty
                                                                      ? '0'
                                                                      : value;
                                                                  projectDetailsList?[
                                                                          index]
                                                                      .SKUPREDISCOUNT = ((((int.parse((projectDetailsList?[index].sKUDISCOUNT ?? '0').isEmpty ? '0' : projectDetailsList?[index].sKUDISCOUNT ?? '0') / 100) + 0.18) /
                                                                              1.18) *
                                                                          100)
                                                                      .toStringAsFixed(
                                                                          5);

                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          (projectDetailsList ?? [])
                                                                              .length;
                                                                      i++) {
                                                                    value.isNotEmpty ||
                                                                            value !=
                                                                                "0"
                                                                        ? (projectDetailsList?[index].sKUDISCOUNT =
                                                                            value)
                                                                        : (projectDetailsList?[index].sKUDISCOUNT =
                                                                            '0');
                                                                    logger(
                                                                        'Total Quantity: ${projectDetailsList?[index].tOTALQTY}');
                                                                    projectDetailsList?[index]
                                                                            .totalPrice =
                                                                        '${int.parse(projectDetailsList?[index].tOTALQTY ?? '0') * int.parse(projectDetailsList?[index].sKUMRP ?? '')}';

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
                                                                            double.parse('${projectDetailsList?[i].totalPrice}') *
                                                                                double.parse('${projectDetailsList?[i].SKUPREDISCOUNT}');
                                                                        double
                                                                            discountAmount =
                                                                            double.parse('${values / 100}');
                                                                        logger(
                                                                            'Discount amount: $discountAmount');
                                                                        projectDetailsList?[i]
                                                                            .totalPriceAfterDiscount = int.parse((projectDetailsList?[i].totalPrice) ??
                                                                                '0') -
                                                                            discountAmount.round();
                                                                        projectDetailsList?[i]
                                                                            .discPrice = int.parse((projectDetailsList?[i].totalPrice) ??
                                                                                '0') -
                                                                            discountAmount;
                                                                        logger(
                                                                            'Total price amount: ${projectDetailsList?[i].totalPriceAfterDiscount}');
                                                                        projectDetailsList
                                                                            ?.forEach((element) {
                                                                          totalDiscountAmount +=
                                                                              ((int.parse(element.totalPrice ?? '0') * double.parse(element.SKUPREDISCOUNT ?? '0')) / 100).round();
                                                                          totalAfterGST +=
                                                                              (element.discPrice ?? 0);
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
                                                                },
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Row(
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
                                                            width: 40,
                                                            height: 40,
                                                            child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  '${double.parse(projectDetailsList?[index].SKUPREDISCOUNT ?? '0').toStringAsFixed(2)} %',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          11),
                                                                )),
                                                          )
                                                        ],
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
                                                      Row(children: [
                                                        Text(
                                                          'MRP:',
                                                          //AppLocalizations.of(context).total_qty,
                                                          style: TextStyle(
                                                            color: AsianPaintColors
                                                                .quantityColor,
                                                            fontFamily:
                                                                AsianPaintsFonts
                                                                    .mulishMedium,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          " \u{20B9} ${projectDetailsList?[index].sKUMRP ?? ''}",
                                                          textAlign:
                                                              TextAlign.justify,
                                                          style: TextStyle(
                                                            color: AsianPaintColors
                                                                .kPrimaryColor,
                                                            fontFamily:
                                                                AsianPaintsFonts
                                                                    .mulishMedium,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ]),
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
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          '\u{20B9}  ${projectDetailsList?[index].totalPriceAfterDiscount}',
                                                          style: TextStyle(
                                                              color: AsianPaintColors
                                                                  .forgotPasswordTextColor,
                                                              fontFamily:
                                                                  AsianPaintsFonts
                                                                      .mulishBold,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 13),
                                                        ),
                                                      ]),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
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
                                                          fontSize: 10,
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
                                                            inputFormatters: <
                                                                TextInputFormatter>[
                                                              LengthLimitingTextInputFormatter(
                                                                  4),
                                                              FilteringTextInputFormatter
                                                                  .allow(RegExp(
                                                                      "[0-9]")),
                                                            ],
                                                            enableInteractiveSelection:
                                                                false,
                                                            controller: TextEditingController.fromValue(TextEditingValue(
                                                                text: (projectDetailsList?[index]
                                                                            .tOTALQTY ??
                                                                        0)
                                                                    .toString(),
                                                                selection: TextSelection.fromPosition(TextPosition(
                                                                    offset: (projectDetailsList?[index].tOTALQTY ??
                                                                            0)
                                                                        .toString()
                                                                        .length)))),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                backgroundColor:
                                                                    AsianPaintColors
                                                                        .whiteColor,
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
                                                              if (value ==
                                                                  '0') {
                                                                value = '1';
                                                              }

                                                              if (value !=
                                                                  '0') {
                                                                projectDetailsList?[
                                                                            index]
                                                                        .tOTALQTY =
                                                                    value;

                                                                for (int i = 0;
                                                                    i <
                                                                        (projectDetailsList ??
                                                                                [])
                                                                            .length;
                                                                    i++) {
                                                                  value.isNotEmpty ||
                                                                          value !=
                                                                              "0"
                                                                      ? (projectDetailsList?[index]
                                                                              .tOTALQTY =
                                                                          value)
                                                                      : (projectDetailsList?[index]
                                                                              .tOTALQTY =
                                                                          '0');
                                                                  projectDetailsList?[
                                                                              index]
                                                                          .totalPrice =
                                                                      '${int.parse(projectDetailsList?[index].tOTALQTY ?? '0') * int.parse(projectDetailsList?[index].sKUMRP ?? '')}';

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
                                                                          double.parse('${projectDetailsList?[i].totalPrice}') *
                                                                              double.parse('${projectDetailsList?[i].SKUPREDISCOUNT}');
                                                                      double
                                                                          discountAmount =
                                                                          double.parse(
                                                                              '${values / 100}');
                                                                      logger(
                                                                          'Discount amount: $discountAmount');
                                                                      projectDetailsList?[
                                                                              i]
                                                                          .totalPriceAfterDiscount = int.parse((projectDetailsList?[i].totalPrice) ??
                                                                              '0') -
                                                                          discountAmount
                                                                              .round();
                                                                      projectDetailsList?[
                                                                              i]
                                                                          .discPrice = int.parse((projectDetailsList?[i].totalPrice) ??
                                                                              '0') -
                                                                          discountAmount;
                                                                      logger(
                                                                          'Total price amount: ${projectDetailsList?[i].totalPriceAfterDiscount}');
                                                                      projectDetailsList
                                                                          ?.forEach(
                                                                              (element) {
                                                                        totalDiscountAmount +=
                                                                            ((int.parse(element.totalPrice ?? '0') * double.parse(element.SKUPREDISCOUNT ?? '0')) / 100).round();
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
                                                                          ((totalAfterGST * 18) / 100)
                                                                              .round();
                                                                      logger(
                                                                          "TotalAfterGST:  $totalAfterGST");
                                                                    },
                                                                  );
                                                                }
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
                                                  (projectDetailsList?[index]
                                                                  .aREADATA
                                                                  ?.length ??
                                                              0) <=
                                                          1
                                                      ? ListView.builder(
                                                          itemCount:
                                                              projectDetailsList?[
                                                                          index]
                                                                      .aREADATA
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
                                                              (context, index) {
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
                                                                          (projectDetailsList?[index].aREADATA?[index].areaname ?? '')
                                                                              .toUpperCase(),
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
                                                                              width: 45,
                                                                              height: 25,
                                                                              child: Align(
                                                                                alignment: Alignment.center,
                                                                                child: Text(
                                                                                  '${projectDetailsList?[index].aREADATA?[index].areaqty}',
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
                                                      : areaData.isNotEmpty
                                                          ? ListView.builder(
                                                              itemCount:
                                                                  areaData
                                                                      .length,
                                                              shrinkWrap: true,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(0),
                                                              physics:
                                                                  const NeverScrollableScrollPhysics(),
                                                              itemExtent: 50,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
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
                                                                            padding: const EdgeInsets.fromLTRB(
                                                                                10,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              areas[index],
                                                                              style: TextStyle(
                                                                                fontSize: 10,
                                                                                fontFamily: AsianPaintsFonts.mulishRegular,
                                                                                fontWeight: FontWeight.w400,
                                                                                color: AsianPaintColors.skuDescriptionColor,
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
                                                                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                                                                                      "${areaData.isNotEmpty ? areaData[index] : ''}",
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
                                                          : const SizedBox(),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          final Map<int, String>
                                                              data =
                                                              <int, String>{};
                                                          areas = [];

                                                          // Dialog dialog =
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (dcontext) {
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
                                                                child:
                                                                    Container(
                                                                  width: 250,
                                                                  height: 450,
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
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .all(
                                                                        10.0),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min, // To make the card compact
                                                                      children: <
                                                                          Widget>[
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                Alignment.centerRight,
                                                                            child:
                                                                                Image.asset(
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
                                                                                  text: '${projectDetailsList?[index].tOTALQTY ?? 0}',
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
                                                                            color:
                                                                                AsianPaintColors.quantityBorder,
                                                                            endIndent:
                                                                                5,
                                                                            indent:
                                                                                5,
                                                                          ),
                                                                          itemCount:
                                                                              projectDetailsList?[index].aREADATA?.length ?? 0,
                                                                          shrinkWrap:
                                                                              true,
                                                                          padding:
                                                                              const EdgeInsets.all(0),
                                                                          physics:
                                                                              const NeverScrollableScrollPhysics(),
                                                                          itemBuilder:
                                                                              (context, ind) {
                                                                            final controller =
                                                                                TextEditingController();

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
                                                                                          projectDetailsList?[index].aREADATA?[ind].toString() ?? '',
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
                                                                                              controller: controller,
                                                                                              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                                                                              textAlign: TextAlign.center,
                                                                                              style: TextStyle(backgroundColor: AsianPaintColors.whiteColor, fontSize: 10, fontFamily: AsianPaintsFonts.mulishRegular, color: AsianPaintColors.kPrimaryColor),
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
                                                                                                  if (_value) {
                                                                                                    data[ind] = controller.text;
                                                                                                    logger(data);
                                                                                                    areas.add(projectDetailsList?[index].aREADATA?[ind].toString() ?? '');
                                                                                                  } else {
                                                                                                    data.removeWhere((key, value) => key == ind);
                                                                                                    areas.remove(projectDetailsList?[index].aREADATA?[ind] ?? '');

                                                                                                    logger(data);
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
                                                                                        if (!_value) {
                                                                                          data[ind] = controller.text;
                                                                                          // areas.add(widget.skuResponseList?[index].aREAINFO?[ind] ?? '');

                                                                                          logger(data);
                                                                                        } else {
                                                                                          data.removeWhere((key, value) => key == ind);
                                                                                          // areas.remove(widget.skuResponseList?[index].aREAINFO?[ind] ?? '');

                                                                                          logger(data);
                                                                                        }
                                                                                        _value = value ?? true;
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
                                                                            height:
                                                                                40,
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.5,
                                                                            child:
                                                                                ElevatedButton(
                                                                              onPressed: () async {
                                                                                // widget
                                                                                //     .skuResponseList?[
                                                                                //         index]
                                                                                //     .aREAINFO = [];

                                                                                int quantity = 0;
                                                                                if (data.values.isNotEmpty) {
                                                                                  for (int i = 0; i < data.values.length; i++) {
                                                                                    if (data.values.elementAt(i).isNotEmpty) {
                                                                                      quantity += int.parse(data.values.elementAt(i));
                                                                                      logger(quantity);
                                                                                      if (quantity > int.parse(projectDetailsList?[index].tOTALQTY ?? '')) {
                                                                                        FlutterToastProvider().show(message: 'Entered quantity is greater than total quantity');
                                                                                      } else {
                                                                                        logger('In If-else');

                                                                                        setState(
                                                                                          () {
                                                                                            // widget.skuResponseList?[index].aREAINFO?.add(areas[i]);
                                                                                          },
                                                                                        );
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                  logger('Length: ${projectDetailsList?[index].aREADATA?.length}');
                                                                                  Navigator.pop(context, Arguments(data));
                                                                                } else {
                                                                                  logger('In else');
                                                                                  Navigator.pop(dcontext);
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
                                                          ).then((value) {
                                                            setState(
                                                              () {
                                                                arguments =
                                                                    value;
                                                                areaData =
                                                                    arguments
                                                                        .dataMap;
                                                                logger(
                                                                    'Selected map: ${arguments.dataMap.length}');
                                                              },
                                                            );
                                                          });
                                                        },
                                                        child: Visibility(
                                                          visible: (projectDetailsList?[
                                                                              index]
                                                                          .aREADATA
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
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              //2nd side column start here
                              const SizedBox(
                                width: 60,
                              ),
                              Flexible(
                                flex: 1,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 100,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 0, 25, 0),
                                      width: MediaQuery.of(context).size.width /
                                          2.4,
                                      height: 250,
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Card(
                                        color: Colors.white,
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 15, 20, 20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.projectName ?? '',
                                                style: TextStyle(
                                                  fontFamily: AsianPaintsFonts
                                                      .mulishMedium,
                                                  color: AsianPaintColors
                                                      .projectUserNameColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    './assets/images/userimage.png',
                                                    width: 18,
                                                    height: 18,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    widget.contactPerson ?? '',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishRegular,
                                                      fontSize: 13,
                                                      color: AsianPaintColors
                                                          .projectUserNameColorTwo,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    './assets/images/call.png',
                                                    width: 18,
                                                    height: 18,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    widget.mobileNumber ?? '',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishRegular,
                                                      fontSize: 13,
                                                      color: AsianPaintColors
                                                          .projectUserNameColorTwo,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        './assets/images/location.png',
                                                        width: 15,
                                                        height: 15,
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        widget.siteAddress ??
                                                            '',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishRegular,
                                                          fontSize: 13,
                                                          color: AsianPaintColors
                                                              .projectUserNameColorTwo,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 35,
                                              ),
                                              Text(
                                                "No of Bathrooms : ${widget.noOfBathrooms}",
                                                style: TextStyle(
                                                  fontFamily: AsianPaintsFonts
                                                      .mulishBold,
                                                  color: AsianPaintColors
                                                      .projectUserNameColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 0, 25, 0),
                                      width: MediaQuery.of(context).size.width /
                                          2.4,
                                      height: 250,
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Card(
                                        child: ListTile(
                                          //contentPadding: EdgeInsets.all(1),
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    top: 15),
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
                                                    (projectDetailsList
                                                                    ?.length ??
                                                                0) ==
                                                            1
                                                        ? "Total Bill (${projectDetailsList?.length} item)"
                                                        : "Total Bill (${projectDetailsList?.length} items)",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishMedium,
                                                        color: AsianPaintColors
                                                            .textFieldLabelColor,
                                                        fontSize: 12),
                                                  ),
                                                  Text(
                                                    '\u{20B9} $totalBeforeGST',
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
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishMedium,
                                                      color: AsianPaintColors
                                                          .textFieldLabelColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    '18 %',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishSemiBold,
                                                      color: AsianPaintColors
                                                          .chooseYourAccountColor,
                                                      fontSize: 12,
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
                                                    "Discount Amount",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishMedium,
                                                      color: AsianPaintColors
                                                          .textFieldLabelColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    ' \u{20B9} $totalDiscountAmount',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishSemiBold,
                                                      color: AsianPaintColors
                                                          .chooseYourAccountColor,
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                ],
                                              ),
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
                                                        fontSize: 12,
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishMedium,
                                                        color: AsianPaintColors
                                                            .textFieldLabelColor),
                                                  ),
                                                  Text(
                                                    ' \u{20B9} ${totalAfterGST.round()}',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishRegular,
                                                        color: AsianPaintColors
                                                            .forgotPasswordTextColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                            padding: const EdgeInsets.only(
                                                right: 60),
                                            height: 40,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.18,
                                            child: GestureDetector(
                                              onTapDown: (details) {
                                                showExportPopupMenuWeb(
                                                    details.globalPosition);
                                              },
                                              child: ElevatedButton(
                                                  onPressed: () async {},
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          alignment:
                                                              Alignment.center,
                                                          elevation: 0,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              35.0),
                                                                  side:
                                                                      BorderSide(
                                                                    width: 1,
                                                                    color: AsianPaintColors
                                                                        .kPrimaryColor,
                                                                  )),
                                                          backgroundColor:
                                                              AsianPaintColors
                                                                  .whiteColor,
                                                          shadowColor:
                                                              AsianPaintColors
                                                                  .buttonBorderColor,
                                                          textStyle: TextStyle(
                                                              color: AsianPaintColors
                                                                  .kPrimaryColor,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  AsianPaintsFonts
                                                                      .mulishBold)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Flexible(
                                                        flex: 1,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  35, 5, 0, 0),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .topCenter,
                                                            child: Text(
                                                              'Export',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    AsianPaintsFonts
                                                                        .mulishBold,
                                                                color: AsianPaintColors
                                                                    .kPrimaryColor,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 0, 25, 0),
                                                        child: SvgPicture.asset(
                                                          'assets/images/drop_down.svg',
                                                          width: 6,
                                                          height: 6,
                                                        ),
                                                      )
                                                    ],
                                                  )),
                                            ))
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ));
                  },
                );
              }
              return const SizedBox(
                width: 80,
                height: 80,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
        tablet: const Scaffold(),
      ),
    );
  }

  Widget showQuoteDialog() {
    final quoteController = TextEditingController();
    return Dialog(
      key: formKey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: BlocConsumer<CopyQuoteBloc, CopyQuoteState>(
        listener: (context, state) {
          if (state is CopyQuoteInitial) {
            const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is CopyQuoteLoading) {
            const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is CopyQuoteLoaded) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectDescription(
                  projectID: widget.projectID,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          CopyQuoteBloc copyQuoteBloc = context.read<CopyQuoteBloc>();
          return SizedBox(
            height: 300,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
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
                          'Bathroom 1 Quote', //AppLocalizations.of(context).user_id,
                      labelStyle: TextStyle(
                          fontFamily: AsianPaintsFonts.mulishMedium,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: AsianPaintColors.textFieldLabelColor),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 250,
                  child: APElevatedButton(
                    onPressed: () async {
                      Journey.quoteName = quoteController.text;
                      Journey.quoteID = widget.quoteID;

                      if (quoteController.text.isNotEmpty) {
                        copyQuoteBloc.copyQuote(
                          projectID: widget.projectID,
                          quoteID: widget.quoteID,
                          quoteName: quoteController.text,
                        );
                      } else {
                        FlutterToastProvider()
                            .show(message: 'Please enter valid Quote name');
                      }
                    },
                    label: state is CopyQuoteLoading
                        ? SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                                color: AsianPaintColors.whiteColor),
                          )
                        : Text(
                            'Create & Add to Project',
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
          );
        },
      ),
    );
  }

  void showPopupMenu(Offset offset) async {
    String? selectedValue;
    await showMenu(
      clipBehavior: Clip.hardEdge,
      context: context,
      position: RelativeRect.fromLTRB(
        0,
        offset.dy,
        0,
        offset.dx,
      ),
      items: [
        PopupMenuItem(
          value: 1,
          child: BlocConsumer<ProjectDescriptionBloc, ProjectsDescriptionState>(
            listener: (context, state) {
              ProjectDescriptionBloc projectDescriptionBloc =
                  context.read<ProjectDescriptionBloc>();
              if (state is ProjectDescriptionLoading) {
                SizedBox(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AsianPaintColors.kPrimaryColor,
                    ),
                  ),
                );
              }

              if (state is ProjectDescriptionLoaded) {
                Navigator.pop(context);
                FlipQuoteBloc flipQuoteBloc = context.read<FlipQuoteBloc>();
                int quantity = 0;
                int price = 0;
                SKUResponse skuResponse = SKUResponse();
                List<Quoteinfo> quoteInfoList = [];
                List<SKUData> skuResponseLists = [];
                List<SKUData> skuList = [];
                List<SKUListData> info =
                    flipQuoteBloc.responseModel?.data?.data ?? [];
                int total = 0;

                for (int i = 0; i < info.length; i++) {
                  logger('Quantity: ${info[i].qUANTITY}');
                  logger('Area Data: ${json.encode(info[i].aREAINFOBJ)}');

                  quantity = (info[i].qUANTITY ?? '1').isEmpty
                      ? int.parse('1')
                      : int.parse(info[i].qUANTITY ?? '1');

                  price = price +
                      quantity * int.parse(skuResponse.data?[i].sKUMRP ?? '0');

                  SKUData skuData = SKUData();
                  skuData.sKURANGE = info[i].sKURANGE ?? '';
                  skuData.sKUIMAGE = info[i].sKUIMAGE ?? '';
                  skuData.sKUCATEGORY = info[i].sKUCATEGORY ?? '';
                  skuData.sKUUSP = info[i].sKUUSP ?? '';
                  skuData.sKUPRODUCTCAT = info[i].sKUPRODUCTCAT ?? '';
                  skuData.sKUDESCRIPTION = info[i].sKUDESCRIPTION ?? '';
                  skuData.complementary = [];
                  skuData.sKUMRP = info[i].sKUMRP ?? '';
                  skuData.sKUCODE = info[i].sKUCODE ?? '';
                  skuData.sKUSRP = info[i].sKUSRP ?? '';
                  skuData.sKUDRAWING = info[i].sKUDRAWING ?? '';
                  skuData.sKUBRAND = info[i].sKUBRAND ?? '';
                  logger('Area Info: ${json.encode(skuData.aREAINFO)}');

                  for (String element in info[i].aREAINFO ?? []) {
                    logger('Area: ${element}');

                    (skuData.aREAINFO ?? []).add(element);
                  }

                  skuData.skuCatCode = info[i].sKUCATCODE ?? '';
                  skuData.sKUTYPE = info[i].sKUTYPE ?? '';
                  skuData.discount = info[i].dISCOUNT;
                  skuData.netDiscount = info[i].nETDICOUNT.toString();
                  skuData.quantity = (info[i].qUANTITY ?? '1').isEmpty
                      ? '1'
                      : info[i].qUANTITY;
                  skuData.totalPrice = info[i].tOTALPRICE;

                  skuData.totalPriceAfterDiscount = info[i].tOTALPRICE;
                  skuData.aREAINFO = [];
                  skuData.totalPrice = info[i].tOTALPRICE;

                  skuData.index = 0;
                  // skuData.areaInfo = info[i].aREAINFOBJ;
                  for (AREAINFOBJ element in info[i].aREAINFOBJ ?? []) {
                    logger('Area in DATA: ${element.aREA}');

                    (skuData.areaInfo ?? []).add(
                        Area(areaname: element.aREA, areaqty: element.qTY));
                  }
                  logger('Area Data: ${json.encode(skuData.areaInfo)}');

                  skuData.skuTypeExpanded = '';
                  skuData.productCardDescriptior = '';
                  price += skuData.totalPriceAfterDiscount ?? 0;

                  skuList.add(skuData);

                  if (!skuResponseLists.contains(skuData)) {
                    logger("In if condition:::");
                    skuResponseLists.add((skuData));
                  }

                  if (!Journey.skuResponseLists.contains(skuData)) {
                    logger("In if condition:::");
                    Journey.skuResponseLists.add((skuData));
                  }
                  total += info[i].tOTALPRICEAFTERDISCOUNT ?? 0;
                }

                logger('Total: $total');
                int gstAmount = total - (total * (100 / (100 + 18))).round();
                int netPrice = total - gstAmount;
                Journey.totalPrice = netPrice.round();
                logger('Total after gst: $netPrice');

                logger('Quantity: ${skuResponseLists.length}');

                // Journey.skuResponseLists = skuResponseLists;

                final secureStorageProvider =
                    getSingleton<SecureStorageProvider>();
                secureStorageProvider.saveQuoteToDisk(Journey.skuResponseLists);
                secureStorageProvider.saveCartDetails(skuResponseLists);

                secureStorageProvider.saveTotalPrice(total.toString());

                secureStorageProvider.saveProjectID(widget.projectID);

                // setState(
                //   () {
                int cartCount = Journey.skuResponseLists.length;
                secureStorageProvider.saveCartCount(cartCount);
                secureStorageProvider.saveProjectID(widget.projectID);
                logger('Cart count: $cartCount');

                Future.delayed(
                  const Duration(seconds: 3),
                );

                // Journey.quoteName = widget.quoteName;
                // Journey.quoteID = widget.quoteID;
                // secureStorageProvider.saveProjectID(widget.projectID);
                Journey.fromFlip = true;

                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewQuote(
                      catIndex: 0,
                      brandIndex: 0,
                      rangeIndex: 0,
                      category: widget.category,
                      brand: widget.brand,
                      range: widget.range,
                      quantity: '0',
                      skuResponseList: [],
                      fromFlip: false,
                      projectID: widget.projectID ?? '',
                      fromFlipScreen: false,
                      totalWithGST: int.parse(widget.totalAfterGst ?? '0'),
                      totalDiscountAmount:
                          int.parse(widget.discountAmount ?? '0'),
                    ),
                  ),
                );

                // _secureStorageProvider.saveQuoteToDisk(skuResponseList);
              }
            },
            builder: (context, state) {
              ProjectDescriptionBloc projectDescriptionBloc =
                  context.read<ProjectDescriptionBloc>();
              return InkWell(
                onTap: () {
                  if ((widget.range ?? '').isEmpty) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        title: const Text("Cannot flip!!"),
                        content: const Text(
                            "This Quote doesn't have sku's mapped to CP range."),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Ok'),
                          ),
                        ],
                      ),
                    );
                  } else if (!(widget.isFlipAvailable ?? true)) {
                    FlutterToastProvider().show(
                        message: 'Flip range not available for this quote');
                  } else {
                    FlipQuoteBloc flipQuoteBloc = context.read<FlipQuoteBloc>();

                    Dialog flipQuoteDialog = Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      child: BlocConsumer<FlipQuoteBloc, FlipQuoteState>(
                        listener: (context, state) {
                          if (state is FlipQuoteLoaded) {
                            logger(
                                'In Listener: ${flipQuoteBloc.responseModel}');
                            if (flipQuoteBloc.responseModel?.matchedStatus ??
                                true) {
                              Navigator.pop(context);

                              if (Journey.skuResponseLists.isNotEmpty) {
                                showCreateExistingDialog(
                                    context,
                                    widget.projectID ?? '',
                                    widget.quoteID ?? '',
                                    widget.category ?? '',
                                    widget.brand ?? '',
                                    widget.range ?? '',
                                    selectedValue ?? '');
                              } else {
                                projectDescriptionBloc.getProjectDescription(
                                    projectID: widget.projectID ?? '',
                                    quoteID: widget.quoteID);

                                // showCreateExistingDialog(
                                //     context,
                                //     widget.projectID ?? '',
                                //     widget.quoteID ?? '',
                                //     widget.category ?? '',
                                //     widget.brand ?? '',
                                //     widget.range ?? '',
                                //     selectedValue ?? '');
                                // calculateSKU(
                                //     widget.projectID ?? '',
                                //     widget.quoteID ?? '',
                                //     widget.category ?? '',
                                //     widget.brand ?? '',
                                //     widget.range ?? '',
                                //     selectedValue ?? '');
                              }
                            } else {
                              showAlertDialog(BuildContext context) {
                                // set up the buttons
                                Widget cancelButton = TextButton(
                                  child: const Text("No"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                );
                                Widget continueButton =
                                    BlocConsumer<FlipQuoteBloc, FlipQuoteState>(
                                  listener: (context, state) {
                                    if (state is FlipQuoteLoaded) {
                                      FlutterToastProvider().show(
                                          message: 'Flipping the quote....');
                                    }
                                    if (state is FlipQuoteLoaded) {
                                      if (Journey.skuResponseLists.isNotEmpty) {
                                        logger(
                                            "Alert response: ${Journey.skuResponseLists.length}");
                                        showCreateExistingDialog(
                                            context,
                                            widget.projectID ?? '',
                                            widget.quoteID ?? '',
                                            widget.category ?? '',
                                            widget.brand ?? '',
                                            widget.range ?? '',
                                            selectedValue ?? '');
                                      } else {
                                        projectDescriptionBloc
                                            .getProjectDescription(
                                                projectID:
                                                    widget.projectID ?? '',
                                                quoteID: widget.quoteID);
                                      }
                                    }
                                  },
                                  builder: (context, state) {
                                    return TextButton(
                                      child: const Text("Yes"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        FlipQuoteBloc fliBloc =
                                            context.read<FlipQuoteBloc>();
                                        fliBloc.flipQuote(
                                            projectID: widget.projectID,
                                            quoteID: widget.quoteID,
                                            currentRange: widget.range,
                                            selectedRange: selectedValue,
                                            createdType: 'new',
                                            areYouSure: true,
                                            quoteName: widget.quoteName);
                                      },
                                    );
                                  },
                                );
                                logger(
                                    "Alert response: ${flipQuoteBloc.responseModel}");

                                // set up the AlertDialog
                                AlertDialog alert = AlertDialog(
                                  title: const Text("AlertDialog"),
                                  content: SingleChildScrollView(
                                    child: SizedBox(
                                      width: double.maxFinite,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          (flipQuoteBloc.responseModel
                                                          ?.notmatchedlist ??
                                                      [])
                                                  .isNotEmpty
                                              ? Scrollbar(
                                                  thumbVisibility: true,
                                                  child: SizedBox(
                                                    height: 150,
                                                    child: ListView.separated(
                                                      separatorBuilder:
                                                          (context, index) =>
                                                              const Divider(),
                                                      shrinkWrap: true,
                                                      itemCount: (flipQuoteBloc
                                                                  .responseModel
                                                                  ?.notmatchedlist ??
                                                              [])
                                                          .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        var result = flipQuoteBloc
                                                                .responseModel
                                                                ?.notmatchedlist?[
                                                            index];
                                                        return ListTile(
                                                          dense: true,
                                                          visualDensity:
                                                              const VisualDensity(
                                                                  vertical: -3),
                                                          tileColor: const Color
                                                                  .fromARGB(
                                                              1, 149, 147, 147),
                                                          title: Text(
                                                              result ?? '',
                                                              style: TextStyle(
                                                                  color: AsianPaintColors
                                                                      .blackColor)),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(
                                                  height: 0,
                                                ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            flipQuoteBloc.responseModel
                                                    ?.matchedText ??
                                                '',
                                            style: TextStyle(
                                                color: AsianPaintColors
                                                    .blackColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    cancelButton,
                                    continueButton,
                                  ],
                                );

                                // show the dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return alert;
                                  },
                                );
                              }

                              showAlertDialog(context);
                            }
                          }
                        },
                        builder: (context, state) {
                          logger('Range: ${widget.range}');
                          return StatefulBuilder(
                            builder: (context, setState) {
                              if ((widget.flipRange ?? []).isEmpty) {
                                FlutterToastProvider()
                                    .show(message: 'Flip ranges not found');
                              }
                              return SizedBox(
                                height: 280,
                                width: double.infinity,
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop(context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 15, 20, 0),
                                            child: Image.asset(
                                              'assets/images/cancel.png',
                                              width: 15,
                                              height: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Choose Range",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: AsianPaintsFonts
                                                .bathSansRegular,
                                            color: AsianPaintColors
                                                .buttonTextColor,
                                            //fontWeight: FontWeight.,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 20, 0, 0),
                                      child: Text(
                                        "Choose a Range to Flip your existing quote.",
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontFamily:
                                                AsianPaintsFonts.mulishMedium,
                                            color: AsianPaintColors
                                                .textFieldLabelColor),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 20, 0, 0),
                                          width: 130,
                                          height: 70,
                                          child: TextFormField(
                                            enableInteractiveSelection: false,
                                            initialValue: widget.range,
                                            style: TextStyle(
                                              color: AsianPaintColors
                                                  .skuDescriptionColor,
                                              fontSize: 10,
                                            ),
                                            decoration: InputDecoration(
                                              enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: AsianPaintColors
                                                          .textFieldUnderLineColor)),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                color: AsianPaintColors
                                                    .textFieldUnderLineColor,
                                              )),
                                              filled: true,
                                              focusColor: AsianPaintColors
                                                  .textFieldUnderLineColor,
                                              fillColor: AsianPaintColors
                                                  .textFieldBorderColor,
                                              border:
                                                  const UnderlineInputBorder(),
                                              labelText:
                                                  'Current Range', //AppLocalizations.of(context).user_id,
                                              labelStyle: TextStyle(
                                                  fontFamily: AsianPaintsFonts
                                                      .mulishBold,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 10,
                                                  color: AsianPaintColors
                                                      .textFieldLabelColor),
                                            ),
                                          ),
                                        ),
                                        Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 20, 0, 0),
                                            width: 160,
                                            height: 70,
                                            child: Autocomplete(
                                              optionsBuilder: ((TextEditingValue
                                                  textValue) {
                                                selectedValue = textValue.text;
                                                return (widget.flipRange ?? [])
                                                    .where((ele) => ele
                                                        .toLowerCase()
                                                        .startsWith(textValue
                                                            .text
                                                            .toLowerCase()));
                                              }),
                                              onSelected: (selectesString) {
                                                print(selectesString);
                                                selectedValue =
                                                    selectesString.toString();
                                              },
                                              optionsViewBuilder: (context,
                                                  onSelected, options) {
                                                return Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            2.5,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Material(
                                                      child: Scrollbar(
                                                        thumbVisibility: true,
                                                        child:
                                                            ListView.separated(
                                                                // padding: EdgeInsets.zero,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  final option =
                                                                      options.elementAt(
                                                                          index);

                                                                  return ListTile(
                                                                    dense: true,
                                                                    visualDensity:
                                                                        const VisualDensity(
                                                                            vertical:
                                                                                -4),
                                                                    title: Text(
                                                                      option
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontFamily: AsianPaintsFonts
                                                                              .mulishRegular,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                    onTap: () {
                                                                      onSelected(
                                                                          option);
                                                                    },
                                                                  );
                                                                },
                                                                separatorBuilder:
                                                                    (context,
                                                                            index) =>
                                                                        const Divider(),
                                                                itemCount:
                                                                    options
                                                                        .length),
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
                                                  focusNode: focusNode,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishRegular,
                                                      fontSize: 12,
                                                      color: AsianPaintColors
                                                          .skuDescriptionColor),
                                                  decoration: InputDecoration(
                                                      filled: true,
                                                      focusColor: AsianPaintColors
                                                          .textFieldUnderLineColor,
                                                      fillColor: AsianPaintColors
                                                          .textFieldBorderColor,
                                                      border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  0),
                                                          borderSide: BorderSide(
                                                              color: AsianPaintColors
                                                                  .createProjectTextBorder)),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  0),
                                                          borderSide: BorderSide(
                                                              color: AsianPaintColors
                                                                  .createProjectTextBorder)),
                                                      enabledBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  0),
                                                          borderSide:
                                                              BorderSide(color: AsianPaintColors.createProjectTextBorder)),
                                                      hintText: 'Select Range*',
                                                      // suffixText:
                                                      //     '*',
                                                      // suffixStyle: TextStyle(
                                                      //     color: AsianPaintColors
                                                      //         .forgotPasswordTextColor),
                                                      hintStyle: const TextStyle(fontSize: 12),
                                                      suffixIcon: Icon(
                                                        Icons.search,
                                                        color: Colors.grey[600],
                                                      )),
                                                  onSubmitted: (value) {
                                                    selectedValue = value;
                                                  },
                                                );
                                              },
                                            )),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Center(
                                      child: SizedBox(
                                        height: 45,
                                        width: 350,
                                        child: APElevatedButton(
                                          onPressed: () async {
                                            if (selectedValue?.isNotEmpty ??
                                                false) {
                                              flipQuoteBloc.flipQuote(
                                                  projectID: widget.projectID,
                                                  quoteID: widget.quoteID,
                                                  currentRange: widget.range,
                                                  selectedRange: selectedValue,
                                                  createdType: 'new',
                                                  areYouSure: false,
                                                  quoteName: widget.quoteName);
                                            } else {
                                              FlutterToastProvider().show(
                                                  message:
                                                      'Please select flip range');
                                            }
                                          },
                                          label: state is FlipQuoteLoading
                                              ? SizedBox(
                                                  height: 15,
                                                  width: 15,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: AsianPaintColors
                                                        .whiteColor,
                                                  ),
                                                )
                                              : Text(
                                                  'Flip Quote',
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
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                    Future.delayed(
                      const Duration(seconds: 0),
                      () => showDialog(
                        context: context,
                        builder: (context) => flipQuoteDialog,
                      ),
                    );
                  }
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "Flip Quote",
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: AsianPaintsFonts.mulishRegular,
                      fontWeight: FontWeight.w400,
                      color: AsianPaintColors.skuDescriptionColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        PopupMenuItem(
          onTap: null,
          value: 2,
          child: InkWell(
            onTap: () {
              logger('On tappedd !!!!!!');
              // showDialog(

              //   context: context,
              //   builder: (context) {
              //     return showQuoteDialog();
              //   },
              // );
              // Future.delayed(
              //   const Duration(seconds: 0),
              //   () =>
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => CreateProject(
              //       projectID: widget.projectID,
              //       isClone: true,
              //       projectName: widget.projectName,
              //       contactPerson: widget.contactPerson,
              //       mobileNumber: widget.mobileNumber,
              //       siteAddress: widget.siteAddress,
              //       noOfBathrooms: widget.noOfBathrooms,
              //     ),
              //   ),
              // ).then((value) => logger(value)),
              // );
              Journey.skuResponseLists = [];

              int quantity = 0;
              price = 0;
              List<Projectdetails>? info = projectDetailsList ?? [];

              for (int i = 0; i < info.length; i++) {
                logger('Quantity: ${info[i].tOTALQTY}');
                logger('Area Data: ${json.encode(info[i].aREADATA)}');

                quantity = int.parse(info[i].tOTALQTY ?? '0');
                // price += int.parse(projectDetailsList?[i].tOTALPRICE ?? '0');

                // price +=
                //     int.parse(info[i].tOTALQTY ?? '0') * int.parse(info[i].sKUMRP ?? '0');

                SKUData skuData = SKUData();
                skuData.sKURANGE = info[i].sKURANGE ?? '';
                skuData.sKUIMAGE = info[i].sKUIMAGE ?? '';
                skuData.sKUCATEGORY = info[i].sKUCATEGORY ?? '';
                skuData.sKUUSP = info[i].sKUUSP ?? '';
                skuData.sKUPRODUCTCAT = info[i].sKUPRODUCTCAT ?? '';
                skuData.sKUDESCRIPTION = info[i].sKUDESCRIPTION ?? '';
                skuData.complementary = [];
                skuData.sKUMRP = info[i].sKUMRP ?? '';
                skuData.sKUCODE = info[i].sKUCODE ?? '';
                skuData.sKUSRP = info[i].sKUSRP ?? '';
                skuData.sKUDRAWING = info[i].sKUDRAWING ?? '';
                skuData.sKUBRAND = info[i].sKUBRAND ?? '';
                logger('Area Info: ${json.encode(skuData.aREAINFO)}');

                for (Area element in info[i].aREADATA ?? []) {
                  logger('Area: ${element.areaname}');

                  (skuData.aREAINFO ?? []).add(element.areaname ?? '');
                }

                skuData.skuCatCode = info[i].sKUCATCODE ?? '';
                skuData.sKUTYPE = info[i].sKUTYPE ?? '';
                skuData.discount = int.parse(info[i].sKUDISCOUNT ?? '');
                skuData.netDiscount = info[i].SKUPREDISCOUNT;
                skuData.quantity = (info[i].tOTALQTY ?? '1').isNotEmpty
                    ? '1'
                    : info[i].tOTALQTY;
                skuData.totalPrice = int.parse(info[i].tOTALPRICE ?? '0');

                skuData.totalPriceAfterDiscount =
                    int.parse(info[i].tOTALPRICE ?? '0');
                skuData.aREAINFO = [];
                skuData.totalPrice = int.parse(info[i].tOTALPRICE ?? '0');

                skuData.index = 0;
                skuData.areaInfo = info[i].aREADATA;
                // for (Area element in info[i].aREADATA ?? []) {
                //   logger('Area in DATA: ${element.areaname}');

                //   (skuData.areaInfo ?? []).add(Area(
                //       areaname: element.areaname,
                //       areaqty: element.areaqty));
                // }
                logger('Area Data: ${json.encode(skuData.areaInfo)}');

                skuData.skuTypeExpanded = '';
                skuData.productCardDescriptior = '';
                price += skuData.totalPriceAfterDiscount ?? 0;

                if (!Journey.skuResponseLists.contains(skuData)) {
                  logger("In if condition:::");
                  Journey.skuResponseLists.add((skuData));
                }
              }

              logger('Journey length ${Journey.skuResponseLists.length}');
              SecureStorageProvider secureStorageProvider =
                  getSingleton<SecureStorageProvider>();
              secureStorageProvider.saveQuoteToDisk(Journey.skuResponseLists);

              secureStorageProvider.saveTotalPrice(widget.totalAfterGst);
              // quantity = 0;
              // int quantity = 0;
              int cartCount = 0;
              setState(
                () {
                  for (int i = 0; i < Journey.skuResponseLists.length; i++) {
                    quantity +=
                        int.parse(Journey.skuResponseLists[i].quantity ?? '');
                  }
                  cartCount = Journey.skuResponseLists.length;
                  secureStorageProvider.saveCartCount(cartCount);
                  logger('Cart count: $cartCount');
                  logger('Quantity: $quantity');
                },
              );

              FlutterToastProvider()
                  .show(message: "Successfully added SKU's to Quote!!");

              Navigator.pop(context);

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
                        totalWithGST: int.parse(widget.totalAfterGst ?? '0'),
                        totalDiscountAmount:
                            int.parse(widget.discountAmount ?? '0'),
                      ),
                    ),
                  );
                },
              );
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Text(
                "Copy Quote",
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: AsianPaintsFonts.mulishRegular,
                  fontWeight: FontWeight.w400,
                  color: AsianPaintColors.skuDescriptionColor,
                ),
              ),
            ),
          ),
        ),
      ],
    ).then((value) {
// NOTE: even you didnt select item this method will be called with null of value so you should call your call back with checking if value is not null

      if (value != null) print(value);
    });
  }

  void showPopupMenuWeb(Offset offset) async {
    String? selectedValue;

    await showMenu(
      clipBehavior: Clip.hardEdge,
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dy * 13,
        offset.dx,
      ),
      items: [
        PopupMenuItem(
          value: 1,
          child: BlocConsumer<ProjectDescriptionBloc, ProjectsDescriptionState>(
            listener: (context, state) {
              ProjectDescriptionBloc projectDescriptionBloc =
                  context.read<ProjectDescriptionBloc>();
              if (state is ProjectDescriptionLoading) {
                SizedBox(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AsianPaintColors.kPrimaryColor,
                    ),
                  ),
                );
              }

              if (state is ProjectDescriptionLoaded) {
                Navigator.pop(context);
                // int quantity = 0;
                // int price = 0;
                // SKUResponse skuResponse = SKUResponse();
                // List<Quoteinfo> quoteInfoList = [];
                // List<SKUData> skuResponseLists = [];
                // List<SKUData> skuList = [];
                // List<Projectdetails>? info = projectDescriptionBloc
                //         .getProjectDescriptionModel
                //         ?.data?[0]
                //         .qUOTEINFO?[0]
                //         .projectdetails ??
                //     [];

                // for (int i = 0; i < info.length; i++) {
                //   logger('Quantity: ${info[i].tOTALQTY}');
                //   logger('Area Data: ${json.encode(info[i].aREADATA)}');

                //   quantity = int.parse(info[i].tOTALQTY ?? '0');

                //   price = price +
                //       int.parse(info[i].tOTALQTY ?? '0') *
                //           int.parse(skuResponse.data?[i].sKUMRP ?? '0');

                //   SKUData skuData = SKUData();
                //   skuData.sKURANGE = info[i].sKURANGE ?? '';
                //   skuData.sKUIMAGE = info[i].sKUIMAGE ?? '';
                //   skuData.sKUCATEGORY = info[i].sKUCATEGORY ?? '';
                //   skuData.sKUUSP = info[i].sKUUSP ?? '';
                //   skuData.sKUPRODUCTCAT = info[i].sKUPRODUCTCAT ?? '';
                //   skuData.sKUDESCRIPTION = info[i].sKUDESCRIPTION ?? '';
                //   skuData.complementary = [];
                //   skuData.sKUMRP = info[i].sKUMRP ?? '';
                //   skuData.sKUCODE = info[i].sKUCODE ?? '';
                //   skuData.sKUSRP = info[i].sKUSRP ?? '';
                //   skuData.sKUDRAWING = info[i].sKUDRAWING ?? '';
                //   skuData.sKUBRAND = info[i].sKUBRAND ?? '';
                //   logger('Area Info: ${json.encode(skuData.aREAINFO)}');

                //   for (Area element in info[i].aREADATA ?? []) {
                //     logger('Area: ${element.areaname}');

                //     (skuData.aREAINFO ?? []).add(element.areaname ?? '');
                //   }

                //   skuData.skuCatCode = info[i].sKUCATCODE ?? '';
                //   skuData.sKUTYPE = info[i].sKUTYPE ?? '';
                //   skuData.discount = int.parse(info[i].sKUDISCOUNT ?? '');
                //   skuData.netDiscount = info[i].SKUPREDISCOUNT;
                //   skuData.quantity = (info[i].tOTALQTY ?? '1').isEmpty
                //       ? '1'
                //       : info[i].tOTALQTY;
                //   skuData.totalPrice = int.parse(info[i].tOTALPRICE ?? '0');

                //   skuData.totalPriceAfterDiscount =
                //       int.parse(info[i].tOTALPRICE ?? '0');
                //   skuData.aREAINFO = [];
                //   skuData.totalPrice = int.parse(info[i].tOTALPRICE ?? '0');

                //   skuData.index = 0;
                //   skuData.areaInfo = info[i].aREADATA;
                //   // for (Area element in info[i].aREADATA ?? []) {
                //   //   logger('Area in DATA: ${element.areaname}');

                //   //   (skuData.areaInfo ?? []).add(Area(
                //   //       areaname: element.areaname,
                //   //       areaqty: element.areaqty));
                //   // }
                //   logger('Area Data: ${json.encode(skuData.areaInfo)}');

                //   skuData.skuTypeExpanded = '';
                //   skuData.productCardDescriptior = '';
                //   price += skuData.totalPriceAfterDiscount ?? 0;

                //   skuList.add(skuData);

                //   if (!skuResponseLists.contains(skuData)) {
                //     logger("In if condition:::");
                //     skuResponseLists.add((skuData));
                //   }

                //   if (!Journey.skuResponseLists.contains(skuData)) {
                //     logger("In if condition:::");
                //     Journey.skuResponseLists.add((skuData));
                //   }
                // }

                // int total = int.parse(projectDescriptionBloc
                //         .getProjectDescriptionModel
                //         ?.data?[0]
                //         .qUOTEINFO?[0]
                //         .totalwithgst ??
                //     '');
                // logger('Total: $total');
                // int gstAmount = total - (total * (100 / (100 + 18))).round();
                // int netPrice = total - gstAmount;
                // Journey.totalPrice = netPrice.round();
                // logger('Total after gst: $netPrice');

                // logger('Quantity: ${skuResponseLists.length}');

                // // Journey.skuResponseLists = skuResponseLists;

                // final secureStorageProvider =
                //     getSingleton<SecureStorageProvider>();
                // secureStorageProvider.saveQuoteToDisk(Journey.skuResponseLists);
                // secureStorageProvider.saveCartDetails(skuResponseLists);

                // secureStorageProvider.saveTotalPrice(total.toString());

                // secureStorageProvider.saveProjectID(widget.projectID);

                // setState(
                //   () {
                //     int cartCount = Journey.skuResponseLists.length;
                //     secureStorageProvider.saveCartCount(cartCount);
                //     secureStorageProvider.saveProjectID(widget.projectID);
                //     logger('Cart count: $cartCount');
                //   },
                // );
                FlipQuoteBloc flipQuoteBloc = context.read<FlipQuoteBloc>();
                int quantity = 0;
                int price = 0;
                SKUResponse skuResponse = SKUResponse();
                List<Quoteinfo> quoteInfoList = [];
                List<SKUData> skuResponseLists = [];
                List<SKUData> skuList = [];
                List<SKUListData> info =
                    flipQuoteBloc.responseModel?.data?.data ?? [];
                int total = 0;

                for (int i = 0; i < info.length; i++) {
                  logger('Quantity: ${info[i].qUANTITY}');
                  logger('Area Data: ${json.encode(info[i].aREAINFOBJ)}');

                  quantity = (info[i].qUANTITY ?? '1').isEmpty
                      ? int.parse('1')
                      : int.parse(info[i].qUANTITY ?? '1');

                  price = price +
                      quantity * int.parse(skuResponse.data?[i].sKUMRP ?? '0');

                  SKUData skuData = SKUData();
                  skuData.sKURANGE = info[i].sKURANGE ?? '';
                  skuData.sKUIMAGE = info[i].sKUIMAGE ?? '';
                  skuData.sKUCATEGORY = info[i].sKUCATEGORY ?? '';
                  skuData.sKUUSP = info[i].sKUUSP ?? '';
                  skuData.sKUPRODUCTCAT = info[i].sKUPRODUCTCAT ?? '';
                  skuData.sKUDESCRIPTION = info[i].sKUDESCRIPTION ?? '';
                  skuData.complementary = [];
                  skuData.sKUMRP = info[i].sKUMRP ?? '';
                  skuData.sKUCODE = info[i].sKUCODE ?? '';
                  skuData.sKUSRP = info[i].sKUSRP ?? '';
                  skuData.sKUDRAWING = info[i].sKUDRAWING ?? '';
                  skuData.sKUBRAND = info[i].sKUBRAND ?? '';
                  logger('Area Info: ${json.encode(skuData.aREAINFO)}');

                  for (String element in info[i].aREAINFO ?? []) {
                    logger('Area: ${element}');

                    (skuData.aREAINFO ?? []).add(element);
                  }

                  skuData.skuCatCode = info[i].sKUCATCODE ?? '';
                  skuData.sKUTYPE = info[i].sKUTYPE ?? '';
                  skuData.discount = info[i].dISCOUNT;
                  skuData.netDiscount = info[i].nETDICOUNT.toString();
                  skuData.quantity = (info[i].qUANTITY ?? '1').isEmpty
                      ? '1'
                      : info[i].qUANTITY;
                  skuData.totalPrice = info[i].tOTALPRICE;

                  skuData.totalPriceAfterDiscount = info[i].tOTALPRICE;
                  skuData.aREAINFO = [];
                  skuData.totalPrice = info[i].tOTALPRICE;

                  skuData.index = 0;
                  // skuData.areaInfo = info[i].aREAINFOBJ;
                  for (AREAINFOBJ element in info[i].aREAINFOBJ ?? []) {
                    logger('Area in DATA: ${element.aREA}');

                    (skuData.areaInfo ?? []).add(
                        Area(areaname: element.aREA, areaqty: element.qTY));
                  }
                  logger('Area Data: ${json.encode(skuData.areaInfo)}');

                  skuData.skuTypeExpanded = '';
                  skuData.productCardDescriptior = '';
                  price += skuData.totalPriceAfterDiscount ?? 0;

                  skuList.add(skuData);

                  if (!skuResponseLists.contains(skuData)) {
                    logger("In if condition:::");
                    skuResponseLists.add((skuData));
                  }

                  if (!Journey.skuResponseLists.contains(skuData)) {
                    logger("In if condition:::");
                    Journey.skuResponseLists.add((skuData));
                  }
                  total += info[i].tOTALPRICEAFTERDISCOUNT ?? 0;
                }

                logger('Total: $total');
                int gstAmount = total - (total * (100 / (100 + 18))).round();
                int netPrice = total - gstAmount;
                Journey.totalPrice = netPrice.round();
                logger('Total after gst: $netPrice');

                logger('Quantity: ${skuResponseLists.length}');

                // Journey.skuResponseLists = skuResponseLists;

                final secureStorageProvider =
                    getSingleton<SecureStorageProvider>();
                secureStorageProvider.saveQuoteToDisk(Journey.skuResponseLists);
                secureStorageProvider.saveCartDetails(skuResponseLists);

                secureStorageProvider.saveTotalPrice(total.toString());

                secureStorageProvider.saveProjectID(widget.projectID);

                // setState(
                //   () {
                int cartCount = Journey.skuResponseLists.length;
                secureStorageProvider.saveCartCount(cartCount);
                secureStorageProvider.saveProjectID(widget.projectID);
                logger('Cart count: $cartCount');

                Future.delayed(
                  const Duration(seconds: 3),
                );

                // Journey.quoteName = widget.quoteName;
                // Journey.quoteID = widget.quoteID;
                // secureStorageProvider.saveProjectID(widget.projectID);
                Journey.fromFlip = true;

                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewQuote(
                      catIndex: 0,
                      brandIndex: 0,
                      rangeIndex: 0,
                      category: widget.category,
                      brand: widget.brand,
                      range: widget.range,
                      quantity: quantity.toString(),
                      skuResponseList: skuResponseLists,
                      fromFlip: false,
                      projectID: widget.projectID ?? '',
                      fromFlipScreen: false,
                      totalWithGST: int.parse(widget.totalAfterGst ?? '0'),
                      totalDiscountAmount:
                          int.parse(widget.discountAmount ?? '0'),
                    ),
                  ),
                );

                // _secureStorageProvider.saveQuoteToDisk(skuResponseList);
              }
            },
            builder: (context, state) {
              ProjectDescriptionBloc projectDescriptionBloc =
                  context.read<ProjectDescriptionBloc>();
              return InkWell(
                onTap: () {
                  if ((widget.range ?? '').isEmpty) {
                    Navigator.pop(context);
                    showDialog(
                      useSafeArea: true,
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        title: const Text("Cannot flip!!"),
                        content: const Text(
                            "This Quote doesn't have sku's mapped to CP range."),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Ok'),
                          ),
                        ],
                      ),
                    );
                  } else if (!(widget.isFlipAvailable ?? true)) {
                    FlutterToastProvider().show(
                        message: 'Flip range not available for this quote');
                  } else {
                    FlipQuoteBloc flipQuoteBloc = context.read<FlipQuoteBloc>();

                    Dialog flipQuoteDialog = Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      child: BlocConsumer<FlipQuoteBloc, FlipQuoteState>(
                        listener: (context, state) {
                          if (state is FlipQuoteLoaded) {
                            logger(
                                'In Listener: ${flipQuoteBloc.responseModel}');
                            if (flipQuoteBloc.responseModel?.matchedStatus ??
                                true) {
                              Navigator.pop(context);

                              if (Journey.skuResponseLists.isNotEmpty) {
                                showCreateExistingDialogWeb(
                                    context,
                                    widget.projectID ?? '',
                                    widget.quoteID ?? '',
                                    widget.category ?? '',
                                    widget.brand ?? '',
                                    widget.range ?? '',
                                    selectedValue ?? '');
                              } else {
                                projectDescriptionBloc.getProjectDescription(
                                    projectID: widget.projectID ?? '',
                                    quoteID: widget.quoteID);
                              }
                            } else {
                              // Navigator.pop(context);
                              showAlertDialog(BuildContext context) {
                                // set up the buttons
                                Widget cancelButton = TextButton(
                                  child: const Text("No"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                );
                                Widget continueButton = TextButton(
                                  child: const Text("Yes"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    if (Journey.skuResponseLists.isNotEmpty) {
                                      showCreateExistingDialogWeb(
                                          context,
                                          widget.projectID ?? '',
                                          widget.quoteID ?? '',
                                          widget.category ?? '',
                                          widget.brand ?? '',
                                          widget.range ?? '',
                                          selectedValue ?? '');
                                    } else {
                                      projectDescriptionBloc
                                          .getProjectDescription(
                                              projectID: widget.projectID ?? '',
                                              quoteID: widget.quoteID);
                                    }
                                  },
                                );

                                // set up the AlertDialog
                                AlertDialog alert = AlertDialog(
                                  title: const Text("AlertDialog"),
                                  content: SizedBox(
                                    width: 350,
                                    height: 250,
                                    child: SingleChildScrollView(
                                      child: SizedBox(
                                        width: double.maxFinite,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            (flipQuoteBloc.responseModel
                                                            ?.notmatchedlist ??
                                                        [])
                                                    .isNotEmpty
                                                ? Scrollbar(
                                                    thumbVisibility: true,
                                                    child: SizedBox(
                                                      height: 150,
                                                      child: ListView.separated(
                                                        separatorBuilder:
                                                            (context, index) =>
                                                                const Divider(),
                                                        shrinkWrap: true,
                                                        itemCount: (flipQuoteBloc
                                                                    .responseModel
                                                                    ?.notmatchedlist ??
                                                                [])
                                                            .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          var result = flipQuoteBloc
                                                                  .responseModel
                                                                  ?.notmatchedlist?[
                                                              index];
                                                          return ListTile(
                                                            dense: true,
                                                            visualDensity:
                                                                const VisualDensity(
                                                                    vertical:
                                                                        -3),
                                                            tileColor: const Color
                                                                    .fromARGB(1,
                                                                149, 147, 147),
                                                            title: Text(
                                                                result ?? '',
                                                                style: TextStyle(
                                                                    color: AsianPaintColors
                                                                        .blackColor)),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(
                                                    height: 0,
                                                  ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              flipQuoteBloc.responseModel
                                                      ?.matchedText ??
                                                  '',
                                              style: TextStyle(
                                                  color: AsianPaintColors
                                                      .blackColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    cancelButton,
                                    continueButton,
                                  ],
                                );

                                // show the dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return alert;
                                  },
                                );
                              }

                              showAlertDialog(context);
                            }
                          }
                        },
                        builder: (context, state) {
                          logger('Range: ${widget.range}');
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return SizedBox(
                                height: 300,
                                width: 400,
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop(context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 15, 20, 0),
                                            child: Image.asset(
                                              'assets/images/cancel.png',
                                              width: 15,
                                              height: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Choose Range",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: AsianPaintsFonts
                                                .bathSansRegular,
                                            color: AsianPaintColors
                                                .buttonTextColor,
                                            //fontWeight: FontWeight.,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 0),
                                      child: Text(
                                        "Choose a Range to Flip your existing quote.",
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontFamily:
                                                AsianPaintsFonts.mulishMedium,
                                            color: AsianPaintColors
                                                .textFieldLabelColor),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 20, 0, 0),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 70,
                                          child: TextFormField(
                                            enableInteractiveSelection: false,
                                            initialValue: widget.range,
                                            style: TextStyle(
                                              color: AsianPaintColors
                                                  .skuDescriptionColor,
                                              fontSize: 10,
                                            ),
                                            decoration: InputDecoration(
                                              enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: AsianPaintColors
                                                          .textFieldUnderLineColor)),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                color: AsianPaintColors
                                                    .textFieldUnderLineColor,
                                              )),
                                              filled: true,
                                              focusColor: AsianPaintColors
                                                  .textFieldUnderLineColor,
                                              fillColor: AsianPaintColors
                                                  .textFieldBorderColor,
                                              border:
                                                  const UnderlineInputBorder(),
                                              labelText:
                                                  'Current Range', //AppLocalizations.of(context).user_id,
                                              labelStyle: TextStyle(
                                                  fontFamily: AsianPaintsFonts
                                                      .mulishBold,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 10,
                                                  color: AsianPaintColors
                                                      .textFieldLabelColor),
                                            ),
                                          ),
                                        ),
                                        Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 20, 0, 0),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 70,
                                            child: Autocomplete(
                                              optionsBuilder: ((TextEditingValue
                                                  textValue) {
                                                selectedValue = textValue.text;
                                                return (widget.flipRange ?? [])
                                                    .where((ele) => ele
                                                        .toLowerCase()
                                                        .startsWith(textValue
                                                            .text
                                                            .toLowerCase()));
                                              }),
                                              onSelected: (selectesString) {
                                                print(selectesString);
                                                selectedValue =
                                                    selectesString.toString();
                                              },
                                              optionsViewBuilder: (context,
                                                  onSelected, options) {
                                                return Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            2.5,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2,
                                                    child: Material(
                                                      child: Scrollbar(
                                                        thumbVisibility: true,
                                                        child:
                                                            ListView.separated(
                                                                // padding: EdgeInsets.zero,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  final option =
                                                                      options.elementAt(
                                                                          index);

                                                                  return ListTile(
                                                                    dense: true,
                                                                    visualDensity:
                                                                        const VisualDensity(
                                                                            vertical:
                                                                                -4),
                                                                    title: Text(
                                                                      option
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontFamily: AsianPaintsFonts
                                                                              .mulishRegular,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                    onTap: () {
                                                                      onSelected(
                                                                          option);
                                                                    },
                                                                  );
                                                                },
                                                                separatorBuilder:
                                                                    (context,
                                                                            index) =>
                                                                        const Divider(),
                                                                itemCount:
                                                                    options
                                                                        .length),
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
                                                  focusNode: focusNode,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishRegular,
                                                      fontSize: 12,
                                                      color: AsianPaintColors
                                                          .skuDescriptionColor),
                                                  decoration: InputDecoration(
                                                      filled: true,
                                                      focusColor: AsianPaintColors
                                                          .textFieldUnderLineColor,
                                                      fillColor: AsianPaintColors
                                                          .textFieldBorderColor,
                                                      border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  0),
                                                          borderSide: BorderSide(
                                                              color: AsianPaintColors
                                                                  .createProjectTextBorder)),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  0),
                                                          borderSide: BorderSide(
                                                              color: AsianPaintColors
                                                                  .createProjectTextBorder)),
                                                      enabledBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  0),
                                                          borderSide:
                                                              BorderSide(color: AsianPaintColors.createProjectTextBorder)),
                                                      hintText: 'Select Range*',
                                                      // suffixText:
                                                      //     '*',
                                                      // suffixStyle: TextStyle(
                                                      //     color: AsianPaintColors
                                                      //         .forgotPasswordTextColor),
                                                      hintStyle: const TextStyle(fontSize: 12),
                                                      suffixIcon: Icon(
                                                        Icons.search,
                                                        color: Colors.grey[600],
                                                      )),
                                                  onSubmitted: (value) {
                                                    selectedValue = value;
                                                  },
                                                );
                                              },
                                            )

                                            // DropdownButtonHideUnderline(
                                            //   child: DropdownButton2(
                                            //     isExpanded: false,

                                            //     hint: Text(
                                            //       'Flip Range',
                                            //       maxLines: 1,
                                            //       style: TextStyle(
                                            //         fontFamily:
                                            //             AsianPaintsFonts.mulishMedium,
                                            //         fontSize: 12,
                                            //         fontWeight: FontWeight.w400,
                                            //         color:
                                            //             AsianPaintColors.quantityColor,
                                            //       ),
                                            //       overflow: TextOverflow.ellipsis,
                                            //     ),

                                            //     items: widget.flipRange!.isNotEmpty
                                            //         ? widget.flipRange!
                                            //             .map(
                                            //               (item) =>
                                            //                   DropdownMenuItem<String>(
                                            //                 value: item,
                                            //                 child: Row(
                                            //                   children: [
                                            //                     Text(
                                            //                       item,
                                            //                       maxLines: 1,
                                            //                       style: TextStyle(
                                            //                         fontWeight:
                                            //                             FontWeight.w400,
                                            //                         fontSize: 9,
                                            //                         //fontWeight: FontWeight.bold,
                                            //                         color: AsianPaintColors
                                            //                             .quantityColor,
                                            //                       ),
                                            //                       overflow: TextOverflow
                                            //                           .ellipsis,
                                            //                     ),
                                            //                   ],
                                            //                 ),
                                            //               ),
                                            //             )
                                            //             .toList()
                                            //         : null,
                                            //     value: selectedValue,
                                            //     onChanged: (value) {
                                            //       setState(() {
                                            //         selectedValue = value as String;
                                            //         logger(
                                            //             'Selected value: $selectedValue');
                                            //         logger('Value: $value');
                                            //       });
                                            //     },
                                            //     icon: widget.flipRange!.isNotEmpty
                                            //         ? const Icon(
                                            //             Icons.keyboard_arrow_down_sharp,
                                            //           )
                                            //         : null,
                                            //     iconSize: 25,
                                            //     iconEnabledColor: Colors.black,
                                            //     iconDisabledColor: Colors.black,
                                            //     buttonHeight: 54,
                                            //     //buttonWidth: 300,
                                            //     buttonPadding: const EdgeInsets.only(
                                            //         left: 10, right: 10),
                                            //     buttonDecoration: BoxDecoration(
                                            //       //borderRadius: BorderRadius.circular(14),
                                            //       // border: Border.all(
                                            //       //   color: Colors.black26,
                                            //       // ),
                                            //       color: AsianPaintColors
                                            //           .textFieldBorderColor,
                                            //     ),
                                            //     buttonElevation: 0,
                                            //     itemHeight: 40,
                                            //     itemPadding: const EdgeInsets.only(
                                            //         left: 14, right: 14),
                                            //     dropdownMaxHeight: 200,
                                            //     dropdownWidth: 130,
                                            //     dropdownPadding: null,
                                            //     dropdownDecoration: BoxDecoration(
                                            //       borderRadius:
                                            //           BorderRadius.circular(2),
                                            //       color: Colors.white,
                                            //     ),
                                            //     dropdownElevation: 0,
                                            //     scrollbarRadius:
                                            //         const Radius.circular(40),
                                            //     scrollbarThickness: 5,
                                            //     isDense: true,
                                            //     scrollbarAlwaysShow: true,
                                            //     offset: const Offset(-0, 150),
                                            //   ),
                                            // ),
                                            ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Center(
                                      child: SizedBox(
                                        height: 45,
                                        width: 350,
                                        child: APElevatedButton(
                                          onPressed: () async {
                                            if (selectedValue?.isNotEmpty ??
                                                false) {
                                              flipQuoteBloc.flipQuote(
                                                  projectID: widget.projectID,
                                                  quoteID: widget.quoteID,
                                                  currentRange: widget.range,
                                                  selectedRange: selectedValue,
                                                  createdType: 'new',
                                                  areYouSure: false,
                                                  quoteName: widget.quoteName);
                                            } else {
                                              FlutterToastProvider().show(
                                                  message:
                                                      'Please select flip range');
                                            }
                                          },
                                          label: state is FlipQuoteLoading
                                              ? SizedBox(
                                                  height: 15,
                                                  width: 15,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: AsianPaintColors
                                                        .whiteColor,
                                                  ),
                                                )
                                              : Text(
                                                  'Flip Quote',
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
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );

                    Future.delayed(
                      const Duration(seconds: 0),
                      () => showDialog(
                        context: context,
                        builder: (context) => flipQuoteDialog,
                      ),
                    );
                  }
                },
                child: SizedBox(
                  width: 120,
                  child: Text(
                    "Flip Quote",
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: AsianPaintsFonts.mulishRegular,
                      fontWeight: FontWeight.w400,
                      color: AsianPaintColors.skuDescriptionColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        PopupMenuItem(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateProject(
                  projectID: widget.projectID,
                  isClone: true,
                  projectName: widget.projectName,
                  contactPerson: widget.contactPerson,
                  mobileNumber: widget.mobileNumber,
                  siteAddress: widget.siteAddress,
                  noOfBathrooms: widget.noOfBathrooms,
                ),
              ),
            ).then((value) => logger(value));
          },
          value: 2,
          child: InkWell(
            onTap: () {
              logger('On tappedd !!!!!!');
              int quantity = 0;
              price = 0;
              List<Projectdetails>? info = projectDetailsList ?? [];
              Journey.skuResponseLists = [];

              for (int i = 0; i < info.length; i++) {
                logger('Quantity: ${info[i].tOTALQTY}');
                logger('Area Data: ${json.encode(info[i].aREADATA)}');

                quantity = int.parse(info[i].tOTALQTY ?? '0');
                // price += int.parse(projectDetailsList?[i].tOTALPRICE ?? '0');

                // price +=
                //     int.parse(info[i].tOTALQTY ?? '0') * int.parse(info[i].sKUMRP ?? '0');

                SKUData skuData = SKUData();
                skuData.sKURANGE = info[i].sKURANGE ?? '';
                skuData.sKUIMAGE = info[i].sKUIMAGE ?? '';
                skuData.sKUCATEGORY = info[i].sKUCATEGORY ?? '';
                skuData.sKUUSP = info[i].sKUUSP ?? '';
                skuData.sKUPRODUCTCAT = info[i].sKUPRODUCTCAT ?? '';
                skuData.sKUDESCRIPTION = info[i].sKUDESCRIPTION ?? '';
                skuData.complementary = [];
                skuData.sKUMRP = info[i].sKUMRP ?? '';
                skuData.sKUCODE = info[i].sKUCODE ?? '';
                skuData.sKUSRP = info[i].sKUSRP ?? '';
                skuData.sKUDRAWING = info[i].sKUDRAWING ?? '';
                skuData.sKUBRAND = info[i].sKUBRAND ?? '';
                logger('Area Info: ${json.encode(skuData.aREAINFO)}');

                for (Area element in info[i].aREADATA ?? []) {
                  logger('Area: ${element.areaname}');

                  (skuData.aREAINFO ?? []).add(element.areaname ?? '');
                }

                skuData.skuCatCode = info[i].sKUCATCODE ?? '';
                skuData.sKUTYPE = info[i].sKUTYPE ?? '';
                skuData.discount = int.parse(info[i].sKUDISCOUNT ?? '');
                skuData.netDiscount = info[i].SKUPREDISCOUNT;
                skuData.quantity =
                    (info[i].tOTALQTY ?? '1').isEmpty ? '1' : info[i].tOTALQTY;
                skuData.totalPrice = int.parse(info[i].tOTALPRICE ?? '0');

                skuData.totalPriceAfterDiscount =
                    int.parse(info[i].tOTALPRICE ?? '0');
                skuData.aREAINFO = [];
                skuData.totalPrice = int.parse(info[i].tOTALPRICE ?? '0');

                skuData.index = 0;
                skuData.areaInfo = info[i].aREADATA;
                // for (Area element in info[i].aREADATA ?? []) {
                //   logger('Area in DATA: ${element.areaname}');

                //   (skuData.areaInfo ?? []).add(Area(
                //       areaname: element.areaname,
                //       areaqty: element.areaqty));
                // }
                logger('Area Data: ${json.encode(skuData.areaInfo)}');

                skuData.skuTypeExpanded = '';
                skuData.productCardDescriptior = '';
                price += skuData.totalPriceAfterDiscount ?? 0;

                if (!Journey.skuResponseLists.contains(skuData)) {
                  logger("In if condition:::");
                  Journey.skuResponseLists.add((skuData));
                }
              }

              logger('Journey length ${Journey.skuResponseLists.length}');
              final secureStorageProvider =
                  getSingleton<SecureStorageProvider>();
              secureStorageProvider.saveQuoteToDisk(Journey.skuResponseLists);

              secureStorageProvider.saveTotalPrice(widget.totalAfterGst);
              // quantity = 0;
              // int quantity = 0;
              int cartCount = 0;
              setState(
                () {
                  for (int i = 0; i < Journey.skuResponseLists.length; i++) {
                    quantity +=
                        int.parse(Journey.skuResponseLists[i].quantity ?? '');
                  }
                  cartCount = Journey.skuResponseLists.length;
                  secureStorageProvider.saveCartCount(cartCount);
                  logger('Cart count: $cartCount');
                  logger('Quantity: $quantity');
                },
              );

              FlutterToastProvider()
                  .show(message: "Successfully added SKU's to Quote!!");

              Navigator.pop(context);
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
                        totalWithGST: int.parse(widget.totalAfterGst ?? '0'),
                        totalDiscountAmount:
                            int.parse(widget.discountAmount ?? '0'),
                      ),
                    ),
                  );
                },
              );
            },
            child: Text(
              "Copy Quote",
              style: TextStyle(
                fontSize: 12,
                fontFamily: AsianPaintsFonts.mulishRegular,
                fontWeight: FontWeight.w400,
                color: AsianPaintColors.skuDescriptionColor,
              ),
            ),
          ),
        ),
      ],
    ).then((value) {
// NOTE: even you didnt select item this method will be called with null of value so you should call your call back with checking if value is not null

      if (value != null) print(value);
    });
  }

  void showCreateExistingDialogAddSku(BuildContext context, String mode) {
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
                                        final secureStorageProvider =
                                            getSingleton<
                                                SecureStorageProvider>();

                                        secureStorageProvider.saveQuoteToDisk(
                                            Journey.skuResponseLists);
                                        secureStorageProvider.saveCartCount(0);
                                      }
                                      List<String> sampleArea = <String>[
                                        'Showers'
                                      ];

                                      List<SKUData> skuDataList = [];
                                      List<Area> areaInfo = [];
                                      List<String> areas = [];
                                      for (int i = 0;
                                          i < projectDetailsList!.length;
                                          i++) {
                                        SKUData skuData = SKUData();
                                        skuData.sKURANGE =
                                            projectDetailsList?[i].sKURANGE ??
                                                '';
                                        skuData.sKUIMAGE =
                                            projectDetailsList?[i].sKUIMAGE;
                                        skuData.sKUCATEGORY =
                                            projectDetailsList?[i]
                                                    .sKUCATEGORY ??
                                                '';
                                        skuData.sKUUSP =
                                            projectDetailsList?[i].sKUUSP ?? '';
                                        skuData.sKUPRODUCTCAT =
                                            projectDetailsList?[i]
                                                    .sKUPRODUCTCAT ??
                                                '';
                                        skuData.sKUDESCRIPTION =
                                            projectDetailsList?[i]
                                                    .sKUDESCRIPTION ??
                                                '';
                                        skuData.complementary = [];
                                        skuData.sKUMRP =
                                            projectDetailsList?[i].sKUMRP ?? '';
                                        skuData.sKUCODE =
                                            projectDetailsList?[i].sKUCODE ??
                                                '';
                                        skuData.sKUSRP =
                                            projectDetailsList?[i].sKUSRP ?? '';
                                        skuData.sKUDRAWING =
                                            projectDetailsList?[i].sKUDRAWING ??
                                                '';
                                        skuData.sKUBRAND =
                                            projectDetailsList?[i].sKUBRAND ??
                                                '';

                                        skuData.skuCatCode =
                                            projectDetailsList?[i].sKUCATCODE ??
                                                '';
                                        skuData.sKUTYPE =
                                            projectDetailsList?[i].sKUTYPE ??
                                                '';
                                        skuData.discount = int.parse(
                                            projectDetailsList?[i]
                                                    .sKUDISCOUNT ??
                                                '');
                                        skuData.netDiscount =
                                            projectDetailsList?[i]
                                                .SKUPREDISCOUNT;
                                        skuData.quantity =
                                            projectDetailsList?[i].tOTALQTY ??
                                                '';
                                        skuData.totalPrice = int.parse(
                                            projectDetailsList?[i].tOTALPRICE ??
                                                '0');
                                        skuData.totalPriceAfterDiscount =
                                            int.parse(projectDetailsList?[i]
                                                    .tOTALPRICE ??
                                                '0');
                                        areas = [];
                                        areas.add('SHOWER_AREA');
                                        skuData.aREAINFO = areas;
                                        areaInfo = [];

                                        for (Area element
                                            in (projectDetailsList?[i]
                                                    .aREADATA ??
                                                [])) {
                                          logger(
                                              'In Project Details: ${json.encode(projectDetailsList?[i].aREADATA)}');
                                          areaInfo.add(Area(
                                              areaname: element.areaname,
                                              areaqty: element.areaqty));

                                          logger(
                                              'In Project Details: ${json.encode(skuData.aREAINFO)}');
                                        }
                                        skuData.areaInfo = areaInfo;
                                        price +=
                                            skuData.totalPriceAfterDiscount ??
                                                0;
                                        // skuDataList.add(skuData);
                                        Journey.skuResponseLists.add(skuData);
                                      }
                                      logger(
                                          'Journey length: ${Journey.skuResponseLists.length}');
                                      final secureStorageProvider =
                                          getSingleton<SecureStorageProvider>();

                                      secureStorageProvider.saveQuoteToDisk(
                                          Journey.skuResponseLists);
                                      secureStorageProvider
                                          .saveTotalPrice(price.toString());
                                      setState(
                                        () {
                                          int cartCount =
                                              Journey.skuResponseLists.length;
                                          secureStorageProvider
                                              .saveCartCount(cartCount);
                                          secureStorageProvider
                                              .saveProjectID(widget.projectID);
                                          logger('Cart count: $cartCount');
                                        },
                                      );

                                      Journey.fromFlip = true;

                                      Journey.quoteName =
                                          widget.quoteName ?? '';
                                      Journey.quoteID = widget.quoteID ?? '';
                                      Journey.projectID = widget.projectID;

                                      Journey.selectedIndex = 0;
                                      Navigator.pop(context);
                                      // Journey.skuResponseLists = snapshot.data ?? [];
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

  downloadFile(url) {
    launchUrl(Uri.parse(url));
  }

  void showCreateExistingDialog(
      BuildContext context,
      String projectID,
      String quoteID,
      String category,
      String brand,
      String range,
      String selectedRange) {
    CreateOrExistingFlip? character = CreateOrExistingFlip.create;
    bool isCreateQuoteClicked = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            ProjectDescriptionBloc projectDescriptionBloc =
                context.read<ProjectDescriptionBloc>();
            return Builder(builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: BlocConsumer<FlipQuoteBloc, FlipQuoteState>(
                  builder: (context, state) {
                    return SizedBox(
                      height: 350,
                      width: double.infinity,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 18, 0, 0),
                                child: Text(
                                  "Select Option",
                                  style: TextStyle(
                                    fontFamily:
                                        AsianPaintsFonts.bathSansRegular,
                                    color: AsianPaintColors.buttonTextColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 18, 20, 0),
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
                                padding:
                                    const EdgeInsets.fromLTRB(20, 25, 18, 0),
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
                                padding:
                                    const EdgeInsets.fromLTRB(20, 3, 18, 0),
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
                                            color: AsianPaintColors
                                                .textFieldLabelColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                AsianPaintsFonts.mulishRegular),
                                      ),
                                      leading: Radio<CreateOrExistingFlip>(
                                        activeColor:
                                            AsianPaintColors.buttonTextColor,
                                        fillColor: MaterialStatePropertyAll(
                                            AsianPaintColors.buttonTextColor),
                                        value: CreateOrExistingFlip.create,
                                        groupValue: character,
                                        onChanged:
                                            (CreateOrExistingFlip? value) {
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
                                            color: AsianPaintColors
                                                .textFieldLabelColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                AsianPaintsFonts.mulishRegular),
                                      ),
                                      leading: Radio<CreateOrExistingFlip>(
                                        activeColor:
                                            AsianPaintColors.buttonTextColor,
                                        fillColor: MaterialStatePropertyAll(
                                            AsianPaintColors.buttonTextColor),
                                        value: CreateOrExistingFlip.existing,
                                        groupValue: character,
                                        onChanged:
                                            (CreateOrExistingFlip? value) {
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
                                            FlipQuoteBloc flipQuoteBl =
                                                context.read<FlipQuoteBloc>();

                                            if (isCreateQuoteClicked) {
                                              flipQuoteBl.flipQuote(
                                                  projectID: projectID,
                                                  quoteID: quoteID,
                                                  currentRange: range,
                                                  selectedRange: selectedRange,
                                                  createdType: "new",
                                                  areYouSure: true,
                                                  quoteName: widget.quoteName);
                                            } else {
                                              flipQuoteBl.flipQuote(
                                                  projectID: projectID,
                                                  quoteID: quoteID,
                                                  currentRange: range,
                                                  selectedRange: selectedRange,
                                                  createdType: "new",
                                                  areYouSure: true,
                                                  quoteName: widget.quoteName);
                                            }
                                          },
                                          label: state is FlipQuoteLoading
                                              ? SizedBox(
                                                  height: 15,
                                                  width: 15,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: AsianPaintColors
                                                        .whiteColor,
                                                  ),
                                                )
                                              : Text(
                                                  AppLocalizations.of(context)
                                                      .save,
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
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          30, 15, 18, 5),
                                      child: Text(
                                        "*Creating new quote will delete existing quote",
                                        style: TextStyle(
                                          fontFamily:
                                              AsianPaintsFonts.mulishRegular,
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
                    );
                  },
                  listener: (context, state) {
                    if (state is FlipQuoteLoaded) {
                      if (!isCreateQuoteClicked) {
                        Journey.skuResponseLists = [];
                      }
                      Navigator.pop(context);
                      FlipQuoteBloc flipQuoteBloc =
                          context.read<FlipQuoteBloc>();
                      int quantity = 0;
                      int price = 0;
                      SKUResponse skuResponse = SKUResponse();
                      List<Quoteinfo> quoteInfoList = [];
                      List<SKUData> skuResponseLists = [];
                      List<SKUData> skuList = [];
                      List<SKUListData> info =
                          flipQuoteBloc.responseModel?.data?.data ?? [];
                      int total = 0;

                      for (int i = 0; i < info.length; i++) {
                        logger('Quantity: ${info[i].qUANTITY}');
                        logger('Area Data: ${json.encode(info[i].aREAINFOBJ)}');

                        quantity = (info[i].qUANTITY ?? '1').isEmpty
                            ? int.parse('1')
                            : int.parse(info[i].qUANTITY ?? '1');

                        price = price +
                            quantity *
                                int.parse(skuResponse.data?[i].sKUMRP ?? '0');

                        SKUData skuData = SKUData();
                        skuData.sKURANGE = info[i].sKURANGE ?? '';
                        skuData.sKUIMAGE = info[i].sKUIMAGE ?? '';
                        skuData.sKUCATEGORY = info[i].sKUCATEGORY ?? '';
                        skuData.sKUUSP = info[i].sKUUSP ?? '';
                        skuData.sKUPRODUCTCAT = info[i].sKUPRODUCTCAT ?? '';
                        skuData.sKUDESCRIPTION = info[i].sKUDESCRIPTION ?? '';
                        skuData.complementary = [];
                        skuData.sKUMRP = info[i].sKUMRP ?? '';
                        skuData.sKUCODE = info[i].sKUCODE ?? '';
                        skuData.sKUSRP = info[i].sKUSRP ?? '';
                        skuData.sKUDRAWING = info[i].sKUDRAWING ?? '';
                        skuData.sKUBRAND = info[i].sKUBRAND ?? '';
                        logger('Area Info: ${json.encode(skuData.aREAINFO)}');

                        for (String element in info[i].aREAINFO ?? []) {
                          logger('Area: ${element}');

                          (skuData.aREAINFO ?? []).add(element);
                        }

                        skuData.skuCatCode = info[i].sKUCATCODE ?? '';
                        skuData.sKUTYPE = info[i].sKUTYPE ?? '';
                        skuData.discount = info[i].dISCOUNT;
                        skuData.netDiscount = info[i].nETDICOUNT.toString();
                        skuData.quantity = (info[i].qUANTITY ?? '1').isEmpty
                            ? '1'
                            : info[i].qUANTITY;
                        skuData.totalPrice = info[i].tOTALPRICE;

                        skuData.totalPriceAfterDiscount = info[i].tOTALPRICE;
                        skuData.aREAINFO = [];
                        skuData.totalPrice = info[i].tOTALPRICE;

                        skuData.index = 0;
                        // skuData.areaInfo = info[i].aREAINFOBJ;
                        for (AREAINFOBJ element in info[i].aREAINFOBJ ?? []) {
                          logger('Area in DATA: ${element.aREA}');

                          (skuData.areaInfo ?? []).add(Area(
                              areaname: element.aREA, areaqty: element.qTY));
                        }
                        logger('Area Data: ${json.encode(skuData.areaInfo)}');

                        skuData.skuTypeExpanded = '';
                        skuData.productCardDescriptior = '';
                        price += skuData.totalPriceAfterDiscount ?? 0;

                        skuList.add(skuData);

                        if (!skuResponseLists.contains(skuData)) {
                          logger("In if condition:::");
                          skuResponseLists.add((skuData));
                        }

                        if (!Journey.skuResponseLists.contains(skuData)) {
                          logger("In if condition:::");
                          Journey.skuResponseLists.add((skuData));
                        }
                        total += info[i].tOTALPRICEAFTERDISCOUNT ?? 0;
                      }

                      logger('Total: $total');
                      int gstAmount =
                          total - (total * (100 / (100 + 18))).round();
                      int netPrice = total - gstAmount;
                      Journey.totalPrice = netPrice.round();
                      logger('Total after gst: $netPrice');

                      logger('Quantity: ${skuResponseLists.length}');

                      // Journey.skuResponseLists = skuResponseLists;

                      final secureStorageProvider =
                          getSingleton<SecureStorageProvider>();
                      secureStorageProvider
                          .saveQuoteToDisk(Journey.skuResponseLists);
                      secureStorageProvider.saveCartDetails(skuResponseLists);

                      secureStorageProvider.saveTotalPrice(total.toString());

                      secureStorageProvider.saveProjectID(widget.projectID);

                      setState(
                        () {
                          int cartCount = Journey.skuResponseLists.length;
                          secureStorageProvider.saveCartCount(cartCount);
                          secureStorageProvider.saveProjectID(widget.projectID);
                          logger('Cart count: $cartCount');
                        },
                      );

                      // Journey.skuResponseLists = skuResponseLists;

                      // final secureStorageProvider =
                      //     getSingleton<SecureStorageProvider>();
                      // secureStorageProvider
                      //     .saveQuoteToDisk(Journey.skuResponseLists);
                      // secureStorageProvider.saveCartDetails(skuResponseLists);
                      // secureStorageProvider.saveCategory(category);
                      // secureStorageProvider.saveBrand(brand);
                      // secureStorageProvider.saveRange(range);
                      // secureStorageProvider.saveTotalPrice(total.toString());

                      // secureStorageProvider.saveProjectID(projectID);

                      // setState(
                      //   () {
                      //     int cartCount = Journey.skuResponseLists.length;
                      //     secureStorageProvider.saveCartCount(cartCount);
                      //     secureStorageProvider.saveProjectID(widget.projectID);
                      //     logger('Cart count: $cartCount');
                      //   },
                      // );

                      Future.delayed(
                        const Duration(seconds: 3),
                      );

                      // Journey.quoteName = widget.quoteName;
                      // Journey.quoteID = widget.quoteID;
                      // secureStorageProvider.saveProjectID(widget.projectID);
                      Journey.fromFlip = true;

                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewQuote(
                            catIndex: 0,
                            brandIndex: 0,
                            rangeIndex: 0,
                            category: category,
                            brand: brand,
                            range: selectedRange,
                            quantity: quantity.toString(),
                            skuResponseList: skuResponseLists,
                            fromFlip: false,
                            projectID: projectID,
                            fromFlipScreen: false,
                            totalWithGST:
                                int.parse(widget.totalAfterGst ?? '0'),
                            totalDiscountAmount:
                                int.parse(widget.discountAmount ?? '0'),
                          ),
                        ),
                      );

                      // _secureStorageProvider.saveQuoteToDisk(skuResponseList);
                    }
                  },
                ),
              );
            });
          },
        );
      },
    );
  }

  void calculateSKU(String projectID, String quoteID, String category,
      String brand, String range, String selectedRange) {
    logger('Quantity before:');

    BlocProvider(
        create: (context) {
          return ProjectDescriptionBloc()
            ..getProjectDescription(projectID: projectID, quoteID: quoteID);
        },
        child: BlocConsumer<ProjectDescriptionBloc, ProjectsDescriptionState>(
          builder: (context, state) {
            return const SizedBox();
          },
          listener: (context, state) {
            if (state is ProjectDescriptionLoaded) {
              ProjectDescriptionBloc projectDescriptionBloc =
                  context.read<ProjectDescriptionBloc>();
              Navigator.pop(context);
              int quantity = 0;
              int price = 0;
              SKUResponse skuResponse = SKUResponse();
              List<Quoteinfo> quoteInfoList = [];
              List<SKUData> skuResponseLists = [];
              List<SKUData> skuList = [];
              List<Projectdetails>? info = projectDescriptionBloc
                      .getProjectDescriptionModel
                      ?.data?[0]
                      .qUOTEINFO?[0]
                      .projectdetails ??
                  [];

              logger('Quantity: ${info.length}');

              for (int i = 0; i < info.length; i++) {
                quantity = (info[i].tOTALQTY ?? '0').isEmpty
                    ? 1
                    : int.parse(info[i].tOTALQTY ?? '0');

                price = price +
                    quantity * int.parse(skuResponse.data?[i].sKUMRP ?? '0');

                SKUData skuData = SKUData();
                skuData.sKURANGE = info[i].sKURANGE ?? '';
                skuData.sKUIMAGE = info[i].sKUIMAGE ?? '';
                skuData.sKUCATEGORY = info[i].sKUCATEGORY ?? '';
                skuData.sKUUSP = info[i].sKUUSP ?? '';
                skuData.sKUPRODUCTCAT = info[i].sKUPRODUCTCAT ?? '';
                skuData.sKUDESCRIPTION = info[i].sKUDESCRIPTION ?? '';
                skuData.complementary = [];
                skuData.sKUMRP = info[i].sKUMRP ?? '';
                skuData.sKUCODE = info[i].sKUCODE ?? '';
                skuData.sKUSRP = info[i].sKUSRP ?? '';
                skuData.sKUDRAWING = info[i].sKUDRAWING ?? '';
                skuData.sKUBRAND = info[i].sKUBRAND ?? '';
                for (Area element in info[i].aREADATA ?? []) {
                  skuData.aREAINFO?.add(element.areaname ?? '');
                }

                skuData.skuCatCode = info[i].sKUCATCODE ?? '';
                skuData.sKUTYPE = info[i].sKUTYPE ?? '';
                skuData.discount = int.parse(info[i].sKUDISCOUNT ?? '');
                skuData.netDiscount = info[i].SKUPREDISCOUNT;
                skuData.quantity =
                    (info[i].tOTALQTY ?? '1').isEmpty ? '1' : info[i].tOTALQTY;
                skuData.totalPrice = int.parse(info[i].tOTALPRICE ?? '0');

                skuData.totalPriceAfterDiscount =
                    int.parse(info[i].tOTALPRICE ?? '0');
                skuData.aREAINFO = [];
                skuData.totalPrice = int.parse(info[i].tOTALPRICE ?? '0');

                skuData.index = 0;
                for (Area element in info[i].aREADATA ?? []) {
                  skuData.areaInfo?.add(Area(
                      areaname: element.areaname, areaqty: element.areaqty));
                }

                skuData.skuTypeExpanded = '';
                skuData.productCardDescriptior = '';
                price += skuData.totalPriceAfterDiscount ?? 0;

                skuList.add(skuData);

                if (!skuResponseLists.contains(skuData)) {
                  logger("In if condition:::");
                  skuResponseLists.add((skuData));
                }

                if (!Journey.skuResponseLists.contains(skuData)) {
                  logger("In if condition:::");
                  Journey.skuResponseLists.add((skuData));
                }

                if (!skuResponseLists.contains(skuData)) {
                  logger("In if condition:::");
                  skuResponseLists.add((skuData));
                }
              }

              int total = int.parse(projectDescriptionBloc
                      .getProjectDescriptionModel
                      ?.data?[0]
                      .qUOTEINFO?[0]
                      .totalwithgst ??
                  '');
              logger('Total: $total');
              int gstAmount = total - (total * (100 / (100 + 18))).round();
              int netPrice = total - gstAmount;
              Journey.totalPrice = netPrice.round();
              logger('Total after gst: $netPrice');

              logger('Quantity: ${skuResponseLists.length}');

              FlipQuoteBloc flipQuoteBl = context.read<FlipQuoteBloc>();

              flipQuoteBl.flipQuote(
                  projectID: projectID,
                  quoteID: quoteID,
                  currentRange: range,
                  selectedRange: selectedRange,
                  createdType: "new",
                  areYouSure: true,
                  quoteName: widget.quoteName);

              Journey.skuResponseLists = skuResponseLists;

              final secureStorageProvider =
                  getSingleton<SecureStorageProvider>();
              secureStorageProvider.saveQuoteToDisk(Journey.skuResponseLists);
              secureStorageProvider.saveCartDetails(skuResponseLists);
              secureStorageProvider.saveCategory(category);
              secureStorageProvider.saveBrand(brand);
              secureStorageProvider.saveRange(range);
              secureStorageProvider.saveTotalPrice(total.toString());

              secureStorageProvider.saveProjectID(projectID);
              setState(
                () {
                  int cartCount = Journey.skuResponseLists.length;
                  secureStorageProvider.saveCartCount(cartCount);
                  secureStorageProvider.saveProjectID(widget.projectID);
                  logger('Cart count: $cartCount');
                },
              );

              Future.delayed(
                const Duration(seconds: 3),
              );

              Navigator.pop(context);
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
                    quantity: quantity.toString(),
                    skuResponseList: skuResponseLists,
                    fromFlip: false,
                    projectID: projectID,
                    fromFlipScreen: false,
                    totalWithGST: int.parse(widget.totalAfterGst ?? '0'),
                    totalDiscountAmount:
                        int.parse(widget.discountAmount ?? '0'),
                  ),
                ),
              );

              // _secureStorageProvider.saveQuoteToDisk(skuResponseList);
            }
          },
        ));
  }

  void showCreateExistingDialogWeb(
      BuildContext context,
      String projectID,
      String quoteID,
      String category,
      String brand,
      String range,
      String selectedRange) {
    CreateOrExistingFlip? character = CreateOrExistingFlip.create;
    bool isCreateQuoteClicked = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            ProjectDescriptionBloc projectDescriptionBloc =
                context.read<ProjectDescriptionBloc>();
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: BlocConsumer<ProjectDescriptionBloc,
                  ProjectsDescriptionState>(
                builder: (context, state) {
                  return SizedBox(
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
                                          color: AsianPaintColors
                                              .textFieldLabelColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              AsianPaintsFonts.mulishRegular),
                                    ),
                                    leading: Radio<CreateOrExistingFlip>(
                                      activeColor:
                                          AsianPaintColors.buttonTextColor,
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
                                          color: AsianPaintColors
                                              .textFieldLabelColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              AsianPaintsFonts.mulishRegular),
                                    ),
                                    leading: Radio<CreateOrExistingFlip>(
                                      activeColor:
                                          AsianPaintColors.buttonTextColor,
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
                                          // FlipQuoteBloc flipQuoteBloc = context.read<FlipQuoteBloc>();
                                          // projectDescriptionBloc
                                          //     .getProjectDescription(
                                          //         projectID: projectID,
                                          //         quoteID: quoteID);
                                          FlipQuoteBloc flipQuoteBl =
                                              context.read<FlipQuoteBloc>();

                                          if (isCreateQuoteClicked) {
                                            flipQuoteBl.flipQuote(
                                                projectID: projectID,
                                                quoteID: quoteID,
                                                currentRange: range,
                                                selectedRange: selectedRange,
                                                createdType: "new",
                                                areYouSure: true,
                                                quoteName: widget.quoteName);
                                          } else {
                                            flipQuoteBl.flipQuote(
                                                projectID: projectID,
                                                quoteID: quoteID,
                                                currentRange: range,
                                                selectedRange: selectedRange,
                                                createdType: "new",
                                                areYouSure: true,
                                                quoteName: widget.quoteName);
                                          }
                                        },
                                        label: state
                                                is ProjectDescriptionLoading
                                            ? SizedBox(
                                                height: 15,
                                                width: 15,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: AsianPaintColors
                                                      .whiteColor,
                                                ),
                                              )
                                            : Text(
                                                AppLocalizations.of(context)
                                                    .save,
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
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        30, 15, 18, 5),
                                    child: Text(
                                      "*Creating new quote will delete existing quote",
                                      style: TextStyle(
                                        fontFamily:
                                            AsianPaintsFonts.mulishRegular,
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
                  );
                },
                listener: (context, state) {
                  if (state is ProjectDescriptionLoaded) {
                    Navigator.pop(context);
                    if (!isCreateQuoteClicked) {
                      Journey.skuResponseLists = [];
                    }
                    Navigator.pop(context);
                    FlipQuoteBloc flipQuoteBloc = context.read<FlipQuoteBloc>();
                    int quantity = 0;
                    int price = 0;
                    SKUResponse skuResponse = SKUResponse();
                    List<Quoteinfo> quoteInfoList = [];
                    List<SKUData> skuResponseLists = [];
                    List<SKUData> skuList = [];
                    List<SKUListData> info =
                        flipQuoteBloc.responseModel?.data?.data ?? [];
                    int total = 0;

                    for (int i = 0; i < info.length; i++) {
                      logger('Quantity: ${info[i].qUANTITY}');
                      logger('Area Data: ${json.encode(info[i].aREAINFOBJ)}');

                      quantity = (info[i].qUANTITY ?? '1').isEmpty
                          ? int.parse('1')
                          : int.parse(info[i].qUANTITY ?? '1');

                      price = price +
                          quantity *
                              int.parse(skuResponse.data?[i].sKUMRP ?? '0');

                      SKUData skuData = SKUData();
                      skuData.sKURANGE = info[i].sKURANGE ?? '';
                      skuData.sKUIMAGE = info[i].sKUIMAGE ?? '';
                      skuData.sKUCATEGORY = info[i].sKUCATEGORY ?? '';
                      skuData.sKUUSP = info[i].sKUUSP ?? '';
                      skuData.sKUPRODUCTCAT = info[i].sKUPRODUCTCAT ?? '';
                      skuData.sKUDESCRIPTION = info[i].sKUDESCRIPTION ?? '';
                      skuData.complementary = [];
                      skuData.sKUMRP = info[i].sKUMRP ?? '';
                      skuData.sKUCODE = info[i].sKUCODE ?? '';
                      skuData.sKUSRP = info[i].sKUSRP ?? '';
                      skuData.sKUDRAWING = info[i].sKUDRAWING ?? '';
                      skuData.sKUBRAND = info[i].sKUBRAND ?? '';
                      logger('Area Info: ${json.encode(skuData.aREAINFO)}');

                      for (String element in info[i].aREAINFO ?? []) {
                        logger('Area: ${element}');

                        (skuData.aREAINFO ?? []).add(element);
                      }

                      skuData.skuCatCode = info[i].sKUCATCODE ?? '';
                      skuData.sKUTYPE = info[i].sKUTYPE ?? '';
                      skuData.discount = info[i].dISCOUNT;
                      skuData.netDiscount = info[i].nETDICOUNT.toString();
                      skuData.quantity = (info[i].qUANTITY ?? '1').isEmpty
                          ? '1'
                          : info[i].qUANTITY;
                      skuData.totalPrice = info[i].tOTALPRICE;

                      skuData.totalPriceAfterDiscount = info[i].tOTALPRICE;
                      skuData.aREAINFO = [];
                      skuData.totalPrice = info[i].tOTALPRICE;

                      skuData.index = 0;
                      // skuData.areaInfo = info[i].aREAINFOBJ;
                      for (AREAINFOBJ element in info[i].aREAINFOBJ ?? []) {
                        logger('Area in DATA: ${element.aREA}');

                        (skuData.areaInfo ?? []).add(
                            Area(areaname: element.aREA, areaqty: element.qTY));
                      }
                      logger('Area Data: ${json.encode(skuData.areaInfo)}');

                      skuData.skuTypeExpanded = '';
                      skuData.productCardDescriptior = '';
                      price += skuData.totalPriceAfterDiscount ?? 0;

                      skuList.add(skuData);

                      if (!skuResponseLists.contains(skuData)) {
                        logger("In if condition:::");
                        skuResponseLists.add((skuData));
                      }

                      if (!Journey.skuResponseLists.contains(skuData)) {
                        logger("In if condition:::");
                        Journey.skuResponseLists.add((skuData));
                      }
                      total += info[i].tOTALPRICEAFTERDISCOUNT ?? 0;
                    }

                    logger('Total: $total');
                    int gstAmount =
                        total - (total * (100 / (100 + 18))).round();
                    int netPrice = total - gstAmount;
                    Journey.totalPrice = netPrice.round();
                    logger('Total after gst: $netPrice');

                    logger('Quantity: ${skuResponseLists.length}');

                    // Journey.skuResponseLists = skuResponseLists;

                    final secureStorageProvider =
                        getSingleton<SecureStorageProvider>();
                    secureStorageProvider
                        .saveQuoteToDisk(Journey.skuResponseLists);
                    secureStorageProvider.saveCartDetails(skuResponseLists);

                    secureStorageProvider.saveTotalPrice(total.toString());

                    secureStorageProvider.saveProjectID(widget.projectID);

                    setState(
                      () {
                        int cartCount = Journey.skuResponseLists.length;
                        secureStorageProvider.saveCartCount(cartCount);
                        secureStorageProvider.saveProjectID(widget.projectID);
                        logger('Cart count: $cartCount');
                      },
                    );

                    // final secureStorageProvider =
                    //     getSingleton<SecureStorageProvider>();
                    // secureStorageProvider
                    //     .saveQuoteToDisk(Journey.skuResponseLists);
                    // secureStorageProvider.saveCartDetails(skuResponseLists);
                    // secureStorageProvider.saveCategory(category);
                    // secureStorageProvider.saveBrand(brand);
                    // secureStorageProvider.saveRange(range);
                    // secureStorageProvider.saveTotalPrice(price.toString());

                    // setState(
                    //   () {
                    //     int cartCount = Journey.skuResponseLists.length;
                    //     secureStorageProvider.saveCartCount(cartCount);
                    //     secureStorageProvider.saveProjectID(widget.projectID);
                    //     logger('Cart count: $cartCount');
                    //   },
                    // );

                    Future.delayed(const Duration(seconds: 3));
                    Journey.quoteName = widget.quoteName;
                    Journey.quoteID = widget.quoteID;
                    Navigator.pop(context);
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
                          quantity: quantity.toString(),
                          skuResponseList: skuResponseLists,
                          fromFlip: isCreateQuoteClicked,
                          projectID: projectID,
                          totalWithGST: int.parse(widget.totalAfterGst ?? '0'),
                          totalDiscountAmount:
                              int.parse(widget.discountAmount ?? '0'),
                        ),
                      ),
                    );

                    // _secureStorageProvider.saveQuoteToDisk(skuResponseList);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
