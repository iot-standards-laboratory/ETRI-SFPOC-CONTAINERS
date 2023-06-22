import 'package:flutter/material.dart';
import 'package:front/app/modules/home/components/monitoring_board_components/crop_control_board.dart';
import 'package:front/app/modules/home/components/monitoring_board_components/crop_growth_board.dart';
import 'package:front/app/modules/home/components/sub_header.dart';
import 'package:front/app/modules/home/config/responsive.dart';
import 'package:get/get.dart';

import '../components/monitoring_board_components/crop_monitoring_board.dart';
import '../config/size_config.dart';
import '../controllers/home_controller.dart';

class MonitoringBoard extends GetView<HomeController> {
  const MonitoringBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Responsive.isDesktop(context)
            ? SizedBox(height: SizeConfig.blockSizeVertical * 6)
            : const SizedBox(height: 10),
        const SubHeader(title: "대시보드"),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 2,
        ),
        const CropMonitoringBoard(),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 6,
        ),
        const CropControlBoard(),
      ],
      // child: controller.currentTimeText,
    );
  }
}
