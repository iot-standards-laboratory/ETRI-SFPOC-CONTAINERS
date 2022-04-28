import 'package:front/constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final ws = WebSocketChannel.connect(
    Uri.base.path[Uri.base.path.length - 1] == '/'
        ? Uri.parse('ws://$serverAddr${Uri.base.path}push/v1')
        : Uri.parse('ws://$serverAddr${Uri.base.path}/push/v1'));
