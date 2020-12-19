import 'package:easy_receipt/models/aawsa.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormRecognizer {
  static Future<AAWSA> analyze({String url}) async {
    var res = await http
        .post(
            "https://prod-03.westus2.logic.azure.com:443/workflows/32a112f87bf74698b870945e293d7cc8/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=DQLKJRygME2xvUzFsz3vU0946nPWQGjVvT8fylFpejg",
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Charset': 'utf-8'
            },
            body: jsonEncode(<String, dynamic>{
              "bill_type": "aawsa",
              "image": {"source": url}
            }))
        .timeout(Duration(minutes: 2));

    if (res.statusCode == 200) {
      if (res.body != null) {
        AAWSA bill = AAWSA.fromJson(json.decode(res.body));
        bill.url = url;
        print("bill");
        return bill;
      } else {
        throw Exception('Null');
      }
    } else {
      throw throw Exception('Not 200: ' + res.statusCode.toString());
    }
  }
}
