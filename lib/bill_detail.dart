import 'package:easy_receipt/receipt_review.dart';
import 'package:easy_receipt/theme/colors.dart';
import 'package:flutter/material.dart';

class BillDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dbackground2,
      appBar: AppBar(
        title: Text(ReceiptPreviewScreen.selectedBill.billMonth),
        backgroundColor: dbackground3,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: _details()))),
    );
  }

  _details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title("Title"),
        _value(ReceiptPreviewScreen.selectedBill.title),
        _sizedBox(),
        _title("Bank Branch"),
        _value(ReceiptPreviewScreen.selectedBill.bankBranch),
        _sizedBox(),
        _title("Payment Date"),
        _value(ReceiptPreviewScreen.selectedBill.paymentDate),
        _sizedBox(),
        _title("Transaction Ref"),
        _value(ReceiptPreviewScreen.selectedBill.transRef),
        _sizedBox(),
        _title("Account Number"),
        _value(ReceiptPreviewScreen.selectedBill.accountNo.toString()),
        _sizedBox(),
        _title("Customer Key"),
        _value(ReceiptPreviewScreen.selectedBill.customerKey),
        _sizedBox(),
        _title("Account Name"),
        _value(ReceiptPreviewScreen.selectedBill.accountName),
        _sizedBox(),
        _title("Bill Month"),
        _value(ReceiptPreviewScreen.selectedBill.billMonth),
        _sizedBox(),
        _title("Current Read"),
        _value(ReceiptPreviewScreen.selectedBill.currentRead.toString()),
        _sizedBox(),
        _title("Previous Read"),
        _value(ReceiptPreviewScreen.selectedBill.previousRead.toString()),
        _sizedBox(),
        _title("Amount"),
        _value(
            ReceiptPreviewScreen.selectedBill.previousRead.toString() + " ETB"),
        _sizedBox(),
        _title("Consumption"),
        _value(ReceiptPreviewScreen.selectedBill.consumption.toString()),
        _sizedBox(),
        _title("Biller Branch"),
        _value(ReceiptPreviewScreen.selectedBill.billerBranch),
        _sizedBox(),
      ],
    );
  }

  _title(String text) {
    return Text(
      text,
      style: TextStyle(color: light),
    );
  }

  _value(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 17),
      overflow: TextOverflow.fade,
      maxLines: 2,
    );
  }

  _sizedBox() {
    return SizedBox(height: 20);
  }
}
