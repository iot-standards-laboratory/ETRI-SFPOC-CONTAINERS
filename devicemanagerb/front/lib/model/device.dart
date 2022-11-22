import 'dart:convert';

class Device {
  final String did;
  final String cid;
  final String dname;
  final String sname;

  const Device({
    required this.did,
    required this.dname,
    required this.cid,
    required this.sname,
  });

  factory Device.fromJson(dynamic json) {
    return Device(
      did: json["did"],
      cid: json["cid"],
      dname: json["dname"],
      sname: json["sname"],
    );
  }

  @override
  String toString() {
    var obj = {
      "did": did,
      "cid": cid,
      "dname": dname,
      "sname": sname,
    };

    return jsonEncode(obj);
  }
}
