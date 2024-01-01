import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:front/app/modules/home/common/dialog.dart';
import 'package:front/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import '../components/style/colors.dart';

class SideMenu extends GetView<HomeController> {
  const SideMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: AppColors.secondaryBg),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 120,
                alignment: Alignment.center,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: 35,
                  height: 20,
                  child: SvgPicture.asset('images/mac-action.svg'),
                ),
              ),
              Obx(
                () => AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: controller.idx.value == 0 ? 1.4 : 1,
                  child: IconButton(
                    iconSize: 20,
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    icon: SvgPicture.asset(
                      'images/pie-chart.svg',
                      colorFilter: ColorFilter.mode(
                        controller.idx.value == 0
                            ? AppColors.black
                            : AppColors.iconGray,
                        BlendMode.srcIn,
                      ),
                      width: 25,
                    ),
                    onPressed: () {
                      if (controller.scaffoldKey.currentState!.isDrawerOpen) {
                        Future.delayed(const Duration(milliseconds: 200), () {
                          Get.back();
                        });
                      }
                      controller.updatePageIndex(0);
                    },
                  ),
                ),
              ),
              Obx(
                () => AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  scale: controller.idx.value == 1 ? 1.4 : 1,
                  child: IconButton(
                    iconSize: 20,
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    icon: Icon(
                      Icons.settings,
                      color: controller.idx.value == 1
                          ? AppColors.black
                          : AppColors.iconGray,
                    ),
                    onPressed: () {
                      makeDialog(context);
                      // if (controller.scaffoldKey.currentState!.isDrawerOpen) {
                      //   Future.delayed(const Duration(milliseconds: 220), () {
                      //     Get.back();
                      //   });
                      // }

                      // controller.updatePageIndex(1);
                    },
                  ),
                ),
              ),
              Obx(
                () => AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: controller.idx.value == 2 ? 1.4 : 1,
                  child: IconButton(
                    iconSize: 20,
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    icon: SvgPicture.asset(
                      'images/clipboard.svg',
                      color: controller.idx.value == 2
                          ? AppColors.black
                          : AppColors.iconGray,
                    ),
                    onPressed: () {
                      if (controller.scaffoldKey.currentState!.isDrawerOpen) {
                        Future.delayed(const Duration(milliseconds: 220), () {
                          Get.back();
                        });
                      }
                      controller.updatePageIndex(2);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
