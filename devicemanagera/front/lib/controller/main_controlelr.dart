import 'dart:convert';

import 'package:front/constants.dart';
import 'package:front/controller/ws.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MainController extends GetxController {
  var sensingValue = 0.obs;
  var ctrlValue = 0.obs;

  MainController() {
    ws.stream.listen((message) async {
      loadData();
    });
    loadData();
  }

  void loadData() async {
    var apiUrl = Uri.base.path[Uri.base.path.length - 1] == '/'
        ? '${Uri.base.path}api/v1'
        : '${Uri.base.path}/api/v1';
    var response = await http.get(Uri.http(serverAddr, apiUrl));

    dynamic body = jsonDecode(response.body);
    // print('${body}');
    sensingValue.value = body["sensingValue"];

    update();
  }

  @override
  void onClose() {
    super.onClose();
    ws.sink.close();
  }
}
