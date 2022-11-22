import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:front/constants.dart';
import 'package:get/get.dart';
import 'app/modules/home/components/style/colors.dart';
import 'app/routes/app_pages.dart';
// import 'config/config_non_web.dart'
//     if (dart.library.html) 'config/config_web.dart';

void main() {
  serverAddr = kIsWeb ? '${Uri.base.host}:${Uri.base.port}' : 'localhost:3579';
  print("${Uri.base.path}");
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.primaryBg,
      ),
    ),
  );
}
