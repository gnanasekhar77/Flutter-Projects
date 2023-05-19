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
import 'package:APaints_QGen/src/data/models/sku_request_model.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/clone_project/clone_project_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/create_quote/create_quote_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/create_quote/create_quote_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/export_project/export_project_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/export_project/export_project_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/get_projects/get_projects_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/get_projects/get_projects_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/project_description.dart/project_description_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/project_description.dart/project_description_state.dart';
import 'package:APaints_QGen/src/presentation/views/loading/loading_screen.dart';
import 'package:APaints_QGen/src/presentation/views/project/create_project.dart';
import 'package:APaints_QGen/src/presentation/views/project/project_description.dart';
import 'package:APaints_QGen/src/presentation/widgets/app_bar.dart';
import 'package:APaints_QGen/src/presentation/widgets/pdf_cache_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../views/project/projects_list.dart';

class MyProjectUi extends StatefulWidget {
  final bool? fromMyProjs;
  final bool? fromViewQuote;
  const MyProjectUi({Key? key, this.fromMyProjs, this.fromViewQuote})
      : super(key: key);

  @override
  State<MyProjectUi> createState() => MyProjectUiState();
}

class MyProjectUiState extends State<MyProjectUi> {
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
  late CreateQuoteBloc createProjectBloc;

  ProjectDescriptionBloc? projectDescriptionBloc;

  @override
  void initState() {
    super.initState();
    createProjectBloc = context.read<CreateQuoteBloc>();

    // getSkuList();
  }

  @override
  Widget build(BuildContext context) {
    String projID = '';
    int? ind;
    Future<List<SKUData>> getSkuList() async {
      category = await secureStorageProvider.getCategory();
      brand = await secureStorageProvider.getBrand();
      range = await secureStorageProvider.getRange();
      return List<SKUData>.from(
          await secureStorageProvider.getQuoteFromDisk() as Iterable);
    }

    Future<bool> onWillPop() async {
      return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to exit an App'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    bool kisweb;
                    try {
                      if (Platform.isAndroid || Platform.isIOS) {
                        kisweb = false;
                      } else {
                        kisweb = true;
                      }
                    } catch (e) {
                      kisweb = true;
                    }
                    if (kisweb) {
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

    return Scaffold(
      backgroundColor: AsianPaintColors.appBackgroundColor,
      appBar: (widget.fromViewQuote ?? false)
          ? AppBarTemplate(isVisible: true, header: 'My Projects')
          : null,
      body: FutureBuilder(
        future: getSkuList(),
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
                            ProjectsListBloc()..getProjects(1)),
                    // BlocProvider(create: (context) => ProjectDescriptionBloc()..getProjectDescription(projectID: projID, quoteID: ''))
                  ],
                  child: WillPopScope(
                    onWillPop: onWillPop,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(50, 30, 50, 20),
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
                                          onPressed: () async {
                                            BuildContext dContext;
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                dContext = context;
                                                return Dialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0)),
                                                  child: BlocConsumer<
                                                      CreateQuoteBloc,
                                                      CreateQuoteState>(
                                                    listener: (context, state) {
                                                      if (state
                                                          is CreateProjectLoaded) {
                                                        setState(
                                                          () {
                                                            // removeData();
                                                          },
                                                        );
                                                      }
                                                    },
                                                    builder: (context, state) {
                                                      return SizedBox(
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
                                                                      fontSize:
                                                                          28,
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
                                                                          dContext);
                                                                    },
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/cancel.png',
                                                                      width: 20,
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
                                                                      controller:
                                                                          mobileNumberController,
                                                                      inputFormatters: <
                                                                          TextInputFormatter>[
                                                                        LengthLimitingTextInputFormatter(
                                                                            10),
                                                                        FilteringTextInputFormatter.allow(
                                                                            RegExp('[0-9]+')),
                                                                      ],
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
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    },
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
                                              return InkWell(
                                                onTap: () {
                                                  List<Quoteinfo>
                                                      quoteInfoList = [];
                                                  List<SKUData> skuDataList =
                                                      snapshot.data ?? [];
                                                  for (int i = 0;
                                                      i < skuDataList.length;
                                                      i++) {
                                                    List<Area> areaInfo = [];
                                                    List<Area> areas =
                                                        skuDataList[i]
                                                                .areaInfo ??
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
                                                    quoteinfo.area = areaInfo;
                                                    quoteinfo
                                                        .totalprice = skuDataList[
                                                            i]
                                                        .totalPriceAfterDiscount
                                                        .toString();
                                                    quoteinfo.bundletype = '';
                                                    quoteinfo.netDiscount =
                                                        skuDataList[i]
                                                                .netDiscount ??
                                                            '0';
                                                    quoteInfoList
                                                        .add(quoteinfo);
                                                  }
                                                  createProjectBloc.createQuote(
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
                                                        Journey.quoteID ?? '',
                                                    projectName: (projectsListBloc
                                                                .getProjectsResponseModel
                                                                ?.data ??
                                                            [])[index]
                                                        .pROJECTNAME,
                                                    contactPerson: (projectsListBloc
                                                                .getProjectsResponseModel
                                                                ?.data ??
                                                            [])[index]
                                                        .cONTACTPERSON,
                                                    mobileNumber: (projectsListBloc
                                                                .getProjectsResponseModel
                                                                ?.data ??
                                                            [])[index]
                                                        .mOBILENUMBER,
                                                    siteAddress: (projectsListBloc
                                                                .getProjectsResponseModel
                                                                ?.data ??
                                                            [])[index]
                                                        .sITEADDRESS,
                                                    noOfBathrooms: (projectsListBloc
                                                                .getProjectsResponseModel
                                                                ?.data ??
                                                            [])[index]
                                                        .nOOFBATHROOMS,
                                                  );

                                                  void removeData() async {
                                                    SharedPreferences
                                                        sharedPreferences =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    sharedPreferences
                                                        .remove('quote');
                                                    await secureStorageProvider
                                                        .saveQuoteToDisk([]);
                                                    await secureStorageProvider
                                                        .saveCartCount(0);
                                                    logger(
                                                        'Quote: ${await secureStorageProvider.getQuoteFromDisk()}');
                                                  }

                                                  removeData();
                                                  Journey.skuResponseLists = [];

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProjectsList(
                                                        projID: (projectsListBloc
                                                                    .getProjectsResponseModel
                                                                    ?.data ??
                                                                [])[index]
                                                            .pROJECTID,
                                                        projIndex: index,
                                                        fromMyProjs: widget
                                                                .fromMyProjs ??
                                                            false,
                                                      ),
                                                    ),
                                                  ).then(
                                                    (value) => logger(value),
                                                  );
                                                },
                                                child: Card(
                                                  child: ListTile(
                                                    hoverColor: AsianPaintColors
                                                        .userTypeTextColor,
                                                    title: Text(
                                                        (projectsListBloc.getProjectsResponseModel
                                                                        ?.data ??
                                                                    [])[index]
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
                                                            horizontal: 12.0),
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
                                                                  Image.asset(
                                                                    './assets/images/userimage.png',
                                                                    width: 15,
                                                                    height: 13,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 3,
                                                                  ),
                                                                  Text(
                                                                    (projectsListBloc.getProjectsResponseModel?.data ??
                                                                                [])[index]
                                                                            .cONTACTPERSON ??
                                                                        '',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            AsianPaintsFonts
                                                                                .mulishRegular,
                                                                        color: AsianPaintColors
                                                                            .skuDescriptionColor),
                                                                  )
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                width: 30,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Image.asset(
                                                                    './assets/images/call.png',
                                                                    width: 15,
                                                                    height: 14,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 3,
                                                                  ),
                                                                  Text(
                                                                      (projectsListBloc.getProjectsResponseModel?.data ?? [])[index]
                                                                              .mOBILENUMBER ??
                                                                          '',
                                                                      style: TextStyle(
                                                                          fontFamily: AsianPaintsFonts
                                                                              .mulishRegular,
                                                                          color:
                                                                              AsianPaintColors.skuDescriptionColor))
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
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            15),
                                                                child: Text(
                                                                  'No of Bathrooms: ${(projectsListBloc.getProjectsResponseModel?.data ?? [])[index].nOOFBATHROOMS ?? ''}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AsianPaintsFonts
                                                                            .mulishRegular,
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
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  './assets/images/groupimage.png',
                                  height: 200,
                                  width: 330,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text('Please choose a project',
                                    style: TextStyle(
                                      fontFamily:
                                          AsianPaintsFonts.bathSansRegular,
                                      fontSize: 20,
                                      color:
                                          AsianPaintColors.skuDescriptionColor,
                                    )),
                                Text('to view quotes',
                                    style: TextStyle(
                                      fontFamily:
                                          AsianPaintsFonts.bathSansRegular,
                                      fontSize: 20,
                                      color:
                                          AsianPaintColors.skuDescriptionColor,
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
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

  Future<Widget> updateContainer(String projID) async {
    logger('In update container>>>>');

    return Expanded(
      child: Container(
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
                    onPressed: () async {},
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
                      showPopupMenu(projID, details.globalPosition);
                    },
                    child: ElevatedButton(
                      onPressed: () async {},
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
                    ..getProjectDescription(projectID: projID),
                ),
              ],
              child: BlocConsumer<ProjectDescriptionBloc,
                  ProjectsDescriptionState>(
                builder: (context, state) {
                  logger('message in builder list!!!!');
                  ProjectDescriptionBloc projectDescriptionBloc =
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
                    logger(
                        'Quote Info List: ${projectDescriptionBloc.getProjectDescriptionModel?.data?[0].pROJECTNAME}');
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
                                    height: 35,
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
                                return Card(
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
                                    contentPadding: const EdgeInsets.symmetric(
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
                                                    fontFamily: AsianPaintsFonts
                                                        .mulishMedium,
                                                    color: AsianPaintColors
                                                        .forgotPasswordTextColor,
                                                    fontWeight: FontWeight.bold,
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
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                '[0-9]+'))
                                                      ],
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
                                                            projectID: projID,
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
    );
  }
}
