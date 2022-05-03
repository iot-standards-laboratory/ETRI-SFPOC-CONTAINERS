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
  var measurements = <String, MeasurementData>{};
  var relations = <String, dynamic>{};

  MainController() {
    ws.stream.listen((message) async {
      var push = jsonDecode(message);
      if ((push["key"] as String).compareTo("putstatus") == 0) {
        loadMeasurement();
      } else {
        loadDev();
      }
      // loadData();
    });
    loadDev();
  }

  void loadDev() async {
    var resp = await http.get(getUri('', '${Uri.base.path}/api/v1/devs/list'));

    if (resp.statusCode == 200) {
      try {
        var body = jsonDecode(resp.body);

        for (var e in body as List<dynamic>) {
          devList.add(Device.fromJson(e));
        }

        await loadMeasurement();
      } on FormatException catch (e) {
        print(e);
      }
      // var response = await http.get(Uri.http(serverAddr, apiUrl));

      update(["devs"]);
    }
  }

  Future<int> loadMeasurement() async {
    for (var dev in devList) {
      var resp = await http.get(
        getUri('', '${Uri.base.path}/api/v1/status'),
        headers: <String, String>{"did": dev.did},
      );

      if (resp.statusCode == 200) {
        try {
          var body = jsonDecode(resp.body);

          if ((body as List<dynamic>).isEmpty) return 0;

          var data = MeasurementData.fromJson(body[0]);
          measurements[data.id] = data;
          print("update : ${data.id}");
          update([data.id]);
        } on FormatException catch (e) {
          print(e);
        }
      }
    }

    return 0;
  }

  @override
  void onClose() {
    super.onClose();
    ws.sink.close();
  }
}
