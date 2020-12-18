import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  @override
  _ReceiptPreviewScreen createState() => _ReceiptPreviewScreen();
}

class _ReceiptPreviewScreen extends State<ReceiptPreviewScreen> {
  final ImagePicker _picker = ImagePicker();
  File _imageFile;
  bool showImageOptions = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  AuthResult user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[_setImageView()],
              ),
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            showImageOptions
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: 5.0, right: 5.0, bottom: 5.0),
                    child: FloatingActionButton(
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
    if (_imageFile != null) {
      return Image.file(_imageFile, width: 500, height: 500);
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

  void signOut() async {
    await firebaseAuth.signOut().then((value) => {
          setState(() {
            user = null;
          })
        });
  }
}
