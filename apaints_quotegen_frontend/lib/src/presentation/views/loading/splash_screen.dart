import 'dart:async';

import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/presentation/blocs/token/get_token_bloc.dart';
import 'package:APaints_QGen/src/presentation/blocs/token/get_token_state.dart';
import 'package:APaints_QGen/src/presentation/views/home/home_screen.dart';
import 'package:APaints_QGen/src/routes.dart';
import 'package:flutter/material.dart';

import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/presentation/views/loading/loading_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SplashScreen());
}

class SplashScreen extends StatelessWidget {
  static const routeName = Routes.SplashScreen;
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Splash();
  }
}

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final secureStorageProvider = getSingleton<SecureStorageProvider>();
  String? token, email, username;
  Future<String?> getToken() async {
    token = await secureStorageProvider.getToken();
    email = await secureStorageProvider.getEmail();
    username = await secureStorageProvider.getUsername();
    logger('Token: $token');

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('first_run') ?? true) {
      FlutterSecureStorage storage = FlutterSecureStorage();

      await storage.deleteAll();

      prefs.setBool('first_run', false);
    }

    if (token == '0') {
      Timer(const Duration(seconds: 3), () {
        logger('Token: $token');
        logger('Email: $email');
        logger('Username: $username');

        // if (token == null || (email ?? '').isEmpty || (username ?? '').isEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const LandingScreen(),
          ),
        );
        // } else {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) =>
        //           HomeScreen(loginType: Journey.loginType ?? 'Internal'),
        //     ),
        //   );
        // }
      });
    }
    return token;
  }

  @override
  void initState() {
    super.initState();
    DefaultCacheManager().emptyCache();

    getToken();

    // Timer(const Duration(seconds: 3), () {
    //   logger('Token: $token');
    //   logger('Email: $email');
    //   logger('Username: $username');

    //   if (token == null || (email ?? '').isEmpty || (username ?? '').isEmpty) {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => const LandingScreen(),
    //       ),
    //     );
    //   } else {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) =>
    //             HomeScreen(loginType: Journey.loginType ?? 'Internal'),
    //       ),
    //     );
    //   }
    // }
    //     // Navigator.pushReplacement(
    //     //   context,
    //     //   MaterialPageRoute(
    //     //     builder: (context) => const LandingScreen(),
    //     //   ),
    //     // ),
    //     );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: bodymobile(context),
        desktop: BlocProvider<TokenBloc>(
          create: (context) => TokenBloc()..getTokens(token ?? ''),
          child: BlocConsumer<TokenBloc, TokenState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is TokenLoaded) {
                Timer(const Duration(seconds: 0), () {
                  logger('Token: $token');
                  logger('Email: $email');
                  logger('Username: $username');

                  // if (token == null || (email ?? '').isEmpty || (username ?? '').isEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                          loginType: Journey.loginType ?? 'Internal'),
                    ),
                  );
                  // } else {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) =>
                  //           HomeScreen(loginType: Journey.loginType ?? 'Internal'),
                  //     ),
                  //   );
                  // }
                });
              } else if (state is TokenFailure) {
                Timer(const Duration(seconds: 0), () {
                  logger('Token: $token');
                  logger('Email: $email');
                  logger('Username: $username');

                  // if (token == null || (email ?? '').isEmpty || (username ?? '').isEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LandingScreen(),
                    ),
                  );
                  // } else {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) =>
                  //           HomeScreen(loginType: Journey.loginType ?? 'Internal'),
                  //     ),
                  //   );
                  // }
                });
              }
              return Builder(builder: (context) {
                return Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      color: Colors.white),
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: SvgPicture.asset(
                        'assets/images/bathsans_logo.svg',
                        height: 20,
                      )),
                      const SizedBox(
                        height: 80,
                        child:
                            Image(image: AssetImage("assets/images/comp.gif")),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ),
        tablet: const Scaffold(),
      ),
    );
  }

  Widget bodymobile(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();

    return BlocProvider<TokenBloc>(
      create: (context) => TokenBloc()..getTokens(token ?? ''),
      child: BlocConsumer<TokenBloc, TokenState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is TokenLoaded) {
            Timer(const Duration(seconds: 3), () {
              logger('Token: $token');
              logger('Email: $email');
              logger('Username: $username');

              // if (token == null || (email ?? '').isEmpty || (username ?? '').isEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen(loginType: Journey.loginType ?? 'Internal'),
                ),
              );
              // } else {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) =>
              //           HomeScreen(loginType: Journey.loginType ?? 'Internal'),
              //     ),
              //   );
              // }
            });
            return Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white), color: Colors.white),
              height: double.infinity,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: SvgPicture.asset(
                    'assets/images/bathsans_logo.svg',
                    height: 20,
                  )),
                  const SizedBox(
                    height: 80,
                    child: Image(image: AssetImage("assets/images/comp.gif")),
                  ),
                ],
              ),
            );
          } else if (state is TokenFailure) {
            Timer(const Duration(seconds: 3), () {
              logger('Token: $token');
              logger('Email: $email');
              logger('Username: $username');

              // if (token == null || (email ?? '').isEmpty || (username ?? '').isEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LandingScreen(),
                ),
              );
              // } else {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) =>
              //           HomeScreen(loginType: Journey.loginType ?? 'Internal'),
              //     ),
              //   );
              // }
            });
            return Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white), color: Colors.white),
              height: double.infinity,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: SvgPicture.asset(
                    'assets/images/bathsans_logo.svg',
                    height: 20,
                  )),
                  const SizedBox(
                    height: 80,
                    child: Image(image: AssetImage("assets/images/comp.gif")),
                  ),
                ],
              ),
            );
          }
          return Builder(builder: (context) {
            return Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white), color: Colors.white),
              height: double.infinity,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: SvgPicture.asset(
                    'assets/images/bathsans_logo.svg',
                    height: 20,
                  )),
                  const SizedBox(
                    height: 80,
                    child: Image(image: AssetImage("assets/images/comp.gif")),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}
