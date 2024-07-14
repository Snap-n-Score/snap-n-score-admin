import 'package:flutter/material.dart';
import 'package:snap_n_score_admin/HomePage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupGlassmorphism extends StatefulWidget {
  const SignupGlassmorphism({super.key});

  @override
  State<SignupGlassmorphism> createState() => _SignupGlassmorphismState();
}

class _SignupGlassmorphismState extends State<SignupGlassmorphism> {
  final supabase = Supabase.instance.client;
  final _formkey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _courseNameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _courseNameController.addListener(() {
      final text = _courseNameController.text.toUpperCase();
      _courseNameController.value = _courseNameController.value.copyWith(
        text: text.replaceAll(' ', ''),
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(20),
      width: screenSize.width * 0.3,
      height: screenSize.height * 0.65,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Signup", style: TextStyle(fontSize: 36)),
          SizedBox(
            height: screenSize.height * 0.01,
          ),
          const Text(
            "Enter your details here !!",
            style: TextStyle(fontSize: 21),
          ),
          SizedBox(
            height: screenSize.height * 0.04,
          ),
          Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      label: const Text('Name'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  TextFormField(
                    controller: _emailController,
                    obscureText: false,
                    decoration: InputDecoration(
                      label: const Text('Email'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      label: const Text('Password'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  TextFormField(
                    controller: _courseNameController,
                    decoration: InputDecoration(
                      label: const Text('Course Name (eg: CSET101)'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
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

                                // retrieving course Id from courses2
                                final courseId = await supabase
                                    .from('courses2')
                                    .select('course_id')
                                    .eq('course_name',
                                        _courseNameController.text);

                                print("CourseID: ${courseId[0]['course_id']}");

                                final Id = courseId[0]['course_id'];

                                // filling the faculty table
                                await supabase.from('faculty').insert({
                                  'name': _nameController.text,
                                  'course_id': Id
                                });

                                //storing faculty id 
                                final faculty_id=await supabase.from('faculty').select('faculty_id').eq('name',_nameController.text );

                                await supabase.auth.signUp(
                                    password: _passwordController.text,
                                    email: _emailController.text,
                                    data:  {
                                      'name': _nameController.text,
                                      'courseName': _courseNameController.text,
                                      'faculty_id':faculty_id
                                    }).then((value) {
                                  sm.showSnackBar(SnackBar(
                                      content: Text(
                                          "Signed up ${value.user!.email!}")));
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HomePage(),
                                      ));
                                }).onError((error, stackTrace) {
                                  sm.showSnackBar(SnackBar(
                                      content: Text("Signed up $error")));
                                });
                              },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("signup "),
                Icon(Icons.arrow_right_alt_sharp),
              ],
            ),
          )
        ],
      ),
    );
  }
}
