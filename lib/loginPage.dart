import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:snap_n_score_admin/login_glassmorphism.dart';
import 'package:snap_n_score_admin/signup_glassmorphism.dart';
import 'package:url_launcher/url_launcher.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  bool islogin = true;
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
            onTap: () => setState(() {
                  islogin = true;
                }),
                overlayColor: const MaterialStatePropertyAll(Colors.transparent),
            child: Text("Snap n' Score")),
        centerTitle: false,
        leadingWidth: 20,
        actions: [
          IconButton(
            onPressed: () async {
              const url = 'https://github.com/rakshitkapoor/Snap-n-Score';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              } else {
                throw 'could not launch $url';
              }
            },
            icon: const ImageIcon(
              AssetImage('github-mark-white.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: islogin
                ? FilledButton(
                    onPressed: () {
                      setState(() {
                        islogin = false;
                      });
                    },
                    child: Text("Signup"))
                : FilledButton(
                    onPressed: () {
                      setState(() {
                        islogin = true;
                      });
                    },
                    child: Text("Login"),
                  ),
          ),
        ],
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("bg_image2.jpg"), fit: BoxFit.cover),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.white.withOpacity(0.05),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    islogin ? LoginGlassmorphism() : SignupGlassmorphism()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
