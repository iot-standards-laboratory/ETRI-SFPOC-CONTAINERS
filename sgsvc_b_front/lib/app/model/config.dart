import 'dart:convert';


class Config {
  final String mqttAddress;
  final String serviceId;
  final String ctrlId;
  // final List<Controller> ctrls;

  Config({
    required this.mqttAddress,
    required this.serviceId,
    required this.ctrlId,
  });
  factory Config.fromJson(
    dynamic json,
    String ctrlId,
  ) {
    // var ctrls = (json['ctrls'] as List<dynamic>)
    //     .map(
    //       (e) => Controller.fromJson(e),
    //     )
    //     .toList();

    return Config(
      mqttAddress: json['mqtt_address'],
      serviceId: json['service_id'],
      ctrlId: ctrlId,
      // ctrls: ctrls,
    );
  }

  String toJson() {
    return jsonEncode({
      'mqtt_address': mqttAddress,
      'service_id': serviceId,
      // 'ctrls': ctrls.map((e) => e.toJson()).toList(),
    });
  }
}
