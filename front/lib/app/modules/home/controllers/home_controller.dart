import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:front/app/model/config.dart';
import 'package:front/app/model/controller.dart';
import 'package:front/app/modules/home/controllers/http_loader.dart';
import 'package:front/app/modules/home/controllers/mqtt_controller.dart';
import 'package:front/constants.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';

enum NotifyEvent { history }

const _historyCheckDuration = Duration(seconds: 10);

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final session = false.obs;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final currentTime = DateTime.now().obs;
  Timer? currentTimeChecker;

  var cropCultureDays = <Rx<int>>[0.obs, 0.obs, 0.obs, 0.obs, 0.obs];
  var temperature = 0.0.obs;
  var humidity = 0.0.obs;
  var co2 = 0.0.obs;

  var ledOperatingInterval = 0.0.obs;
  var desiredTemperatur = 0.0.obs;
  var desiredHumidity = 0.0.obs;
  var temperatureDifference = 0.0.obs;
  var irrigationInterval = 0.0.obs;

  var date = DateTime.now();

  var led = false.obs;
  var isLedAuto = false.obs;

  var ventilationFan = false.obs;
  var isVentilationFanAuto = false.obs;

  var circulator = false.obs;
  var isCirculatorAuto = false.obs;

  var airConditioner = false.obs;
  var isAirConditionerAuto = false.obs;
  var irrigationSystem = <Rx<bool>>[
    false.obs,
    false.obs,
    false.obs,
    false.obs,
    false.obs,
  ];
  var isIrrigationSystemAuto = <Rx<bool>>[
    false.obs,
    false.obs,
    false.obs,
    false.obs,
    false.obs,
  ];
  final _idx = 0.obs;
  Rx<int> get idx => _idx;

  void updatePageIndex(int i) {
    _idx.value = i;

    if (i == 2) {
      timer = Timer.periodic(_historyCheckDuration, (timer) {
        updateLatestInformationToHistory();
      });

      return;
    }

    if (isTimerRunning()) {
      timer!.cancel();
    }
  }

  var serverOperatingTime = <List<Rx<bool>>>[
    <Rx<bool>>[],
    <Rx<bool>>[],
    <Rx<bool>>[],
    <Rx<bool>>[],
    <Rx<bool>>[],
    <Rx<bool>>[],
  ];
  var clientOperatingTime = <List<Rx<bool>>>[
    <Rx<bool>>[],
    <Rx<bool>>[],
    <Rx<bool>>[],
    <Rx<bool>>[],
    <Rx<bool>>[],
    <Rx<bool>>[],
  ];

  var temperatureHistory = <double>[].obs;
  var humidityHistory = <double>[].obs;
  var co2History = <double>[].obs;

  Timer? timer;
  void loadHistory() {
    for (var i = 0; i < 48; i++) {
      temperatureHistory.add(0);
      humidityHistory.add(0);
      co2History.add(0);
    }
    updateLatestInformationToHistory();
  }

  bool isTimerRunning() {
    var isTimerRunning = timer?.isActive;
    return isTimerRunning != null && isTimerRunning;
  }

  void updateLatestInformationToHistory() {
    var now = DateTime.now();
    temperatureHistory[((now.hour * 60) + now.minute) ~/ 30] =
        Random().nextInt(50).toDouble();

    humidityHistory[((now.hour * 60) + now.minute) ~/ 30] =
        Random().nextInt(50).toDouble();

    co2History[((now.hour * 60) + now.minute) ~/ 30] =
        Random().nextInt(50).toDouble();
    update([NotifyEvent.history]);
  }
  // var temperatureHistory = <double>

  var operatingTimeChanged = <Rx<bool>>[];
  bool compareOperatingTime(List<Rx<bool>> src, List<Rx<bool>> dest) {
    if (src.length != dest.length) {
      return true;
    }

    for (var i = 0; i < src.length; i++) {
      if (src[i].value != dest[i].value) {
        return true;
      }
    }

    return false;
  }

  void upplyOperatingTime(int idx) {
    for (var i = 0; i < serverOperatingTime[idx].length; i++) {
      serverOperatingTime[idx][i].value = clientOperatingTime[idx][i].value;
    }

    operatingTimeChanged[idx].value = compareOperatingTime(
        serverOperatingTime[idx], clientOperatingTime[idx]);

    // operatingTimeChanged[idx].value = true;
    Get.snackbar("update", "Successfully updated");
  }

  void updateDate(DateTime d) {
    var now = DateTime.now();
    if (now.year != d.year || now.month != d.month || now.day != d.day) {
      if (isTimerRunning()) {
        timer!.cancel();
      }
    } else {
      if (!isTimerRunning()) {
        timer = timer = Timer.periodic(_historyCheckDuration, (timer) {
          updateLatestInformationToHistory();
        });
      }
    }

    date = d;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    var now = DateTime.now();
    var after = 60000 - (now.second * 1000) - now.millisecond;
    Future.delayed(Duration(milliseconds: after), () {
      currentTime.value = DateTime.now();
      currentTimeChecker = Timer.periodic(const Duration(minutes: 1), (timer) {
        currentTime.value = DateTime.now();
      });
    });
    for (var i = 0; i < 6; i++) {
      operatingTimeChanged.add(false.obs);
      for (var j = 0; j < 24; j++) {
        serverOperatingTime[i].add(false.obs);
        clientOperatingTime[i].add(false.obs);
      }
    }
    loadHistory();
  }

  Config? svcConfig;

  var ctrls = <Controller>[];
  Controller? selectedCtrl;
  late MQTTController _mqttController;

  Future<void> load() async {
    svcConfig = await loadConfig();
    ctrls = svcConfig!.ctrls;

    if (ctrls.isEmpty) {
      _mqttController.unsubscribeChannel(topic: _mqttController.latestTopic);
      temperature.value = 0;
      humidity.value = 0;
      co2.value = 0;
      led.value = false;
      ventilationFan.value = false;
      selectedCtrl = null;
    }
    // if (selectedCtrl == null) {
    //   updateSelectedCtrl(ctrls[0]);
    // }
    update(["reload"]);
  }

  void init() async {
    _mqttController = MQTTController(
      mqttAddr: "mqtt.godopu.com",
      onUpdate: (topic, payload) {
        if (topic == svcConfig!.serviceId) {
          load();
        } else {
          var obj = jsonDecode(payload);
          if (topic.endsWith("/sensor")) {
            temperature.value = obj['temp'] ?? temperature.value;
            humidity.value = obj['humi'] ?? humidity.value;
            co2.value = obj['soilHumi'] ?? co2.value;
          } else if (topic.endsWith("/actuator")) {
            led.value = obj['led'] ?? led.value;
            ventilationFan.value = obj['fan'] ?? ventilationFan.value;
          }
        }
      },
    );

    await load();
    var ok = await _mqttController.connect(svcConfig!.serviceId);

    if (selectedCtrl == null && ctrls.isNotEmpty) {
      updateSelectedCtrl(ctrls[0]);
    }
  }

  var b_timeout = false;

  void updateSelectedCtrl(Controller ctrl) {
    selectedCtrl = ctrl;
    _mqttController.updateSubscribeChannel(
        topic: '${selectedCtrl!.reportChan}/#');

    var msgBuilder = MqttClientPayloadBuilder();
    msgBuilder.addString('actuator');
    _mqttController.publish('${selectedCtrl!.controlChan}/get', msgBuilder);

    msgBuilder.clear();
    msgBuilder.addString('sensor');
    _mqttController.publish('${selectedCtrl!.controlChan}/get', msgBuilder);
  }

  void publishMessage(String path, dynamic value) {
    try {
      var jCtrlmessage = <String, dynamic>{
        "path": path,
        "value": value,
      };
      var sCtrlMessage = jsonEncode(jCtrlmessage);

      var msgBuilder = MqttClientPayloadBuilder();
      msgBuilder.addString(sCtrlMessage);

      b_timeout = true;
      Future.delayed(const Duration(seconds: 3), () {
        b_timeout = false;
      });
      if (selectedCtrl != null) {
        _mqttController.publish(
            '${selectedCtrl!.controlChan}/post', msgBuilder);
      }
    } catch (e) {
      print(e.toString());
      return;
    }
  }

  @override
  void onReady() {
    super.onReady();
    init();
  }

  @override
  void onClose() {
    super.onClose();
    _mqttController.disconnect();
  }
}
