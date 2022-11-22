import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:front/app/modules/home/components/style/colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BarChartCopmponent extends StatelessWidget {
  final double maxY;
  final List<double> value;
  final scrollController = ScrollController();
  BarChartCopmponent({
    required this.maxY,
    required this.value,
    Key? key,
  }) : super(key: key);

  BarChartGroupData _renderBar(int idx, double y) {
    return BarChartGroupData(
      x: idx,
      barRods: [
        BarChartRodData(
          width: 60,
          toY: y > maxY ? maxY : y,
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          backDrawRodData: BackgroundBarChartRodData(
              toY: maxY, show: true, color: AppColors.barBg),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus
        }),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          child: SizedBox(
            width: (90) * 48,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(enabled: false),
                borderData: FlBorderData(show: false),
                maxY: maxY,
                alignment: BarChartAlignment.spaceBetween,
                gridData: FlGridData(
                  drawHorizontalLine: true,
                  horizontalInterval: maxY / 5,
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 30,
                      showTitles: true,
                      getTitlesWidget: (idx, meta) =>
                          Text("${value[idx.toInt()]}"),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      interval: maxY / 5,
                      reservedSize: 40,
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text("$value"),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 40,
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        var hour = (value * 30 + 30) ~/ 60;
                        var minute = value % 2 == 0 ? "30" : "00";

                        return hour < 10
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('~ 0$hour:$minute'),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('~ $hour:$minute'),
                              );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  48,
                  (idx) => _renderBar(
                    idx,
                    value[idx],
                  ),
                ),
              ),

              swapAnimationDuration:
                  const Duration(milliseconds: 150), // Optional
              swapAnimationCurve: Curves.linear, // Optional
            ),
          ),
        ),
      ),
    );
  }
}
