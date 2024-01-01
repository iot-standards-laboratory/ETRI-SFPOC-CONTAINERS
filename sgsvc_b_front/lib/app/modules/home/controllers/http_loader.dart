import 'dart:convert';

import 'package:front/app/model/config.dart';
import 'package:front/constants.dart';
import 'package:http/http.dart' as http;

final uriGetter = Uri.base.scheme == 'http' ? Uri.http : Uri.http;

Future<Config?> loadConfig() async {
  print("send: ${uriGetter(serverAddr, '${Uri.base.path}api/init')}");
  try {
    var resp =
        await http.get(uriGetter(serverAddr, '${Uri.base.path}api/init'));

    var body = jsonDecode(resp.body);
    var config =
        Config.fromJson(body, Uri.base.queryParameters["ctrl_id"] ?? "");

    return config;
  } catch (e) {
    print(e.toString());
  }

  return null;
}
