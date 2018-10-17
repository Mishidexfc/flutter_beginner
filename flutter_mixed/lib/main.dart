import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static const platform = const MethodChannel('samples.flutter.io/battery');
  static const receiver = const EventChannel('samples.flutter.io/receiver');
  // 电池信息字符串
  String _batteryLevel = 'Unknown battery level.';
  // flutter页面标题
  String _titleText = 'How to get battery level';

  // 获取电量信息，并更新到label
  Future<Null> _getBatteryLevel() async {
    String batteryLevel;
    try {
      // 异步回调
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<Null> _informNavigatorPopFlutter() async {
    try {
      await platform.invokeMethod('informNavigatorPopFlutter');
    } on PlatformException catch (e) {
    }
  }

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
    receiver.receiveBroadcastStream('Jue Wang').listen(_onEvent,onError: _onError);
  }

  // event channel接收到事件，刷新标题
  void _onEvent(Object event) {
    var eventText = event;
    setState(() {
      _titleText = eventText;
    });
  }

  void _onError(Object error) {

  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: _informNavigatorPopFlutter),
        title: new Text(_titleText),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
                _batteryLevel
            )
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _getBatteryLevel,
        tooltip: 'Hint: Get battery level',
        child: new Icon(Icons.battery_charging_full),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
