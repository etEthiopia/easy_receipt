import 'package:easy_receipt/receipt_review.dart';
import 'package:easy_receipt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BillImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dbackground2,
      appBar: AppBar(
        title: Text(ReceiptPreviewScreen.selectedBill.billMonth),
        backgroundColor: dbackground3,
      ),
      body: SafeArea(
          child: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(
          top: 10.0,
        ),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              // image: DecorationImage(
            ),
            child: loadimage(ReceiptPreviewScreen.selectedBill.url)),
      )),
    );
  }

  Widget _error(BuildContext context, String url, dynamic error) {
    print(error);
    return const Center(
        child: Icon(
      Icons.error,
    ));
  }

  Widget _progress(BuildContext context, String url, dynamic downloadProgress) {
    return Center(
        child: CircularProgressIndicator(
      value: downloadProgress.progress,
      valueColor: AlwaysStoppedAnimation<Color>(primary),
    ));
  }

  Widget loadimage(String image) {
    return CachedNetworkImage(
      imageUrl: image,
      progressIndicatorBuilder: _progress,
      errorWidget: _error,
    );
  }
}
