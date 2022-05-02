import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:front/constants.dart';
import 'package:front/controller/http_handle.dart';
import 'package:front/controller/main_controlelr.dart';
import 'package:front/model/device.dart';
import 'package:front/model/measurement.dart';
import 'package:get/get.dart';

// import 'controller/ws.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      initialBinding: BindingsBuilder(() {
        Get.put(MainController());
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void dispose() {
    super.dispose();
  }

  Widget getStatusWidget(String did, MeasurementData? data) {
    if (data == null) {
      return Container();
    } else {
      print("get: ${data.id}");
      return GetBuilder<MainController>(
        id: data.id,
        builder: (ctrl) {
          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ctrl.measurements[did]!.status
                  .map(
                    (e) => Text(
                      "${e.key}: ${e.value} ${e.unit}",
                      style: const TextStyle(fontSize: 22),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      );
    }
  }

  Widget getDeviceWidget(Device dev, MeasurementData? data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "device name : ${dev.dname}",
          style: const TextStyle(fontSize: 26),
        ),
        Text(
          "device identifier : ${dev.did}",
          style: const TextStyle(fontSize: 22),
        ),
        Text(
          "controller id of device : ${dev.cid}",
          style: const TextStyle(fontSize: 22),
        ),
        const Text(
          "status :",
          style: const TextStyle(fontSize: 22),
        ),
        getStatusWidget(dev.did, data),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GetBuilder<MainController>(
        id: "devs",
        builder: (controller) {
          return ListView(
            children: controller.devList
                .map((e) => getDeviceWidget(e, controller.measurements[e.did]))
                .toList(),
          );
        },
      ),
    );
  }
}
