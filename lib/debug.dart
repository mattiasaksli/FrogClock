import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

var thefrog;

class DebugStateful extends StatefulWidget {
  @override
  DebugState createState() => DebugState();
}

class DebugState extends State<DebugStateful> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
        child: Column(
          children: <Widget>[
            Text("Connection: ${thefrog}"),
            RaisedButton(
              onPressed: () {
                bluetoothSearch();
              },
              child: const Text('Bluetooth search',
                  style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

void onFrogFound(device) async {
  await device.connect();
  print('${thefrog.name} connected!');
  List<BluetoothService> services = await thefrog.discoverServices();
  services.forEach((service) async {
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      print(c.uuid);
      if (c.uuid.toString() == "00001990-0000-1000-8000-00805f9b34fb") {
        print("uuid mathc!");
        await c.write([0xE8, 0x03]);
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
      if ((device.id.id == "F5:3C:86:E7:D2:64" || device.name == "FrogAlarm") &&
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
