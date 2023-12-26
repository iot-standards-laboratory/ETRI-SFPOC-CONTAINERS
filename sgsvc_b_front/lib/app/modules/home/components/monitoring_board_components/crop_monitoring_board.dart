import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/responsive.dart';
import '../../config/size_config.dart';
import '../../controllers/home_controller.dart';
import '../style/colors.dart';

class CropMonitoringBoard extends StatelessWidget {
  const CropMonitoringBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '상태 모니터링',
          style: GoogleFonts.sofia(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 1,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.start,
          children: [
            GetX<HomeController>(
              builder: (ctrl) {
                return CropMonitoringComponent(
                    label: "온도",
                    sublabel: "",
                    value: ctrl.temperature.value,
                    unit: "");
              },
            ),
          ],
        ),
      ],
    );
  }
}

class CropMonitoringComponent extends StatelessWidget {
  final String unit;
  final String label;
  final String sublabel;
  final double value;

  const CropMonitoringComponent({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.unit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: EdgeInsets.only(
          top: 40,
          bottom: 40,
          left: 20,
          right: Responsive.isMobile(context) ? 20 : 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.sofia(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            sublabel,
            style: GoogleFonts.sofia(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            ":",
            style: GoogleFonts.sofia(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${value.toStringAsFixed(2)}',
            style: GoogleFonts.almendraSc(
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 5),
          label == "온도"
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ㅇ",
                      style: GoogleFonts.sofia(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "C",
                      style: GoogleFonts.sofia(
                        fontSize: 24,
                      ),
                    ),
                  ],
                )
              : Text(
                  unit,
                  style: GoogleFonts.sofia(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ],
      ),
    );
  }
}
