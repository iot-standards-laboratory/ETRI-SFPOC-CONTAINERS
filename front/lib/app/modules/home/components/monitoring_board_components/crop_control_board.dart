import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:front/app/modules/home/components/style/colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/responsive.dart';
import '../../config/size_config.dart';
import '../../controllers/home_controller.dart';

class CropControlBoard extends GetView<HomeController> {
  const CropControlBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, ctis) {
        var width = Responsive.isMobile(context) ? 280.0 : 360.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '스마트 팜 제어',
              style: GoogleFonts.sofia(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical * 1,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.start,
                  children: [
                    GetX<HomeController>(builder: (ctrl) {
                      return CropControlComponent(
                        label: "LED",
                        status: ctrl.led.value,
                        isAuto: ctrl.isLedAuto.value,
                        width: width,
                        backgroundColor: AppColors.white,
                        onCheckBoxChanged: (b) {
                          ctrl.isLedAuto.value = b!;
                        },
                        onStatusChanged: ctrl.isLedAuto.value
                            ? null
                            : (b) {
                                if (ctrl.led.value == b) return;
                                // ctrl.led.value = b;
                                ctrl.publishMessage("led", b);
                              },
                      );
                    }),
                    GetX<HomeController>(builder: (ctrl) {
                      return CropControlComponent(
                        label: "환기 팬",
                        status: ctrl.ventilationFan.value,
                        isAuto: ctrl.isVentilationFanAuto.value,
                        width: width,
                        backgroundColor: AppColors.white,
                        onCheckBoxChanged: (b) {
                          ctrl.isVentilationFanAuto.value = b!;
                        },
                        onStatusChanged: ctrl.isLedAuto.value
                            ? null
                            : (b) {
                                if (ctrl.ventilationFan.value == b) return;
                                // ctrl.ventilationFan.value = b;
                                ctrl.publishMessage('fan', b);
                              },
                      );
                    }),
                    GetX<HomeController>(builder: (ctrl) {
                      return CropControlComponent(
                        label: "순환 서큘레이터",
                        status: ctrl.circulator.value,
                        isAuto: ctrl.isCirculatorAuto.value,
                        width: width,
                        backgroundColor: AppColors.white,
                        onCheckBoxChanged: (b) {
                          ctrl.isCirculatorAuto.value = b!;
                        },
                        onStatusChanged: (b) {
                          ctrl.circulator.value = b;
                        },
                      );
                    }),
                    GetX<HomeController>(builder: (ctrl) {
                      return CropControlComponent(
                        label: "냉/난방기 ",
                        status: ctrl.airConditioner.value,
                        isAuto: ctrl.isAirConditionerAuto.value,
                        width: width,
                        backgroundColor: AppColors.white,
                        onCheckBoxChanged: (b) {
                          ctrl.isAirConditionerAuto.value = b!;
                        },
                        onStatusChanged: (b) {
                          ctrl.airConditioner.value = b;
                        },
                      );
                    }),
                  ],
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 2,
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '관수 시스템',
                        style: GoogleFonts.sofia(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ScrollConfiguration(
                        behavior: const MaterialScrollBehavior().copyWith(
                            dragDevices: {
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.touch,
                              PointerDeviceKind.stylus
                            }),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                              children: List<Widget>.generate(
                                  controller.irrigationSystem.length, (idx) {
                            return Obx(() {
                              return CropControlComponent(
                                label: '${idx + 1}단',
                                status: controller.irrigationSystem[0].value,
                                isAuto:
                                    controller.isIrrigationSystemAuto[0].value,
                                width: 220,
                                backgroundColor: AppColors.white,
                                onCheckBoxChanged: (b) {
                                  controller.isIrrigationSystemAuto[0].value =
                                      b!;
                                },
                                onStatusChanged: (b) {
                                  if (controller.irrigationSystem[0].value ==
                                      b) {
                                    return;
                                  }
                                  // ctrl.ventilationFan.value = b;
                                  controller.publishMessage('pump', b);
                                },
                              );
                            });
                          }).toList()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}

class CropControlComponent extends StatelessWidget {
  final String label;
  final double width;
  final bool status;
  final bool isAuto;
  final Color? backgroundColor;
  final void Function(bool)? onStatusChanged;
  final void Function(bool?)? onCheckBoxChanged;
  const CropControlComponent({
    super.key,
    required this.label,
    required this.status,
    required this.isAuto,
    this.width = 0,
    this.onStatusChanged,
    this.onCheckBoxChanged,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: backgroundColor,
      ),
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 10,
        runSpacing: 20,
        alignment: WrapAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  label,
                  style: GoogleFonts.adamina(
                    fontSize: (width / 8 > 20) ? 20 : width / 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedScale(
                        scale: (!isAuto && status) ? 1.2 : 0.8,
                        duration: const Duration(milliseconds: 300),
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: (!isAuto && status)
                                ? MaterialStateProperty.all(
                                    Colors.lightBlue[600])
                                : MaterialStateProperty.all(Colors.grey[200]),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            elevation: MaterialStateProperty.all<double>(8),
                          ),
                          onPressed: () {
                            if (onStatusChanged != null) {
                              onStatusChanged!(true);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "켜짐",
                              style: GoogleFonts.bebasNeue(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedScale(
                      scale: (!isAuto && !status) ? 1.2 : 0.8,
                      duration: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: (!isAuto && !status)
                                ? MaterialStateProperty.all(Colors.amber[900])
                                : MaterialStateProperty.all(Colors.grey[200]),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            elevation: MaterialStateProperty.all<double>(8),
                          ),
                          onPressed: () {
                            if (onStatusChanged != null) {
                              onStatusChanged!(false);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "꺼짐",
                              style: GoogleFonts.bebasNeue(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("자동", style: TextStyle(fontSize: 16)),
                    ),
                    Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onChanged: onCheckBoxChanged,
                      value: isAuto,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
