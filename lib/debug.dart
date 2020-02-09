import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

BluetoothDevice frogDevice;

class DebugStateful extends StatefulWidget {
  @override
  DebugState createState() => DebugState();
}

class DebugState extends State<DebugStateful> {
  void DisconnectFrog() {
    if (frogDevice != null) {
      frogDevice.disconnect();
      setState(() {
        frogDevice = null;
        print("Frog disconnected.");
      });
    } else {
      print("No frog to disconnect.");
    }
  }

  void ConnectFrog() {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 30));

// Listen to scan results
    flutterBlue.scanResults.listen((scanResult) async {
      print("Found devices: ${scanResult.length}");
      for (ScanResult result in scanResult) {
        var device = result.device;
        print('${device.name} found.');
        if ((device.id.id == "F5:3C:86:E7:D2:64" ||
                device.name == "FrogAlarm") &&
            frogDevice == null) {
          print('${device.name} connecting');
          setState(() {
            frogDevice = device;
          });
          device.connect();
          print('${device.name} stopping scan!');
          flutterBlue.stopScan();
          break;
        }
      }
    });

    // Stop scanning
    flutterBlue.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
        child: Column(
          children: <Widget>[
            Text("Connection: ${frogDevice}"),
            RaisedButton(
              onPressed: () {
                ConnectFrog();
              },
              child: const Text('Connect frog', style: TextStyle(fontSize: 20)),
            ),
            RaisedButton(
              onPressed: () {
                DisconnectFrog();
              },
              child:
                  const Text('Disconnect frog', style: TextStyle(fontSize: 20)),
            ),
            RaisedButton(
              onPressed: () {
                setFrogTimer(0, 0, 1);
              },
              child: const Text('Test frog', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

List<int> converter(hours, minutes, seconds) {
  print([hours, minutes, seconds]);
  var milliseconds = (hours * 3600 + minutes * 60 + seconds);
  List<int> signal = [milliseconds & 0xFF, (milliseconds >> 8) & 0xFF];
  print(signal);
  return signal;
}

/*void onFrogFound(device) async {
  await device.connect();
  print('${frogDevice.name} connected!');
  List<BluetoothService> services = await frogDevice.discoverServices();
  services.forEach((service) async {
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      print(c.uuid);
      if (c.uuid == new Guid("00001990-0000-1000-8000-00805f9b34fb")) { ///WILL THIS LINE WORK? THE LAST WORKING ONE WAS: c.uuid.toString() == "00001990-0000-1000-8000-00805f9b34fb"
        print("Uuid match!");
        await c.write(converter(0, 0, 1));
        print("Delay sent!");
      }
    }
  });
  print("Finished");
  device.disconnect();
  frogDevice = null;
}*/

void setFrogTimer(hh, mm, ss) async {
  if (frogDevice != null) {
    List<BluetoothService> services = await frogDevice.discoverServices();
    services.forEach((service) async {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid == new Guid("00001990-0000-1000-8000-00805f9b34fb")) {
          ///WILL THIS LINE WORK? THE LAST WORKING ONE WAS: c.uuid.toString() == "00001990-0000-1000-8000-00805f9b34fb"
          await c.write(converter(hh, mm, ss));
          print("Delay sent!");
        }
      }
    });
  }
}

/*void bluetoothSearch() async {
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
          frogDevice == null) {
        print('${device.name} connecting');
        frogDevice = device;
        onFrogFound(device);
        print('${device.name} stopping scan!');
        flutterBlue.stopScan();
        break;
      }
    }
  });

  // Stop scanning
  flutterBlue.stopScan();
}*/
