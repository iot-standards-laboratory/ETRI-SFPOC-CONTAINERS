import 'package:flutter/material.dart';
import 'package:front/app/model/controller.dart';
import 'package:front/app/modules/home/views/monitoring_board.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/header.dart';
import '../config/responsive.dart';
import '../config/size_config.dart';
import '../controllers/home_controller.dart';
import '../controllers/side_menu.dart';
import '../components/style/colors.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  Widget renderBoard(int idx, BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return SafeArea(
      child: Scaffold(
        key: controller.scaffoldKey,
        appBar: !Responsive.isDesktop(context)
            ? AppBar(
                elevation: 0,
                iconTheme: IconTheme.of(context).copyWith(color: Colors.black),
                backgroundColor: AppColors.primaryBg,
                title: Text(
                  "Smart Farm",
                  style: GoogleFonts.sofia(
                    fontSize: 24,
                    color: Colors.grey[850],
                    fontWeight: FontWeight.w800,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: GetBuilder<HomeController>(
                        id: "reload",
                        builder: (controller) {
                          return PopupMenuButton<Controller>(
                            onSelected: (value) {
                              controller.updateSelectedCtrl(value);
                            },
                            itemBuilder: (context) {
                              return controller.ctrls
                                  .map(
                                    (e) => PopupMenuItem<Controller>(
                                      value: e,
                                      child: Text(e.name),
                                    ),
                                  )
                                  .toList();
                            },
                          );
                        }),
                  ),
                ],
              )
            : const PreferredSize(
                preferredSize: Size.zero,
                child: SizedBox(),
              ),
        body: Row(
          children: [
            Expanded(
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
