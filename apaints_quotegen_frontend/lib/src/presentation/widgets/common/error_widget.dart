import 'package:APaints_QGen/src/core/utils/edge_insets.dart';
import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:APaints_QGen/src/core/utils/sized_boxes.dart';
import 'package:APaints_QGen/src/presentation/widgets/common/buttons/elevated_button.dart';
import 'package:flutter/material.dart';

class APErrorWidget extends StatefulWidget {
  final String errorMessage;
  final void Function()? onRetryPressed;
  final Widget? extraError;
  final double? height;
  final String? errorImage;
  final Widget? errorRetryButton;
  final Widget? errorAlternativeButton;

  const APErrorWidget({
    Key? key,
    required this.errorMessage,
    this.onRetryPressed,
    this.extraError,
    this.height,
    this.errorImage,
    this.errorRetryButton,
    this.errorAlternativeButton,
  }) : super(key: key);

  @override
  _APErrorWidgetState createState() => _APErrorWidgetState();
}

class _APErrorWidgetState extends State<APErrorWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: AsianPaintEdgeInsets.ALL_20,
          child: Image.asset(
            widget.errorImage ?? '',
            height: widget.height ?? displayHeight(context) * 0.2,
          ),
        ),
        Text(
          widget.errorMessage,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
          textAlign: TextAlign.center,
        ),
        if (widget.extraError != null) ...[
          AsianPaintSizedBoxes.height_15,
          widget.extraError!,
        ],
        AsianPaintSizedBoxes.height_15,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.errorAlternativeButton ?? const SizedBox(),
            widget.errorRetryButton ??
                APElevatedButton(
                  onPressed: widget.onRetryPressed,
                  padding: AsianPaintEdgeInsets.horizontal_15
                      .add(AsianPaintEdgeInsets.vertical_15),
                  label: const Text(
                    'Retry',
                  ),
                ),
          ],
        ),
      ],
    );
  }
}
