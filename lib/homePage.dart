// ignore_for_file: file_names

import 'dart:async';

import 'package:custom_qr_generator/custom_qr_generator.dart';
import 'package:flutter/material.dart';
import 'package:snap_n_score_admin/loginPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import 'dart:ui';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  String _randomNumbers = '';
  String? storedRandomNumber;
  Timer? _timer; // Add this timer variable
  bool isGenerating = false; // Add this flag to track generation state

  @override
  void dispose() {
    _timer?.cancel(); // Clean up timer when widget is disposed
    super.dispose();
  }

  void _generateRandomNumbers() async {
    final sm = ScaffoldMessenger.of(context);
    final faculty_id = supabase.auth.currentUser?.userMetadata?['faculty_id'];

    if (faculty_id == null || faculty_id.isEmpty) {
      sm.showSnackBar(const SnackBar(
        content: Text("Faculty ID not found"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Toggle generation state
    setState(() {
      isGenerating = !isGenerating;
    });

    if (isGenerating) {
      // Start generating QR codes
      _startQRGeneration(faculty_id[0]['faculty_id'].toString(), sm);
    } else {
      // Stop generating QR codes
      _stopQRGeneration();
    }
  }

  void _startQRGeneration(String facultyId, ScaffoldMessengerState sm) async {
    // Initial generation
    await _generateNewQR(facultyId, sm);

    // Set up periodic generation
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _generateNewQR(facultyId, sm);
    });
  }

  void _stopQRGeneration() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _generateNewQR(
      String facultyId, ScaffoldMessengerState sm) async {
    // Deactivate previous QR if exists
    if (storedRandomNumber != null) {
      await supabase
          .from('keys_table')
          .update({'active': 0}).eq('key_value', storedRandomNumber.toString());
    }

    // Generate new random number
    randomNumber();

    // Insert new QR
    final response =await supabase.from('keys_table').insert({
      'key_value': storedRandomNumber.toString(),
      'public_enkey': 123,
      'private_enkey': 251,
      'faculty_id': facultyId,
      'active': 1
    }).select('key_id');
    

    sm.showSnackBar(const SnackBar(content: Text("New QR Generated")));
    print("New QR generated: $storedRandomNumber");

    setState(() {});
  }

  void randomNumber() {
    final _random = Random();
    _randomNumbers = (_random.nextInt(900000) + 1000000).toString();
    storedRandomNumber = _randomNumbers;
  }

  var screenSize = Size(0, 0);
  @override
  Widget build(BuildContext context) {
    setState(() {
      screenSize = MediaQuery.of(context).size;
    });
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(1, 84, 98, 1),
              Color.fromRGBO(2, 80, 92, 1),
              Color.fromRGBO(6, 16, 15, 1)
            ],
          ),
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
                    height: screenSize.height * 0.65,
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
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              isGenerating ? Colors.red[100] : null,
                            ),
                          ),
                          child: Text(isGenerating
                              ? "Stop Generation"
                              : "Start Generation"),
                        )
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
