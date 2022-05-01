import 'dart:convert';

import 'package:front/common/util.dart';
import 'package:front/controller/ws.dart';
import 'package:front/model/device.dart';
import 'package:front/model/measurement.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MainController extends GetxController {
  // var devList =
  var ws = subscribeWithWebsocket();
  var devList = <Device>[];
  var measurement = MeasurementData(id: "", status: <Status>[]);
  var index = 0.obs;

  MainController() {
    ws.stream.listen((message) async {
      print(message);
      // loadData();
    });
    loadDev();
  }

  void changeIndex(int newIdx) {
    if (index.value != newIdx) {
      index.value = newIdx;
    }
    update();
  }

  void loadDev() async {
    var resp = await http.get(getUri('', '${Uri.base.path}/api/v1/devs/list'));

    if (resp.statusCode == 200) {
      try {
        var body = jsonDecode(resp.body);

        for (var e in body as List<dynamic>) {
          devList.add(Device.fromJson(e));
        }

        loadMeasurement();
      } on FormatException catch (e) {
        print(e);
      }
      // var response = await http.get(Uri.http(serverAddr, apiUrl));

      update();
    }
  }

  void loadMeasurement() async {
    if (index.value >= devList.length) return;

    var resp = await http.get(
      getUri('', '${Uri.base.path}/api/v1/status'),
      headers: <String, String>{"did": devList[index.value].did},
    );

    if (resp.statusCode == 200) {
      try {
        var body = jsonDecode(resp.body);

        if ((body as List<dynamic>).isEmpty) return;

        measurement = MeasurementData.fromJson(body[0]);
      } on FormatException catch (e) {
        print(e);
      }
      // var response = await http.get(Uri.http(serverAddr, apiUrl));

      update(["status"]);
    }
  }

  @override
  void onClose() {
    super.onClose();
    ws.sink.close();
  }
}
