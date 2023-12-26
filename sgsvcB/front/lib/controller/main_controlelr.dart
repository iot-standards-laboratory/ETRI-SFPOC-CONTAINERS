import 'dart:convert';

import 'package:front/common/util.dart';
import 'package:front/controller/ws.dart';
import 'package:front/model/device.dart';
import 'package:front/model/measurement.dart';
import 'package:front/model/relation_mapper.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MainController extends GetxController {
  // var devList =
  var ws = subscribeWithWebsocket();
  var devList = <Device>[];
  var msmts = <String, MeasurementData>{};
  var relations = RelationMapper();

  MainController() {
    ws.stream.listen((message) async {
      var push = jsonDecode(message);
      if ((push["key"] as String).compareTo("putstatus") == 0) {
        loadMeasurement(push["value"]);
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

        devList.clear();
        for (var e in body as List<dynamic>) {
          devList.add(Device.fromJson(e));
        }

        await loadMeasurement("");
      } on FormatException catch (e) {
        print(e);
      }
      // var response = await http.get(Uri.http(serverAddr, apiUrl));

      update(["devs"]);
    }
  }

  // MeasurementData? getMeasurementData(String did) {
  //   var list = relations.getRelatedElements(did);
  //   if (list == null) {
  //     return null;
  //   }
  //   for (var e in list) {
  //     if (e is MeasurementData) {
  //       return e;
  //     }
  //   }

  //   return null;
  // }

  void postStatus(String mid, String did, dynamic status) {
    var body = <String, dynamic>{
      "did": did,
      "status": status,
    };
    http.post(
      getUri('', '${Uri.base.path}/api/v1/status/$mid'),
      body: jsonEncode(body),
    );

    update([mid]);
  }

  Future<int> loadMeasurement(String mid) async {
    if (mid.isEmpty) {
      msmts.clear();
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
            msmts[data.id] = data;
            relations.addRelation(data.id, dev);
            relations.addRelation(dev.did, data);
            update([data.id]);
          } on FormatException catch (e) {
            print(e);
          }
        }
      }
    } else {
      var resp = await http.get(
        getUri('', '${Uri.base.path}/api/v1/status/$mid'),
      );

      if (resp.statusCode == 200) {
        try {
          var body = jsonDecode(resp.body);

          var data = MeasurementData.fromJson(body);
          var msmt = msmts[mid];

          msmt!.status = data.status;
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
