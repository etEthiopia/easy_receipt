import 'dart:io';
import 'package:easy_receipt/api/form_recognizer.dart';
import 'package:easy_receipt/bill_detail.dart';
import 'package:easy_receipt/models/aawsa.dart';
import 'package:easy_receipt/phone_auth.dart';
import 'package:easy_receipt/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ReceiptPreviewScreen extends StatefulWidget {
  static AAWSA selectedBill;

  @override
  _ReceiptPreviewScreen createState() => _ReceiptPreviewScreen();
}

class _ReceiptPreviewScreen extends State<ReceiptPreviewScreen> {
  final ImagePicker _picker = ImagePicker();
  File _imageFile;
  bool showImageOptions = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  AuthResult user;
  DatabaseReference _dbref;
  bool loading = false;
  String loadingText = "";
  FirebaseApp app;
  List<AAWSA> bills = [];

  void initFirebaseApp() async {
    app = await FirebaseApp.configure(
      name: 'db',
      options: const FirebaseOptions(
        googleAppID: '1:1090189103942:android:96ecfef8037894f6e48b47',
        apiKey: 'AIzaSyCP2zZ66nVcVErdBv4a-d_RYxY5HoQ-blU',
        databaseURL: 'https://easyreceipt-ae09b-default-rtdb.firebaseio.com/',
      ),
    );
    _dbref = FirebaseDatabase(app: app).reference();
  }

  void readyThePrevious() {
    setState(() {
      bills = [];
    });
    List<AAWSA> temps = [];
    if (user != null) {
      setState(() {
        loading = true;
        loadingText = "Loading";
      });
      _dbref.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        if (values != null) {
          if (values.length > 0) {
            values.forEach((key, values) {
              if (values['user'] == user.user.uid) {
                temps.add(AAWSA.fromDB(
                  user: values['user'] ?? '-',
                  url: values['url'] ?? '-',
                  title: values['title'] ?? '-',
                  bankBranch: values['bank_branch'] ?? '-',
                  paymentDate: values['payment_date'] ?? '-',
                  transRef: values['tran_ref'] ?? '-',
                  accountNo: values['account_no'] ?? 0,
                  customerKey: values['customer_key'] ?? '-',
                  accountName: values['account_name'] ?? '-',
                  billMonth: values['bill_month'] ?? '-',
                  currentRead: values['current_read'] ?? 0,
                  previousRead: values['previous_read'] ?? 0,
                  consumption: values['consumption'] ?? 0,
                  amount: values['amount'] ?? 0,
                  billerBranch: values['biller_branch'] ?? '-',
                ));
              }
            });
            temps = temps.reversed.toList();
            setState(() {
              bills = temps;
            });
            temps = [];
          }
        }
        setState(() {
          loading = false;
          loadingText = "";
        });
      }).catchError((e) {
        print("Error: " + e.toString());
        setState(() {
          loading = false;
          loadingText = "";
        });
        Fluttertoast.showToast(
            msg: "Couldn't Load Data",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initFirebaseApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: dbackground2,
        appBar: AppBar(
          backgroundColor: dbackground3,
          actions: [
            user != null
                ? IconButton(
                    icon: Icon(
                      Icons.account_circle,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      signOut();
                    })
                : SizedBox(
                    height: 0,
                  )
          ],
          title: Text(
            "Easy Receipt",
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 5.0),
                child: _setImageView()),
          ),
        ),
        floatingActionButton: user != null && _imageFile == null && !loading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  showImageOptions
                      ? Padding(
                          padding: const EdgeInsets.only(
                              left: 5.0, right: 5.0, bottom: 5.0),
                          child: FloatingActionButton(
                            backgroundColor: primary,
                            mini: true,
                            onPressed: () {
                              setState(() {
                                showImageOptions = false;
                              });
                              _openCamera(context);
                            },
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                            ),
                          ),
                        )
                      : SizedBox(height: 0),
                  showImageOptions
                      ? Padding(
                          padding: const EdgeInsets.only(
                              left: 5.0, right: 5.0, bottom: 10.0),
                          child: FloatingActionButton(
                            backgroundColor: primary,
                            mini: true,
                            onPressed: () {
                              setState(() {
                                showImageOptions = false;
                              });
                              _openGallery(context);
                            },
                            child: Icon(
                              Icons.photo,
                              size: 18,
                            ),
                          ),
                        )
                      : SizedBox(height: 0),
                  FloatingActionButton(
                      backgroundColor: dark,
                      onPressed: () {
                        setState(() {
                          showImageOptions = !showImageOptions;
                        });
                      },
                      child: Icon(
                        !showImageOptions ? Icons.add : Icons.close,
                        size: 28,
                      )),
                ],
              )
            : SizedBox(
                height: 0,
              ));
  }

  void _openGallery(BuildContext context) async {
    var picture = await _picker.getImage(source: ImageSource.gallery);
    this.setState(() {
      _imageFile = File(picture.path);
    });
    // Navigator.of(context).pop();
  }

  void _openCamera(BuildContext context) async {
    var picture = await _picker.getImage(source: ImageSource.camera);
    this.setState(() {
      _imageFile = File(picture.path);
    });
    //Navigator.of(context).pop();
  }

  Widget _setImageView() {
    if (user == null) {
      return anonymousSection();
    } else if (_imageFile != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 5.0),
        child: !loading
            ? Column(
                children: [
                  Image.file(
                    _imageFile,
                    height: MediaQuery.of(context).size.height * 0.75,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RaisedButton(
                            color: accent,
                            onPressed: () {
                              setState(() {
                                _imageFile = null;
                              });
                            },
                            child: Text("Cancel")),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: RaisedButton(
                            color: primary,
                            onPressed: () async {
                              uploadImage();
                            },
                            child: Text("Upload")),
                      ),
                    ],
                  ),
                ],
              )
            : Container(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.35,
                ),
                child: _loadingSection()),
      );
    } else if (bills.length > 0 && !loading) {
      return Column(children: [
        Container(
          height: 200,
          child: SimpleLineChart.withSampleData(bills),
        ),
        Container(
            height: 300,
            child: ListView.builder(
                itemCount: bills.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Container(
                      child: InkWell(
                        onTap: () {
                          ReceiptPreviewScreen.selectedBill = bills[index];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BillDetail()),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(bills[index].billMonth,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17)),
                            ),
                            Text(bills[index].amount.toString() + " ETB",
                                style: TextStyle(
                                  color: light,
                                ))
                          ],
                        ),
                      ),
                      margin: EdgeInsets.only(top: 13, left: 10, right: 10),
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: dbackground3,
                              offset: const Offset(1.0, 1.0),
                              blurRadius: 5.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                          color: dbackground2,
                          borderRadius: BorderRadius.circular(10)));
                }))
      ]);
    } else if (loading) {
      return Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 5.0),
        child: Container(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.35,
            ),
            child: _loadingSection()),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _logoSection(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
          ),
          Text(
            "By Dagmawi Negussu",
            style: TextStyle(
              color: primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
  }

  void uploadImage() async {
    try {
      setState(() {
        loading = true;
        loadingText = "Uploading Receipt";
      });
      String extsn = _imageFile.path.split('/').last.split('.').last;
      String name = user.user.displayName +
          '_' +
          DateTime.now()
              .toString()
              .replaceAll('-', '_')
              .replaceAll(' ', '_')
              .replaceAll(':', '_')
              .replaceAll('.', '_') +
          '.' +
          extsn;
      final StorageReference storageRef =
          FirebaseStorage.instance.ref().child(name);
      final StorageUploadTask uploadTask = storageRef.putFile(
        File(_imageFile.path),
        StorageMetadata(
          contentType: "image" + '/' + extsn,
        ),
      );
      final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
      final String url = await downloadUrl.ref.getDownloadURL();
      print('URL Is $url');
      setState(() {
        _imageFile = null;
        loading = true;
        loadingText = "Analyzing Receipt";
      });
      analyzeAndSave(url);
    } catch (e) {
      print("ERROR: $e");
      setState(() {
        loadingText = "";
        loading = false;
      });
    }
    setState(() {
      _imageFile = null;
    });
  }

  void signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      //Create Google Auth credentials to pass to Firebase
      final AuthCredential googleAuthCredential =
          GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      //Authenticate against Firebase with Google credentials

      await firebaseAuth
          .signInWithCredential(googleAuthCredential)
          .then((userCredential) => {
                setState(() => {user = userCredential})
              });
      readyThePrevious();
    } catch (e) {
      print("sign in error");
    }
  }

  void analyzeAndSave(String url) async {
    try {
      AAWSA bill = await FormRecognizer.analyze(url: url);
      print("Bill ${bill.billMonth} processed Successfully");
      bill.user = this.user.user.uid;
      bill.url = url;
      Map<String, dynamic> jsonbill = bill.toMap();
      setState(() {
        loading = true;
        loadingText = "Saving the Data";
      });
      _dbref.push().set(jsonbill).then((value) {
        readyThePrevious();
      }).catchError((e) {
        Fluttertoast.showToast(
            msg: e,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0);
        setState(() {
          loadingText = "";
          loading = false;
        });
      });
    } catch (e) {
      print("ERROR PROCESSING $e");
      setState(() {
        loadingText = "";
        loading = false;
      });
    }
  }

  Widget _loadingSection() {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primary),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            loadingText,
            style: TextStyle(
              color: primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _logoSection() {
    return Container(
        margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        alignment: Alignment.topCenter,
        child: Image.asset(
          "assets/playstore.png",
          width: 100.0,
        ));
  }

  void signOut() async {
    await firebaseAuth
        .signOut()
        .then((value) => {
              GoogleSignIn()
                  .signOut()
                  .then((value) => {
                        setState(() {
                          user = null;
                        })
                      })
                  .catchError((e) => {
                        setState(() {
                          user = null;
                        })
                      })
            })
        .catchError((e) => {
              setState(() {
                user = null;
              })
            });
    setState(() {
      user = null;
    });
  }

  Widget anonymousSection() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _logoSection(),
        SizedBox(
          height: 20,
        ),
        SignInButton(
          Buttons.Google,
          onPressed: () async {
            signInWithGoogle();
          },
        ),
        SignInButton(
          Buttons.Pinterest,
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PhoneAuth()),
            ).then((value) {
              if (value != null) {
                setState(() {
                  user = value;
                });
              }
            });
          },
          text: "Sign in with Phone",
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
        ),
        Text(
          "By Dagmawi Negussu",
          style: TextStyle(
            color: primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class SimpleLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleLineChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(seriesList, animate: animate);
  }

  factory SimpleLineChart.withSampleData(List<AAWSA> bils) {
    return new SimpleLineChart(
      _createSampleData(bils),
      // Disable animations for image tests.
      animate: false,
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, int>> _createSampleData(
      List<AAWSA> bils) {
    List<LinearSales> data = [];
    for (AAWSA onebill in bils) {
      data.add(
          LinearSales(index: bils.indexOf(onebill), amount: onebill.amount));
    }
    return [
      new charts.Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.pink.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.index,
        measureFn: (LinearSales sales, _) => sales.amount,
        data: data,
        seriesColor: charts.ColorUtil.fromDartColor(Colors.yellow),
      )
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  final int index;
  final double amount;

  LinearSales({this.index, this.amount});
}
