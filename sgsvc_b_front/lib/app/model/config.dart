import 'controller.dart';

class Config {
  final String mqttAddress;
  final String serviceId;
  final List<Controller> ctrls;

  Config(
      {required this.mqttAddress,
      required this.serviceId,
      required this.ctrls});
  factory Config.fromJson(dynamic json) {
    var ctrls = (json['ctrls'] as List<dynamic>)
        .map(
          (e) => Controller.fromJson(e),
        )
        .toList();

    return Config(
      mqttAddress: json['mqtt_address'],
      serviceId: json['service_id'],
      ctrls: ctrls,
    );
  }
}
