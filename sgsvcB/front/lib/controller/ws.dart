import 'dart:html';

import 'package:front/common/util.dart';
import 'package:front/constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel subscribeWithWebsocket() {
  return WebSocketChannel.connect(
    getUri('ws://$serverAddr', '${Uri.base.path}/push/v1'),
  );
}
