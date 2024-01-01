import 'package:flutter/material.dart';
import 'package:front/app/modules/home/views/historical_monitoring_board.dart';
import 'package:front/app/modules/home/views/monitoring_board.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/header.dart';
import '../config/responsive.dart';
import '../config/size_config.dart';
import '../controllers/home_controller.dart';
import '../controllers/side_menu.dart';
import '../components/style/colors.dart';
import 'settings_board.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  Widget renderBoard(int idx, BuildContext context) {
    return IndexedStack(
      index: idx,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: (controller.idx.value == 0) ? 1 : 0,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: Responsive.isMobile(context) ? 20 : 80,
            ),
            child: Column(
              children: [
                if (Responsive.isDesktop(context)) const Header(),
                const MonitoringBoard(),
              ],
            ),
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: (controller.idx.value == 1) ? 1 : 0,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: Responsive.isMobile(context) ? 20 : 80,
            ),
            child: Column(
              children: [
                if (Responsive.isDesktop(context)) const Header(),
                const SettingsBoard(),
              ],
            ),
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: (controller.idx.value == 2) ? 1 : 0,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: Responsive.isMobile(context) ? 20 : 80,
            ),
            child: Column(
              children: [
                if (Responsive.isDesktop(context)) const Header(),
                const HistoricalMonitoringBoard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return SafeArea(
      child: Scaffold(
        key: controller.scaffoldKey,
        drawer: const SizedBox(width: 100, child: SideMenu()),
        appBar: !Responsive.isDesktop(context)
            ? AppBar(
                elevation: 0,
                iconTheme: IconTheme.of(context).copyWith(color: Colors.black),
                backgroundColor: AppColors.primaryBg,
                leading: IconButton(
                  onPressed: () {
                    controller.scaffoldKey.currentState!.openDrawer();
                  },
                  icon: const Icon(Icons.menu, color: AppColors.black),
                ),
                title: Text(
                  "Smart Farm (basic)",
                  style: GoogleFonts.sofia(
                    fontSize: 24,
                    color: Colors.grey[850],
                    fontWeight: FontWeight.w800,
                  ),
                ),
                actions: const [],
              )
            : const PreferredSize(
                preferredSize: Size.zero,
                child: SizedBox(),
              ),
        body: Row(
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                flex: 1,
                child: SideMenu(),
              ),
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Obx(
                  () => renderBoard(controller.idx.value, context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
