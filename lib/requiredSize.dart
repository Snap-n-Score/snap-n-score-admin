import 'package:flutter/material.dart';

class SizeReqScreen extends StatefulWidget {
  const SizeReqScreen({super.key});

  @override
  State<SizeReqScreen> createState() => _SizeReqScreenState();
}

class _SizeReqScreenState extends State<SizeReqScreen> {
  var screenSize = const Size(0, 0);
  @override
  Widget build(BuildContext context) {
    setState(() {
      screenSize = MediaQuery.of(context).size;
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Color.fromARGB(96, 183, 28, 28),
                  Colors.black
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "This Website Works best on large displays",
                  style: TextStyle(
                      color: Colors.red.shade100,
                      fontSize: screenSize.width * 0.04),
                ),
                Text(
                  "Tip: use in full screen mode",
                  style: TextStyle(
                      color: Colors.red.shade100,
                      fontSize: screenSize.width * 0.02),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
