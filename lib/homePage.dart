import 'dart:math';
import 'dart:ui';

import 'package:custom_qr_generator/custom_qr_generator.dart';
import 'package:flutter/material.dart';
import 'package:snap_n_score_admin/loginPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  String _randomNumbers = '';
  String? storedRandomNumber; //to store the random number generated

  void _generateRandomNumbers() async {
    final sm = ScaffoldMessenger.of(context);
    final faculty_id = supabase.auth.currentUser?.userMetadata?['faculty_id'];
    print("Id ${faculty_id[0]['faculty_id']}");
    final _random = Random();
    _randomNumbers =
        (_random.nextInt(900000) + 1000000).toString(); // 7-digit string
    storedRandomNumber = _randomNumbers; // store the generated random number

    // checking if teacher has already generated the qr or not
    final exists = await supabase
        .from('keys_table')
        .select('active')
        .eq('faculty_id', faculty_id[0]['faculty_id']);

    if (exists.isEmpty || exists[0]['active'] == 0) {
      await supabase.from('keys_table').insert({
        'key_value': storedRandomNumber,
        'public_enkey': 123,
        'private_enkey': 251,
        'faculty_id': faculty_id[0]['faculty_id'],
        'active': 1
      });
      sm.showSnackBar(const SnackBar(content: Text("Qr Generated")));
      print("qr generated");

      Future.delayed(const Duration(seconds: 15), () async {
        await Supabase.instance.client.from('keys_table').update(
            {'active': 0}).eq('key_value', storedRandomNumber.toString());
        print("Updated");
      });
    } else {
      sm.showSnackBar(SnackBar(
        content: const Text("Qr Already generated"),
        backgroundColor: Colors.redAccent[100],
      ));
      //  not optimatal => rather try to disable button or freeze state for 15 seconds
      Future.delayed(const Duration(seconds: 15), () async {
        await Supabase.instance.client.from('keys_table').update(
            {'active': 0}).eq('key_value', storedRandomNumber.toString());
        print("Updated");
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Snap n' Score"),
        centerTitle: false,
        actions: [
          Text(
              'Welcome back, ${supabase.auth.currentUser!.userMetadata!['name']}'),
          Padding(
            padding: const EdgeInsets.all(10),
            child: FilledButton(
              onPressed: () async {
                await supabase.auth.signOut().then((value) {
                  return Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const loginPage(),
                      ));
                });
              },
              child: const Text("Logout"),
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.red[100])),
            ),
          )
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: screenSize.width * 0.3,
                    height: screenSize.height * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomPaint(
                          painter: QrPainter(
                            data: _randomNumbers,
                            options: const QrOptions(
                              shapes: QrShapes(
                                darkPixel: QrPixelShapeRoundCorners(
                                    cornerFraction: 0.05),
                                frame: QrFrameShapeCircle(),
                                ball: QrBallShapeCircle(),
                              ),
                              colors: QrColors(
                                dark: QrColorSolid(Colors.black),
                                light: QrColorSolid(Colors.black),
                              ),
                            ),
                          ),
                          size: const Size(300, 300),
                        ),
                        SizedBox(height: screenSize.height * 0.07),
                        FilledButton(
                          onPressed: _generateRandomNumbers,
                          child: const Text("Generate"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
