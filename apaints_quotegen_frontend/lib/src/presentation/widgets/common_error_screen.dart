import 'package:APaints_QGen/src/core/utils/edge_insets.dart';
import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:APaints_QGen/src/presentation/views/loading/loading_screen.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/elevated_button.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/outlined_button.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/error_widget.dart';
import 'package:APaints_QGen/translations/locale_keys.g.dart';
import 'package:flutter/material.dart';

class CommonErrorScreen extends StatelessWidget {
  final String? errorMessage;
  const CommonErrorScreen({
    Key? key,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     APErrorWidget(
    //       errorMessage: LocaleKeys.somethingWentWrong.translate(),
    //       errorImage: '',
    //       errorRetryButton: APElevatedButton(
    //         padding: AsianPaintEdgeInsets.horizontal_20
    //             .add(AsianPaintEdgeInsets.vertical_15),
    //         label: Text("Back"),
    //         margin: AsianPaintEdgeInsets.left_10,
    //         onPressed: () {
    //           Navigator.pop(context);
    //         },
    //       ),
    //       errorAlternativeButton: APOutlinedButton(
    //         padding: AsianPaintEdgeInsets.horizontal_20
    //             .add(AsianPaintEdgeInsets.vertical_15),
    //         margin: AsianPaintEdgeInsets.right_20,
    //         label: const Text("Restart App"),
    //         onPressed: () {
    //           Navigator.pushNamedAndRemoveUntil(
    //             context,
    //             LandingScreen.routeName,
    //             (route) => false,
    //           );
    //         },
    //       ),
    //       extraError: Padding(
    //         padding: AsianPaintEdgeInsets.horizontal_25,
    //         child: Column(
    //           children: [
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Flexible(
    //                   child: Text(
    //                     errorMessage?.handleOverflow(200) ??
    //                         "Oops! you landed somewhere you shouldn't!",
    //                     style:
    //                         Theme.of(context).textTheme.bodyLarge!.copyWith(),
    //                     textAlign: TextAlign.center,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}
