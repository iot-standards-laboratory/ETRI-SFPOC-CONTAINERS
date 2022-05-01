import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:front/constants.dart';
import 'package:front/controller/http_handle.dart';
import 'package:front/controller/main_controlelr.dart';
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
  int _ctrlValue = 0;

  void _incrementCounter() {
    _ctrlValue += 100;
    setState(() {});
    postCtrl(_ctrlValue);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(width: 100, height: 100, color: Colors.red),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
