import 'package:flutter/material.dart';
import 'package:snap_n_score_admin/homePage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginGlassmorphism extends StatefulWidget {
  const LoginGlassmorphism({super.key});

  @override
  State<LoginGlassmorphism> createState() => _GlassmorphismState();
}

class _GlassmorphismState extends State<LoginGlassmorphism> {
  final supabase = Supabase.instance.client;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(20),
      width: screenSize.width * 0.3,
      height: screenSize.height * 0.5,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Login", style: TextStyle(fontSize: 36)),
          SizedBox(
            height: screenSize.height * 0.01,
          ),
          const Text(
            "Enter your details here !!",
            style: TextStyle(fontSize: 21),
          ),
          SizedBox(
            height: screenSize.height * 0.05,
          ),
          Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      label: const Text('Email'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.05),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: false,
                    decoration: InputDecoration(
                      label: const Text('Password'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.05),
                ],
              ),
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
                fixedSize: MaterialStatePropertyAll(
                    Size(screenSize.width * 0.2, screenSize.height * 0.05))),
                                    onPressed: () async {
                                      final sm = ScaffoldMessenger.of(context);
                                      await supabase.auth
                                          .signInWithPassword(
                                              password:
                                                  _passwordController.text,
                                              email: _emailController.text)
                                          .then((value) {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    HomePage())));
                                      }).onError((error, stackTrace) {
                                        sm.showSnackBar(
                                            SnackBar(content: Text("$error")));
                                      });
                                    },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children:  [
                Text("Login "),
                Icon(Icons.arrow_right_alt_sharp),
              ],
            ),
          )
        ],
      ),
    );
  }
}
