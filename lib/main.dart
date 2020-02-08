import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

const appName = 'FrogAlarm';
const PrimaryColor = Colors.green;
var thefrog;

void main() {
  runApp(MaterialApp(
    title: appName,
    home: MyHomePage(),
    theme: ThemeData(
      primaryColor: PrimaryColor,
    ),
    supportedLocales: [
      const Locale('en'), // English
    ],
  ));
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Container(
              width: 200,
              child: Column(
                children: <Widget>[
                  DateTimeForm(),
                  Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        isSwitched = value;
                        print(isSwitched);
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                  RaisedButton(
                    onPressed: bluetoothSearch,
                    child: const Text('Bluetooth search',
                        style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  void onFrogFound(device) async {
    await device.connect();
    print('${thefrog.name} connected!');
    List<BluetoothService> services = await thefrog.discoverServices();
    services.forEach((service) async {
      var characteristics = service.characteristics;
      for(BluetoothCharacteristic c in characteristics) {
        print(c.uuid);
        if(c.uuid.toString() == "00001990-0000-1000-8000-00805f9b34fb") {
          print("uuid mathc!");
          await c.write([0xE8,0x03]);
          print("Delay sent!");
        }
      }
    });
    print("Finished");
    device.disconnect();
    thefrog = null;
  }

  void bluetoothSearch() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 10));

// Listen to scan results
    flutterBlue.scanResults.listen((scanResult) async {
      print("Found devices: ${scanResult.length}");
      for (ScanResult result in scanResult) {
        var device = result.device;
        print('${device.name} found.');
        if ((device.id.id == "F5:3C:86:E7:D2:64" ||
                device.name == "FrogAlarm") &&
            thefrog == null) {
          print('${device.name} connecting');
          thefrog = device;
          onFrogFound(device);
          print('${device.name} stopping scan!');
          flutterBlue.stopScan();
          break;
        }
      }
    });

    // Stop scanning
    flutterBlue.stopScan();
  }
}

class DateTimeForm extends StatefulWidget {
  @override
  _DateTimeFormState createState() => _DateTimeFormState();
}

class _DateTimeFormState extends State<DateTimeForm> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BasicTimeField();
  }
}

class BasicTimeField extends StatelessWidget {
  final format = DateFormat("hh:mm a");

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Frog will ring (${format.pattern})'),
          Text("Connection: ${thefrog}"),
          DateTimeField(
            format: format,
            resetIcon: null,
            onShowPicker: (context, currentValue) async {
              final time = await showTimePicker(
                context: context,
                initialTime:
                    TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
              );
              return DateTimeField.convert(time);
            },
          ),
        ]);
  }
}
