import 'dart:convert';

import 'package:front/app/model/config.dart';
import 'package:front/constants.dart';
import 'package:http/http.dart' as http;

Future<Config> loadConfig() async {
  var resp = await http.get(Uri.http(serverAddr, '${Uri.base.path}api/init'));
  var body = jsonDecode(resp.body);
  var config = Config.fromJson(body);
  return config;
  // return <Service>[];
}

