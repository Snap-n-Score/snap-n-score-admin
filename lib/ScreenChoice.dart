import 'package:flutter/material.dart';
import 'package:snap_n_score_admin/loginPage.dart';
import 'package:snap_n_score_admin/requiredSize.dart';

class ScreenChoice extends StatelessWidget {
  const ScreenChoice({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      print("Max height : ${constraints.maxHeight}, Max width: ${constraints.maxWidth}");
      if(constraints.maxHeight>850 && constraints.maxWidth>1140){
        return loginPage();
      }
      else{
        return SizeReqScreen();
      }
    });
  }
}
