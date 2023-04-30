import 'package:front/constants.dart';
import 'package:http/http.dart' as http;

void postCtrl(int ctrlValue) async {
  var apiUrl = Uri.base.path[Uri.base.path.length - 1] == '/'
      ? '${Uri.base.path}api/v1'
      : '${Uri.base.path}/api/v1';

  print(apiUrl);

  var response = await http
      .put(Uri.http(serverAddr, apiUrl), body: {"ctrlValue": ctrlValue});

  print("postctrl : " + response.body);
}
