import 'package:flutter/material.dart';
import 'package:front/app/modules/home/components/setting_board_component/parameter_settings_board.dart';
import 'package:front/app/modules/home/components/setting_board_component/time_settings_board.dart';
import 'package:front/app/modules/home/components/sub_header.dart';
import 'package:front/app/modules/home/config/responsive.dart';
import 'package:front/app/modules/home/config/size_config.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import '../controllers/home_controller.dart';

class SettingsBoard extends GetView<HomeController> {
  const SettingsBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Responsive.isDesktop(context)
            ? SizedBox(height: SizeConfig.blockSizeVertical * 6)
            : const SizedBox(height: 10),
        const SubHeader(title: "설정"),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 2,
        ),
        ParameterSettingsBoard(),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 6,
        ),
        const TimeSettingsBoard(),
      ],
    );
  }
}
