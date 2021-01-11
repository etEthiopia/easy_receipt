import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'theme/colors.dart';

class PhoneAuth extends StatefulWidget {
  @override
  _PhoneAuthState createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  String smsCode;
  bool code;
  final TextEditingController _codeController = TextEditingController();

  Future registerUser(String mobile, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) {
          _auth.signInWithCredential(authCredential).then((AuthResult result) {
            Navigator.pop(context, result);
            Navigator.pop(context, result);
          }).catchError((e) {
            print("V_ERROR " + e);
          });
        },
        verificationFailed: (AuthException authException) {
          print("F_ERROR " + authException.message);
        },
        codeSent: (String verificationId, [int forceResendingToken]) async {
          //show dialog to take input from the user
          await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                    title: Text("Enter SMS Code"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: _codeController,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Done"),
                        textColor: Colors.white,
                        color: Colors.redAccent,
                        onPressed: () {
                          FirebaseAuth auth = FirebaseAuth.instance;

                          smsCode = _codeController.text.trim();
                          print("SIGNED IN: " + smsCode + ":" + verificationId);

                          AuthCredential credential =
                              PhoneAuthProvider.getCredential(
                                  verificationId: verificationId,
                                  smsCode: smsCode);
                          auth
                              .signInWithCredential(credential)
                              .then((AuthResult result) {
                            print("SIGNED IN: " + result.toString());
                            Navigator.pop(context);
                            Navigator.pop(context, result);
                          }).catchError((e) {
                            print("S_ERROR " + e);
                          });
                        },
                      )
                    ],
                  ));
        },
        codeAutoRetrievalTimeout: null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dbackground2,
      appBar: AppBar(
        title: Text("Easy Receipt"),
        backgroundColor: dbackground3,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(
              top: 50.0,
              left: 50.0,
              right: 50.0,
            ),
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    style: TextStyle(color: primary),
                    decoration: InputDecoration(
                        hintText: "Type your Phone",
                        hintStyle: TextStyle(color: light),
                        icon: Icon(
                          Icons.phone,
                          color: primary,
                        ),
                        isDense: true),
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // code
                  //     ? TextField(
                  //         style: TextStyle(color: primary),
                  //         decoration: InputDecoration(
                  //             hintText: "Type the Code",
                  //             hintStyle: TextStyle(color: light),
                  //             icon: Icon(
                  //               Icons.confirmation_number,
                  //               color: primary,
                  //             ),
                  //             isDense: true),
                  //         keyboardType: TextInputType.number,
                  //         controller: _codeController,
                  //       )
                  //     : SizedBox(
                  //         height: 0,
                  //       ),
                  SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      elevation: 1,
                      shadowColor: light,
                      color: light,
                      child: FlatButton(
                        onPressed: () async {
                          await registerUser(_phoneController.text, context);
                        },
                        child: Text(
                          "VERIFY",
                          style: TextStyle(
                            color: dbackground1,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
      )),
    );
  }
}
