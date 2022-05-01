import 'dart:convert';

import 'package:front/common/util.dart';
import 'package:front/constants.dart';
import 'package:front/controller/ws.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MainController extends GetxController {
  // var devList =
  var ws = subscribeWithWebsocket();

  MainController() {
    ws.stream.listen((message) async {
      loadData();
    });
    loadData();
  }

  void loadData() async {
    var apiUrl = getURL("/api/v1/devs/list");
    print(apiUrl);
    // var response = await http.get(Uri.http(serverAddr, apiUrl));

    update();
  }

  @override
  void onClose() {
    super.onClose();
    ws.sink.close();
  }
}
