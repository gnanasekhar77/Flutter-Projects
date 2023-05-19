import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/range_list.dart';
import 'package:APaints_QGen/src/presentation/widgets/app_bar.dart';
import 'package:APaints_QGen/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrandsList extends StatefulWidget {
  static const routeName = Routes.BrandsScreen;
  final int categoryIndex;
  final String? category;
  const BrandsList({super.key, required this.categoryIndex, this.category});

  @override
  State<BrandsList> createState() => _BrandsListState();
}

class _BrandsListState extends State<BrandsList> {
  @override
  Widget build(BuildContext context) {
    String cat = widget.category!;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Responsive(
      desktop: Scaffold(
        backgroundColor: AsianPaintColors.appBackgroundColor,
        key: scaffoldKey,
        appBar: AppBarTemplate(
          isVisible: true,
          header: AppLocalizations.of(context).brands,
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(48, 30, 0, 0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    AppLocalizations.of(context).brands,
                    style: TextStyle(
                      color: AsianPaintColors.projectUserNameColor,
                      fontFamily: AsianPaintsFonts.bathSansRegular,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(37, 10, 20, 0),
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20),
                      itemCount: Journey.catagoriesData?[widget.categoryIndex]
                              .list!.length ??
                          0,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RangeList(
                                        catIndex: widget.categoryIndex,
                                        brandIndex: index,
                                        category: widget.category,
                                        brand: Journey
                                                .catagoriesData?[
                                                    widget.categoryIndex]
                                                .list?[index]
                                                .brand ??
                                            '',
                                      )),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Image.network(
                                        Journey
                                                .catagoriesData?[
                                                    widget.categoryIndex]
                                                .list![index]
                                                .brandImage ??
                                            '',
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.25,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 5),
                                        child: Text(
                                          Journey
                                                  .catagoriesData?[
                                                      widget.categoryIndex]
                                                  .list?[index]
                                                  .brand ??
                                              '',
                                          style: TextStyle(
                                              color: AsianPaintColors
                                                  .forgotPasswordTextColor,
                                              fontSize: 12,
                                              fontFamily: AsianPaintsFonts
                                                  .mulishMedium),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
      tablet: const Scaffold(),
      mobile: Scaffold(
        backgroundColor: AsianPaintColors.appBackgroundColor,
        key: scaffoldKey,
        appBar: AppBarTemplate(
          isVisible: true,
          header: AppLocalizations.of(context).brands,
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3 / 2.7,
                        ),
                        itemCount: Journey.catagoriesData?[widget.categoryIndex]
                                .list!.length ??
                            0,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RangeList(
                                    catIndex: widget.categoryIndex,
                                    brandIndex: index,
                                    category: widget.category,
                                    brand: Journey
                                            .catagoriesData?[
                                                widget.categoryIndex]
                                            .list![index]
                                            .brand ??
                                        '',
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              color: Colors.white,
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Image.network(
                                      Journey
                                              .catagoriesData?[
                                                  widget.categoryIndex]
                                              .list?[index]
                                              .brandImage ??
                                          '',
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.17,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Text(
                                        Journey
                                                .catagoriesData?[
                                                    widget.categoryIndex]
                                                .list?[index]
                                                .brand ??
                                            '',
                                        style: TextStyle(
                                            color: AsianPaintColors
                                                .forgotPasswordTextColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            fontFamily:
                                                AsianPaintsFonts.mulishMedium),
                                      ),
                                    ),
                                  ]),
                            ),
                          );
                        }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                onPressed: () =>
                    Future.delayed(const Duration(milliseconds: 1), () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                }),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}
