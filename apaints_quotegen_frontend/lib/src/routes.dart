import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/my_projects.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/quick_quote.dart';
import 'package:APaints_QGen/src/presentation/views/bottom_navigations/template_quote/template_quote_mobile.dart';
import 'package:APaints_QGen/src/presentation/views/home/home_screen.dart';
import 'package:APaints_QGen/src/presentation/views/loading/loading_screen.dart';
import 'package:APaints_QGen/src/presentation/views/loading/splash_screen.dart';
import 'package:APaints_QGen/src/presentation/views/login/external/login_otp_view.dart';
import 'package:APaints_QGen/src/presentation/views/login/external/login_view_external.dart';
import 'package:APaints_QGen/src/presentation/views/login/internal/login_view.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/brands_list.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/range_list.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/sku_list.dart';
import 'package:APaints_QGen/src/presentation/views/quick_quote/view_quote.dart';
import 'package:APaints_QGen/src/presentation/views/sku/sku_description.dart';
import 'package:APaints_QGen/src/presentation/widgets/common_error_screen.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'presentation/views/bottom_navigations/competiton_search/mobile/competition_search.dart';

class AsianPaintsRouter {
  AsianPaintsRouter._();

  static Widget Function(BuildContext, Animation<double>, Animation<double>)
      _getBuilder(Widget screen) {
    return (context, _, __) => screen;
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // FRRouter.generateRoute(settings);
    Widget Function(
      BuildContext context,
      Animation<double>,
      Animation<double>,
    ) builder;
    logger('ROUTE: ${settings.name ?? ''}');
    switch (settings.name) {
      case SplashScreen.routeName:
        builder = _getBuilder(const SplashScreen());
        break;
      case LandingScreen.routeName:
        builder = _getBuilder(const LandingScreen());
        break;
      case LoginScreen.routeName:
        builder = _getBuilder(const LoginScreen());
        break;
      case ExternalUserLoginScreen.routeName:
        builder = _getBuilder(const ExternalUserLoginScreen());
        break;

      case ExternalUserOTPScreen.routeName:
        builder = _getBuilder(const ExternalUserOTPScreen());
        break;
      case HomeScreen.routeName:
        builder = _getBuilder(HomeScreen(
          loginType: '',
        ));
        break;
      case QuickQuote.routeName:
        builder = _getBuilder(QuickQuote());
        break;
      // case BookingHistoryPage.routeName:
      //   builder = _getBuilder(HomeScreen(
      //     page: HomeScreen.pageIndex[BookingHistoryPage.routeName],
      //   ));
      //   break;
      case TemplateQuote.routeName:
        builder = _getBuilder(TemplateQuote());
        break;
      case CompetitionSearch.routeName:
        builder = _getBuilder(const CompetitionSearch());
        break;
      case MyProjects.routeName:
        builder = _getBuilder(MyProjects());
        break;
      case BrandsList.routeName:
        builder = _getBuilder(const BrandsList(
          categoryIndex: 0,
        ));
        break;

      // case OTPVerificationScreen.routeName:
      //   var arguments = settings.arguments != null
      //       ? (settings.arguments as Map<String, dynamic>)
      //       : {};
      //   builder = _getBuilder(OTPVerificationScreen(
      //     email: arguments[OTPVerificationScreen.emailKey],
      //     phoneNumber: arguments[OTPVerificationScreen.phoneNumberKey],
      //     password: arguments[OTPVerificationScreen.passwordKey],
      //     name: arguments[OTPVerificationScreen.nameKey],
      //     fromScreen: arguments[OTPVerificationScreen.fromScreenKey],
      //     type: arguments[OTPVerificationScreen.typeKey],
      //   ));
      //   break;
      case RangeList.routeName:
        builder = _getBuilder(const RangeList(
          catIndex: 0,
          brandIndex: 0,
        ));
        break;
      case SKUList.routeName:
        builder = _getBuilder(const SKUList(
          brandIndex: 0,
          catIndex: 0,
          rangeIndex: 0,
          brand: '',
          category: '',
          range: '',
        ));
        break;
      case ViewQuote.routeName:
        builder = _getBuilder(ViewQuote(
          catIndex: 0,
          brandIndex: 0,
          rangeIndex: 0,
        ));
        break;
      case SKUDescriptionPage.routeName:
        builder = _getBuilder(SKUDescriptionPage(
          brandIndex: 0,
          catIndex: 0,
          rangeIndex: 0,
        ));
        break;
      default:
        builder = _getBuilder(const CommonErrorScreen());
    }

    return PageRouteBuilder(
      pageBuilder: builder,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}

class Routes {
  Routes._();
  static const String LandingScreen = '/loading';
  static const String SplashScreen = '/';
  static const String HomeScreen = '/home';
  static const String InternalLoginScreen = '/internal_login';
  static const String ExternalLoginScreen = '/external_login';
  static const String OTPVerificationScreen = '/otp-verification';

  static const String BrandsScreen = '/brands_screen';
  static const String RangeScreen = '/range_screen';
  static const String SKUScreen = '/sku_screen';

  static const String SKUDescriptionScreen = '/sku_description_screen';
  static const String ViewQuoteScreen = '/view_quote_screen';

  static const String QuickQuoteScreen = '/quick-quote';
  static const String CompetitionSearchScreen = '/competion-search';
  static const String TemplateQuoteScreen = '/template-quote';
  static const String MyProjectsScreen = '/my-projects';
}
