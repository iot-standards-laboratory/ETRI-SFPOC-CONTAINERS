import 'package:flutter/material.dart';
import 'package:front/app/modules/home/components/current_time_text.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/responsive.dart';
import '../controllers/home_controller.dart';

class SubHeader extends GetView<HomeController> {
  final String title;
  const SubHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context)
        ? Column(
            children: [
              Text(
                title,
                style: GoogleFonts.bebasNeue(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const CurrentTimeText(),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.bebasNeue(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const CurrentTimeText(),
            ],
          );
  }
}
