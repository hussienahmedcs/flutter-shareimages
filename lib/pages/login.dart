import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharewallpaper/util/data-repository.dart';
import 'package:sharewallpaper/util/helper.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? phoneNumber;
  final DataRepository repository = DataRepository();
  final Helper helper = Helper();
  PhoneAuthCredential? _credential;
  String? _verificationId;
  int? _resendToken;
  bool isResendActive = false;

  _verificationFailed(FirebaseAuthException e) {
    helper.hideLoader();
    if (e.code == 'invalid-phone-number') {
      helper.showToast('The provided phone number is not valid.');
    } else {
      helper.showToast(e.message);
    }
  }

  _verificationCompleted(PhoneAuthCredential credential) {
    print("verificationCompleted");
    _credential = _credential;
    helper.hideLoader();
  }

  _codeSent(String verificationId, int? resendToken) {
    helper.hideLoader();
    _verificationId = verificationId;
    _resendToken = resendToken;
    openOtpDialog();
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    helper.hideLoader();
    helper.showToast("codeAutoRetrievalTimeout");
    isResendActive = true;
  }

  openOtpDialog() {
    String? _code;
    _verify() {
      print("verify");
      helper.showLoader();
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: _code!);
      repository.auth.signInWithCredential(credential);
    }

    _resend() {
      verifyPhoneNumber();
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Mobile Phone Confirmation"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 2.4,
                      width: MediaQuery.of(context).size.height,
                      // alignment: widget.alignment,
                      child: ListView(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Please Enter Received SMS Code Here',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 30),
                            child: TextField(
                              onChanged: (value) => setState(() {
                                _code = value;
                              }),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          FlatButton(
                            onPressed: _resend,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                  text: "Didn't receive the code? ",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 15),
                                  children: [
                                    TextSpan(
                                        text: " RESEND",
                                        // recognizer: onTapRecognizer,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16))
                                  ]),
                            ),
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 30),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: FlatButton(
                              onPressed: _verify,
                              child: ButtonTheme(
                                height: 50,
                                child: Center(
                                    child: Text(
                                  "VERIFY".toUpperCase(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  verifyPhoneNumber() {
    isResendActive = false;
    helper.showLoader();
    repository.auth.verifyPhoneNumber(
        phoneNumber: phoneNumber!.trim(),
        verificationCompleted: _verificationCompleted,
        verificationFailed: _verificationFailed,
        codeSent: _codeSent,
        codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
        forceResendingToken: _resendToken);
  }

  sendOtp() {
    if (phoneNumber == null) return;
    verifyPhoneNumber();
  }

  Future<bool> loginOrSignUp() async {
    helper.showLoader();
    var completer = Completer<bool>();
    String did = await repository.getDeviceId();
    helper.postGeneric("/login", {"phone": phoneNumber!, "device": did}).then(
        (value) {
          helper.setUserId(value.body);
      completer.complete(true);
      helper.hideLoader();
    });
    return completer.future;
  }

  doLogin() {
    loginOrSignUp().then((value) {
      if (value) {
        Navigator.popAndPushNamed(context, "/");
      }
    });
  }

  login() async {
    // sendOtp();
    doLogin();
  }

  doCreate() {
    loginOrSignUp().then((value) {
      if (value) {
        helper.showToast("Account Created Successfully!");
        Navigator.popAndPushNamed(context, "/profile");
      }
    });
  }

  register() {
    if (phoneNumber == null) return;
    doCreate();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // openOtpDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/background.png'),
                        fit: BoxFit.fill)),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        left: 30,
                        width: 80,
                        height: 200,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/light-1.png'))),
                        )),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/light-2.png'))),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      width: 80,
                      height: 150,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/clock.png'))),
                      ),
                    ),
                    Positioned(
                      child: Container(
                        margin: EdgeInsets.only(top: 50),
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(143, 148, 251, .2),
                                blurRadius: 20.0,
                                offset: Offset(0, 10))
                          ]),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(8.0),
                            // decoration: BoxDecoration(
                            //     border: Border(
                            //         bottom:
                            //             BorderSide(color: Colors.grey[400]!))),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) => phoneNumber = value,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Phone number",
                                  hintStyle:
                                      TextStyle(color: Colors.grey[400])),
                            ),
                          ),
                          // Container(
                          //   padding: EdgeInsets.all(8.0),
                          //   child: TextField(
                          //     decoration: InputDecoration(
                          //         border: InputBorder.none,
                          //         hintText: "Password",
                          //         hintStyle:
                          //             TextStyle(color: Colors.grey[400])),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    FlatButton(
                      onPressed: login,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [
                              Color.fromRGBO(143, 148, 251, 1),
                              Color.fromRGBO(143, 148, 251, .6),
                            ])),
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 70,
                    ),
                    FlatButton(
                      onPressed: register(),
                      child: Text(
                        "Create Account",
                        style:
                            TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
