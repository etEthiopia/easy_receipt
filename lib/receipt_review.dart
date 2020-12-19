import 'dart:io';
import 'package:easy_receipt/api/form_recognizer.dart';
import 'package:easy_receipt/models/aawsa.dart';
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

class ReceiptPreviewScreen extends StatefulWidget {
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
  FirebaseApp app;

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
        floatingActionButton: user != null && _imageFile == null
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
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                ),
              ),
      );
    } else {
      return Column(
        children: [
          Text("Please select an image"),
          user == null
              ? FlatButton(
                  onPressed: () async {
                    signInWithGoogle();
                  },
                  child: Text("Sign In With Google"))
              : FlatButton(
                  onPressed: () async {
                    signOut();
                  },
                  child: Text("Sign Out")),
          Text((user != null) ? user.user.displayName : "Not logged in"),
        ],
      );
    }
  }

  void uploadImage() async {
    try {
      setState(() {
        loading = true;
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
      // final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
      // final String url = (await downloadUrl.ref.getDownloadURL());
      String url =
          "https://firebasestorage.googleapis.com/v0/b/easyreceipt-ae09b.appspot.com/o/20201213_072511.jpg?alt=media&token=72916cd6-9be8-4aae-b435-fef0187fe628";
      print('URL Is $url');
      analyzeAndSave(url);
      setState(() {
        loading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() {
        loading = false;
      });
    }
  }

  void signInWithGoogle() async {
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
  }

  void analyzeAndSave(String url) async {
    try {
      AAWSA bill = await FormRecognizer.analyze(url: url);
      print("Bill ${bill.billMonth} processed Successfully");
      Fluttertoast.showToast(
          msg: "Bill ${bill.billMonth} processed Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20.0);

      Map<String, dynamic> jsonbill = bill.toMap();
      try {
        _dbref.push().set(jsonbill);
        Fluttertoast.showToast(
            msg: "Bill ${bill.billMonth} saved Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: dark,
            textColor: Colors.white,
            fontSize: 20.0);
      } catch (e) {
        Fluttertoast.showToast(
            msg: e,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      print("ERROR PROCESSING $e");
    }
  }

  void signOut() async {
    await firebaseAuth.signOut().then((value) => {
          setState(() {
            user = null;
          })
        });
  }

  Widget anonymousSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Column(
        children: [
          Text(
            "Choose Easy Receipt, \n Choose Easy Life",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 10,
          ),
          SignInButton(
            Buttons.Google,
            onPressed: () async {
              signInWithGoogle();
            },
          )
        ],
      ),
    );
  }
}
