import 'package:flutter/material.dart';
import 'package:snap_n_score_admin/loginPage.dart';
import 'package:snap_n_score_admin/requiredSize.dart';

class ScreenChoice extends StatelessWidget {
  const ScreenChoice({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if(constraints.maxHeight>670 && constraints.maxWidth>1120){
        return const loginPage();
      }
      else{
        return const SizeReqScreen();
      }
    });
  }
}
