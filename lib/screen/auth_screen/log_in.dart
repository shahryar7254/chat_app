//import 'dart:io';
//import 'dart:js';
import 'dart:io';
import 'dart:math';
import 'package:chat_app/helper/dilog.dart';
import 'package:chat_app/modles/chatuser.dart';
import 'package:chat_app/screen/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../main.dart';
class loginscreen extends StatefulWidget {
  const loginscreen({super.key});

  @override
  State<loginscreen> createState() => _loginscreenState();
}

googlebutton(BuildContext context){
  dilog.showProgres(context);
  signInWithGoogle().then((user) async {
    Navigator.pop(context);
    if(user!= null) {
      print('\nUser: ${user.user}');
      print('\nUserAdditionInfo: ${user.additionalUserInfo}');
      if( await apis.userExists()) {
    Navigator.pushReplacement(context,
    MaterialPageRoute(builder: (context) => homescreen()));
      }else{
        apis.createuser().then((value) => {
    Navigator.pushReplacement(context,
    MaterialPageRoute(builder: (context) => homescreen()))
    });
    }


    }
  });
}
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth = await googleUser
          ?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('signInWithGoogle: $e');
   // dilog.showSnackbar(context as BuildContext,'no internet');
      return null;
    }
  }


class _loginscreenState extends State<loginscreen> {
  @override
  Widget build(BuildContext context) {
    mq =MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          title: Text('Well come to Chat App',)
      ),
body: Stack(children: [
  Positioned(
    top: mq.height* .10,
    width: mq.width*.2,
     left: mq.width*.4,
     child: Image.asset('assets/chat.png' )),
  Positioned(
     bottom: mq.height* .15,
      width: mq.width*0.8,
      left: mq.width*.1,
      height: mq.height*.06,
     // child: Image.asset('assets/google.png' )
     child: ElevatedButton.icon(
       style: ElevatedButton.styleFrom(
         shape: StadiumBorder(), elevation: 1
       ),
        onPressed: (){
          googlebutton(context);
        },
        icon: Image.asset('assets/google.png',
          height: mq.height *9,
        ),
      label: Text('Sign-In with Google',
        style:TextStyle(fontSize: 20) ,)
      ),
  )
],
    ),);
  }
}
