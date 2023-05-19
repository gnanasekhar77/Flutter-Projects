// import 'package:APaints_QGen/src/core/utils/colors.dart';
// import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'dart:io';

import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/project_description_response_model.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/presentation/blocs/email_template/email_template_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/email_template/email_template_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/clone_project/clone_project_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/delete_quote/delete_quote_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/delete_quote/delete_quote_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/export_project/export_project_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/export_project/export_project_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/project_description.dart/project_description_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/project_description.dart/project_description_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/search/search_bloc.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/quick_quote.dart';
import 'package:APaints_QGen/src/presentation/views/home/home_screen.dart';
import 'package:APaints_QGen/src/presentation/views/project/create_project.dart';
import 'package:APaints_QGen/src/presentation/views/project/projects_list.dart';
import 'package:APaints_QGen/src/presentation/views/project/view_quote_in_project.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/view_quote.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/elevated_button.dart';
import 'package:APaints_QGen/src/presentation/widgets/pdf_cache_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../responsive.dart';
import '../../widgets/app_bar.dart';
import 'package:badges/badges.dart' as badges;

class ProjectDescription extends StatefulWidget {
  final String? projectID;
  final String? projectName;
  final String? contactPerson;
  final String? mobileNumber;
  final String? siteAddress;
  final String? noOfBathrooms;
  const ProjectDescription({
    Key? key,
    this.projectID,
    this.projectName,
    this.contactPerson,
    this.mobileNumber,
    this.siteAddress,
    this.noOfBathrooms,
  }) : super(key: key);

  @override
  State<ProjectDescription> createState() => ProjectDescriptionState();
}

class ProjectDescriptionState extends State<ProjectDescription> {
  final projectNameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final siteAddressController = TextEditingController();
  final noBathroomsController = TextEditingController();
  late ProjectDescriptionBloc projectDescriptionBloc;
  String? category;
  int grandTotal = 0;
  String? brand;
  String? range;
  bool? _showCartBadge;
  Color color = Colors.red;

  bool loadingStatus = false;
  String? userName = "";
  int? cartBadgeAmount;

  @override
  void initState() {
    super.initState();
    projectNameController.text = widget.projectName ?? '';
    contactPersonController.text = widget.contactPerson ?? '';
    mobileNumberController.text = widget.mobileNumber ?? '';
    siteAddressController.text = widget.siteAddress ?? '';
    noBathroomsController.text = widget.noOfBathrooms ?? '';
    getUsername();
  }

  final secureStorageProvider = getSingleton<SecureStorageProvider>();

  void clearCartCount() async {
    setState(() {
      secureStorageProvider.saveCartCount(0);
    });
  }

  Future<List<SKUData>> getSkuList() async {
    category = await secureStorageProvider.getCategory();
    logger('Category: $category');
    brand = await secureStorageProvider.getBrand();
    range = await secureStorageProvider.getRange();
    // cartCount = await secureStorageProvider.getCartCount();

    return List<SKUData>.from(
        await secureStorageProvider.getQuoteFromDisk() as Iterable);
  }

  Future<String?> getUsername() async {
    userName = await secureStorageProvider.read(key: 'username');
    cartBadgeAmount = await secureStorageProvider.getCartCount();
    logger("Cart Amount in init: $cartBadgeAmount");

    return userName;
  }

  Widget _shoppingCartBadge(
      List<SKUData> skuData, String category, String brand, String range) {
    if (cartBadgeAmount != null) {
      _showCartBadge = cartBadgeAmount! > 0;
    }
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: 0, end: 3),
      showBadge: _showCartBadge ?? false,
      badgeColor: color,
      badgeContent: Text(
        cartBadgeAmount.toString(),
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

  @override
  Widget build(BuildContext context) {
    Journey.projectID = '';

    clearCartCount();
    return Responsive(
      mobile: WillPopScope(
        onWillPop: () async {
          // do something here
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const ProjectsList();
              },
            ),
          );
          return true;
        },
        child: Scaffold(
          backgroundColor: AsianPaintColors.appBackgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 10.0,
            elevation: 5.0,
            title: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Journey.area = 'ALL';
                          Journey.selectedIndex = 0;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return HomeScreen(loginType: Journey.loginType);
                              },
                            ),
                          );
                        },
                        child: SvgPicture.asset('assets/images/home.svg'),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Journey.area = 'ALL';
                          Journey.selectedIndex = 0;
                          if (Journey.skuResponseLists.isNotEmpty) {
                            Navigator.pop(context);
                          } else {
                            Journey.area = 'ALL';
                            Journey.selectedIndex = 0;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const ProjectsList();
                                },
                              ),
                            );
                          }
                        },
                        child: SvgPicture.asset('assets/images/back.svg'),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                  Row(children: [
                    Text(
                      'Projects',
                      style: TextStyle(
                          color: AsianPaintColors.whiteColor,
                          fontWeight: FontWeight.w500,
                          fontFamily: AsianPaintsFonts.bathSansRegular),
                    ),
                  ]),
                  Row(
                    children: [
                      _shoppingCartBadge(Journey.skuResponseLists,
                          category ?? '', brand ?? '', range ?? ''),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                          onTap: () {
                            showSearch(
                                context: context,
                                delegate: SearchList(
                                    searchBloc: BlocProvider.of<SearchListBloc>(
                                        context)));
                          },
                          child: SvgPicture.asset('assets/images/search.svg')),
                    ],
                  )
                ],
              ),
            ),
          ),
          // AppBarTemplate(
          //   header: 'Projects',
          //   isVisible: true,
          // ),
          body: MultiBlocProvider(
            providers: [
              BlocProvider<ProjectDescriptionBloc>(
                create: (context) => ProjectDescriptionBloc()
                  ..getProjectDescription(projectID: widget.projectID ?? ''),
              ),
            ],
            child:
                BlocConsumer<ProjectDescriptionBloc, ProjectsDescriptionState>(
              builder: (context, state) {
                if (state is ProjectDescriptionInitial) {
                  const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ProjectDescriptionLoading) {
                  const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ProjectDescriptionLoaded) {
                  projectDescriptionBloc =
                      context.read<ProjectDescriptionBloc>();
                  if (((projectDescriptionBloc
                                  .getProjectDescriptionModel?.data ??
                              [])
                          .isNotEmpty) &&
                      (projectDescriptionBloc.getProjectDescriptionModel
                                  ?.data?[0].qUOTEINFO ??
                              [])
                          .isNotEmpty) {
                    category = projectDescriptionBloc.getProjectDescriptionModel
                            ?.data?[0].qUOTEINFO?[0].category ??
                        '';
                  } else {
                    category = "Sanware & Cisterns";
                  }

                  return Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        // height: MediaQuery.of(context).size.height * 0.28,
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                        child: Card(
                          color: Colors.white,
                          elevation: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  projectDescriptionBloc
                                          .getProjectDescriptionModel
                                          ?.data?[0]
                                          .pROJECTNAME ??
                                      '',
                                  style: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishMedium,
                                    color:
                                        AsianPaintColors.projectUserNameColor,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/user_small.svg',
                                      width: 12,
                                      height: 12,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      projectDescriptionBloc
                                              .getProjectDescriptionModel
                                              ?.data?[0]
                                              .cONTACTPERSON ??
                                          '',
                                      style: TextStyle(
                                        fontFamily:
                                            AsianPaintsFonts.mulishRegular,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
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
                                    SvgPicture.asset(
                                      'assets/images/call.svg',
                                      width: 12,
                                      height: 12,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      projectDescriptionBloc
                                              .getProjectDescriptionModel
                                              ?.data?[0]
                                              .mOBILENUMBER ??
                                          '',
                                      style: TextStyle(
                                        fontFamily:
                                            AsianPaintsFonts.mulishRegular,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          './assets/images/location.png',
                                          width: 12,
                                          height: 12,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .sITEADDRESS ??
                                              '',
                                          style: TextStyle(
                                            fontFamily:
                                                AsianPaintsFonts.mulishRegular,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: AsianPaintColors
                                                .projectUserNameColorTwo,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "No of Bathrooms : ${projectDescriptionBloc.getProjectDescriptionModel?.data?[0].nOOFBATHROOMS}",
                                  style: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishBold,
                                    color:
                                        AsianPaintColors.projectUserNameColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, top: 10),
                            itemCount: projectDescriptionBloc
                                .getProjectDescriptionModel
                                ?.data?[0]
                                .qUOTEINFO
                                ?.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ViewQuoteInProject(
                                              catIndex: 0,
                                              brandIndex: 0,
                                              rangeIndex: 0,
                                              category: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .category,
                                              brand: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .brand,
                                              range: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .range,
                                              projectDetailsList:
                                                  projectDescriptionBloc
                                                      .getProjectDescriptionModel
                                                      ?.data?[0]
                                                      .qUOTEINFO?[index]
                                                      .projectdetails,
                                              flipRange: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .fliprange,
                                              projectID: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .pROJECTID,
                                              quoteID: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .quoteid,
                                              totalAfterGst:
                                                  projectDescriptionBloc
                                                      .getProjectDescriptionModel
                                                      ?.data?[0]
                                                      .qUOTEINFO?[index]
                                                      .totalwithgst,
                                              discountAmount:
                                                  projectDescriptionBloc
                                                      .getProjectDescriptionModel
                                                      ?.data?[0]
                                                      .qUOTEINFO?[index]
                                                      .discountamount,
                                              projectName: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .pROJECTNAME,
                                              contactPerson:
                                                  projectDescriptionBloc
                                                      .getProjectDescriptionModel
                                                      ?.data?[0]
                                                      .cONTACTPERSON,
                                              mobileNumber:
                                                  projectDescriptionBloc
                                                      .getProjectDescriptionModel
                                                      ?.data?[0]
                                                      .mOBILENUMBER,
                                              siteAddress: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .sITEADDRESS,
                                              noOfBathrooms:
                                                  projectDescriptionBloc
                                                      .getProjectDescriptionModel
                                                      ?.data?[0]
                                                      .nOOFBATHROOMS,
                                              quoteName: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .quotename,
                                              index: index,
                                              isFlipAvailable:
                                                  projectDescriptionBloc
                                                      .getProjectDescriptionModel
                                                      ?.data?[0]
                                                      .qUOTEINFO?[index]
                                                      .isFlipAvailable,
                                            )),
                                  );
                                },
                                child: Card(
                                  elevation: 0,
                                  child: ListTile(
                                    tileColor: AsianPaintColors.whiteColor,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: VerticalDivider(
                                            indent: 5,
                                            endIndent: 5,
                                            color: AsianPaintColors
                                                .userTypeCardsColor,
                                          ),
                                        ),
                                        BlocConsumer<DelQuoteBloc,
                                            DeleteQuoteState>(
                                          builder: (context, state) {
                                            DelQuoteBloc delQuoteBloc =
                                                context.read<DelQuoteBloc>();
                                            return InkWell(
                                              onTap: () {
                                                delQuoteBloc.deleteQuote(
                                                    projectID:
                                                        projectDescriptionBloc
                                                            .getProjectDescriptionModel
                                                            ?.data?[0]
                                                            .pROJECTID,
                                                    quoteID: projectDescriptionBloc
                                                        .getProjectDescriptionModel
                                                        ?.data?[0]
                                                        .qUOTEINFO?[index]
                                                        .quoteid);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 10, 0),
                                                child: Image.asset(
                                                  './assets/images/deleteIcon.png',
                                                  width: 12,
                                                  height: 14,
                                                ),
                                              ),
                                            );
                                          },
                                          listener: (context, state) {
                                            if (state
                                                is DeleteQuoteStateInitial) {
                                              const Center(
                                                child: SizedBox(
                                                  height: 45,
                                                  width: 45,
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),
                                              );
                                            } else if (state
                                                is DeleteQuoteStateLoading) {
                                              const Center(
                                                child: SizedBox(
                                                  height: 45,
                                                  width: 45,
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),
                                              );
                                            } else if (state
                                                is DeleteQuoteStateLoaded) {
                                              setState(() {
                                                projectDescriptionBloc
                                                    .getProjectDescription(
                                                        projectID:
                                                            widget.projectID ??
                                                                "");
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),

                                    //leading: const Icon(Icons.abc),
                                    title: Text(
                                      projectDescriptionBloc
                                              .getProjectDescriptionModel
                                              ?.data?[0]
                                              .qUOTEINFO?[index]
                                              .quotename ??
                                          '',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontFamily:
                                              AsianPaintsFonts.mulishBold,
                                          color: AsianPaintColors
                                              .projectUserNameColor),
                                    ),

                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 12.0),
                                    dense: true,
                                    subtitle: Container(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: [
                                          (projectDescriptionBloc
                                                          .getProjectDescriptionModel
                                                          ?.data?[0]
                                                          .qUOTEINFO?[index]
                                                          .range ??
                                                      '')
                                                  .isNotEmpty
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 10, 0),
                                                  child: RichText(
                                                    text: TextSpan(
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: 'Range: ',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    AsianPaintsFonts
                                                                        .mulishMedium,
                                                                fontSize: 10,
                                                                color: AsianPaintColors
                                                                    .skuDescriptionColor)),
                                                        TextSpan(
                                                            text: projectDescriptionBloc
                                                                    .getProjectDescriptionModel
                                                                    ?.data?[0]
                                                                    .qUOTEINFO?[
                                                                        index]
                                                                    .range ??
                                                                '',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AsianPaintsFonts
                                                                      .mulishMedium,
                                                              color: AsianPaintColors
                                                                  .skuDescriptionColor,
                                                              fontSize: 10,
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(
                                                  width: 0,
                                                ),
                                          // const SizedBox(
                                          //   width: 15,
                                          // ),
                                          RichText(
                                            text: TextSpan(
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: 'Total Amount : ',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishMedium,
                                                        fontSize: 10,
                                                        color: AsianPaintColors
                                                            .skuDescriptionColor)),
                                                TextSpan(
                                                    text:
                                                        '\u{20B9} ${projectDescriptionBloc.getProjectDescriptionModel?.data?[0].qUOTEINFO?[index].totalwithgst}',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishBlack,
                                                      color: AsianPaintColors
                                                          .forgotPasswordTextColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                    )),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                            height: 42,
                            width: 140,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateProject(
                                      projectID: projectDescriptionBloc
                                          .getProjectDescriptionModel
                                          ?.data?[0]
                                          .pROJECTID,
                                      isClone: true,
                                      projectName: projectDescriptionBloc
                                          .getProjectDescriptionModel
                                          ?.data?[0]
                                          .pROJECTNAME,
                                      contactPerson: projectDescriptionBloc
                                          .getProjectDescriptionModel
                                          ?.data?[0]
                                          .cONTACTPERSON,
                                      mobileNumber: projectDescriptionBloc
                                          .getProjectDescriptionModel
                                          ?.data?[0]
                                          .mOBILENUMBER,
                                      siteAddress: projectDescriptionBloc
                                          .getProjectDescriptionModel
                                          ?.data?[0]
                                          .sITEADDRESS,
                                      noOfBathrooms: projectDescriptionBloc
                                          .getProjectDescriptionModel
                                          ?.data?[0]
                                          .nOOFBATHROOMS,
                                    ),
                                  ),
                                ).then((value) => logger(value));
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35.0),
                                ),
                                backgroundColor:
                                    AsianPaintColors.userTypeTextColor,
                                shadowColor: AsianPaintColors.buttonBorderColor,
                                textStyle: TextStyle(
                                  color: AsianPaintColors.whiteColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AsianPaintsFonts.mulishBold,
                                ),
                              ),
                              child: Text(
                                'Copy Project',
                                //AppLocalizations.of(context).add_sku,
                                style: TextStyle(
                                  fontFamily: AsianPaintsFonts.mulishBold,
                                  color: AsianPaintColors.whiteColor,
                                  //color: Colors.white,
                                  //fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
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
                          List<QUOTEINFO> quoteInfoList = projectDescriptionBloc
                                  .getProjectDescriptionModel
                                  ?.data?[0]
                                  .qUOTEINFO ??
                              [];
                          grandTotal = 0;
                          for (int i = 0; i < quoteInfoList.length; i++) {
                            grandTotal +=
                                int.parse(quoteInfoList[i].totalwithgst ?? '');
                          }
                          return SizedBox(
                              height: 110,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        30, 20, 30, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Grand Total",
                                          style: TextStyle(
                                            fontFamily:
                                                AsianPaintsFonts.mulishBold,
                                            fontSize: 12,
                                            color: AsianPaintColors
                                                .chooseYourAccountColor,
                                          ),
                                        ),
                                        Text(
                                          "\u{20B9} $grandTotal",
                                          style: TextStyle(
                                            fontFamily:
                                                AsianPaintsFonts.mulishBlack,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AsianPaintColors
                                                .forgotPasswordTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 0, 0, 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          height: 45,
                                          width: 160,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              final secureStorageProvider =
                                                  getSingleton<
                                                      SecureStorageProvider>();
                                              Journey.projectID =
                                                  widget.projectID ?? '';
                                              Journey.fromFlip = false;

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomeScreen(
                                                            loginType: Journey
                                                                    .loginType ??
                                                                'Internal')),
                                              ).then((value) => logger(value));
                                              await secureStorageProvider
                                                  .saveProjectID(
                                                      widget.projectID);
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
                                                color:
                                                    AsianPaintColors.whiteColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    AsianPaintsFonts.mulishBold,
                                              ),
                                            ),
                                            child: Text(
                                              'Add Quote',
                                              style: TextStyle(
                                                fontFamily:
                                                    AsianPaintsFonts.mulishBold,
                                                color:
                                                    AsianPaintColors.whiteColor,
                                                //color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 45,
                                          width: 150,
                                          child: GestureDetector(
                                            onTapDown:
                                                (TapDownDetails details) {
                                              showPopupMenu(
                                                  details.globalPosition);
                                            },
                                            child: ElevatedButton(
                                              onPressed: () async {},
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            35.0),
                                                    side: BorderSide(
                                                        width: 1,
                                                        color: AsianPaintColors
                                                            .kPrimaryColor)),
                                                backgroundColor:
                                                    AsianPaintColors.whiteColor,
                                                shadowColor: AsianPaintColors
                                                    .buttonBorderColor,
                                                textStyle: TextStyle(
                                                  color: AsianPaintColors
                                                      .kPrimaryColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: AsianPaintsFonts
                                                      .mulishBold,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(25, 0, 0, 0),
                                                    child: Text(
                                                      'Export',
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
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 0, 15, 0),
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
                                      ],
                                    ),
                                  )
                                ],
                              ));
                        },
                      ),
                    ],
                  );
                } else if (state is ProjectDescriptionFailure) {
                  return ProjectDescriptionBloc().loadingStatus == true
                      ? SizedBox(
                          height: displayHeight(context) * 0.65,
                          width: displayWidth(context),
                          child:
                              const Center(child: CircularProgressIndicator()))
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
      ),
      desktop: Container(
        width: MediaQuery.of(context).size.width / 2.1,
        padding: const EdgeInsets.fromLTRB(100, 30, 100, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Quotes',
                  style: TextStyle(
                      fontFamily: AsianPaintsFonts.bathSansRegular,
                      fontSize: 20,
                      color: AsianPaintColors.projectUserNameColor),
                ),
                const SizedBox(
                  width: 130,
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5),
                  height: 40,
                  width: 130,
                  child: ElevatedButton(
                    onPressed: () async {
                      final secureStorageProvider =
                          getSingleton<SecureStorageProvider>();
                      Journey.projectID = widget.projectID ?? '';
                      Journey.fromFlip = false;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomeScreen(loginType: Journey.loginType)),
                      ).then((value) => logger(value));
                      await secureStorageProvider
                          .saveProjectID(widget.projectID);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                      backgroundColor: AsianPaintColors.resetPasswordLabelColor,
                      shadowColor: AsianPaintColors.buttonBorderColor,
                      textStyle: TextStyle(
                        color: AsianPaintColors.whiteColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: AsianPaintsFonts.mulishLight,
                      ),
                    ),
                    child: Text(
                      'Add Quote',
                      style: TextStyle(
                        fontFamily: AsianPaintsFonts.mulishBold,
                        color: AsianPaintColors.whiteColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                  height: 35,
                  width: 130,
                  child: GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      showPopupMenuWeb(details.globalPosition);
                    },
                    child: ElevatedButton(
                      onPressed: () async {
                        showPopupMenuWeb(const Offset(0, 0));
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                            side: BorderSide(
                                width: 1,
                                color: AsianPaintColors.kPrimaryColor)),
                        backgroundColor: AsianPaintColors.whiteColor,
                        shadowColor: AsianPaintColors.buttonBorderColor,
                        textStyle: TextStyle(
                          color: AsianPaintColors.kPrimaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: AsianPaintsFonts.mulishBold,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
                            child: Text(
                              'Export',
                              style: TextStyle(
                                fontFamily: AsianPaintsFonts.mulishBold,
                                color: AsianPaintColors.kPrimaryColor,
                                //color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
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
              ],
            ),
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => ProjectDescriptionBloc()
                    ..getProjectDescription(projectID: widget.projectID ?? ''),
                ),
              ],
              child: BlocConsumer<ProjectDescriptionBloc,
                  ProjectsDescriptionState>(
                builder: (context, state) {
                  projectDescriptionBloc =
                      context.read<ProjectDescriptionBloc>();
                  if (state is ProjectDescriptionInitial) {
                    const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is ProjectDescriptionLoading) {
                    const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is ProjectDescriptionLoaded) {
                    int grandTotal = 0;
                    List<QUOTEINFO> quoteInfoList = projectDescriptionBloc
                            .getProjectDescriptionModel?.data?[0].qUOTEINFO ??
                        [];
                    for (int i = 0; i < quoteInfoList.length; i++) {
                      grandTotal +=
                          int.parse(quoteInfoList[i].totalwithgst ?? '');
                    }
                    return Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: MediaQuery.of(context).size.height * 0.32,
                          padding: const EdgeInsets.fromLTRB(0, 25, 0, 15),
                          child: Card(
                            color: Colors.white,
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(15, 15, 20, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    projectDescriptionBloc
                                            .getProjectDescriptionModel
                                            ?.data?[0]
                                            .pROJECTNAME ??
                                        '',
                                    style: TextStyle(
                                      fontFamily: AsianPaintsFonts.mulishMedium,
                                      color:
                                          AsianPaintColors.projectUserNameColor,
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
                                        projectDescriptionBloc
                                                .getProjectDescriptionModel
                                                ?.data?[0]
                                                .cONTACTPERSON ??
                                            '',
                                        style: TextStyle(
                                          fontFamily:
                                              AsianPaintsFonts.mulishRegular,
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
                                        projectDescriptionBloc
                                                .getProjectDescriptionModel
                                                ?.data?[0]
                                                .mOBILENUMBER ??
                                            '',
                                        style: TextStyle(
                                          fontFamily:
                                              AsianPaintsFonts.mulishRegular,
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
                                            projectDescriptionBloc
                                                    .getProjectDescriptionModel
                                                    ?.data?[0]
                                                    .sITEADDRESS ??
                                                '',
                                            style: TextStyle(
                                              fontFamily: AsianPaintsFonts
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
                                    height: 25,
                                  ),
                                  Text(
                                    "No of Bathrooms : ${projectDescriptionBloc.getProjectDescriptionModel?.data?[0].nOOFBATHROOMS}",
                                    style: TextStyle(
                                      fontFamily: AsianPaintsFonts.mulishBold,
                                      color:
                                          AsianPaintColors.projectUserNameColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: 315,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: projectDescriptionBloc
                                  .getProjectDescriptionModel
                                  ?.data?[0]
                                  .qUOTEINFO
                                  ?.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ViewQuoteInProject(
                                              catIndex: 0,
                                              brandIndex: 0,
                                              rangeIndex: 0,
                                              category: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .category,
                                              brand: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .brand,
                                              range: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .range,
                                              projectDetailsList: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .projectdetails,
                                              flipRange: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .fliprange,
                                              projectID: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .projectid,
                                              quoteID: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .quoteid,
                                              totalAfterGst: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .totalwithgst,
                                              discountAmount: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .discountamount,
                                              projectName: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .pROJECTNAME,
                                              contactPerson: projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .cONTACTPERSON,
                                              mobileNumber: projectDescriptionBloc.getProjectDescriptionModel?.data?[0].mOBILENUMBER,
                                              siteAddress: projectDescriptionBloc.getProjectDescriptionModel?.data?[0].sITEADDRESS,
                                              noOfBathrooms: projectDescriptionBloc.getProjectDescriptionModel?.data?[0].nOOFBATHROOMS,
                                              isFlipAvailable: projectDescriptionBloc.getProjectDescriptionModel?.data?[0].qUOTEINFO?[index].isFlipAvailable)),
                                    ).then((value) => logger(value));
                                  },
                                  child: Card(
                                    child: ListTile(
                                      title: Text(
                                          projectDescriptionBloc
                                                  .getProjectDescriptionModel
                                                  ?.data?[0]
                                                  .qUOTEINFO?[index]
                                                  .quotename ??
                                              '',
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontFamily:
                                                  AsianPaintsFonts.mulishBold,
                                              color: AsianPaintColors
                                                  .projectUserNameColor)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 12.0),
                                      dense: false,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 20, 0),
                                            child: VerticalDivider(
                                              indent: 5,
                                              endIndent: 5,
                                              color: AsianPaintColors
                                                  .userTypeCardsColor,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 10, 0),
                                            child: Image.asset(
                                              './assets/images/deleteIcon.png',
                                              width: 13,
                                              height: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 13, 0, 0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: 'Range : ',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishMedium,
                                                          fontSize: 10,
                                                          color: AsianPaintColors
                                                              .skuDescriptionColor)),
                                                  TextSpan(
                                                    text: projectDescriptionBloc
                                                        .getProjectDescriptionModel
                                                        ?.data?[0]
                                                        .qUOTEINFO?[index]
                                                        .range,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .mulishMedium,
                                                      color: AsianPaintColors
                                                          .forgotPasswordTextColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 100,
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: 'Total Amount :',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishMedium,
                                                          fontSize: 10,
                                                          color: AsianPaintColors
                                                              .skuDescriptionColor)),
                                                  TextSpan(
                                                      text:
                                                          ' \u{20B9} ${projectDescriptionBloc.getProjectDescriptionModel?.data?[0].qUOTEINFO?[index].totalwithgst}',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishMedium,
                                                        color: AsianPaintColors
                                                            .forgotPasswordTextColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 10,
                                                      )),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                          width: 530,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'Total Amount :',
                                        style: TextStyle(
                                            fontFamily:
                                                AsianPaintsFonts.mulishMedium,
                                            fontSize: 10,
                                            color: AsianPaintColors
                                                .skuDescriptionColor)),
                                    TextSpan(
                                        text: ' \u{20B9} $grandTotal',
                                        style: TextStyle(
                                          fontFamily:
                                              AsianPaintsFonts.mulishMedium,
                                          color: AsianPaintColors
                                              .forgotPasswordTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        )),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                height: 35,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Dialog dialog = Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      child: SizedBox(
                                        height: 470,
                                        width: 400,
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          30, 20, 0, 0),
                                                  child: Text(
                                                    "Copy Project",
                                                    style: TextStyle(
                                                      fontSize: 28,
                                                      fontFamily:
                                                          AsianPaintsFonts
                                                              .bathSansRegular,
                                                      color: AsianPaintColors
                                                          .buttonTextColor,
                                                      //fontWeight: FontWeight.,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 15, 20, 0),
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
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      30, 30, 30, 10),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 45,
                                                    child: TextFormField(
                                                      enableInteractiveSelection:
                                                          false,
                                                      validator: (value) {
                                                        if ((value ?? '')
                                                            .isEmpty) {
                                                          FlutterToastProvider()
                                                              .show(
                                                                  message:
                                                                      'Please enter a valid project name');
                                                        }
                                                      },
                                                      controller:
                                                          projectNameController,
                                                      keyboardType:
                                                          TextInputType.name,
                                                      textAlign:
                                                          TextAlign.start,
                                                      textAlignVertical:
                                                          TextAlignVertical
                                                              .center,
                                                      cursorColor: AsianPaintColors
                                                          .createProjectLabelColor,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishRegular,
                                                          color: AsianPaintColors
                                                              .createProjectLabelColor),
                                                      decoration:
                                                          InputDecoration(
                                                              enabledBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: AsianPaintColors
                                                                          .createProjectTextBorder)),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: AsianPaintColors
                                                                    .createProjectTextBorder,
                                                              )),
                                                              filled: true,
                                                              focusColor:
                                                                  AsianPaintColors
                                                                      .createProjectTextBorder,
                                                              fillColor:
                                                                  AsianPaintColors
                                                                      .whiteColor,
                                                              border: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      strokeAlign:
                                                                          1,
                                                                      color: AsianPaintColors
                                                                          .createProjectTextBorder)),
                                                              labelText:
                                                                  AppLocalizations.of(context)
                                                                      .project_name, //AppLocalizations.of(context).user_id,
                                                              labelStyle: TextStyle(
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishMedium,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 13,
                                                                  color: AsianPaintColors
                                                                      .chooseYourAccountColor),
                                                              floatingLabelStyle: TextStyle(
                                                                  color: AsianPaintColors
                                                                      .kPrimaryColor,
                                                                  fontSize: 13,
                                                                  fontFamily:
                                                                      AsianPaintsFonts.mulishRegular)),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  SizedBox(
                                                    height: 45,
                                                    child: TextFormField(
                                                      enableInteractiveSelection:
                                                          false,
                                                      controller:
                                                          contactPersonController,
                                                      keyboardType:
                                                          TextInputType.name,
                                                      textAlign:
                                                          TextAlign.start,
                                                      textAlignVertical:
                                                          TextAlignVertical
                                                              .center,
                                                      cursorColor: AsianPaintColors
                                                          .createProjectLabelColor,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishRegular,
                                                          color: AsianPaintColors
                                                              .createProjectLabelColor),
                                                      decoration:
                                                          InputDecoration(
                                                              enabledBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: AsianPaintColors
                                                                          .createProjectTextBorder)),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: AsianPaintColors
                                                                    .createProjectTextBorder,
                                                              )),
                                                              filled: true,
                                                              focusColor:
                                                                  AsianPaintColors
                                                                      .createProjectTextBorder,
                                                              fillColor:
                                                                  AsianPaintColors
                                                                      .whiteColor,
                                                              border: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      strokeAlign:
                                                                          1,
                                                                      color: AsianPaintColors
                                                                          .createProjectTextBorder)),
                                                              labelText:
                                                                  AppLocalizations.of(context)
                                                                      .contact_person, //AppLocalizations.of(context).user_id,
                                                              labelStyle: TextStyle(
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishMedium,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 13,
                                                                  color: AsianPaintColors
                                                                      .chooseYourAccountColor),
                                                              floatingLabelStyle: TextStyle(
                                                                  color: AsianPaintColors
                                                                      .kPrimaryColor,
                                                                  fontSize: 13,
                                                                  fontFamily:
                                                                      AsianPaintsFonts.mulishRegular)),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  SizedBox(
                                                    height: 45,
                                                    child: TextFormField(
                                                      enableInteractiveSelection:
                                                          false,
                                                      controller:
                                                          mobileNumberController,
                                                      keyboardType:
                                                          TextInputType.phone,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                '[0-9.,]+')),
                                                      ],
                                                      textAlign:
                                                          TextAlign.start,
                                                      textAlignVertical:
                                                          TextAlignVertical
                                                              .center,
                                                      cursorColor: AsianPaintColors
                                                          .createProjectLabelColor,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishRegular,
                                                          color: AsianPaintColors
                                                              .createProjectLabelColor),
                                                      decoration:
                                                          InputDecoration(
                                                              enabledBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: AsianPaintColors
                                                                          .createProjectTextBorder)),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: AsianPaintColors
                                                                    .createProjectTextBorder,
                                                              )),
                                                              filled: true,
                                                              focusColor:
                                                                  AsianPaintColors
                                                                      .createProjectTextBorder,
                                                              fillColor:
                                                                  AsianPaintColors
                                                                      .whiteColor,
                                                              border: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      strokeAlign:
                                                                          1,
                                                                      color: AsianPaintColors
                                                                          .createProjectTextBorder)),
                                                              labelText:
                                                                  AppLocalizations.of(context)
                                                                      .mobile_number, //AppLocalizations.of(context).user_id,
                                                              labelStyle: TextStyle(
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishMedium,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 13,
                                                                  color: AsianPaintColors
                                                                      .chooseYourAccountColor),
                                                              floatingLabelStyle: TextStyle(
                                                                  color: AsianPaintColors
                                                                      .chooseYourAccountColor,
                                                                  fontSize: 13,
                                                                  fontFamily:
                                                                      AsianPaintsFonts.mulishMedium)),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  SizedBox(
                                                    height: 45,
                                                    child: TextFormField(
                                                      enableInteractiveSelection:
                                                          false,
                                                      controller:
                                                          siteAddressController,
                                                      keyboardType:
                                                          TextInputType
                                                              .streetAddress,
                                                      textAlign:
                                                          TextAlign.start,
                                                      textAlignVertical:
                                                          TextAlignVertical
                                                              .center,
                                                      cursorColor: AsianPaintColors
                                                          .createProjectLabelColor,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishRegular,
                                                          color: AsianPaintColors
                                                              .createProjectLabelColor),
                                                      decoration:
                                                          InputDecoration(
                                                              enabledBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: AsianPaintColors
                                                                          .createProjectTextBorder)),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: AsianPaintColors
                                                                    .createProjectTextBorder,
                                                              )),
                                                              filled: true,
                                                              focusColor:
                                                                  AsianPaintColors
                                                                      .createProjectTextBorder,
                                                              fillColor:
                                                                  AsianPaintColors
                                                                      .whiteColor,
                                                              border: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      strokeAlign:
                                                                          1,
                                                                      color: AsianPaintColors
                                                                          .createProjectTextBorder)),
                                                              labelText:
                                                                  AppLocalizations.of(context)
                                                                      .site_address, //AppLocalizations.of(context).user_id,
                                                              labelStyle: TextStyle(
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishMedium,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 13,
                                                                  color: AsianPaintColors
                                                                      .chooseYourAccountColor),
                                                              floatingLabelStyle: TextStyle(
                                                                  color: AsianPaintColors
                                                                      .chooseYourAccountColor,
                                                                  fontSize: 13,
                                                                  fontFamily:
                                                                      AsianPaintsFonts.mulishMedium)),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  SizedBox(
                                                    height: 45,
                                                    child: TextFormField(
                                                      enableInteractiveSelection:
                                                          false,
                                                      controller:
                                                          noBathroomsController,
                                                      keyboardType:
                                                          const TextInputType
                                                                  .numberWithOptions(
                                                              signed: true,
                                                              decimal: true),
                                                      textAlign:
                                                          TextAlign.start,
                                                      textAlignVertical:
                                                          TextAlignVertical
                                                              .center,
                                                      cursorColor: AsianPaintColors
                                                          .createProjectLabelColor,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishRegular,
                                                          color: AsianPaintColors
                                                              .createProjectLabelColor),
                                                      decoration:
                                                          InputDecoration(
                                                              enabledBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: AsianPaintColors
                                                                          .createProjectTextBorder)),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: AsianPaintColors
                                                                    .createProjectTextBorder,
                                                              )),
                                                              filled: true,
                                                              focusColor:
                                                                  AsianPaintColors
                                                                      .createProjectTextBorder,
                                                              fillColor:
                                                                  AsianPaintColors
                                                                      .whiteColor,
                                                              border: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      strokeAlign:
                                                                          1,
                                                                      color: AsianPaintColors
                                                                          .createProjectTextBorder)),
                                                              labelText:
                                                                  AppLocalizations.of(context)
                                                                      .no_of_bathrooms, //AppLocalizations.of(context).user_id,
                                                              labelStyle: TextStyle(
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishMedium,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 13,
                                                                  color: AsianPaintColors
                                                                      .chooseYourAccountColor),
                                                              floatingLabelStyle: TextStyle(
                                                                  color: AsianPaintColors
                                                                      .chooseYourAccountColor,
                                                                  fontSize: 13,
                                                                  fontFamily:
                                                                      AsianPaintsFonts.mulishMedium)),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 40,
                                                  ),
                                                  SizedBox(
                                                    width: 330,
                                                    height: 45,
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        if (projectNameController
                                                            .text.isEmpty) {
                                                          FlutterToastProvider()
                                                              .show(
                                                                  message:
                                                                      'Please enter a valid project name');
                                                        } else if (contactPersonController
                                                            .text.isEmpty) {
                                                          FlutterToastProvider()
                                                              .show(
                                                                  message:
                                                                      'Please enter a valid contact person name');
                                                        } else if (mobileNumberController
                                                                .text.isEmpty ||
                                                            mobileNumberController
                                                                    .text
                                                                    .length !=
                                                                10) {
                                                          FlutterToastProvider()
                                                              .show(
                                                                  message:
                                                                      'Please enter a valid mobile number');
                                                        } else if (siteAddressController
                                                            .text.isEmpty) {
                                                          FlutterToastProvider()
                                                              .show(
                                                                  message:
                                                                      'Please enter a valid site address');
                                                        } else if (noBathroomsController
                                                            .text.isEmpty) {
                                                          FlutterToastProvider()
                                                              .show(
                                                                  message:
                                                                      'Please enter a valid number');
                                                        } else {
                                                          CloneProjectBloc
                                                              cloneProjectBloc =
                                                              context.read<
                                                                  CloneProjectBloc>();

                                                          cloneProjectBloc
                                                              .cloneProject(
                                                            projectID: widget
                                                                .projectID,
                                                            projectName:
                                                                projectNameController
                                                                    .text,
                                                            contactPerson:
                                                                contactPersonController
                                                                    .text,
                                                            mobileNumber:
                                                                mobileNumberController
                                                                    .text,
                                                            siteAddress:
                                                                siteAddressController
                                                                    .text,
                                                            noOfBathrooms:
                                                                noBathroomsController
                                                                    .text,
                                                          );
                                                          FlutterToastProvider()
                                                              .show(
                                                                  message:
                                                                      "Project created successfully!!");

                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      35.0),
                                                        ),
                                                        backgroundColor:
                                                            AsianPaintColors
                                                                .resetPasswordLabelColor,
                                                        shadowColor:
                                                            AsianPaintColors
                                                                .buttonBorderColor,
                                                        textStyle: TextStyle(
                                                          color:
                                                              AsianPaintColors
                                                                  .whiteColor,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishBold,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Save',
                                                        //AppLocalizations.of(context).add_sku,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishBold,
                                                          color:
                                                              AsianPaintColors
                                                                  .whiteColor,
                                                          //color: Colors.white,
                                                          fontSize: 15,
                                                          //fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );

                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return dialog;
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35.0),
                                    ),
                                    backgroundColor:
                                        AsianPaintColors.userTypeTextColor,
                                    shadowColor:
                                        AsianPaintColors.buttonBorderColor,
                                    textStyle: TextStyle(
                                      color: AsianPaintColors.whiteColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AsianPaintsFonts.mulishBold,
                                    ),
                                  ),
                                  child: Text(
                                    'Copy Project',
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
                        )
                      ],
                    );
                  } else if (state is ProjectDescriptionFailure) {
                    return ProjectDescriptionBloc().loadingStatus == true
                        ? SizedBox(
                            height: displayHeight(context) * 0.65,
                            width: displayWidth(context),
                            child: const Center(
                                child: CircularProgressIndicator()))
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
          ],
        ),
      ),
      tablet: const Scaffold(),
    );
  }

  void showPopupMenu(Offset offset) async {
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
            onTap: () {
              shareMail(context);
            },
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
                    emailTemplateBloc.getEmailTemplateList(
                      projectID: widget.projectID,
                      quoteID: "",
                      email: Journey.email,
                      category: category,
                      total: grandTotal.toString(),
                      userName: Journey.username,
                    );
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
                    var appDir = (await getTemporaryDirectory()).path;
                    Directory(appDir).delete(recursive: true);
                    exportProjectBloc.getExportProject(
                        projectID: widget.projectID ?? '', quoteID: '');
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset('./assets/images/pdf.svg'),
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
                  // Share.share(
                  //     exportProjectBloc.exportProjectResponseModel?.pdfurl ??
                  //         '');
                  logger(
                      'PDF URL: ${exportProjectBloc.exportProjectResponseModel?.pdfurl}');
                  Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (_) => PDFViewerCachedFromUrl(
                        url: exportProjectBloc
                                .exportProjectResponseModel?.pdfurl ??
                            '',
                        name: '',
                        allowShare: true,
                        subject: 'Bathsense by Asian Paints | $category',
                        totalPrice: grandTotal.toString(),
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

  showLoaderDialog(BuildContext contex, String message) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: Text(
                message,
                softWrap: true,
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

    final emailController = TextEditingController();

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
                  if (state is EmailTemplateFailure) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    FlutterToastProvider().show(message: 'Please try again');
                  }
                },
                builder: (context, state) {
                  EmailTemplateBloc emailTemplateBloc =
                      context.read<EmailTemplateBloc>();
                  return SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(20, 18, 0, 0),
                              child: Text(
                                "Share Quotation",
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
                        const SizedBox(
                          height: 10,
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
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textAlign: TextAlign.start,
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorColor:
                                      AsianPaintColors.createProjectLabelColor,
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
                                          'Enter Email', //AppLocalizations.of(context).user_id,
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
                                          Navigator.pop(context);
                                          emailTemplateBloc
                                              .getEmailTemplateList(
                                                  projectID: widget.projectID,
                                                  quoteID: '',
                                                  email: emailController.text,
                                                  category: category,
                                                  total: grandTotal.toString(),
                                                  userName: Journey.username);
                                        },
                                        label: Text(
                                          "Share",
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

  void showPopupMenuWeb(Offset offset) async {
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
            )),
        PopupMenuItem(
            value: 2,
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
                        projectID: widget.projectID ?? '', quoteID: '');
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

  downloadFile(url) {
    launchUrl(Uri.parse(url));
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
