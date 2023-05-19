import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:APaints_QGen/src/core/utils/theme.dart';
import 'package:APaints_QGen/src/data/datasources/remote/alice_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_settings_provider.dart';
import 'package:APaints_QGen/src/data/repositories/search_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/authentication/authentication_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/categories/categories_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/bundle_sanware_list/competiton_search_san_bund_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_list/competiton_search_list_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_result/competiton_search_result_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/copy_quote/copy_quote_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/email_template/email_template_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/clone_project/clone_project_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/create_quote/create_quote_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/delete_quote/delete_quote_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/delete_sku_from_quote/delete_sku_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/export_project/export_project_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/flip_quote/flip_quote_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/get_projects/get_projects_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/project_description.dart/project_description_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/search/search_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/sku/sku_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/template_quote/search_list/template_quote_list_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/template_quote/search_result/temp_quote_search_result_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/token/get_token_bloc.dart';
import 'package:APaints_QGen/src/routes.dart';
import 'package:APaints_QGen/translations/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final AppConfigProvider _configProvider = getSingleton<AppConfigProvider>();
  final AliceProvider _aliceProvider = getSingleton<AliceProvider>();

  void globalSnackbar(String? message, bool showHideButton) {
    ScaffoldMessenger.of(_navigatorKey.currentContext!).removeCurrentSnackBar();
    ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          message ?? '',
        ),
        action: showHideButton
            ? SnackBarAction(
                label: LocaleKeys.hide.translate(),
                onPressed: () {
                  ScaffoldMessenger.of(_navigatorKey.currentContext!)
                      .hideCurrentSnackBar();
                },
              )
            : null,
        duration: const Duration(seconds: 3),
        elevation: 4,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppSettingsProvider appSettingsProvider =
        getProvider<AppSettingsProvider>(context);

    _configProvider.setNavigatorKey(_navigatorKey);
    _aliceProvider.setNavigatorKey();
    _configProvider.setGlobalSnackbar(globalSnackbar);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) => AuthenticationBloc()..appStarted(),
        ),
        BlocProvider(
          create: (BuildContext context) => CategoriesListBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => SkuListBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => ProjectsListBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => CreateQuoteBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => ProjectDescriptionBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => CloneProjectBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => FlipQuoteBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => ExportProjectBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => DelQuoteBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) =>
              SearchListBloc(searchListRepo: SearchRepositoryImpl()),
        ),
        BlocProvider(
          create: (BuildContext context) => GetCompetitionSearchListBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => GetCompetitionSearchResultBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => TemplateQuoteListBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => GetTempQuoteSearchResultBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => CopyQuoteBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => DelSkuBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => GetCompetitionSanBundResultBloc(),
        ),
        BlocProvider(create: (BuildContext context) => EmailTemplateBloc()),
        BlocProvider(create: (BuildContext context) => TokenBloc()),

        // BlocProvider(
        //   create: (BuildContext context) => ConfigBloc(),
        // ),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
        ],
        locale: context.locale,
        builder: (context, child) {
          // ErrorWidget.builder =
          //     (FlutterErrorDetails errorDetails) => CommonErrorScreen(
          //           errorMessage: errorDetails.exceptionAsString(),
          //         );
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.SplashScreen,
        onGenerateRoute: AsianPaintsRouter.generateRoute,
        theme: AsianPaintsTheme.getTheme(appSettingsProvider.isDark),
        darkTheme: AsianPaintsTheme.getTheme(appSettingsProvider.isDark),
        themeMode:
            appSettingsProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }
}
