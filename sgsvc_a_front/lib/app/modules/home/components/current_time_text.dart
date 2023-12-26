import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/home_controller.dart';

class CurrentTimeText extends StatelessWidget {
  const CurrentTimeText({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(builder: (controller) {
      return Text(
        DateFormat('yyyy-MM-d   h:mm a')
            .format(controller.currentTime.value)
            .toString(),
        style: GoogleFonts.bebasNeue(
          fontSize: 16,
        ),
      );
    });
  }
}
