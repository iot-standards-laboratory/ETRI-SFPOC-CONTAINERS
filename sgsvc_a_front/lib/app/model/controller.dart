class Controller {
  final String reportChan;
  final String controlChan;
  final String name;

  Controller(
      {required this.reportChan,
      required this.controlChan,
      required this.name});

  factory Controller.fromJson(dynamic json) {
    return Controller(
      name: json['name'],
      reportChan: json['report_chan'],
      controlChan: json['control_chan'],
    );
  }
}
