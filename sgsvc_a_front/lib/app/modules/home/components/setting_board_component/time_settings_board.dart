import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:front/app/modules/home/controllers/home_controller.dart';
import 'package:front/app/modules/home/components/style/colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/responsive.dart';
import '../../config/size_config.dart';

class TimeSettingsBoard extends GetView<HomeController> {
  const TimeSettingsBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            '동작 시간 설정',
            style: GoogleFonts.sofia(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 1,
        ),
        TimeSettingsComponent(
          label: "LED",
          idx: 0,
          onPressed: ((idx, value) {
            controller.clientOperatingTime[0][idx].value = value;
            controller.operatingTimeChanged[0].value =
                controller.compareOperatingTime(
              controller.clientOperatingTime[0],
              controller.serverOperatingTime[0],
            );
          }),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 1,
        ),
        TimeSettingsComponent(
          label: "관수 1단",
          idx: 1,
          onPressed: ((idx, value) {
            controller.clientOperatingTime[1][idx].value = value;
            controller.operatingTimeChanged[1].value =
                controller.compareOperatingTime(
              controller.clientOperatingTime[1],
              controller.serverOperatingTime[1],
            );
          }),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 1,
        ),
        TimeSettingsComponent(
          label: "관수 2단",
          idx: 2,
          onPressed: ((idx, value) {
            controller.operatingTimeChanged[2].value =
                controller.clientOperatingTime[2][idx].value = value;
            controller.compareOperatingTime(
              controller.clientOperatingTime[2],
              controller.serverOperatingTime[2],
            );
          }),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 1,
        ),
        TimeSettingsComponent(
          label: "관수 3단",
          idx: 3,
          onPressed: ((idx, value) {
            controller.clientOperatingTime[3][idx].value = value;
            controller.operatingTimeChanged[3].value =
                controller.compareOperatingTime(
              controller.clientOperatingTime[3],
              controller.serverOperatingTime[3],
            );
          }),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 1,
        ),
        TimeSettingsComponent(
          label: "관수 4단",
          idx: 4,
          onPressed: ((idx, value) {
            controller.clientOperatingTime[4][idx].value = value;
            controller.operatingTimeChanged[4].value =
                controller.compareOperatingTime(
              controller.clientOperatingTime[4],
              controller.serverOperatingTime[4],
            );
          }),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 1,
        ),
        TimeSettingsComponent(
          label: "관수 5단",
          idx: 5,
          onPressed: ((idx, value) {
            controller.clientOperatingTime[5][idx].value = value;
            controller.operatingTimeChanged[5].value =
                controller.compareOperatingTime(
              controller.clientOperatingTime[5],
              controller.serverOperatingTime[5],
            );
          }),
        ),
      ],
    );
  }
}

class TimeSettingsComponent extends GetView<HomeController> {
  final String label;
  final int idx;
  final Function(int, bool)? onPressed;
  const TimeSettingsComponent(
      {super.key, required this.label, required this.idx, this.onPressed});

  Widget _renderMobile() {
    var spacing = (Get.width ~/ 40).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.abel(
                fontSize: 24,
                color: Colors.grey[850],
                fontWeight: FontWeight.w800,
              ),
            ),
            Obx(() {
              return !controller.operatingTimeChanged[idx].value
                  ? Container()
                  : TextButton(
                      onPressed: () {
                        controller.upplyOperatingTime(idx);
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue)),
                      child: Text(
                        "적용",
                        style: GoogleFonts.abel(
                          fontSize: 16,
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
            }),
          ],
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 1,
        ),
        Center(
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.white,
                ),
                child: Column(
                  children: [
                    Text(
                      "--오 전--",
                      style: GoogleFonts.abel(
                        fontSize: 18,
                        color: Colors.grey[850],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 2,
                    ),
                    ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: Get.width > 720 ? 350 : 450),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: spacing,
                        children: List.generate(
                          12,
                          (index) => SizedBox(
                            width: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("~ ${index + 1}:00"),
                                Obx(() {
                                  return Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    onChanged: (value) {
                                      onPressed!(index, value!);
                                    },
                                    value: controller
                                        .clientOperatingTime[idx][index].value,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.white,
                ),
                child: Column(
                  children: [
                    Text(
                      "--오 후--",
                      style: GoogleFonts.abel(
                        fontSize: 18,
                        color: Colors.grey[850],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 2,
                    ),
                    ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: Get.width > 720 ? 350 : 450),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: spacing,
                        children: List.generate(
                          12,
                          (index) => SizedBox(
                            width: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("~ ${index + 1}:00"),
                                Obx(() {
                                  return Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    onChanged: (value) {
                                      onPressed!(12 + index, value!);
                                    },
                                    value: controller
                                        .clientOperatingTime[idx][12 + index]
                                        .value,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _render() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.abel(
                  fontSize: 24,
                  color: Colors.grey[850],
                  fontWeight: FontWeight.w800,
                ),
              ),
              Obx(() {
                return !controller.operatingTimeChanged[idx].value
                    ? Container()
                    : TextButton(
                        onPressed: () {
                          controller.upplyOperatingTime(idx);
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue)),
                        child: Text(
                          "적용",
                          style: GoogleFonts.abel(
                            fontSize: 16,
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
              }),
            ],
          ),
          SizedBox(
            height: SizeConfig.blockSizeVertical * 1,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(100, 224, 224, 224),
            ),
            child: Row(
              children: [
                Text(
                  "오 전",
                  style: GoogleFonts.abel(
                    fontSize: 18,
                    color: Colors.grey[850],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: SizeConfig.blockSizeVertical * 2),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                        dragDevices: {
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.touch,
                          PointerDeviceKind.stylus
                        }),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          12,
                          (index) => SizedBox(
                            width: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("~ ${index + 1}:00"),
                                Obx(() {
                                  return Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    onChanged: (value) {
                                      onPressed!(index, value!);
                                    },
                                    value: controller
                                        .clientOperatingTime[idx][index].value,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: SizeConfig.blockSizeVertical * 1,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(100, 224, 224, 224),
            ),
            child: Row(
              children: [
                Text(
                  "오 후",
                  style: GoogleFonts.abel(
                    fontSize: 18,
                    color: Colors.grey[850],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: SizeConfig.blockSizeVertical * 2),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                        dragDevices: {
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.touch,
                          PointerDeviceKind.stylus
                        }),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          12,
                          (index) => SizedBox(
                            width: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("~ ${index + 1}:00"),
                                Obx(() {
                                  return Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    onChanged: (value) {
                                      onPressed!(12 + index, value!);
                                    },
                                    value: controller
                                        .clientOperatingTime[idx][12 + index]
                                        .value,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context) ? _renderMobile() : _render();
  }
}
