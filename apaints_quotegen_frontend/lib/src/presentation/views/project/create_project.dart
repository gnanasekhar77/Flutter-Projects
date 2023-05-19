import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/sku_request_model.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/clone_project/clone_project_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/clone_project/clone_project_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/create_quote/create_quote_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/create_quote/create_quote_state.dart';
import 'package:APaints_QGen/src/presentation/views/project/project_description.dart';
import 'package:APaints_QGen/src/presentation/views/project/projects_list.dart';
import 'package:APaints_QGen/src/presentation/widgets/app_bar.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateProject extends StatefulWidget {
  final String? projectID;
  final String? projectName;
  final String? contactPerson;
  final String? mobileNumber;
  final String? siteAddress;
  final String? noOfBathrooms;

  final bool? isClone;
  const CreateProject({
    super.key,
    this.projectID,
    this.isClone,
    this.projectName,
    this.contactPerson,
    this.mobileNumber,
    this.siteAddress,
    this.noOfBathrooms,
  });

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  final projectNameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final siteAddressController = TextEditingController();
  final noBathroomsController = TextEditingController();
  final secureStorageProvider = getSingleton<SecureStorageProvider>();

  @override
  void initState() {
    if (widget.isClone ?? true) {
      projectNameController.text = '';
      contactPersonController.text = widget.contactPerson ?? '';
      mobileNumberController.text = widget.mobileNumber ?? '';
      siteAddressController.text = widget.siteAddress ?? '';
      noBathroomsController.text = widget.noOfBathrooms ?? '';
    }
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CreateQuoteBloc>();
    return Responsive(
      mobile: Scaffold(
        appBar: AppBarTemplate(
          isVisible: false,
          header: AppLocalizations.of(context).new_project,
        ),
        body: BlocConsumer<CreateQuoteBloc, CreateQuoteState>(
          listener: (context, state) {
            // if (state is CreateQuoteLoaded ) {
            //   CreateQuoteBloc createQuoteBloc = context.read<CreateQuoteBloc>();
            //   String projectID = createQuoteBloc
            //           .createQuoteToExistingProjectResponseModel?.projetID ??
            //       '';
            //   Navigator.pop(context);
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) =>
            //           ProjectDescription(projectID: projectID),
            //     ),
            //   );
            //   // Navigator.pop(context, "");
            // }

            if (state is CreateQuoteLoading || state is CreateProjectLoading) {
              showLoaderDialog(context, 'Creating project.. Please wait..');
            }

            if (state is CreateQuoteLoaded || state is CreateProjectLoaded) {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectsList(),
                ),
              );
              // Navigator.pop(context, "");
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 45,
                          child: TextFormField(
                            enableInteractiveSelection: false,
                            validator: (value) {
                              if ((value ?? '').isEmpty) {
                                FlutterToastProvider().show(
                                    message:
                                        'Please enter a valid project name');
                              }
                            },
                            controller: projectNameController,
                            keyboardType: TextInputType.name,
                            textAlign: TextAlign.start,
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor:
                                AsianPaintColors.createProjectLabelColor,
                            style: TextStyle(
                                fontSize: 13,
                                fontFamily: AsianPaintsFonts.mulishRegular,
                                color:
                                    AsianPaintColors.createProjectLabelColor),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AsianPaintColors
                                            .createProjectTextBorder)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color:
                                      AsianPaintColors.createProjectTextBorder,
                                )),
                                filled: true,
                                focusColor:
                                    AsianPaintColors.createProjectTextBorder,
                                fillColor: AsianPaintColors.whiteColor,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        strokeAlign: 1,
                                        color: AsianPaintColors
                                            .createProjectTextBorder)),
                                labelText: AppLocalizations.of(context)
                                    .project_name, //AppLocalizations.of(context).user_id,
                                labelStyle: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishMedium,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: AsianPaintColors
                                        .chooseYourAccountColor),
                                floatingLabelStyle: TextStyle(
                                    color:
                                        AsianPaintColors.chooseYourAccountColor,
                                    fontSize: 12,
                                    fontFamily: AsianPaintsFonts.mulishMedium)),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 45,
                          child: TextFormField(
                            enableInteractiveSelection: false,
                            controller: contactPersonController,
                            keyboardType: TextInputType.name,
                            textAlign: TextAlign.start,
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor:
                                AsianPaintColors.createProjectLabelColor,
                            style: TextStyle(
                                fontSize: 13,
                                fontFamily: AsianPaintsFonts.mulishRegular,
                                color:
                                    AsianPaintColors.createProjectLabelColor),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AsianPaintColors
                                            .createProjectTextBorder)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color:
                                      AsianPaintColors.createProjectTextBorder,
                                )),
                                filled: true,
                                focusColor:
                                    AsianPaintColors.createProjectTextBorder,
                                fillColor: AsianPaintColors.whiteColor,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        strokeAlign: 1,
                                        color: AsianPaintColors
                                            .createProjectTextBorder)),
                                labelText: AppLocalizations.of(context)
                                    .contact_person, //AppLocalizations.of(context).user_id,
                                labelStyle: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishMedium,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: AsianPaintColors
                                        .chooseYourAccountColor),
                                floatingLabelStyle: TextStyle(
                                    color:
                                        AsianPaintColors.chooseYourAccountColor,
                                    fontSize: 12,
                                    fontFamily: AsianPaintsFonts.mulishMedium)),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 45,
                          child: TextFormField(
                            enableInteractiveSelection: false,
                            inputFormatters: <TextInputFormatter>[
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.allow(
                                  RegExp('[0-9]+')),
                            ],
                            controller: mobileNumberController,
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: true, decimal: true),
                            textAlign: TextAlign.start,
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor:
                                AsianPaintColors.createProjectLabelColor,
                            style: TextStyle(
                                fontSize: 13,
                                fontFamily: AsianPaintsFonts.mulishRegular,
                                color:
                                    AsianPaintColors.createProjectLabelColor),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AsianPaintColors
                                            .createProjectTextBorder)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color:
                                      AsianPaintColors.createProjectTextBorder,
                                )),
                                filled: true,
                                focusColor:
                                    AsianPaintColors.createProjectTextBorder,
                                fillColor: AsianPaintColors.whiteColor,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        strokeAlign: 1,
                                        color: AsianPaintColors
                                            .createProjectTextBorder)),
                                labelText: AppLocalizations.of(context)
                                    .mobile_number, //AppLocalizations.of(context).user_id,
                                labelStyle: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishMedium,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: AsianPaintColors
                                        .chooseYourAccountColor),
                                floatingLabelStyle: TextStyle(
                                    color:
                                        AsianPaintColors.chooseYourAccountColor,
                                    fontSize: 12,
                                    fontFamily: AsianPaintsFonts.mulishMedium)),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 45,
                          child: TextFormField(
                            enableInteractiveSelection: false,
                            controller: siteAddressController,
                            keyboardType: TextInputType.streetAddress,
                            textAlign: TextAlign.start,
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor:
                                AsianPaintColors.createProjectLabelColor,
                            style: TextStyle(
                                fontSize: 13,
                                fontFamily: AsianPaintsFonts.mulishRegular,
                                color:
                                    AsianPaintColors.createProjectLabelColor),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AsianPaintColors
                                            .createProjectTextBorder)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color:
                                      AsianPaintColors.createProjectTextBorder,
                                )),
                                filled: true,
                                focusColor:
                                    AsianPaintColors.createProjectTextBorder,
                                fillColor: AsianPaintColors.whiteColor,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        strokeAlign: 1,
                                        color: AsianPaintColors
                                            .createProjectTextBorder)),
                                labelText: AppLocalizations.of(context)
                                    .site_address, //AppLocalizations.of(context).user_id,
                                labelStyle: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishMedium,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: AsianPaintColors
                                        .chooseYourAccountColor),
                                floatingLabelStyle: TextStyle(
                                    color:
                                        AsianPaintColors.chooseYourAccountColor,
                                    fontSize: 12,
                                    fontFamily: AsianPaintsFonts.mulishMedium)),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 45,
                          child: TextFormField(
                            enableInteractiveSelection: false,
                            inputFormatters: <TextInputFormatter>[
                              LengthLimitingTextInputFormatter(4),
                            ],
                            controller: noBathroomsController,
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: true, decimal: true),
                            textAlign: TextAlign.start,
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor:
                                AsianPaintColors.createProjectLabelColor,
                            style: TextStyle(
                                fontSize: 13,
                                fontFamily: AsianPaintsFonts.mulishRegular,
                                color:
                                    AsianPaintColors.createProjectLabelColor),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AsianPaintColors
                                            .createProjectTextBorder)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color:
                                      AsianPaintColors.createProjectTextBorder,
                                )),
                                filled: true,
                                focusColor:
                                    AsianPaintColors.createProjectTextBorder,
                                fillColor: AsianPaintColors.whiteColor,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        strokeAlign: 1,
                                        color: AsianPaintColors
                                            .createProjectTextBorder)),
                                labelText: AppLocalizations.of(context)
                                    .no_of_bathrooms, //AppLocalizations.of(context).user_id,
                                labelStyle: TextStyle(
                                    fontFamily: AsianPaintsFonts.mulishMedium,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: AsianPaintColors
                                        .chooseYourAccountColor),
                                floatingLabelStyle: TextStyle(
                                    color:
                                        AsianPaintColors.chooseYourAccountColor,
                                    fontSize: 12,
                                    fontFamily: AsianPaintsFonts.mulishMedium)),
                          ),
                        ),
                      ],
                    ),
                    BlocConsumer<CloneProjectBloc, CloneProjectState>(
                      listener: (context, state) {
                        if(state is CloneProjectLoaded) {
                          showLoaderDialog(context, 'Copying project.. Please wait..');
                        }
                        if (state is CloneProjectLoaded) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProjectsList(),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: APElevatedButton(
                                onPressed: () async {
                                  if (projectNameController.text.isEmpty) {
                                    FlutterToastProvider().show(
                                        message:
                                            'Please enter a valid project name');
                                  } else if (contactPersonController
                                      .text.isEmpty) {
                                    FlutterToastProvider().show(
                                        message:
                                            'Please enter a valid contact person name');
                                  } else if (mobileNumberController
                                          .text.isEmpty ||
                                      mobileNumberController.text.length !=
                                          10) {
                                    FlutterToastProvider().show(
                                        message:
                                            'Please enter a valid mobile number');
                                  } else if (siteAddressController
                                      .text.isEmpty) {
                                    FlutterToastProvider().show(
                                        message:
                                            'Please enter a valid site address');
                                  } else if (noBathroomsController
                                      .text.isEmpty) {
                                    FlutterToastProvider().show(
                                        message: 'Please enter a valid number');
                                  } else {
                                    CloneProjectBloc cloneProjectBloc =
                                        context.read<CloneProjectBloc>();
                                    if (widget.isClone!) {
                                      Journey.projectName =
                                          projectNameController.text;
                                      Journey.contactPerson =
                                          contactPersonController.text;
                                      Journey.mobileNumber =
                                          mobileNumberController.text;
                                      Journey.siteAddress =
                                          siteAddressController.text;
                                      Journey.noOfBathrooms =
                                          noBathroomsController.text;
                                      // List<Quoteinfo> quoteInfoList = [];
                                      // List<SKUData> skuDataList =
                                      //     Journey.quoteResponseList ?? [];
                                      // for (int i = 0; i < skuDataList.length; i++) {
                                      //   List<Area> areaInfo = [];
                                      //   List<Area> areas =
                                      //       skuDataList[i].areaInfo ?? [];
                                      //   for (int j = 0; j < areas.length; j++) {
                                      //     Area area = Area();
                                      //     area.areaname = areas[j].areaname ?? '';
                                      //     area.areaqty = areas[j].areaqty ?? '';
                                      //     areaInfo.add(area);
                                      //   }
                                      //   Quoteinfo quoteinfo = Quoteinfo();
                                      //   quoteinfo.skuid = skuDataList[i].skuCatCode;
                                      //   quoteinfo.discount =
                                      //       skuDataList[i].discount.toString();
                                      //   quoteinfo.netDiscount =
                                      //       skuDataList[i].netDiscount;
                                      //   quoteinfo.totalqty =
                                      //       skuDataList[i].quantity.toString();
                                      //   quoteinfo.area = areaInfo;
                                      //   quoteinfo.totalprice = skuDataList[i]
                                      //       .totalPriceAfterDiscount
                                      //       .toString();
                                      //   quoteinfo.bundletype = '';
                                      //   quoteInfoList.add(quoteinfo);
                                      // }
                                      cloneProjectBloc.cloneProject(
                                        projectID: widget.projectID,
                                        projectName: projectNameController.text,
                                        contactPerson:
                                            contactPersonController.text,
                                        mobileNumber:
                                            mobileNumberController.text,
                                        siteAddress: siteAddressController.text,
                                        noOfBathrooms:
                                            noBathroomsController.text,
                                      );
                                      // Navigator.pop(context);
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) =>
                                      //         const ProjectsList(),
                                      //   ),
                                      // );
                                    } else {
                                      Journey.projectName =
                                          projectNameController.text;
                                      Journey.contactPerson =
                                          contactPersonController.text;
                                      Journey.mobileNumber =
                                          mobileNumberController.text;
                                      Journey.siteAddress =
                                          siteAddressController.text;
                                      Journey.noOfBathrooms =
                                          noBathroomsController.text;
                                      // List<Quoteinfo> quoteInfoList = [];
                                      // List<SKUData> skuDataList =
                                      //     Journey.quoteResponseList ?? [];
                                      // for (int i = 0; i < skuDataList.length; i++) {
                                      //   List<Area> areaInfo = [];
                                      //   List<Area> areas =
                                      //       skuDataList[i].areaInfo ?? [];
                                      //   for (int j = 0; j < areas.length; j++) {
                                      //     Area area = Area();
                                      //     area.areaname = areas[j].areaname ?? '';
                                      //     area.areaqty = areas[j].areaqty ?? '';
                                      //     areaInfo.add(area);
                                      //   }
                                      //   Quoteinfo quoteinfo = Quoteinfo();
                                      //   quoteinfo.skuid = skuDataList[i].skuCatCode;
                                      //   quoteinfo.discount =
                                      //       skuDataList[i].discount.toString();
                                      //   quoteinfo.netDiscount =
                                      //       skuDataList[i].netDiscount;
                                      //   quoteinfo.totalqty =
                                      //       skuDataList[i].quantity.toString();
                                      //   quoteinfo.area = areaInfo;
                                      //   quoteinfo.totalprice = skuDataList[i]
                                      //       .totalPriceAfterDiscount
                                      //       .toString();
                                      //   quoteinfo.bundletype = '';
                                      //   quoteInfoList.add(quoteinfo);
                                      // }

                                      bloc.createProject(
                                        projectName: projectNameController.text,
                                        contactPerson:
                                            contactPersonController.text,
                                        mobileNumber:
                                            mobileNumberController.text,
                                        siteAddress: siteAddressController.text,
                                        noOfBathrooms:
                                            noBathroomsController.text,
                                      );
                                    }
                                  }
                                },
                                label: state is CreateQuoteLoading ||
                                        state is CreateProjectLoading ||
                                        state is CloneProjectLoading
                                    ? SizedBox(
                                        height: 15,
                                        width: 15,
                                        child: CircularProgressIndicator(
                                          color:
                                              AsianPaintColors.buttonTextColor,
                                        ),
                                      )
                                    : Text(
                                        AppLocalizations.of(context).save,
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
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      tablet: const Scaffold(),
      desktop: Scaffold(
        body: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: SizedBox(
            height: 470,
            width: 400,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(30, 20, 0, 0),
                      child: Text(
                        "New Project",
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: AsianPaintsFonts.bathSansRegular,
                          color: AsianPaintColors.buttonTextColor,
                          //fontWeight: FontWeight.,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 15, 20, 0),
                      child: Image.asset(
                        'assets/images/cancel.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 45,
                        child: TextFormField(
                          enableInteractiveSelection: false,
                          validator: (value) {
                            if ((value ?? '').isEmpty) {
                              FlutterToastProvider().show(
                                  message: 'Please enter a valid project name');
                            }
                          },
                          controller: projectNameController,
                          keyboardType: TextInputType.name,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: AsianPaintColors.createProjectLabelColor,
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              color: AsianPaintColors.createProjectLabelColor),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AsianPaintColors
                                          .createProjectTextBorder)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: AsianPaintColors.createProjectTextBorder,
                              )),
                              filled: true,
                              focusColor:
                                  AsianPaintColors.createProjectTextBorder,
                              fillColor: AsianPaintColors.whiteColor,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      strokeAlign: 1,
                                      color: AsianPaintColors
                                          .createProjectTextBorder)),
                              labelText: AppLocalizations.of(context)
                                  .project_name, //AppLocalizations.of(context).user_id,
                              labelStyle: TextStyle(
                                  fontFamily: AsianPaintsFonts.mulishMedium,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                  color:
                                      AsianPaintColors.chooseYourAccountColor),
                              floatingLabelStyle: TextStyle(
                                  color: AsianPaintColors.kPrimaryColor,
                                  fontSize: 13,
                                  fontFamily: AsianPaintsFonts.mulishRegular)),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 45,
                        child: TextFormField(
                          enableInteractiveSelection: false,
                          controller: contactPersonController,
                          keyboardType: TextInputType.name,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: AsianPaintColors.createProjectLabelColor,
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              color: AsianPaintColors.createProjectLabelColor),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AsianPaintColors
                                          .createProjectTextBorder)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: AsianPaintColors.createProjectTextBorder,
                              )),
                              filled: true,
                              focusColor:
                                  AsianPaintColors.createProjectTextBorder,
                              fillColor: AsianPaintColors.whiteColor,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      strokeAlign: 1,
                                      color: AsianPaintColors
                                          .createProjectTextBorder)),
                              labelText: AppLocalizations.of(context)
                                  .contact_person, //AppLocalizations.of(context).user_id,
                              labelStyle: TextStyle(
                                  fontFamily: AsianPaintsFonts.mulishMedium,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                  color:
                                      AsianPaintColors.chooseYourAccountColor),
                              floatingLabelStyle: TextStyle(
                                  color: AsianPaintColors.kPrimaryColor,
                                  fontSize: 13,
                                  fontFamily: AsianPaintsFonts.mulishRegular)),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 45,
                        child: TextFormField(
                          enableInteractiveSelection: false,
                          controller: mobileNumberController,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: AsianPaintColors.createProjectLabelColor,
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              color: AsianPaintColors.createProjectLabelColor),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AsianPaintColors
                                          .createProjectTextBorder)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: AsianPaintColors.createProjectTextBorder,
                              )),
                              filled: true,
                              focusColor:
                                  AsianPaintColors.createProjectTextBorder,
                              fillColor: AsianPaintColors.whiteColor,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      strokeAlign: 1,
                                      color: AsianPaintColors
                                          .createProjectTextBorder)),
                              labelText: AppLocalizations.of(context)
                                  .mobile_number, //AppLocalizations.of(context).user_id,
                              labelStyle: TextStyle(
                                  fontFamily: AsianPaintsFonts.mulishMedium,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                  color:
                                      AsianPaintColors.chooseYourAccountColor),
                              floatingLabelStyle: TextStyle(
                                  color:
                                      AsianPaintColors.chooseYourAccountColor,
                                  fontSize: 13,
                                  fontFamily: AsianPaintsFonts.mulishMedium)),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 45,
                        child: TextFormField(
                          enableInteractiveSelection: false,
                          controller: siteAddressController,
                          keyboardType: TextInputType.streetAddress,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: AsianPaintColors.createProjectLabelColor,
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              color: AsianPaintColors.createProjectLabelColor),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AsianPaintColors
                                          .createProjectTextBorder)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: AsianPaintColors.createProjectTextBorder,
                              )),
                              filled: true,
                              focusColor:
                                  AsianPaintColors.createProjectTextBorder,
                              fillColor: AsianPaintColors.whiteColor,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      strokeAlign: 1,
                                      color: AsianPaintColors
                                          .createProjectTextBorder)),
                              labelText: AppLocalizations.of(context)
                                  .site_address, //AppLocalizations.of(context).user_id,
                              labelStyle: TextStyle(
                                  fontFamily: AsianPaintsFonts.mulishMedium,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                  color:
                                      AsianPaintColors.chooseYourAccountColor),
                              floatingLabelStyle: TextStyle(
                                  color:
                                      AsianPaintColors.chooseYourAccountColor,
                                  fontSize: 13,
                                  fontFamily: AsianPaintsFonts.mulishMedium)),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 45,
                        child: TextFormField(
                          enableInteractiveSelection: false,
                          controller: noBathroomsController,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: AsianPaintColors.createProjectLabelColor,
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: AsianPaintsFonts.mulishRegular,
                              color: AsianPaintColors.createProjectLabelColor),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AsianPaintColors
                                          .createProjectTextBorder)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: AsianPaintColors.createProjectTextBorder,
                              )),
                              filled: true,
                              focusColor:
                                  AsianPaintColors.createProjectTextBorder,
                              fillColor: AsianPaintColors.whiteColor,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      strokeAlign: 1,
                                      color: AsianPaintColors
                                          .createProjectTextBorder)),
                              labelText: AppLocalizations.of(context)
                                  .no_of_bathrooms, //AppLocalizations.of(context).user_id,
                              labelStyle: TextStyle(
                                  fontFamily: AsianPaintsFonts.mulishMedium,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                  color:
                                      AsianPaintColors.chooseYourAccountColor),
                              floatingLabelStyle: TextStyle(
                                  color:
                                      AsianPaintColors.chooseYourAccountColor,
                                  fontSize: 13,
                                  fontFamily: AsianPaintsFonts.mulishMedium)),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                        width: 330,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35.0),
                            ),
                            backgroundColor:
                                AsianPaintColors.resetPasswordLabelColor,
                            shadowColor: AsianPaintColors.buttonBorderColor,
                            textStyle: TextStyle(
                              color: AsianPaintColors.whiteColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: AsianPaintsFonts.mulishBold,
                            ),
                          ),
                          child: Text(
                            'Save',
                            //AppLocalizations.of(context).add_sku,
                            style: TextStyle(
                              fontFamily: AsianPaintsFonts.mulishBold,
                              color: AsianPaintColors.whiteColor,
                              //color: Colors.white,
                              fontSize: 20,
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
        ),
      ),
    );
  }
}
