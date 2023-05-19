import 'dart:convert';
import 'dart:io';

import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/get_projects_response_model.dart';
import 'package:APaints_QGen/src/data/models/project_description_response_model.dart';
import 'package:APaints_QGen/src/data/models/sku_request_model.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/presentation/blocs/email_template/email_template_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/email_template/email_template_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/clone_project/clone_project_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/clone_project/clone_project_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/create_quote/create_quote_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/create_quote/create_quote_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/delete_quote/delete_quote_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/delete_quote/delete_quote_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/export_project/export_project_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/export_project/export_project_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/get_projects/get_projects_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/get_projects/get_projects_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/project_description.dart/project_description_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/project_description.dart/project_description_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/search/search_bloc.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/quick_quote.dart';
import 'package:APaints_QGen/src/presentation/views/home/home_screen.dart';
import 'package:APaints_QGen/src/presentation/views/loading/loading_screen.dart';
import 'package:APaints_QGen/src/presentation/views/project/create_project.dart';
import 'package:APaints_QGen/src/presentation/views/project/project_description.dart';
import 'package:APaints_QGen/src/presentation/views/project/view_quote_in_project.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/view_quote.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/elevated_button.dart';
import 'package:APaints_QGen/src/presentation/widgets/pdf_cache_url.dart';
import 'package:APaints_QGen/src/presentation/widgets/sidemenunav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../responsive.dart';
import '../../widgets/app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:badges/badges.dart' as badges;

class ProjectsList extends StatefulWidget {
  final String? projID;
  final bool? fromMyProjs;
  final bool? appBarVisible;
  final int? projIndex;
  const ProjectsList(
      {Key? key,
      this.projID,
      this.fromMyProjs,
      this.appBarVisible,
      this.projIndex})
      : super(key: key);

  @override
  State<ProjectsList> createState() => ProjectsListState();
}

class ProjectsListState extends State<ProjectsList> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  bool isClone = false;
  String? category;
  String? brand;
  String? range;

  final projectNameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final siteAddressController = TextEditingController();
  final noBathroomsController = TextEditingController();
  final secureStorageProvider = getSingleton<SecureStorageProvider>();

  ProjectDescriptionBloc? projectDescriptionBloc;
  late ProjectsListBloc? projectsListBloc;
  int? cartCount = 0;
  late Future myFuture;
  String? selProjID;
  late CreateQuoteBloc createProjectBloc;
  String projID = '';
  int? ind = 0;
  bool isFirstTime = true;
  bool isQuoteLoaded = false;
  String? projectID;
  String? quoteID;
  List<Data>? projectData;

  bool? _showCartBadge;
  Color color = Colors.red;

  bool loadingStatus = false;
  String? userName = "";
  int? cartBadgeAmount;
  var scrollController = ScrollController();
  int page = 1;
  bool isLoading = false;
  int totalRows = 0;
  int totalLength = 0;
  List<ProjectData> projectsData = <ProjectData>[];
  int grandTotal = 0;
  @override
  void initState() {
    super.initState();
    getUsername();
    myFuture = getSkuList();
    createProjectBloc = context.read<CreateQuoteBloc>();
    projID = widget.projID ?? 'PRJ1';
    // scrollController.addListener(pagination);
  }

  void pagination(int totalLength, int totalRows) {
    if ((scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) &&
        (totalLength < totalRows)) {
      logger('Total Length: $totalLength');
      logger('Total Rows: $totalRows');
      setState(() {
        isLoading = true;
        page += 1;
        //add api for load the more data according to new page
      });
    }
  }

  Future<List<SKUData>> getSkuList() async {
    category = await secureStorageProvider.getCategory();
    logger('Category: $category');
    brand = await secureStorageProvider.getBrand();
    range = await secureStorageProvider.getRange();
    cartCount = await secureStorageProvider.getCartCount();

    return List<SKUData>.from(
        await secureStorageProvider.getQuoteFromDisk() as Iterable);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String?> getUsername() async {
    userName = await secureStorageProvider.read(key: 'username');
    cartBadgeAmount = await secureStorageProvider.getCartCount();
    logger("Cart Amount in init: $cartBadgeAmount");

    return userName;
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

  void showPopuMenu(BuildContext context) async {
    await showMenu(
      //clipBehavior: Clip.hardEdge,
      context: context,
      position: const RelativeRect.fromLTRB(
        600,
        55,
        0,
        0,
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.09,
                  width: MediaQuery.of(context).size.width * 0.06,
                  color: AsianPaintColors.userTypeTextColor,
                  child: SizedBox(
                    // height:  MediaQuery.of(context).size.height*0.09,
                    // width:  MediaQuery.of(context).size.width*0.06,
                    // color: AsianPaintColors.userTypeTextColor,

                    //color: AsianPaintColors.userTypeTextColor,
                    child: SvgPicture.asset(
                      'assets/images/circle.svg',
                      width: 30,
                      height: 10,
                      //color: AsianPaintColors.buttonTextColor,
                      //cacheColorFilter: isVisible,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Column(
                  children: [
                    Text(
                      "John Doe",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: AsianPaintsFonts.mulishBold,
                        color: AsianPaintColors.kPrimaryLightColor,
                      ),
                    ),
                    Divider(
                      indent: 2,
                      endIndent: 2,
                      height: 12,
                      thickness: 3,
                      color: AsianPaintColors.appBackgroundColor,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LandingScreen()));
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/images/logout.svg'),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "logout",
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: AsianPaintsFonts.mulishMedium,
                                color:
                                    AsianPaintColors.forgotPasswordTextColor),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            )),
      ],
    ).then((value) {
      if (value != null) print(value);
    });
  }

  Future<bool> onWillPop() async {
    Journey.area = 'ALL';
    Journey.selectedIndex = 0;
    if (Journey.skuResponseLists.isNotEmpty) {
      Navigator.pop(context);
      // return false;
    } else {
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
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    logger('Project ID before WIdget: ${widget.projIndex}');
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return WillPopScope(
      onWillPop: onWillPop,
      child: Responsive(
        mobile: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          backgroundColor: AsianPaintColors.appBackgroundColor,
          drawer: Drawer(
            backgroundColor: AsianPaintColors.whiteColor,
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: AsianPaintColors.kPrimaryColor,
                  ),
                  child: Container(
                    width: double.infinity,
                    color: AsianPaintColors.kPrimaryColor,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: SvgPicture.asset('assets/images/back.svg'),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Center(
                          child: CircleAvatar(
                            foregroundColor: AsianPaintColors.buttonTextColor,
                            radius: 30,
                            backgroundImage:
                                const AssetImage('assets/images/user.png'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          Journey.username ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontFamily: AsianPaintsFonts.mulishRegular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(thickness: 1, color: AsianPaintColors.quantityBorder),
                ListTile(
                  tileColor: AsianPaintColors.whiteColor,
                  iconColor: AsianPaintColors.forgotPasswordTextColor,
                  leading: const Icon(Icons.login_outlined),
                  title: Text(
                    AppLocalizations.of(context).logout,
                    style: TextStyle(
                      fontFamily: AsianPaintsFonts.mulishRegular,
                      color: AsianPaintColors.forgotPasswordTextColor,
                    ),
                  ),
                  onTap: () {
                    onWillPopLogout();
                  },
                ),
                Divider(
                  thickness: 1,
                  color: AsianPaintColors.quantityBorder,
                ),
              ],
            ),
          ),
          appBar: (widget.fromMyProjs ?? false)
              ? null
              : AppBar(
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
                                      return HomeScreen(
                                          loginType: Journey.loginType);
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
                                        return HomeScreen(
                                            loginType: Journey.loginType);
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
                                          searchBloc:
                                              BlocProvider.of<SearchListBloc>(
                                                  context)));
                                },
                                child: SvgPicture.asset(
                                    'assets/images/search.svg')),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
          body: FutureBuilder(
            future: myFuture,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.done:
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(
                          create: (context) =>
                              ProjectsListBloc()..getProjects(page))
                    ],
                    child: RefreshIndicator(
                      onRefresh: () {
                        return ProjectsListBloc().getProjects(page);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          !(widget.fromMyProjs ?? false)
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 15, 10, 0),
                                    child: RichText(
                                      textAlign: TextAlign.left,
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: '*',
                                              style: TextStyle(
                                                  fontFamily: AsianPaintsFonts
                                                      .mulishBold,
                                                  fontWeight: FontWeight.bold,
                                                  color: AsianPaintColors
                                                      .forgotPasswordTextColor)),
                                          TextSpan(
                                              text: AppLocalizations.of(context)
                                                  .projects_header,
                                              style: TextStyle(
                                                fontFamily:
                                                    AsianPaintsFonts.mulishBold,
                                                color: AsianPaintColors
                                                    .buttonTextColor,
                                                fontSize: 12,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  height: 0,
                                ),
                          BlocConsumer<ProjectsListBloc, ProjectsState>(
                            builder: (context, state) {
                              projectsListBloc =
                                  context.read<ProjectsListBloc>();

                              if (state is GetProjectsInitial) {
                                const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (state is GetProjectsLoading) {
                                const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (state is GetProjectsLoaded) {
                                logger(
                                    'Projects Loaded: ${snapshot.data?.length}');
                                totalLength += (projectsListBloc
                                            ?.getProjectsResponseModel?.data ??
                                        [])
                                    .length;
                                totalRows = projectsListBloc
                                        ?.getProjectsResponseModel?.totalrows ??
                                    0;
                                scrollController.addListener(
                                  () {
                                    pagination(totalLength, totalRows);
                                  },
                                );
                                (projectData ?? []).clear();
                                for (int i = 0;
                                    i <
                                        (projectsListBloc
                                                    ?.getProjectsResponseModel
                                                    ?.data ??
                                                [])
                                            .length;
                                    i++) {
                                  projectsData.add((projectsListBloc
                                          ?.getProjectsResponseModel?.data ??
                                      [])[i]);
                                }
                                // projectsData = projectsListBloc
                                //         ?.getProjectsResponseModel?.data ??
                                //     [];
                                return (projectsData).isNotEmpty
                                    ? Expanded(
                                        child: ListView.builder(
                                            padding: const EdgeInsets.all(10),
                                            scrollDirection: Axis.vertical,
                                            controller: scrollController,
                                            // shrinkWrap: true,
                                            itemCount: (projectsData).length,
                                            itemBuilder: (context, index) {
                                              return BlocConsumer<
                                                  CreateQuoteBloc,
                                                  CreateQuoteState>(
                                                listener: (context, state) {
                                                  if (state
                                                      is CreateQuoteInitial) {
                                                    const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  } else if (state
                                                      is CreateQuoteLoading) {
                                                    const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  } else if (state
                                                      is CreateQuoteLoaded) {
                                                    logger(
                                                        'In quote loaded:::: ${Journey.projectID}');
                                                    if (Journey.projectID ==
                                                        (projectsData)[index]
                                                            .pROJECTID) {
                                                      projID =
                                                          (projectsData)[index]
                                                                  .pROJECTID ??
                                                              '';
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProjectDescription(
                                                            projectID:
                                                                (projectsData)[
                                                                        index]
                                                                    .pROJECTID,
                                                          ),
                                                        ),
                                                      );

                                                      FlutterToastProvider().show(
                                                          message:
                                                              'Quote added successfully!!!');
                                                      isQuoteLoaded = true;
                                                      Journey.projectID = '';
                                                    }
                                                  }
                                                },
                                                builder: (context, state) {
                                                  return InkWell(
                                                    onTap: () async {
                                                      List<Quoteinfo>
                                                          quoteInfoList = [];
                                                      List<SKUData>
                                                          skuDataList =
                                                          snapshot.data ?? [];
                                                      logger(
                                                          'SKU data: ${snapshot.data?.length}');
                                                      for (int i = 0;
                                                          i <
                                                              skuDataList
                                                                  .length;
                                                          i++) {
                                                        List<Area> areaInfo =
                                                            [];
                                                        List<String> areaStr =
                                                            skuDataList[i]
                                                                    .aREAINFO ??
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
                                                      logger(
                                                          'Quote List length: ${quoteInfoList.length}');
                                                      if (isFirstTime &&
                                                          quoteInfoList
                                                              .isNotEmpty &&
                                                          (Journey.quoteName ??
                                                                  '')
                                                              .isNotEmpty) {
                                                        selProjID =
                                                            (projectsData)[
                                                                    index]
                                                                .pROJECTID;
                                                        logger(
                                                            'Quote List length in if: ${quoteInfoList.length}');
                                                        createProjectBloc
                                                            .createQuote(
                                                          quoteInfoList:
                                                              quoteInfoList,
                                                          category: category,
                                                          brand: brand,
                                                          range: range,
                                                          discountAmount: Journey
                                                              .totalDiscountAmount
                                                              .toString(),
                                                          totalPriceWithGST: Journey
                                                              .totalAmountAfterGST
                                                              .toString(),
                                                          quoteName:
                                                              Journey.quoteName,
                                                          projectID:
                                                              (projectsData)[
                                                                      index]
                                                                  .pROJECTID,
                                                          quoteType: "",
                                                          isExist: true,
                                                          quoteID:
                                                              Journey.quoteID ??
                                                                  '',
                                                          projectName:
                                                              (projectsData)[
                                                                      index]
                                                                  .pROJECTNAME,
                                                          contactPerson:
                                                              (projectsData)[
                                                                      index]
                                                                  .cONTACTPERSON,
                                                          mobileNumber:
                                                              (projectsData)[
                                                                      index]
                                                                  .mOBILENUMBER,
                                                          siteAddress:
                                                              (projectsData)[
                                                                      index]
                                                                  .sITEADDRESS,
                                                          noOfBathrooms:
                                                              (projectsData)[
                                                                      index]
                                                                  .nOOFBATHROOMS,
                                                        );
                                                        // void removeData() async{
                                                        SharedPreferences
                                                            sharedPreferences =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        sharedPreferences
                                                            .clear();
                                                        sharedPreferences
                                                            .remove('quote');
                                                        List<SKUData> skuData =
                                                            [];
                                                        secureStorageProvider
                                                            .saveQuoteToDisk(
                                                                skuData);
                                                        secureStorageProvider
                                                            .saveCartCount(0);
                                                        logger('Quote: ');
                                                        Journey.skuResponseLists =
                                                            [];
                                                        // }

                                                        // removeData();
                                                        isFirstTime = false;
                                                      } else {
                                                        logger(
                                                            'In else case::::');
                                                        // if(Journey.skuResponseLists.isNotEmpty) {
                                                        //    FlutterToastProvider().show(
                                                        //   message:
                                                        //       'Quote added successfully!!!');
                                                        // }
                                                        Journey.projectID = '';
                                                        projID = (projectsData)[
                                                                    index]
                                                                .pROJECTID ??
                                                            '';
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                ProjectDescription(
                                                              projectID:
                                                                  (projectsData)[
                                                                          index]
                                                                      .pROJECTID,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      // void removeData() async {
                                                      SharedPreferences
                                                          sharedPreferences =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      sharedPreferences.clear();
                                                      sharedPreferences
                                                          .remove('quote');
                                                      Journey.skuResponseLists =
                                                          [];
                                                      List<SKUData> skuData =
                                                          <SKUData>[];
                                                      secureStorageProvider
                                                          .saveQuoteToDisk(
                                                              skuData);

                                                      secureStorageProvider
                                                          .saveCartCount(0);
                                                      logger('Quote: ');
                                                      // }

                                                      // removeData();
                                                      // ignore: use_build_context_synchronously
                                                      // Navigator.push(
                                                      //   context,
                                                      //   MaterialPageRoute(
                                                      //     builder: (context) =>
                                                      //         ProjectDescription(
                                                      //       projectID: projectsListBloc
                                                      //           .getProjectsResponseModel
                                                      //           ?.data[index]
                                                      //           .pROJECTID,
                                                      //     ),
                                                      //   ),
                                                      // );
                                                    },
                                                    child: Card(
                                                      child: ListTile(
                                                        title: Text(
                                                            ((projectsData)[
                                                                        index]
                                                                    .pROJECTNAME) ??
                                                                '',
                                                            style: TextStyle(
                                                                fontSize: 12.0,
                                                                fontFamily:
                                                                    AsianPaintsFonts
                                                                        .mulishBold,
                                                                color: AsianPaintColors
                                                                    .projectUserNameColor)),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 10.0,
                                                                horizontal:
                                                                    12.0),
                                                        dense: true,
                                                        subtitle: Column(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 15),
                                                              child: Row(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      SvgPicture
                                                                          .asset(
                                                                        'assets/images/user_small.svg',
                                                                        width:
                                                                            12,
                                                                        height:
                                                                            12,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            3,
                                                                      ),
                                                                      Text(
                                                                        ((projectsData)[index].cONTACTPERSON) ??
                                                                            '',
                                                                        style: TextStyle(
                                                                            fontFamily: AsianPaintsFonts
                                                                                .mulishRegular,
                                                                            fontSize:
                                                                                10,
                                                                            color:
                                                                                AsianPaintColors.skuDescriptionColor),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 30,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      SvgPicture
                                                                          .asset(
                                                                        'assets/images/call.svg',
                                                                        width:
                                                                            12,
                                                                        height:
                                                                            12,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            3,
                                                                      ),
                                                                      Text(
                                                                          ((projectsData)[index].mOBILENUMBER) ??
                                                                              '',
                                                                          style: TextStyle(
                                                                              fontFamily: AsianPaintsFonts.mulishRegular,
                                                                              fontSize: 10,
                                                                              color: AsianPaintColors.skuDescriptionColor))
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 15),
                                                                  child:
                                                                      RichText(
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    text:
                                                                        TextSpan(
                                                                      children: <
                                                                          TextSpan>[
                                                                        TextSpan(
                                                                            text:
                                                                                'No of Bathrooms: ',
                                                                            style: TextStyle(
                                                                                fontFamily: AsianPaintsFonts.mulishRegular,
                                                                                fontSize: 8,
                                                                                color: AsianPaintColors.skuDescriptionColor)),
                                                                        TextSpan(
                                                                            text:
                                                                                ((projectsData)[index].nOOFBATHROOMS),
                                                                            style: TextStyle(
                                                                              fontFamily: AsianPaintsFonts.mulishBold,
                                                                              color: AsianPaintColors.chooseYourAccountColor,
                                                                              fontSize: 8,
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }),
                                      )
                                    : SizedBox(
                                        height: displayHeight(context) * 0.65,
                                        width: displayWidth(context),
                                        child: const Center(
                                            child: Text(
                                          'No projects available',
                                          style: TextStyle(fontSize: 14),
                                        )));
                              } else if (state is GetProjectsFailure) {
                                return ProjectsListBloc().loadingStatus == true
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
                            buildWhen: (previous, current) {
                              return true;
                            },
                            listener: (context, state) {},
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(25, 0, 25, 10),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CreateProject(
                                          projectID: '',
                                          isClone: false,
                                        ),
                                      ),
                                    ).then((value) => logger(value));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35.0),
                                    ),
                                    backgroundColor: AsianPaintColors
                                        .resetPasswordLabelColor,
                                    shadowColor:
                                        AsianPaintColors.buttonBorderColor,
                                    textStyle: TextStyle(
                                      color: AsianPaintColors.whiteColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AsianPaintsFonts.mulishBold,
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .create_new_project,
                                    //AppLocalizations.of(context).add_sku,
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
                    ),
                  );
                default:
                  return const SizedBox();
              }
              logger('In multi bloc builder!!!!');
            },
          ),
        ),
        tablet: const Scaffold(),
        desktop: Scaffold(
          backgroundColor: AsianPaintColors.appBackgroundColor,
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                logger('Journey length: ${Journey.skuResponseLists.length}');
                // Navigator.pop(context);
                if (Journey.skuResponseLists.isNotEmpty) {
                  Navigator.pop(context);
                } else {
                  Journey.area = 'ALL';
                  Journey.selectedIndex = 0;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Sidemen();
                      },
                    ),
                  );
                }
              },
              child: BackButton(
                onPressed: () {
                  logger('Journey length: ${Journey.skuResponseLists.length}');
                  // Navigator.pop(context);
                  if (Journey.skuResponseLists.isNotEmpty) {
                    Navigator.pop(context);
                  } else {
                    Journey.area = 'ALL';
                    Journey.selectedIndex = 0;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const Sidemen();
                        },
                      ),
                    );
                  }
                },
                color: AsianPaintColors.whiteColor,
              ),
            ),
            backgroundColor: AsianPaintColors.resetPasswordLabelColor,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Journey.loginType == 'Internal';

                    Navigator.pushAndRemoveUntil<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const Sidemen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: SvgPicture.asset(
                    "./assets/images/bathsans_logo.svg",
                    height: 17,
                  ),
                ),
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset("./assets/images/rounduser.svg",
                            height: 35),
                        InkWell(
                          onTap: () {
                            showSearch(
                                context: context,
                                delegate: SearchListWeb(
                                    searchBloc: BlocProvider.of<SearchListBloc>(
                                        context)));
                          },
                          child: SvgPicture.asset(
                              "./assets/images/outline-search-normal.svg",
                              height: 18),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 13,
                    ),
                    InkWell(
                      onTapDown: (details) {
                        showPopuMenu(context);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset("./assets/images/rounduser.svg",
                              height: 35),
                          SvgPicture.asset("./assets/images/outline-user.svg",
                              height: 20),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 13,
                    ),
                    // Image.asset(
                    //   './images/user_desktop.png',
                    //   width: 25,
                    //   height: 25,
                    // ),
                    // const SizedBox(width: 13),
                    InkWell(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset("./assets/images/rounduser.svg",
                              height: 35),
                          _shoppingCartBadge(Journey.skuResponseLists,
                              category ?? '', brand ?? '', range ?? ''),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          body: FutureBuilder(
            future: getSkuList(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(
                          create: (context) =>
                              ProjectsListBloc()..getProjects(page)),
                      // BlocProvider(create: (context) => ProjectDescriptionBloc()..getProjectDescription(projectID: projID, quoteID: ''))
                    ],
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.fromLTRB(100, 30, 100, 20),
                            width: MediaQuery.of(context).size.width / 2,
                            child: Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 2),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Projects',
                                        //AppLocalizations.of(context).projects,
                                        style: TextStyle(
                                            fontFamily: AsianPaintsFonts
                                                .bathSansRegular,
                                            fontSize: 20,
                                            color: AsianPaintColors
                                                .projectUserNameColor),
                                      ),
                                      SizedBox(
                                        //padding: const EdgeInsets.only(top: 5),
                                        height: 35,
                                        width: 150,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            BuildContext dialogContext;

                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                dialogContext = context;
                                                return Dialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0)),
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
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      30,
                                                                      20,
                                                                      0,
                                                                      0),
                                                              child: Text(
                                                                "New Project",
                                                                style:
                                                                    TextStyle(
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
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      0,
                                                                      15,
                                                                      20,
                                                                      0),
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      dialogContext);
                                                                },
                                                                child:
                                                                    Image.asset(
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
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  30,
                                                                  30,
                                                                  30,
                                                                  10),
                                                          child: BlocConsumer<
                                                              CreateQuoteBloc,
                                                              CreateQuoteState>(
                                                            builder: (context,
                                                                state) {
                                                              return Column(
                                                                children: [
                                                                  SizedBox(
                                                                    height: 45,
                                                                    child:
                                                                        TextFormField(
                                                                      enableInteractiveSelection:
                                                                          false,
                                                                      validator:
                                                                          (value) {
                                                                        if ((value ??
                                                                                '')
                                                                            .isEmpty) {
                                                                          FlutterToastProvider()
                                                                              .show(message: 'Please enter a valid project name');
                                                                        }
                                                                      },
                                                                      controller:
                                                                          projectNameController,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .name,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      textAlignVertical:
                                                                          TextAlignVertical
                                                                              .center,
                                                                      cursorColor:
                                                                          AsianPaintColors
                                                                              .createProjectLabelColor,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          fontFamily: AsianPaintsFonts
                                                                              .mulishRegular,
                                                                          color:
                                                                              AsianPaintColors.createProjectLabelColor),
                                                                      decoration: InputDecoration(
                                                                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AsianPaintColors.createProjectTextBorder)),
                                                                          focusedBorder: OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                            color:
                                                                                AsianPaintColors.createProjectTextBorder,
                                                                          )),
                                                                          filled: true,
                                                                          focusColor: AsianPaintColors.createProjectTextBorder,
                                                                          fillColor: AsianPaintColors.whiteColor,
                                                                          border: OutlineInputBorder(borderSide: BorderSide(strokeAlign: 1, color: AsianPaintColors.createProjectTextBorder)),
                                                                          labelText: AppLocalizations.of(context).project_name, //AppLocalizations.of(context).user_id,
                                                                          labelStyle: TextStyle(fontFamily: AsianPaintsFonts.mulishMedium, fontWeight: FontWeight.w400, fontSize: 13, color: AsianPaintColors.chooseYourAccountColor),
                                                                          floatingLabelStyle: TextStyle(color: AsianPaintColors.kPrimaryColor, fontSize: 13, fontFamily: AsianPaintsFonts.mulishRegular)),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 45,
                                                                    child:
                                                                        TextFormField(
                                                                      enableInteractiveSelection:
                                                                          false,
                                                                      controller:
                                                                          contactPersonController,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .name,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      textAlignVertical:
                                                                          TextAlignVertical
                                                                              .center,
                                                                      cursorColor:
                                                                          AsianPaintColors
                                                                              .createProjectLabelColor,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          fontFamily: AsianPaintsFonts
                                                                              .mulishRegular,
                                                                          color:
                                                                              AsianPaintColors.createProjectLabelColor),
                                                                      decoration: InputDecoration(
                                                                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AsianPaintColors.createProjectTextBorder)),
                                                                          focusedBorder: OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                            color:
                                                                                AsianPaintColors.createProjectTextBorder,
                                                                          )),
                                                                          filled: true,
                                                                          focusColor: AsianPaintColors.createProjectTextBorder,
                                                                          fillColor: AsianPaintColors.whiteColor,
                                                                          border: OutlineInputBorder(borderSide: BorderSide(strokeAlign: 1, color: AsianPaintColors.createProjectTextBorder)),
                                                                          labelText: AppLocalizations.of(context).contact_person, //AppLocalizations.of(context).user_id,
                                                                          labelStyle: TextStyle(fontFamily: AsianPaintsFonts.mulishMedium, fontWeight: FontWeight.w400, fontSize: 13, color: AsianPaintColors.chooseYourAccountColor),
                                                                          floatingLabelStyle: TextStyle(color: AsianPaintColors.kPrimaryColor, fontSize: 13, fontFamily: AsianPaintsFonts.mulishRegular)),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 45,
                                                                    child:
                                                                        TextFormField(
                                                                      enableInteractiveSelection:
                                                                          false,
                                                                      inputFormatters: <
                                                                          TextInputFormatter>[
                                                                        LengthLimitingTextInputFormatter(
                                                                            10),
                                                                        FilteringTextInputFormatter.allow(
                                                                            RegExp('[0-9]+')),
                                                                      ],
                                                                      controller:
                                                                          mobileNumberController,
                                                                      keyboardType: const TextInputType
                                                                              .numberWithOptions(
                                                                          signed:
                                                                              true,
                                                                          decimal:
                                                                              true),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      textAlignVertical:
                                                                          TextAlignVertical
                                                                              .center,
                                                                      cursorColor:
                                                                          AsianPaintColors
                                                                              .createProjectLabelColor,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          fontFamily: AsianPaintsFonts
                                                                              .mulishRegular,
                                                                          color:
                                                                              AsianPaintColors.createProjectLabelColor),
                                                                      decoration: InputDecoration(
                                                                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AsianPaintColors.createProjectTextBorder)),
                                                                          focusedBorder: OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                            color:
                                                                                AsianPaintColors.createProjectTextBorder,
                                                                          )),
                                                                          filled: true,
                                                                          focusColor: AsianPaintColors.createProjectTextBorder,
                                                                          fillColor: AsianPaintColors.whiteColor,
                                                                          border: OutlineInputBorder(borderSide: BorderSide(strokeAlign: 1, color: AsianPaintColors.createProjectTextBorder)),
                                                                          labelText: AppLocalizations.of(context).mobile_number, //AppLocalizations.of(context).user_id,
                                                                          labelStyle: TextStyle(fontFamily: AsianPaintsFonts.mulishMedium, fontWeight: FontWeight.w400, fontSize: 13, color: AsianPaintColors.chooseYourAccountColor),
                                                                          floatingLabelStyle: TextStyle(color: AsianPaintColors.chooseYourAccountColor, fontSize: 13, fontFamily: AsianPaintsFonts.mulishMedium)),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 45,
                                                                    child:
                                                                        TextFormField(
                                                                      enableInteractiveSelection:
                                                                          false,
                                                                      controller:
                                                                          siteAddressController,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .streetAddress,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      textAlignVertical:
                                                                          TextAlignVertical
                                                                              .center,
                                                                      cursorColor:
                                                                          AsianPaintColors
                                                                              .createProjectLabelColor,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          fontFamily: AsianPaintsFonts
                                                                              .mulishRegular,
                                                                          color:
                                                                              AsianPaintColors.createProjectLabelColor),
                                                                      decoration: InputDecoration(
                                                                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AsianPaintColors.createProjectTextBorder)),
                                                                          focusedBorder: OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                            color:
                                                                                AsianPaintColors.createProjectTextBorder,
                                                                          )),
                                                                          filled: true,
                                                                          focusColor: AsianPaintColors.createProjectTextBorder,
                                                                          fillColor: AsianPaintColors.whiteColor,
                                                                          border: OutlineInputBorder(borderSide: BorderSide(strokeAlign: 1, color: AsianPaintColors.createProjectTextBorder)),
                                                                          labelText: AppLocalizations.of(context).site_address, //AppLocalizations.of(context).user_id,
                                                                          labelStyle: TextStyle(fontFamily: AsianPaintsFonts.mulishMedium, fontWeight: FontWeight.w400, fontSize: 13, color: AsianPaintColors.chooseYourAccountColor),
                                                                          floatingLabelStyle: TextStyle(color: AsianPaintColors.chooseYourAccountColor, fontSize: 13, fontFamily: AsianPaintsFonts.mulishMedium)),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 45,
                                                                    child:
                                                                        TextFormField(
                                                                      enableInteractiveSelection:
                                                                          false,
                                                                      inputFormatters: <
                                                                          TextInputFormatter>[
                                                                        LengthLimitingTextInputFormatter(
                                                                            4),
                                                                      ],
                                                                      controller:
                                                                          noBathroomsController,
                                                                      keyboardType: const TextInputType
                                                                              .numberWithOptions(
                                                                          signed:
                                                                              true,
                                                                          decimal:
                                                                              true),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      textAlignVertical:
                                                                          TextAlignVertical
                                                                              .center,
                                                                      cursorColor:
                                                                          AsianPaintColors
                                                                              .createProjectLabelColor,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          fontFamily: AsianPaintsFonts
                                                                              .mulishRegular,
                                                                          color:
                                                                              AsianPaintColors.createProjectLabelColor),
                                                                      decoration: InputDecoration(
                                                                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AsianPaintColors.createProjectTextBorder)),
                                                                          focusedBorder: OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                            color:
                                                                                AsianPaintColors.createProjectTextBorder,
                                                                          )),
                                                                          filled: true,
                                                                          focusColor: AsianPaintColors.createProjectTextBorder,
                                                                          fillColor: AsianPaintColors.whiteColor,
                                                                          border: OutlineInputBorder(borderSide: BorderSide(strokeAlign: 1, color: AsianPaintColors.createProjectTextBorder)),
                                                                          labelText: AppLocalizations.of(context).no_of_bathrooms, //AppLocalizations.of(context).user_id,
                                                                          labelStyle: TextStyle(fontFamily: AsianPaintsFonts.mulishMedium, fontWeight: FontWeight.w400, fontSize: 13, color: AsianPaintColors.chooseYourAccountColor),
                                                                          floatingLabelStyle: TextStyle(color: AsianPaintColors.chooseYourAccountColor, fontSize: 13, fontFamily: AsianPaintsFonts.mulishMedium)),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 40,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 330,
                                                                    height: 45,
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () async {
                                                                        if (projectNameController
                                                                            .text
                                                                            .isEmpty) {
                                                                          FlutterToastProvider()
                                                                              .show(message: 'Please enter a valid project name');
                                                                        } else if (contactPersonController
                                                                            .text
                                                                            .isEmpty) {
                                                                          FlutterToastProvider()
                                                                              .show(message: 'Please enter a valid contact person name');
                                                                        } else if (mobileNumberController.text.isEmpty ||
                                                                            mobileNumberController.text.length !=
                                                                                10) {
                                                                          FlutterToastProvider()
                                                                              .show(message: 'Please enter a valid mobile number');
                                                                        } else if (siteAddressController
                                                                            .text
                                                                            .isEmpty) {
                                                                          FlutterToastProvider()
                                                                              .show(message: 'Please enter a valid site address');
                                                                        } else if (noBathroomsController
                                                                            .text
                                                                            .isEmpty) {
                                                                          FlutterToastProvider()
                                                                              .show(message: 'Please enter a valid number');
                                                                        } else {
                                                                          createProjectBloc
                                                                              .createProject(
                                                                            projectName:
                                                                                projectNameController.text,
                                                                            contactPerson:
                                                                                contactPersonController.text,
                                                                            mobileNumber:
                                                                                mobileNumberController.text,
                                                                            siteAddress:
                                                                                siteAddressController.text,
                                                                            noOfBathrooms:
                                                                                noBathroomsController.text,
                                                                          );

                                                                          setState(
                                                                            () {
                                                                              FlutterToastProvider().show(message: "Project created successfully!!");

                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          );
                                                                        }
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(35.0),
                                                                        ),
                                                                        backgroundColor:
                                                                            AsianPaintColors.resetPasswordLabelColor,
                                                                        shadowColor:
                                                                            AsianPaintColors.buttonBorderColor,
                                                                        textStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              AsianPaintColors.whiteColor,
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontFamily:
                                                                              AsianPaintsFonts.mulishBold,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        'Save',
                                                                        //AppLocalizations.of(context).add_sku,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              AsianPaintsFonts.mulishBold,
                                                                          color:
                                                                              AsianPaintColors.whiteColor,
                                                                          //color: Colors.white,
                                                                          fontSize:
                                                                              15,
                                                                          //fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                            listener: (context,
                                                                state) {
                                                              if (state
                                                                  is CreateProjectLoaded) {
                                                                void
                                                                    removeData() async {
                                                                  SharedPreferences
                                                                      sharedPreferences =
                                                                      await SharedPreferences
                                                                          .getInstance();
                                                                  sharedPreferences
                                                                      .remove(
                                                                          'quote');
                                                                  await secureStorageProvider
                                                                      .saveQuoteToDisk(
                                                                          []);
                                                                  await secureStorageProvider
                                                                      .saveCartCount(
                                                                          0);
                                                                  logger(
                                                                      'Quote: ${await secureStorageProvider.getQuoteFromDisk()}');
                                                                }

                                                                setState(
                                                                  () {
                                                                    removeData();
                                                                  },
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
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
                                                .resetPasswordLabelColor,
                                            shadowColor: AsianPaintColors
                                                .buttonBorderColor,
                                            textStyle: TextStyle(
                                              color:
                                                  AsianPaintColors.whiteColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              fontFamily:
                                                  AsianPaintsFonts.mulishLight,
                                            ),
                                          ),
                                          child: Text(
                                            'Create New Project',
                                            //AppLocalizations.of(context).create_new_project,
                                            //AppLocalizations.of(context).add_sku,
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
                                    ],
                                  ),
                                ),
                                !(widget.fromMyProjs ?? false)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 5, 0, 10),
                                            child: RichText(
                                              textAlign: TextAlign.left,
                                              text: TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: '*',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishBold,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          color: AsianPaintColors
                                                              .forgotPasswordTextColor)),
                                                  TextSpan(
                                                      text: AppLocalizations.of(
                                                              context)
                                                          .projects_header,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AsianPaintsFonts
                                                                .mulishBold,
                                                        color: AsianPaintColors
                                                            .buttonTextColor,
                                                        fontSize: 15,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                BlocConsumer<ProjectsListBloc, ProjectsState>(
                                  builder: (context, state) {
                                    CreateQuoteBloc createProjectBloc =
                                        context.read<CreateQuoteBloc>();

                                    ProjectsListBloc projectsListBloc =
                                        context.read<ProjectsListBloc>();

                                    projectDescriptionBloc =
                                        context.read<ProjectDescriptionBloc>();
                                    if (state is GetProjectsInitial) {
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (state is GetProjectsLoading) {
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (state is GetProjectsLoaded) {
                                      return Expanded(
                                        child: ListView.builder(
                                            padding:
                                                const EdgeInsets.only(top: 30),
                                            scrollDirection: Axis.vertical,
                                            // shrinkWrap: true,
                                            itemCount: (projectsListBloc
                                                        .getProjectsResponseModel
                                                        ?.data ??
                                                    [])
                                                .length,
                                            itemBuilder: (context, index) {
                                              return BlocConsumer<
                                                  CreateQuoteBloc,
                                                  CreateQuoteState>(
                                                listener: (context, state) {
                                                  if (state
                                                      is CreateQuoteLoaded) {
                                                    logger(
                                                        'Create Quote Loaded::');
                                                    setState(
                                                      () {
                                                        projID = (projectsListBloc
                                                                        .getProjectsResponseModel
                                                                        ?.data ??
                                                                    [])[ind ?? 0]
                                                                .pROJECTID ??
                                                            '';
                                                        // ind = index;

                                                        logger(
                                                            'Project ID in Create Quote: $projID');
                                                        //      SharedPreferences
                                                        //     sharedPreferences =
                                                        //     await SharedPreferences
                                                        //         .getInstance();
                                                        // sharedPreferences.clear();
                                                        // sharedPreferences
                                                        //     .remove('quote');
                                                        List<SKUData> skuData =
                                                            [];
                                                        secureStorageProvider
                                                            .saveQuoteToDisk(
                                                                skuData);
                                                        secureStorageProvider
                                                            .saveCartCount(0);
                                                        logger('Quote: ');
                                                        Journey.skuResponseLists =
                                                            [];
                                                        // updateContainer(projID);
                                                      },
                                                    );
                                                  }
                                                },
                                                builder: (context, state) {
                                                  return InkWell(
                                                    onTap: () async {
                                                      List<Quoteinfo>
                                                          quoteInfoList = [];
                                                      List<SKUData>
                                                          skuDataList =
                                                          snapshot.data ?? [];
                                                      logger(
                                                          'SKU data: ${snapshot.data?.length}');
                                                      for (int i = 0;
                                                          i <
                                                              skuDataList
                                                                  .length;
                                                          i++) {
                                                        List<Area> areaInfo =
                                                            [];
                                                        List<String> areaStr =
                                                            skuDataList[i]
                                                                    .aREAINFO ??
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
                                                      logger(
                                                          'Quote List length: ${quoteInfoList.length}');
                                                      if (isFirstTime &&
                                                          quoteInfoList
                                                              .isNotEmpty &&
                                                          (Journey.quoteName ??
                                                                  '')
                                                              .isNotEmpty) {
                                                        selProjID = (projectsListBloc
                                                                    .getProjectsResponseModel
                                                                    ?.data ??
                                                                [])[index]
                                                            .pROJECTID;
                                                        ind = index;
                                                        logger(
                                                            'Quote List length in if: ${quoteInfoList.length}');
                                                        createProjectBloc
                                                            .createQuote(
                                                          quoteInfoList:
                                                              quoteInfoList,
                                                          category: category,
                                                          brand: brand,
                                                          range: range,
                                                          discountAmount: Journey
                                                              .totalDiscountAmount
                                                              .toString(),
                                                          totalPriceWithGST: Journey
                                                              .totalAmountAfterGST
                                                              .toString(),
                                                          quoteName:
                                                              Journey.quoteName,
                                                          projectID: (projectsListBloc
                                                                      .getProjectsResponseModel
                                                                      ?.data ??
                                                                  [])[index]
                                                              .pROJECTID,
                                                          quoteType: "",
                                                          isExist: true,
                                                          quoteID:
                                                              Journey.quoteID ??
                                                                  '',
                                                          projectName:
                                                              (projectsListBloc
                                                                          .getProjectsResponseModel
                                                                          ?.data ??
                                                                      [])[index]
                                                                  .pROJECTNAME,
                                                          contactPerson:
                                                              (projectsListBloc
                                                                          .getProjectsResponseModel
                                                                          ?.data ??
                                                                      [])[index]
                                                                  .cONTACTPERSON,
                                                          mobileNumber:
                                                              (projectsListBloc
                                                                          .getProjectsResponseModel
                                                                          ?.data ??
                                                                      [])[index]
                                                                  .mOBILENUMBER,
                                                          siteAddress:
                                                              (projectsListBloc
                                                                          .getProjectsResponseModel
                                                                          ?.data ??
                                                                      [])[index]
                                                                  .sITEADDRESS,
                                                          noOfBathrooms:
                                                              (projectsListBloc
                                                                          .getProjectsResponseModel
                                                                          ?.data ??
                                                                      [])[index]
                                                                  .nOOFBATHROOMS,
                                                        );
                                                        // void removeData() async{

                                                        [];
                                                        // }

                                                        // removeData();
                                                        isFirstTime = false;
                                                      } else {
                                                        logger(
                                                            'In else case::::');
                                                        setState(
                                                          () {
                                                            projID = (projectsListBloc
                                                                            .getProjectsResponseModel
                                                                            ?.data ??
                                                                        [])[index]
                                                                    .pROJECTID ??
                                                                '';
                                                            ind = index;
                                                            logger(
                                                                'Project ID: $projID');
                                                            // updateContainer(projID);
                                                          },
                                                        );
                                                      }
                                                      // void removeData() async {
                                                      SharedPreferences
                                                          sharedPreferences =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      sharedPreferences.clear();
                                                      sharedPreferences
                                                          .remove('quote');
                                                      Journey.skuResponseLists =
                                                          [];
                                                      List<SKUData> skuData =
                                                          <SKUData>[];
                                                      secureStorageProvider
                                                          .saveQuoteToDisk(
                                                              skuData);

                                                      secureStorageProvider
                                                          .saveCartCount(0);
                                                      logger('Quote: ');
                                                    },
                                                    child: Card(
                                                      child: ListTile(
                                                        hoverColor:
                                                            AsianPaintColors
                                                                .userTypeTextColor,
                                                        title: Text(
                                                            (projectsListBloc.getProjectsResponseModel?.data ??
                                                                            [])[
                                                                        index]
                                                                    .pROJECTNAME ??
                                                                '',
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                fontFamily:
                                                                    AsianPaintsFonts
                                                                        .mulishBold,
                                                                color: AsianPaintColors
                                                                    .projectUserNameColor)),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 10.0,
                                                                horizontal:
                                                                    12.0),
                                                        dense: true,
                                                        subtitle: Column(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 15),
                                                              child: Row(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        './assets/images/userimage.png',
                                                                        width:
                                                                            15,
                                                                        height:
                                                                            13,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            3,
                                                                      ),
                                                                      Text(
                                                                        (projectsListBloc.getProjectsResponseModel?.data ?? [])[index].cONTACTPERSON ??
                                                                            '',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                AsianPaintsFonts.mulishRegular,
                                                                            color: AsianPaintColors.skuDescriptionColor),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 30,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        './assets/images/call.png',
                                                                        width:
                                                                            15,
                                                                        height:
                                                                            14,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            3,
                                                                      ),
                                                                      Text(
                                                                          (projectsListBloc.getProjectsResponseModel?.data ?? [])[index].mOBILENUMBER ??
                                                                              '',
                                                                          style: TextStyle(
                                                                              fontFamily: AsianPaintsFonts.mulishRegular,
                                                                              color: AsianPaintColors.skuDescriptionColor))
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            15),
                                                                    child: Text(
                                                                      'No of Bathrooms: ${(projectsListBloc.getProjectsResponseModel?.data ?? [])[index].nOOFBATHROOMS ?? ''}',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            AsianPaintsFonts.mulishRegular,
                                                                        color: AsianPaintColors
                                                                            .skuDescriptionColor,
                                                                      ),
                                                                    )),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }),
                                      );
                                    } else if (state is GetProjectsFailure) {
                                      return ProjectsListBloc().loadingStatus ==
                                              true
                                          ? SizedBox(
                                              height:
                                                  displayHeight(context) * 0.65,
                                              width: displayWidth(context),
                                              child: const Center(
                                                  child:
                                                      CircularProgressIndicator()))
                                          : SizedBox(
                                              height:
                                                  displayHeight(context) * 0.65,
                                              width: displayWidth(context),
                                              child: Center(
                                                child: Text(
                                                  state.message,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                            );
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
                              ],
                            ),
                          ),
                        ),
                        const VerticalDivider(
                          color: Colors.black26,
                          width: 1,
                        ),
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.1,
                            padding:
                                const EdgeInsets.fromLTRB(100, 30, 100, 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Quotes',
                                      style: TextStyle(
                                          fontFamily:
                                              AsianPaintsFonts.bathSansRegular,
                                          fontSize: 20,
                                          color: AsianPaintColors
                                              .projectUserNameColor),
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
                                          Journey.projectID = projID;

                                          Journey.fromFlip = false;

                                          await secureStorageProvider
                                              .saveProjectID(projID);
                                          // ignore: use_build_context_synchronously
                                          Navigator.pushAndRemoveUntil<void>(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder: (BuildContext context) =>
                                                  const Sidemen(),
                                            ),
                                            (Route<dynamic> route) => false,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(35.0),
                                          ),
                                          backgroundColor: AsianPaintColors
                                              .resetPasswordLabelColor,
                                          shadowColor: AsianPaintColors
                                              .buttonBorderColor,
                                          textStyle: TextStyle(
                                            color: AsianPaintColors.whiteColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            fontFamily:
                                                AsianPaintsFonts.mulishLight,
                                          ),
                                        ),
                                        child: Text(
                                          'Add Quote',
                                          style: TextStyle(
                                            fontFamily:
                                                AsianPaintsFonts.mulishBold,
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
                                          showPopupMenuWeb(
                                              (projID.isEmpty
                                                      ? widget.projID
                                                      : projID) ??
                                                  '',
                                              details.globalPosition);
                                        },
                                        child: ElevatedButton(
                                          onPressed: () async {},
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
                                              color: AsianPaintColors
                                                  .kPrimaryColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              fontFamily:
                                                  AsianPaintsFonts.mulishBold,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        25, 0, 0, 0),
                                                child: Text(
                                                  'Export',
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
                                                        0, 0, 15, 0),
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
                                      create: (context) =>
                                          ProjectDescriptionBloc()
                                            ..getProjectDescription(
                                                projectID: projID, quoteID: ''),
                                    ),
                                  ],
                                  child: BlocConsumer<ProjectDescriptionBloc,
                                      ProjectsDescriptionState>(
                                    builder: (context, state) {
                                      logger('message in builder list!!!!');
                                      projectDescriptionBloc = context
                                          .read<ProjectDescriptionBloc>();
                                      if (state is ProjectDescriptionInitial) {
                                        const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if (state
                                          is ProjectDescriptionLoading) {
                                        const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if (state
                                          is ProjectDescriptionLoaded) {
                                        grandTotal = 0;
                                        projectData = projectDescriptionBloc!
                                                .getProjectDescriptionModel
                                                ?.data ??
                                            [];
                                        List<QUOTEINFO> quoteInfoList =
                                            projectDescriptionBloc!
                                                    .getProjectDescriptionModel
                                                    ?.data?[0]
                                                    .qUOTEINFO ??
                                                [];
                                        logger(
                                            'Quote Info List: ${json.encode(projectDescriptionBloc?.getProjectDescriptionModel?.data?[0].qUOTEINFO)}');
                                        for (int i = 0;
                                            i < quoteInfoList.length;
                                            i++) {
                                          grandTotal += int.parse(
                                              quoteInfoList[i].totalwithgst ??
                                                  '');
                                        }
                                        return Column(
                                          children: [
                                            SingleChildScrollView(
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.35,
                                                // height: MediaQuery.of(context)
                                                //         .size
                                                //         .height *
                                                //     0.32,
                                                constraints: BoxConstraints(
                                                  minHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.30,
                                                ),
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 25, 0, 15),
                                                child: Card(
                                                  color: Colors.white,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        15, 15, 20, 20),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          projectDescriptionBloc!
                                                                  .getProjectDescriptionModel
                                                                  ?.data?[0]
                                                                  .pROJECTNAME ??
                                                              '',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AsianPaintsFonts
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
                                                              projectDescriptionBloc!
                                                                      .getProjectDescriptionModel
                                                                      ?.data?[0]
                                                                      .cONTACTPERSON ??
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
                                                              projectDescriptionBloc!
                                                                      .getProjectDescriptionModel
                                                                      ?.data?[0]
                                                                      .mOBILENUMBER ??
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
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
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
                                                                  projectDescriptionBloc!
                                                                          .getProjectDescriptionModel
                                                                          ?.data?[
                                                                              0]
                                                                          .sITEADDRESS ??
                                                                      '',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AsianPaintsFonts
                                                                            .mulishRegular,
                                                                    fontSize:
                                                                        13,
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
                                                          "No of Bathrooms : ${projectDescriptionBloc!.getProjectDescriptionModel?.data?[0].nOOFBATHROOMS}",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AsianPaintsFonts
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
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.35,
                                              height: 315,
                                              child: ListView.builder(
                                                  shrinkWrap: false,
                                                  itemCount: projectDescriptionBloc!
                                                      .getProjectDescriptionModel!
                                                      .data?[0]
                                                      .qUOTEINFO
                                                      ?.length,
                                                  itemBuilder: (context, ind) {
                                                    return InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ViewQuoteInProject(
                                                                    catIndex: 0,
                                                                    brandIndex:
                                                                        0,
                                                                    rangeIndex:
                                                                        0,
                                                                    category: projectData?[
                                                                            0]
                                                                        .qUOTEINFO?[
                                                                            ind]
                                                                        .category,
                                                                    brand: projectData?[
                                                                            0]
                                                                        .qUOTEINFO?[
                                                                            ind]
                                                                        .brand,
                                                                    range: projectData?[
                                                                            0]
                                                                        .qUOTEINFO?[
                                                                            ind]
                                                                        .range,
                                                                    projectDetailsList: projectData?[
                                                                            0]
                                                                        .qUOTEINFO?[
                                                                            ind]
                                                                        .projectdetails,
                                                                    flipRange: projectData?[
                                                                            0]
                                                                        .qUOTEINFO?[
                                                                            ind]
                                                                        .fliprange,
                                                                    projectID:
                                                                        projectData?[0]
                                                                            .pROJECTID,
                                                                    quoteID: projectData?[
                                                                            0]
                                                                        .qUOTEINFO?[
                                                                            ind]
                                                                        .quoteid,
                                                                    totalAfterGst: projectData?[
                                                                            0]
                                                                        .qUOTEINFO?[
                                                                            ind]
                                                                        .totalwithgst,
                                                                    discountAmount: projectData?[
                                                                            0]
                                                                        .qUOTEINFO?[
                                                                            ind]
                                                                        .discountamount,
                                                                    projectName:
                                                                        projectData?[0]
                                                                            .pROJECTNAME,
                                                                    contactPerson:
                                                                        projectData?[0]
                                                                            .cONTACTPERSON,
                                                                    mobileNumber:
                                                                        projectData?[0]
                                                                            .mOBILENUMBER,
                                                                    siteAddress:
                                                                        projectData?[0]
                                                                            .sITEADDRESS,
                                                                    noOfBathrooms:
                                                                        projectData?[0]
                                                                            .nOOFBATHROOMS,
                                                                    quantity: (projectData?[0].qUOTEINFO?[ind].projectdetails ??
                                                                            [])
                                                                        .length
                                                                        .toString(),
                                                                    quoteName: projectData?[
                                                                            0]
                                                                        .qUOTEINFO?[
                                                                            ind]
                                                                        .quotename,
                                                                  )),
                                                        );
                                                      },
                                                      child: Card(
                                                        child: ListTile(
                                                          title: Text(
                                                              projectDescriptionBloc!
                                                                      .getProjectDescriptionModel
                                                                      ?.data?[0]
                                                                      .qUOTEINFO?[
                                                                          ind]
                                                                      .quotename ??
                                                                  '',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                  fontFamily:
                                                                      AsianPaintsFonts
                                                                          .mulishBold,
                                                                  color: AsianPaintColors
                                                                      .projectUserNameColor)),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical:
                                                                      10.0,
                                                                  horizontal:
                                                                      12.0),
                                                          dense: false,
                                                          trailing: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        0,
                                                                        0,
                                                                        20,
                                                                        0),
                                                                child:
                                                                    VerticalDivider(
                                                                  indent: 5,
                                                                  endIndent: 5,
                                                                  color: AsianPaintColors
                                                                      .userTypeCardsColor,
                                                                ),
                                                              ),
                                                              BlocConsumer<
                                                                  DelQuoteBloc,
                                                                  DeleteQuoteState>(
                                                                builder:
                                                                    (context,
                                                                        state) {
                                                                  DelQuoteBloc
                                                                      delQuoteBloc =
                                                                      context.read<
                                                                          DelQuoteBloc>();
                                                                  return GestureDetector(
                                                                    onTap: () {
                                                                      projectID =
                                                                          projectData?[0].qUOTEINFO?[ind].projectid ??
                                                                              '';
                                                                      quoteID =
                                                                          projectData?[0].qUOTEINFO?[ind].quoteid ??
                                                                              '';
                                                                      logger(
                                                                          'Project ID: ${json.encode(projectData)}');
                                                                      logger(
                                                                          'Quote ID: ${projectDescriptionBloc!.getProjectDescriptionModel?.data?[0].qUOTEINFO?[ind].quoteid}');
                                                                      logger(
                                                                          'Quote ID: ${json.encode(projectDescriptionBloc?.getProjectDescriptionModel?.data)}');
                                                                      delQuoteBloc.deleteQuote(
                                                                          projectID:
                                                                              projectID,
                                                                          quoteID:
                                                                              quoteID);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              0,
                                                                              0,
                                                                              10,
                                                                              0),
                                                                      child: Image
                                                                          .asset(
                                                                        './assets/images/deleteIcon.png',
                                                                        width:
                                                                            13,
                                                                        height:
                                                                            13,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                listener:
                                                                    (context,
                                                                        state) {
                                                                  if (state
                                                                      is DeleteQuoteStateLoading) {
                                                                    SizedBox(
                                                                      height: displayHeight(
                                                                              context) *
                                                                          0.65,
                                                                      width: displayWidth(
                                                                          context),
                                                                      child:
                                                                          const Center(
                                                                        child:
                                                                            CircularProgressIndicator(),
                                                                      ),
                                                                    );
                                                                  }
                                                                  if (state
                                                                      is DeleteQuoteStateLoaded) {
                                                                    setState(
                                                                        () {
                                                                      // projectDescriptionBloc =
                                                                      //     context.read<ProjectDescriptionBloc>();
                                                                      // projectDescriptionBloc!.getProjectDescription(
                                                                      //     projectID:
                                                                      //         projectDescriptionBloc!.getProjectDescriptionModel?.data?[ind ?? (widget.projIndex ?? 0)].qUOTEINFO?[index].projectid ?? "");
                                                                      ind = ind;
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                          subtitle: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    0,
                                                                    13,
                                                                    0,
                                                                    0),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                (projectDescriptionBloc!.getProjectDescriptionModel?.data?[0].qUOTEINFO?[ind].range ??
                                                                            '')
                                                                        .isNotEmpty
                                                                    ? Flexible(
                                                                        flex: 1,
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              0,
                                                                              0,
                                                                              20,
                                                                              0),
                                                                          child:
                                                                              RichText(
                                                                            text:
                                                                                TextSpan(
                                                                              children: <TextSpan>[
                                                                                TextSpan(text: 'Range : ', style: TextStyle(fontFamily: AsianPaintsFonts.mulishMedium, fontSize: 10, color: AsianPaintColors.skuDescriptionColor)),
                                                                                TextSpan(
                                                                                  text: projectDescriptionBloc!.getProjectDescriptionModel?.data?[0].qUOTEINFO?[ind].range,
                                                                                  style: TextStyle(
                                                                                    fontFamily: AsianPaintsFonts.mulishMedium,
                                                                                    color: AsianPaintColors.forgotPasswordTextColor,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 10,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : const SizedBox(),
                                                                Flexible(
                                                                  flex: 1,
                                                                  child:
                                                                      RichText(
                                                                    text:
                                                                        TextSpan(
                                                                      children: <
                                                                          TextSpan>[
                                                                        TextSpan(
                                                                            text:
                                                                                'Total Amount :',
                                                                            style: TextStyle(
                                                                                fontFamily: AsianPaintsFonts.mulishMedium,
                                                                                fontSize: 10,
                                                                                color: AsianPaintColors.skuDescriptionColor)),
                                                                        TextSpan(
                                                                            text:
                                                                                ' \u{20B9} ${projectDescriptionBloc!.getProjectDescriptionModel?.data?[0].qUOTEINFO?[ind].totalwithgst}',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: AsianPaintsFonts.mulishMedium,
                                                                              color: AsianPaintColors.forgotPasswordTextColor,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 10,
                                                                            )),
                                                                      ],
                                                                    ),
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
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 10, 0, 0),
                                              width: 530,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text:
                                                                'Total Amount :',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    AsianPaintsFonts
                                                                        .mulishMedium,
                                                                fontSize: 10,
                                                                color: AsianPaintColors
                                                                    .skuDescriptionColor)),
                                                        TextSpan(
                                                            text:
                                                                ' \u{20B9} $grandTotal',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AsianPaintsFonts
                                                                      .mulishMedium,
                                                              color: AsianPaintColors
                                                                  .forgotPasswordTextColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                        // projectNameController
                                                        //     .text = projectData?[
                                                        //             0]
                                                        //         .pROJECTNAME ??
                                                        //     '';
                                                        contactPersonController
                                                            .text = projectData?[
                                                                    0]
                                                                .cONTACTPERSON ??
                                                            '';
                                                        mobileNumberController
                                                            .text = projectData?[
                                                                    0]
                                                                .mOBILENUMBER ??
                                                            '';
                                                        siteAddressController
                                                            .text = projectData?[
                                                                    0]
                                                                .sITEADDRESS ??
                                                            '';
                                                        noBathroomsController
                                                            .text = projectData?[
                                                                    0]
                                                                .nOOFBATHROOMS ??
                                                            '';
                                                        Dialog dialog = Dialog(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15.0)),
                                                          child: SizedBox(
                                                            height: 470,
                                                            width: 400,
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              30,
                                                                              20,
                                                                              0,
                                                                              0),
                                                                      child:
                                                                          Text(
                                                                        "Copy Project",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              28,
                                                                          fontFamily:
                                                                              AsianPaintsFonts.bathSansRegular,
                                                                          color:
                                                                              AsianPaintColors.buttonTextColor,
                                                                          //fontWeight: FontWeight.,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding: const EdgeInsets.fromLTRB(
                                                                            0,
                                                                            15,
                                                                            20,
                                                                            0),
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/images/cancel.png',
                                                                          width:
                                                                              20,
                                                                          height:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          30,
                                                                          30,
                                                                          30,
                                                                          10),
                                                                  child: Column(
                                                                    children: [
                                                                      SizedBox(
                                                                        height:
                                                                            45,
                                                                        child:
                                                                            TextFormField(
                                                                          enableInteractiveSelection:
                                                                              false,
                                                                          validator:
                                                                              (value) {
                                                                            if ((value ?? '').isEmpty) {
                                                                              FlutterToastProvider().show(message: 'Please enter a valid project name');
                                                                            }
                                                                          },
                                                                          controller:
                                                                              projectNameController,
                                                                          keyboardType:
                                                                              TextInputType.name,
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          textAlignVertical:
                                                                              TextAlignVertical.center,
                                                                          cursorColor:
                                                                              AsianPaintColors.createProjectLabelColor,
                                                                          style: TextStyle(
                                                                              fontSize: 13,
                                                                              fontFamily: AsianPaintsFonts.mulishRegular,
                                                                              color: AsianPaintColors.createProjectLabelColor),
                                                                          decoration: InputDecoration(
                                                                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AsianPaintColors.createProjectTextBorder)),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                color: AsianPaintColors.createProjectTextBorder,
                                                                              )),
                                                                              filled: true,
                                                                              focusColor: AsianPaintColors.createProjectTextBorder,
                                                                              fillColor: AsianPaintColors.whiteColor,
                                                                              border: OutlineInputBorder(borderSide: BorderSide(strokeAlign: 1, color: AsianPaintColors.createProjectTextBorder)),
                                                                              labelText: AppLocalizations.of(context).project_name, //AppLocalizations.of(context).user_id,
                                                                              labelStyle: TextStyle(fontFamily: AsianPaintsFonts.mulishMedium, fontWeight: FontWeight.w400, fontSize: 13, color: AsianPaintColors.chooseYourAccountColor),
                                                                              floatingLabelStyle: TextStyle(color: AsianPaintColors.kPrimaryColor, fontSize: 13, fontFamily: AsianPaintsFonts.mulishRegular)),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            15,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            45,
                                                                        child:
                                                                            TextFormField(
                                                                          enableInteractiveSelection:
                                                                              false,
                                                                          controller:
                                                                              contactPersonController,
                                                                          keyboardType:
                                                                              TextInputType.name,
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          textAlignVertical:
                                                                              TextAlignVertical.center,
                                                                          cursorColor:
                                                                              AsianPaintColors.createProjectLabelColor,
                                                                          style: TextStyle(
                                                                              fontSize: 13,
                                                                              fontFamily: AsianPaintsFonts.mulishRegular,
                                                                              color: AsianPaintColors.createProjectLabelColor),
                                                                          decoration: InputDecoration(
                                                                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AsianPaintColors.createProjectTextBorder)),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                color: AsianPaintColors.createProjectTextBorder,
                                                                              )),
                                                                              filled: true,
                                                                              focusColor: AsianPaintColors.createProjectTextBorder,
                                                                              fillColor: AsianPaintColors.whiteColor,
                                                                              border: OutlineInputBorder(borderSide: BorderSide(strokeAlign: 1, color: AsianPaintColors.createProjectTextBorder)),
                                                                              labelText: AppLocalizations.of(context).contact_person, //AppLocalizations.of(context).user_id,
                                                                              labelStyle: TextStyle(fontFamily: AsianPaintsFonts.mulishMedium, fontWeight: FontWeight.w400, fontSize: 13, color: AsianPaintColors.chooseYourAccountColor),
                                                                              floatingLabelStyle: TextStyle(color: AsianPaintColors.kPrimaryColor, fontSize: 13, fontFamily: AsianPaintsFonts.mulishRegular)),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            15,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            45,
                                                                        child:
                                                                            TextFormField(
                                                                          enableInteractiveSelection:
                                                                              false,
                                                                          controller:
                                                                              mobileNumberController,
                                                                          inputFormatters: [
                                                                            FilteringTextInputFormatter.allow(RegExp('[0-9]+'))
                                                                          ],
                                                                          keyboardType: const TextInputType.numberWithOptions(
                                                                              signed: true,
                                                                              decimal: true),
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          textAlignVertical:
                                                                              TextAlignVertical.center,
                                                                          cursorColor:
                                                                              AsianPaintColors.createProjectLabelColor,
                                                                          style: TextStyle(
                                                                              fontSize: 13,
                                                                              fontFamily: AsianPaintsFonts.mulishRegular,
                                                                              color: AsianPaintColors.createProjectLabelColor),
                                                                          decoration: InputDecoration(
                                                                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AsianPaintColors.createProjectTextBorder)),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                color: AsianPaintColors.createProjectTextBorder,
                                                                              )),
                                                                              filled: true,
                                                                              focusColor: AsianPaintColors.createProjectTextBorder,
                                                                              fillColor: AsianPaintColors.whiteColor,
                                                                              border: OutlineInputBorder(borderSide: BorderSide(strokeAlign: 1, color: AsianPaintColors.createProjectTextBorder)),
                                                                              labelText: AppLocalizations.of(context).mobile_number, //AppLocalizations.of(context).user_id,
                                                                              labelStyle: TextStyle(fontFamily: AsianPaintsFonts.mulishMedium, fontWeight: FontWeight.w400, fontSize: 13, color: AsianPaintColors.chooseYourAccountColor),
                                                                              floatingLabelStyle: TextStyle(color: AsianPaintColors.chooseYourAccountColor, fontSize: 13, fontFamily: AsianPaintsFonts.mulishMedium)),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            15,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            45,
                                                                        child:
                                                                            TextFormField(
                                                                          enableInteractiveSelection:
                                                                              false,
                                                                          controller:
                                                                              siteAddressController,
                                                                          keyboardType:
                                                                              TextInputType.streetAddress,
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          textAlignVertical:
                                                                              TextAlignVertical.center,
                                                                          cursorColor:
                                                                              AsianPaintColors.createProjectLabelColor,
                                                                          style: TextStyle(
                                                                              fontSize: 13,
                                                                              fontFamily: AsianPaintsFonts.mulishRegular,
                                                                              color: AsianPaintColors.createProjectLabelColor),
                                                                          decoration: InputDecoration(
                                                                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AsianPaintColors.createProjectTextBorder)),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                color: AsianPaintColors.createProjectTextBorder,
                                                                              )),
                                                                              filled: true,
                                                                              focusColor: AsianPaintColors.createProjectTextBorder,
                                                                              fillColor: AsianPaintColors.whiteColor,
                                                                              border: OutlineInputBorder(borderSide: BorderSide(strokeAlign: 1, color: AsianPaintColors.createProjectTextBorder)),
                                                                              labelText: AppLocalizations.of(context).site_address, //AppLocalizations.of(context).user_id,
                                                                              labelStyle: TextStyle(fontFamily: AsianPaintsFonts.mulishMedium, fontWeight: FontWeight.w400, fontSize: 13, color: AsianPaintColors.chooseYourAccountColor),
                                                                              floatingLabelStyle: TextStyle(color: AsianPaintColors.chooseYourAccountColor, fontSize: 13, fontFamily: AsianPaintsFonts.mulishMedium)),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            15,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            45,
                                                                        child:
                                                                            TextFormField(
                                                                          enableInteractiveSelection:
                                                                              false,
                                                                          controller:
                                                                              noBathroomsController,
                                                                          keyboardType: const TextInputType.numberWithOptions(
                                                                              signed: true,
                                                                              decimal: true),
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          textAlignVertical:
                                                                              TextAlignVertical.center,
                                                                          cursorColor:
                                                                              AsianPaintColors.createProjectLabelColor,
                                                                          style: TextStyle(
                                                                              fontSize: 13,
                                                                              fontFamily: AsianPaintsFonts.mulishRegular,
                                                                              color: AsianPaintColors.createProjectLabelColor),
                                                                          decoration: InputDecoration(
                                                                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AsianPaintColors.createProjectTextBorder)),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                color: AsianPaintColors.createProjectTextBorder,
                                                                              )),
                                                                              filled: true,
                                                                              focusColor: AsianPaintColors.createProjectTextBorder,
                                                                              fillColor: AsianPaintColors.whiteColor,
                                                                              border: OutlineInputBorder(borderSide: BorderSide(strokeAlign: 1, color: AsianPaintColors.createProjectTextBorder)),
                                                                              labelText: AppLocalizations.of(context).no_of_bathrooms, //AppLocalizations.of(context).user_id,
                                                                              labelStyle: TextStyle(fontFamily: AsianPaintsFonts.mulishMedium, fontWeight: FontWeight.w400, fontSize: 13, color: AsianPaintColors.chooseYourAccountColor),
                                                                              floatingLabelStyle: TextStyle(color: AsianPaintColors.chooseYourAccountColor, fontSize: 13, fontFamily: AsianPaintsFonts.mulishMedium)),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            40,
                                                                      ),
                                                                      BlocConsumer<
                                                                          CloneProjectBloc,
                                                                          CloneProjectState>(
                                                                        listener:
                                                                            (context,
                                                                                state) {
                                                                          if (state
                                                                              is CloneProjectLoaded) {
                                                                            setState(() {
                                                                              FlutterToastProvider().show(message: "Project created successfully!!");
                                                                            });

                                                                            Navigator.of(context).pop();
                                                                          }
                                                                        },
                                                                        builder:
                                                                            (context,
                                                                                state) {
                                                                          return SizedBox(
                                                                            width:
                                                                                330,
                                                                            height:
                                                                                45,
                                                                            child:
                                                                                APElevatedButton(
                                                                              onPressed: () async {
                                                                                if (projectNameController.text.isEmpty) {
                                                                                  FlutterToastProvider().show(message: 'Please enter a valid project name');
                                                                                } else if (contactPersonController.text.isEmpty) {
                                                                                  FlutterToastProvider().show(message: 'Please enter a valid contact person name');
                                                                                } else if (mobileNumberController.text.isEmpty || mobileNumberController.text.length != 10) {
                                                                                  FlutterToastProvider().show(message: 'Please enter a valid mobile number');
                                                                                } else if (siteAddressController.text.isEmpty) {
                                                                                  FlutterToastProvider().show(message: 'Please enter a valid site address');
                                                                                } else if (noBathroomsController.text.isEmpty) {
                                                                                  FlutterToastProvider().show(message: 'Please enter a valid number');
                                                                                } else {
                                                                                  CloneProjectBloc cloneProjectBloc = context.read<CloneProjectBloc>();

                                                                                  cloneProjectBloc.cloneProject(
                                                                                    projectID: projID,
                                                                                    projectName: projectNameController.text,
                                                                                    contactPerson: contactPersonController.text,
                                                                                    mobileNumber: mobileNumberController.text,
                                                                                    siteAddress: siteAddressController.text,
                                                                                    noOfBathrooms: noBathroomsController.text,
                                                                                  );
                                                                                }
                                                                              },
                                                                              label: state is CloneProjectLoading
                                                                                  ? Center(
                                                                                      child: SizedBox(
                                                                                        height: 15,
                                                                                        width: 15,
                                                                                        child: CircularProgressIndicator(color: AsianPaintColors.buttonTextColor),
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
                                                                              // style:
                                                                              //     ElevatedButton.styleFrom(
                                                                              //   shape: RoundedRectangleBorder(
                                                                              //     borderRadius: BorderRadius.circular(35.0),
                                                                              //   ),
                                                                              //   backgroundColor: AsianPaintColors.resetPasswordLabelColor,
                                                                              //   shadowColor: AsianPaintColors.buttonBorderColor,
                                                                              //   textStyle: TextStyle(
                                                                              //     color: AsianPaintColors.whiteColor,
                                                                              //     fontSize: 13,
                                                                              //     fontWeight: FontWeight.bold,
                                                                              //     fontFamily: AsianPaintsFonts.mulishBold,
                                                                              //   ),
                                                                              // ),
                                                                              // child:
                                                                              //     Text(
                                                                              //   'Save',
                                                                              //   //AppLocalizations.of(context).add_sku,
                                                                              //   style: TextStyle(
                                                                              //     fontFamily: AsianPaintsFonts.mulishBold,
                                                                              //     color: AsianPaintColors.whiteColor,
                                                                              //     //color: Colors.white,
                                                                              //     fontSize: 15,
                                                                              //     //fontWeight: FontWeight.bold,
                                                                              //   ),
                                                                              // ),
                                                                            ),
                                                                          );
                                                                        },
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
                                                                .userTypeTextColor,
                                                        shadowColor:
                                                            AsianPaintColors
                                                                .buttonBorderColor,
                                                        textStyle: TextStyle(
                                                          color:
                                                              AsianPaintColors
                                                                  .whiteColor,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              AsianPaintsFonts
                                                                  .mulishBold,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Copy Project',
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
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        );
                                      } else if (state
                                          is ProjectDescriptionFailure) {
                                        return ProjectDescriptionBloc()
                                                    .loadingStatus ==
                                                true
                                            ? SizedBox(
                                                height: displayHeight(context) *
                                                    0.65,
                                                width: displayWidth(context),
                                                child: const Center(
                                                    child:
                                                        CircularProgressIndicator()))
                                            : SizedBox(
                                                height: displayHeight(context) *
                                                    0.65,
                                                width: displayWidth(context),
                                                child: Center(
                                                    child: Text(
                                                  state.message,
                                                  style: const TextStyle(
                                                      fontSize: 14),
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
                        ),
                      ],
                    ),
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  void showPopupMenu(String projectID, Offset offset) async {
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
                String fileCachePath = "";

                ExportProjectBloc exportProjectBloc =
                    context.read<ExportProjectBloc>();
                if (state is ExportProjectLoaded) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  // Share.share(
                  //     exportProjectBloc.exportProjectResponseModel?.pdfurl ??
                  //         '');
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
                    width: 250,
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
                                          if (emailController.text.isEmpty ||
                                              !isValidEmail(
                                                  emailController.text)) {
                                            FlutterToastProvider().show(
                                                message:
                                                    'Please enter a valid email id');
                                          } else {
                                            Navigator.pop(context);
                                            emailTemplateBloc
                                                .getEmailTemplateList(
                                                    projectID: projID,
                                                    quoteID: '',
                                                    email: emailController.text,
                                                    category: category,
                                                    total:
                                                        grandTotal.toString(),
                                                    userName: Journey.username);
                                          }
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

  void showPopupMenuWeb(String projectID, Offset offset) async {
    await showMenu(
      clipBehavior: Clip.hardEdge,
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        120,
        150,
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
                if (state is EmailTemplateFailure) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  FlutterToastProvider().show(message: 'Please try again');
                }
              },
              builder: (context, state) {
                EmailTemplateBloc emailTemplateBloc =
                    context.read<EmailTemplateBloc>();
                return GestureDetector(
                  onTap: () {
                    emailTemplateBloc.getEmailTemplateList(
                        projectID: projID,
                        quoteID: '',
                        email: Journey.email,
                        category: category,
                        total: grandTotal.toString(),
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

  downloadFile(url) {
    launchUrl(Uri.parse(url));
  }
}
