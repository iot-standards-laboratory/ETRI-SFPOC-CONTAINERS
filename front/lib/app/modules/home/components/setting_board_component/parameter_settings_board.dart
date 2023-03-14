import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front/app/modules/home/components/style/colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../config/responsive.dart';
import '../../config/size_config.dart';
import '../../controllers/home_controller.dart';

class ParameterSettingsBoard extends GetView<HomeController> {
  final pageController = PageController(viewportFraction: 1, keepPage: true);
  late List<Widget> pages;

  ParameterSettingsBoard({super.key}) {
    pages = [
      Obx(() {
        return ParameterSettingsComponent(
          label: 'LED 동작 시간',
          value: controller.ledOperatingInterval.value,
          unit: Text(
            "분/시",
            style: GoogleFonts.sofia(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          onPressed: () async {
            var value = await _showInputDialog(Get.context!, 'LED 동작 시간',
                controller.ledOperatingInterval.value, 60);
            if (value != controller.ledOperatingInterval.value) {
              controller.ledOperatingInterval.value = value;
              return;
            }
          },
        );
      }),
      Obx(
        () => ParameterSettingsComponent(
            label: '희망 온도',
            value: controller.desiredTemperatur.value,
            unit: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ㅇ",
                  style: GoogleFonts.sofia(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  "C",
                  style: GoogleFonts.sofia(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            onPressed: () async {
              var value = await _showInputDialog(Get.context!, '희망 온도',
                  controller.desiredTemperatur.value, 100);
              if (value != controller.desiredTemperatur.value) {
                controller.desiredTemperatur.value = value;
                return;
              }
            }),
      ),
      Obx(
        () => ParameterSettingsComponent(
          label: '희망 습도',
          value: controller.desiredHumidity.value,
          unit: Text(
            "%",
            style: GoogleFonts.sofia(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          onPressed: () async {
            var value = await _showInputDialog(
                Get.context!, '희망 습도', controller.desiredHumidity.value, 100);
            if (value != controller.desiredHumidity.value) {
              controller.desiredHumidity.value = value;
              return;
            }
          },
        ),
      ),
      Obx(
        () => ParameterSettingsComponent(
            label: '상/하 온도 차이',
            value: controller.temperatureDifference.value,
            unit: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ㅇ",
                  style: GoogleFonts.sofia(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  "C 이하",
                  style: GoogleFonts.sofia(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            onPressed: () async {
              var value = await _showInputDialog(Get.context!, '상/하 온도 차이',
                  controller.temperatureDifference.value, 100);
              if (value != controller.temperatureDifference.value) {
                controller.temperatureDifference.value = value;
                return;
              }
            }),
      ),
      Obx(
        () => ParameterSettingsComponent(
            label: '관수 시간',
            value: controller.irrigationInterval.value,
            unit: Text(
              "분/시",
              style: GoogleFonts.sofia(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            onPressed: () async {
              var value = await _showInputDialog(Get.context!, '관수 시간',
                  controller.irrigationInterval.value, 60);
              if (value != controller.irrigationInterval.value) {
                controller.irrigationInterval.value = value;
                return;
              }
            }),
      ),
    ];
  }

  Widget _renderDesktop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '자동 설정',
          style: GoogleFonts.sofia(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 1,
        ),
        ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus
          }),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: pages
                  .map(
                    ((e) => Padding(
                        padding: const EdgeInsets.only(right: 10), child: e)),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '자동 설정',
          style: GoogleFonts.sofia(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 1,
        ),
        SizedBox(
          height: 200,
          child: ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus
            }),
            child: PageView.builder(
              itemCount: pages.length,
              controller: pageController,

              // itemCount: pages.length,
              itemBuilder: (_, idx) {
                return pages[idx];
              },
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 2,
        ),
        Center(
          child: SmoothPageIndicator(
            controller: pageController,
            count: pages.length,
            effect: const WormEffect(
              dotHeight: 16,
              dotWidth: 16,
              type: WormType.thin,
              // strokeWidth: 5,
            ),
            onDotClicked: (index) {
              pageController.jumpToPage(index);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Responsive(
      desktop: _renderDesktop(),
      tablet: _renderDesktop(),
      mobile: _renderMobile(),
    );
  }
}

class ParameterSettingsComponent extends StatelessWidget {
  final double value;
  final Widget unit;
  final String label;
  final Function()? onPressed;
  const ParameterSettingsComponent({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.bebasNeue(
                fontSize: 24,
                color: Colors.grey[850],
                fontWeight: FontWeight.w700),
          ),
          InkWell(
            hoverColor: Colors.transparent,
            onTap: onPressed,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$value',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 50,
                    color: Colors.grey[850],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: unit,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

final formKey = GlobalKey<FormState>();
Future<double> _showInputDialog(BuildContext context, String label,
    double initValue, double maxValue) async {
  var value = await showDialog<double>(
    context: context,
    builder: (BuildContext context) {
      var value = initValue;
      return AlertDialog(
        // title: Text('Welcome'),
        elevation: 0,
        backgroundColor: Colors.white,
        content: SizedBox(
          width: 260,
          height: 260,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Text(
                  '$label: ',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 30,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('현재 값: $initValue',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 20,
                          )),
                      TextFormField(
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          // for version 2 and greater youcan also use this
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        onSaved: (val) {
                          if (val == null) {
                            value = initValue;
                          } else {
                            value = double.parse(val);
                          }
                        },
                        validator: (val) {
                          try {
                            var parsedValue = double.parse(val!);
                            if (parsedValue > maxValue) {
                              throw Exception("$maxValue 보다 작은 수를 입력해주세요");
                            }
                          } catch (e) {
                            return e.toString();
                          }
                          return null;
                        },
                        style: GoogleFonts.bebasNeue(
                          fontSize: 36,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        Navigator.pop(context, value);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.deepPurple),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    child: const SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Center(
                          child: Text(
                            "apply",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return value ?? initValue;
}
