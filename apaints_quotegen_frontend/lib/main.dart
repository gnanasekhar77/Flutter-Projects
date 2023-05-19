import 'dart:async';

import 'package:APaints_QGen/app.dart';
import 'package:APaints_QGen/setup.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_settings_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/easy_localization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(
//     MaterialApp(
//       localizationsDelegates: const [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: const [
//         Locale('en', ''),
//       ],
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: BlocProvider<AuthBloc>(
//         create: (context) => AuthBloc(AuthImpl()),
//         child: const HomePage(),
//       ),
//     ),
//   );
// }

// class HomePage extends StatelessWidget {
//   const HomePage({Key? key}) : super(key: key);

//   void initState() {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: [SystemUiOverlay.bottom]);
//   }

//   void dispose() {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: SystemUiOverlay.values);
//   }

//   @override
//   Widget build(BuildContext context) {
//     context.read<AuthBloc>().add(const AuthEventInitialize());
//     return BlocConsumer<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state.isLoading) {
//           const SplashScreen();
//         } else {
//           // LoadingScreen().hide();
//         }
//       },
//       builder: (context, state) {
//         if (state is AuthStateLoggedIn) {
//           return const HomeScreen();
//         } else if (state is AuthStateNeedsVerification) {
//           return const SplashScreen();
//         } else if (state is AuthStateLoggedOut) {
//           return const LandingScreen();
//         } else {
//           return const SplashScreen();
//           // return const Scaffold(
//           //   body: CircularProgressIndicator(),
//           // );
//         }
//       },
//     );
//   }
// }

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    logger(event!);
  }

  @override
  void onTransition(
      Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    logger('##$transition');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    logES(error, stackTrace);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupResources();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await runZonedGuarded<Future<void>>(() async {
    // ignore: deprecated_member_use
    BlocOverrides.runZoned(
      () => runApp(
        getSingleton<EasyLocalizationProvider>().easyLocalization(
          path: 'assets/translations',
          supportedLocales: [const Locale('en', '')],
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                  create: (_) => AppSettingsProvider()..setup()),
            ],
            child: const App(),
          ),
        ),
      ),
      blocObserver: SimpleBlocObserver(),
    );
  }, (Object error, StackTrace stackTrace) {
    logES(error, stackTrace);
  });
}
