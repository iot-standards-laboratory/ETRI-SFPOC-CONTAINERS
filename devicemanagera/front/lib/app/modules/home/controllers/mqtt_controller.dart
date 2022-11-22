import 'package:front/app/controller/mqttclient.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MQTTController {
  MqttBrowserClient? mqttClient;
  String? latestTopic;
  Function(String topic, String payload) onUpdate;
  MQTTController({required this.onUpdate}) {
    mqttClient = newMqttClient(mqttAddr: "localhost");

    final connMess = MqttConnectMessage()
        // .withClientIdentifier('service')
        .withWillTopic(
            'public/statuschanged') // If you set this you must set a will message
        .withWillMessage('I am user')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    mqttClient!.connectionMessage = connMess;
  }

  Future<bool> connect(String svcId) async {
    try {
      await mqttClient!.connect("etri", "etrismartfarm");
      _subscribeChannel(topic: svcId);
    } on Exception catch (e) {
      mqttClient!.disconnect();
      return false;
    }

    mqttClient!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      // print('');

      onUpdate!(c[0].topic, pt);
    });

    return true;
  }

  void addOnUpdate(Function(String topic, String payload) newOnUpdate) {
    onUpdate = newOnUpdate;
  }

  void _subscribeChannel({required String topic}) {
    mqttClient!.subscribe(topic, MqttQos.atMostOnce);
  }

  void updateSubscribeChannel({required String topic}) {
    if (latestTopic != null && latestTopic!.isNotEmpty) {
      unsubscribeChannel(topic: latestTopic!);
    }

    latestTopic = topic;
    _subscribeChannel(topic: topic);
  }

  void disconnect() {
    mqttClient!.disconnect();
  }

  void unsubscribeChannel({required String topic}) {
    mqttClient!.unsubscribe(topic);
  }
}
