import 'package:flutter/material.dart';
import 'package:front/app/modules/home/components/historical_monitoring_board_component/bar_chart_component.dart';
import 'package:front/app/modules/home/components/monitoring_board_components/crop_monitoring_board.dart';
import 'package:front/app/modules/home/components/sub_header.dart';
import 'package:front/app/modules/home/config/responsive.dart';
import 'package:front/app/modules/home/config/size_config.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/home_controller.dart';

class HistoricalMonitoringBoard extends GetView<HomeController> {
  const HistoricalMonitoringBoard({super.key});

  Widget _renderDatePicker() {
    return Row(
      children: [
        GetBuilder<HomeController>(builder: (ctrl) {
          return Text(
            DateFormat('yyyy-MM-d').format(ctrl.date),
            style: GoogleFonts.almendraSc(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          );
        }),
        const SizedBox(
          width: 15,
        ),
        IconButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
                context: Get.context!,
                initialDate: controller.date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now());
            if (pickedDate != null) {
              controller.updateDate(pickedDate);
            }
          },
          icon: const Icon(Icons.calendar_month),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Responsive.isDesktop(context)
            ? SizedBox(height: SizeConfig.blockSizeVertical * 6)
            : const SizedBox(height: 10),
        const SubHeader(title: "모니터링"),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 2,
        ),
        const CropMonitoringBoard(),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 6,
        ),
        _renderDatePicker(),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 3,
        ),
        Text(
          "온도",
          style: GoogleFonts.almendraSc(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: GetBuilder<HomeController>(
              id: NotifyEvent.history,
              builder: (controller) {
                return BarChartCopmponent(
                  maxY: 50,
                  value: controller.temperatureHistory,
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 3,
        ),
        Text(
          "습도",
          style: GoogleFonts.almendraSc(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: GetBuilder<HomeController>(
              id: NotifyEvent.history,
              builder: (controller) {
                return BarChartCopmponent(
                  maxY: 100,
                  value: controller.humidityHistory,
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 3,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "CO",
              style: GoogleFonts.sofia(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              "2",
              style: GoogleFonts.sofia(
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: GetBuilder<HomeController>(
              id: NotifyEvent.history,
              builder: (controller) {
                return BarChartCopmponent(
                  maxY: 100,
                  value: controller.co2History,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
