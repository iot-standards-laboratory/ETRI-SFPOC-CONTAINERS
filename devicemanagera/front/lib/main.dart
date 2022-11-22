import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/modules/home/components/style/colors.dart';
import 'app/routes/app_pages.dart';
import 'config/config_non_web.dart'
    if (dart.library.html) 'config/config_web.dart';

void main() {
  setPathUrlStrategy();
  print(getInitPath());
  // usePathUrlStrategy();
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: getInitPath(),
      getPages: AppPages.routes,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.primaryBg,
      ),
    ),
  );
}
