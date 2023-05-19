import 'dart:async';
import 'dart:io';

import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/presentation/widgets/app_bar.dart';
import 'package:APaints_QGen/src/presentation/widgets/pdf/flutter_cached_pdfview.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class PDFViewerCachedFromUrl extends StatelessWidget {
  PDFViewerCachedFromUrl(
      {Key? key,
      required this.url,
      required this.name,
      this.allowShare,
      this.subject,
      this.totalPrice})
      : super(key: key);

  final String url;
  final String name;
  final bool? allowShare;
  final String? subject;
  final String? totalPrice;
  final StreamController<String> _pageCountController =
      StreamController<String>();

  @override
  Widget build(BuildContext context) {
    String fileCachePath = "";
    logger('PDF CACHE URL: $url');

    return WillPopScope(
      onWillPop: () async {
        // do something here
        return true;
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Scaffold(
          appBar: AppBarTemplate(isVisible: true, header: 'PDF'),
          body: const PDF().cachedFromUrl(
            url,
            placeholder: (double progress) =>
                Center(child: Text('$progress %')),
            whenDone: (filePath) async {
              fileCachePath = filePath;
            },
            errorWidget: (dynamic error) =>
                Center(child: Text(error.toString())),
          ),
          floatingActionButton: Visibility(
            visible: allowShare == true ? true : false,
            child: FloatingActionButton(
              backgroundColor: AsianPaintColors.whiteColor,
              onPressed: () async {
                final box = context.findRenderObject() as RenderBox?;
                // ignore: deprecated_member_use
                await Share.shareFiles(
                  [fileCachePath],
                  // subject: subject,
                  // text:
                      // "Hello, \n\nGreetings from Bathsense! \n\nThank you for your interest in Bathsense products for your bathroom. Based on our initial discussion and material selection, we have provided the estimated cost in the attached quote. \n\nThe total price for all deliverables is \u{20B9}$totalPrice. We've broken this down in the quote, so you can see each individual product's cost, and what is the price for each area in your bathroom. \n\nBathsense products ensure that you install them once and never have to worry about maintaining them. Superior quality of material allows us to offer you the best bathroom experience. we have the best warranty policy in the industry. Therefore, in case of any issues, we ensure free servicing along with spare parts provision. Our ISO certified services have a benchmarked resolution time within 48 hours. \n\nWe would be happy to discuss this quote and provide answers to any questions you may have. We hope that you find our cost schedule acceptable. \n\nBathsense helps you create truly beautiful bathrooms! For more inspiration visit our website (www.bathsense.com). \n \nWarm regards, \n${Journey.username ?? ''}",
                  // mimeTypes: ['application/pdf'],
                );
              },
              child: const Icon(Icons.share),
            ),
          ),
        ),
      ),
    );
  }
}
