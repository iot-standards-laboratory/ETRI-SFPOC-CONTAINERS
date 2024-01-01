// import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:front/app/routes/app_pages.dart';

void setPathUrlStrategy() {
  setUrlStrategy(const PathUrlStrategy());
  usePathUrlStrategy();
}

String getInitPath() {
  return Uri.base.path != '/' ? Uri.base.path : AppPages.INITIAL;
}
