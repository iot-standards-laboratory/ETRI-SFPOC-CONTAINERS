import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:front/app/modules/home/config/size_config.dart';
import 'package:front/app/modules/home/components/style/colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/home_controller.dart';

class CropGrowthBoard extends GetView<HomeController> {
  const CropGrowthBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '생육 정보',
          style: GoogleFonts.bebasNeue(
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
              children: List.generate(
                controller.cropCultureDays.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Obx(() {
                    return CropGrowthComponent(
                      label: '${i + 1}단',
                      value: controller.cropCultureDays[i].value,
                      sowingHandler: () {
                        controller.cropCultureDays[i].value = 7;
                      },
                      harvestingHandler: () {
                        controller.cropCultureDays[i].value = 0;
                      },
                    );
                  }),
                ),
              ).toList(),
            ),
          ),
        )
      ],
    );
  }
}

class CropGrowthComponent extends StatelessWidget {
  final String label;
  final int value;
  final void Function()? sowingHandler;
  final void Function()? harvestingHandler;

  const CropGrowthComponent({
    required this.label,
    required this.value,
    this.sowingHandler,
    this.harvestingHandler,
    super.key,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          Text(
            label,
            style: GoogleFonts.bebasNeue(
                fontSize: 24,
                color: Colors.grey[850],
                fontWeight: FontWeight.w700),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${value.abs()}',
                style: GoogleFonts.bebasNeue(
                  fontSize: 32,
                  color: value >= 0 ? Colors.grey[850] : Colors.red,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  '일',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 12,
                    color: value >= 0 ? Colors.grey[850] : Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  value >= 0 ? '남았습니다.' : '지났습니다.',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 16,
                    color: value >= 0 ? Colors.grey[850] : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.lightBlue[600]),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  elevation: MaterialStateProperty.all<double>(8),
                ),
                onPressed: sowingHandler,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "파종",
                    style: GoogleFonts.bebasNeue(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber[900]),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  elevation: MaterialStateProperty.all<double>(8),
                ),
                onPressed: harvestingHandler,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "수확",
                    style: GoogleFonts.bebasNeue(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
