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
                        onLabel: "켜짐",
                        offLabel: "꺼짐",
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
                        label: "환기 도어",
                        onLabel: "열림",
                        offLabel: "닫힘",
                        status: ctrl.ventilationDoor.value,
                        isAuto: ctrl.isVentilationDoorAuto.value,
                        width: width,
                        backgroundColor: AppColors.white,
                        onCheckBoxChanged: (b) {
                          ctrl.isVentilationDoorAuto.value = b!;
                        },
                        onStatusChanged: ctrl.isLedAuto.value
                            ? null
                            : (b) {
                                if (ctrl.ventilationDoor.value == b) return;
                                // ctrl.ventilationFan.value = b;
                                ctrl.publishMessage('door', b);
                              },
                      );
                    }),
                    GetX<HomeController>(builder: (ctrl) {
                      return CropControlComponent(
                        label: "알림",
                        onLabel: "켜짐",
                        offLabel: "꺼짐",
                        status: ctrl.buzzer.value,
                        isAuto: ctrl.isBuzzerAuto.value,
                        width: width,
                        backgroundColor: AppColors.white,
                        onCheckBoxChanged: (b) {
                          ctrl.buzzer.value = b!;
                        },
                        onStatusChanged: (b) {
                          if (ctrl.buzzer.value == b) return;
                          ctrl.publishMessage('buzzer', b);
                        },
                      );
                    }),
                  ],
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
  final String onLabel;
  final String offLabel;
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
    required this.onLabel,
    required this.offLabel,
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
                              onLabel,
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
                              offLabel,
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
