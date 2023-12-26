import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

MqttBrowserClient newMqttClient({
  required String scheme,
  required String host,
  required int port,
}) {
  var client =
      MqttBrowserClient('$scheme://$host', '', maxConnectionAttempts: 5);
  client.logging(on: false);
  client.setProtocolV311();
  client.connectTimeoutPeriod = 10000;
  client.port = port;
  client.onDisconnected = onDisconnected;
  client.onConnected = onConnected;
  client.onSubscribed = onSubscribed;
  client.pongCallback = pong;
  client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
  client.autoReconnect = true;
  client.resubscribeOnAutoReconnect = true;
  return client;
}

void Subscribe({
  required MqttBrowserClient client,
  required String topic,
  Function(String topic, String payload)? onUpdate,
}) {
  if (client.connectionStatus!.state != MqttConnectionState.connected) {
    print("ERROR::Client is invalid error");
    return;
  }

  print('LOG::Subscribing to the $topic');
  client.subscribe(topic, MqttQos.atMostOnce);

  /// The client has a change notifier object(see the Observable class) which we then listen to to get
  /// notifications of published updates to each subscribed topic.
}

/// The subscribed callback
void onSubscribed(String topic) {
  print('LOG::Subscription confirmed for topic $topic');
}

/// The unsolicited disconnect callback
void onDisconnected() {
  print('LOG::OnDisconnected client callback - Client disconnection');

  // if (client!.connectionStatus!.disconnectionOrigin ==
  //     MqttDisconnectionOrigin.solicited) {
  //   print('LOG::OnDisconnected callback is solicited, this is correct');
  // }
}

/// The successful connect callback
void onConnected() {
  print('LOG::OnConnected client callback - Client connection was sucessful');
}

/// Pong callback
void pong() {
  print('LOG::Ping response client callback invoked');
}
