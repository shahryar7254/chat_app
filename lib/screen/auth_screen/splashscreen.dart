import 'package:flutter/material.dart';
import 'package:chat_app/helper/dilog.dart';
import 'package:chat_app/screen/auth_screen/log_in.dart';
import 'package:chat_app/screen/homescreen.dart';
import '../../main.dart';

class splash_screen extends StatefulWidget {
  const splash_screen({Key? key}) : super(key: key);

  @override
  State<splash_screen> createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      if (apis.auth.currentUser != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => homescreen()));
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => loginscreen()),
        );
      }
      // Remove the following line, as it causes the issue
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => loginscreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size; // Initialize mq in build method

    return Scaffold(
      body: Stack(
        children: [
          AnimatedPositioned(
             top: mq.height * 0.30,
             right: mq.width * 0.2,
             width: mq.width * 0.5,
           // left: mq.width * 0.4,
            duration: const Duration(seconds: 1),
            child: Image.asset('assets/chat.png',//height: mq.height* 5, width: mq.width*1,
            ),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            width: mq.width * 0.8,
           left: mq.width * 0.1,
            height: mq.height * 0.06,
             child: Text(
              'Welcome to Chat App 🖤',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87,fontSize: 20,//mq.width* .5,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
