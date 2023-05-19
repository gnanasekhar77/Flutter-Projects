import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/competiton_search/mobile/competition_search.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/quick_quote.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/template_quote/template_quote_web.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:side_navigation/side_navigation.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/fonts.dart';
import 'app_bar.dart';

import 'my_projects_ui_web.dart';

class Sidemen extends StatefulWidget {
  const Sidemen({Key? key}) : super(key: key);

  @override
  State<Sidemen> createState() => _SidemenState();
}

class _SidemenState extends State<Sidemen> {
  PageController page = PageController();

  SideMenuController sideMenu = SideMenuController();

  //int get selectedIndex => _selectedIndex;
  bool isQuickQuoteSel = false;
  bool isTemplateSel = false;
  bool isCompSel = false;
  bool isMyProjSel = false;
  @override
  void initState() {
    isQuickQuoteSel = true;
    sideMenu.addListener((p0) {
      page.jumpToPage(p0);
    });
    super.initState();
  }

  List<Widget> views = Journey.loginType == 'Internal'
      ? const [
          QuickQuote(),
          TemplateQuoteUi(),
          CompetitionSearch(),
          MyProjectUi(
            fromMyProjs: true,
          )
        ]
      : const [
          QuickQuote(),
          TemplateQuoteUi(),
          MyProjectUi(
            fromMyProjs: true,
          )
        ];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    logger("Journey Login Type in web: " '${Journey.loginType}');
    logger('Side menu: ${sideMenu.currentPage}');
    // int get selectedIndex => _selectedIndex;

    return Scaffold(
      /// You can use an AppBar if you want to
      appBar: AppBarTemplate(
        isVisible: true,
        header: '',
      ),

      // The row is needed to display the current view
      body: Row(
        children: [
          /// Pretty similar to the BottomNavigationBar!
          Journey.loginType == 'Internal'
              ? SideNavigationBar(
                  selectedIndex: selectedIndex,
                  theme: SideNavigationBarTheme(
                      // backgroundColor: AsianPaintColors.whiteColor,
                      itemTheme: SideNavigationBarItemTheme(
                          selectedBackgroundColor:
                              AsianPaintColors.buttonTextColor,
                          selectedItemColor: AsianPaintColors.whiteColor,
                          unselectedBackgroundColor:
                              AsianPaintColors.whiteColor,
                          unselectedItemColor:
                              AsianPaintColors.skuDescriptionColor,
                          labelTextStyle: TextStyle(
                              fontFamily: AsianPaintsFonts.mulishRegular)),
                      togglerTheme: const SideNavigationBarTogglerTheme(),
                      dividerTheme: SideNavigationBarDividerTheme.standard()),
                  items: const [
                    SideNavigationBarItem(
                      icon: Icons.timer_outlined,
                      label: 'Quick Quote',
                    ),
                    SideNavigationBarItem(
                      icon: Icons.view_comfortable_outlined,
                      label: 'Template Quote',
                    ),
                    SideNavigationBarItem(
                      icon: Icons.search,
                      label: 'Competition Search',
                    ),
                    SideNavigationBarItem(
                      icon: Icons.beenhere_outlined,
                      // icon: Icons.turned_in_not_outlined,
                      label: 'My Projects',
                    ),
                  ],
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                )
              : SideNavigationBar(
                  selectedIndex: selectedIndex,
                  theme: SideNavigationBarTheme(
                      // backgroundColor: AsianPaintColors.whiteColor,
                      itemTheme: SideNavigationBarItemTheme(
                          selectedBackgroundColor:
                              AsianPaintColors.buttonTextColor,
                          selectedItemColor: AsianPaintColors.whiteColor,
                          unselectedBackgroundColor:
                              AsianPaintColors.whiteColor,
                          unselectedItemColor:
                              AsianPaintColors.skuDescriptionColor,
                          labelTextStyle: TextStyle(
                              fontFamily: AsianPaintsFonts.mulishRegular)),
                      togglerTheme: const SideNavigationBarTogglerTheme(),
                      dividerTheme: SideNavigationBarDividerTheme.standard()),
                  //
                  items: const [
                    SideNavigationBarItem(
                      icon: Icons.timer_outlined,
                      label: 'Quick Quote',
                    ),
                    SideNavigationBarItem(
                      icon: Icons.view_comfortable_outlined,
                      label: 'Template Quote',
                    ),
                    SideNavigationBarItem(
                      icon: Icons.beenhere_outlined,
                      label: 'My Projects',
                    ),
                  ],
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                ),

          /// Make it take the rest of the available width
          Expanded(
            child: views.elementAt(selectedIndex),
          )
        ],
      ),
    );
  }

  // return Scaffold(
  //   appBar: AppBarTemplate(
  //     isVisible: true,
  //     header: '',
  //   ),
  //   body: Row(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     children: [
  //       SideMenu(
  //         controller: sideMenu,
  //         style: SideMenuStyle(
  //           itemHeight: 80,
  //           itemBorderRadius: const BorderRadius.all(Radius.zero),
  //           itemOuterPadding: const EdgeInsets.all(0),
  //           itemInnerSpacing: 30,
  //           //showTooltip: true,
  //           displayMode: SideMenuDisplayMode.open,
  //           selectedColor: AsianPaintColors.buttonTextColor,

  //           selectedTitleTextStyle: TextStyle(
  //               color: AsianPaintColors.whiteColor,
  //               fontFamily: AsianPaintsFonts.bathSansRegular),
  //           unselectedTitleTextStyle: TextStyle(
  //               color: AsianPaintColors.skuDescriptionColor,
  //               fontFamily: AsianPaintsFonts.bathSansRegular),
  //           //selectedIconColor: AsianPaintColors.whiteColor,
  //           // unselectedIconColor: Colors.red,

  //           backgroundColor: AsianPaintColors.whiteColor,
  //         ),
  //         items: Journey.loginType == 'Internal'
  //             ? [
  //                 SideMenuItem(
  //                   priority: 0,
  //                   title: 'Quick Quote',
  //                   onTap: (page, _) {
  //                     setState(() {
  //                       isQuickQuoteSel = true;
  //                       isTemplateSel = false;
  //                       isCompSel = false;
  //                       isMyProjSel = false;
  //                     });

  //                     sideMenu.changePage(page);
  //                   },
  //                   iconWidget: SvgPicture.asset(
  //                     'assets/images/timer1.svg',
  //                     color: isQuickQuoteSel
  //                         ? AsianPaintColors.whiteColor
  //                         : AsianPaintColors.skuDescriptionColor,
  //                   ), //Image.asset('./assets/images/location.png'),
  //                 ),
  //                 SideMenuItem(
  //                   priority: 1,
  //                   title: 'Template Quote',
  //                   onTap: (page, _) {
  //                     sideMenu.changePage(page);
  //                     setState(() {
  //                       isQuickQuoteSel = false;
  //                       isTemplateSel = true;
  //                       isCompSel = false;
  //                       isMyProjSel = false;
  //                     });
  //                   },
  //                   iconWidget: SvgPicture.asset(
  //                     'assets/images/grid-71.svg',
  //                     color: isTemplateSel
  //                         ? AsianPaintColors.whiteColor
  //                         : AsianPaintColors.skuDescriptionColor,
  //                   ),
  //                 ),
  //                 SideMenuItem(
  //                   priority: 2,
  //                   title: 'Competition Search',
  //                   onTap: (page, _) {
  //                     setState(() {
  //                       isQuickQuoteSel = false;
  //                       isTemplateSel = false;
  //                       isCompSel = true;
  //                       isMyProjSel = false;
  //                     });
  //                     sideMenu.changePage(page);
  //                   },
  //                   iconWidget: SvgPicture.asset(
  //                     'assets/images/search-normal1.svg',
  //                     color: isCompSel
  //                         ? AsianPaintColors.whiteColor
  //                         : AsianPaintColors.skuDescriptionColor,
  //                   ),
  //                 ),
  //                 SideMenuItem(
  //                   priority: 3,
  //                   title: 'My Projects',
  //                   onTap: (page, _) {
  //                     setState(() {
  //                       isQuickQuoteSel = false;
  //                       isTemplateSel = false;
  //                       isCompSel = false;
  //                       isMyProjSel = true;
  //                     });
  //                     sideMenu.changePage(page);
  //                   },
  //                   iconWidget: SvgPicture.asset(
  //                     'assets/images/archive-tick1.svg',
  //                     color: isMyProjSel
  //                         ? AsianPaintColors.whiteColor
  //                         : AsianPaintColors.skuDescriptionColor,
  //                   ),
  //                 ),
  //               ]
  //             : [
  //                 SideMenuItem(
  //                   priority: 0,
  //                   title: 'Quick Quote',
  //                   onTap: (page, _) {
  //                     setState(() {
  //                       isQuickQuoteSel = true;
  //                       isTemplateSel = false;
  //                       isMyProjSel = false;
  //                     });
  //                     sideMenu.changePage(page);
  //                   },
  //                   iconWidget: SvgPicture.asset(
  //                     'assets/images/timer1.svg',
  //                     color: isQuickQuoteSel
  //                         ? AsianPaintColors.whiteColor
  //                         : AsianPaintColors.skuDescriptionColor,
  //                   ),

  //                   //tooltipContent: "This is a tooltip for Dashboard item",
  //                 ),
  //                 SideMenuItem(
  //                   priority: 1,
  //                   title: 'Template Quote',
  //                   onTap: (page, _) {
  //                     setState(() {
  //                       isQuickQuoteSel = false;
  //                       isTemplateSel = true;
  //                       isMyProjSel = false;
  //                     });
  //                     sideMenu.changePage(page);
  //                   },
  //                   iconWidget: SvgPicture.asset(
  //                     'assets/images/grid-71.svg',
  //                     color: isTemplateSel
  //                         ? AsianPaintColors.whiteColor
  //                         : AsianPaintColors.skuDescriptionColor,
  //                   ),
  //                 ),
  //                 SideMenuItem(
  //                   priority: 2,
  //                   title: 'My Projects',
  //                   onTap: (page, _) {
  //                     sideMenu.changePage(page);
  //                     setState(() {
  //                       isQuickQuoteSel = false;
  //                       isTemplateSel = false;
  //                       isMyProjSel = true;
  //                     });
  //                   },
  //                   iconWidget: SvgPicture.asset(
  //                     'assets/images/archive-tick1.svg',
  //                     color: isMyProjSel
  //                         ? AsianPaintColors.whiteColor
  //                         : AsianPaintColors.skuDescriptionColor,
  //                   ),
  //                 ),
  //               ],
  //       ),
  //       Expanded(
  //         child: Journey.loginType == 'Internal'
  //             ? PageView(
  //                 physics: const NeverScrollableScrollPhysics(),
  //                 controller: page,
  //                 children: const [
  //                   QuickQuote(),
  //                   TemplateQuoteUi(),
  //                   CompetitionSearch(),
  //                   MyProjectUi()
  //                 ],
  //               )
  //             : PageView(
  //                 physics: const NeverScrollableScrollPhysics(),
  //                 controller: page,
  //                 children: const [
  //                   QuickQuote(),
  //                   TemplateQuoteUi(),
  //                   MyProjectUi()
  //                 ],
  //               ),
  //       ),
  //     ],
  //   ),
  // );
  // }
}
