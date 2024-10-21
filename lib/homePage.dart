// ignore_for_file: file_names

import 'package:custom_qr_generator/custom_qr_generator.dart';
import 'package:flutter/material.dart';
import 'package:snap_n_score_admin/lecture_hall.dart';
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
  final List<LectureHall> lectureHalls = [
    LectureHall(name: '102NLH', latitude: 40.712776, longitude: -74.005974),
    LectureHall(name: '002ALH', latitude: 34.052235, longitude: -118.243683),
    LectureHall(name: '101PLH', latitude: 37.774929, longitude: -122.419418),
  ];
  final supabase = Supabase.instance.client;
  bool _firstTime = true;
  String? selectedLectureHall;
  String _randomNumbers = '';
  String? storedRandomNumber; //to store the random number generated

  void _generateRandomNumbers() async {
    if (_firstTime) {
      _firstTime = false;
    }
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
                  backgroundColor: WidgetStatePropertyAll(Colors.red[100])),
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
                        _firstTime
                            // entering locations in which lecture will be held
                            ? Column(
                                children: [
                                  const Text(
                                      "Select the location of the lecture hall"),
                                  DropdownButton<String>(
                                    value: selectedLectureHall,
                                    hint: const Text("Select a location"),
                                    items: lectureHalls
                                        .map((e) => DropdownMenuItem(
                                              child: Text(e.name),
                                              value: e.name,
                                            ))
                                        .toList(),
                                    onChanged: (String? value) {
                                      setState(() {
                                        selectedLectureHall = value;
                                      });
                                    },
                                  ),
                                ],
                              )
                            : CustomPaint(
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
                        Text("Location: $selectedLectureHall"),
                        SizedBox(height: screenSize.height * 0.02),
                        FilledButton(
                          onPressed: _generateRandomNumbers,
                          child: _firstTime
                              ? Text("Generate")
                              : Text("Regenerate"),
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
