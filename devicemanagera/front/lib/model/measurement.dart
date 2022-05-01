import 'dart:convert';

class MeasurementData {
  final String id;
  final String? name;
  final List<dynamic>? tags;
  final List<Status> status;

  MeasurementData({
    required this.id,
    required this.status,
    this.name = "",
    this.tags,
  });

  factory MeasurementData.fromJson(dynamic json) {
    var status = <Status>[];

    if (json["status"] is List<dynamic>) {
      for (var element in (json["status"] as List<dynamic>)) {
        status.add(Status.fromJson(element));
      }
    }

    return MeasurementData(
      id: json["id"],
      name: json["name"],
      tags: json["tags"],
      status: status,
    );
  }
  @override
  String toString() {
    var statusList = <dynamic>[];
    for (var element in status) {
      statusList.add(element.toMap());
    }

    var obj = {
      "id": id,
      "name": name,
      "status": statusList,
      "tags": tags,
    };
    return jsonEncode(obj);
  }
}

class Status {
  final String key;
  final String type;
  final String unit;
  final dynamic value;
  final String? description;

  Status({
    required this.key,
    required this.type,
    required this.unit,
    required this.value,
    this.description,
  });

  factory Status.fromJson(dynamic json) {
    return Status(
      key: json["Key"],
      type: json["Type"],
      unit: json["Unit"],
      description: json["Description"],
      value: json["Value"],
    );
  }

  dynamic toMap() {
    var obj = {
      "key": key,
      "type": type,
      "unit": unit,
      "description": description,
      "value": value,
    };
    return obj;
  }

  @override
  String toString() {
    var obj = toMap();
    return jsonEncode(obj);
  }
}
