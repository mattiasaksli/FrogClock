import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:intl/intl.dart';

const appName = 'FrogAlarm';
const PrimaryColor = Colors.lightGreen;
var thefrog;

void main() {
  runApp(MaterialApp(
    title: appName,
    home: PageViewController(),
    theme: ThemeData(
      primaryColor: PrimaryColor,
    ),
    supportedLocales: [
      const Locale('en'), // English
    ],
  ));
}

class PageViewController extends StatelessWidget {
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      children: <Widget>[AlarmStateful(), TimerStateful(), DebugStateful()],
    );
  }
}

class AlarmStateful extends StatefulWidget {
  @override
  AlarmState createState() => AlarmState();
}

class AlarmState extends State<AlarmStateful> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
              /*bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.directions_car)),
                Tab(icon: Icon(Icons.directions_transit)),
                Tab(icon: Icon(Icons.directions_bike)),
              ],
            ),*/
              ),
          body: Container(
            margin: EdgeInsets.fromLTRB(50, 50, 50, 50),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 100, 0, 50),
                  child: Text(
                    "frog will ring at",
                    style: TextStyle(
                        fontSize: 40,
                        color: isSwitched
                            ? Color.fromARGB(255, 0, 70, 0)
                            : Color.fromARGB(255, 200, 200, 200)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(100, 10, 100, 10),
                  child: DateTimeForm(),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: Transform.scale(
                    scale: 4,
                    child: Switch(
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
                  ),
                ),
              ],
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

class BasicTimeField extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BasicTimeFieldState();
  }
}

class BasicTimeFieldState extends State<BasicTimeField> {
  final format = DateFormat("HH:mm");

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    var currentValue = TimeOfDay.now();
    return Center(
        child: Transform.scale(
            scale: 8,
            child: GestureDetector(
                onTap: () async {
                  print("Trying to opena di clocka");
                  currentValue = await showTimePicker(
                    context: context,
                    initialTime:
                        currentValue ?? TimeOfDay.fromDateTime(DateTime.now()),
                  );
                },
                child: Text(localizations.formatTimeOfDay(currentValue,
                    alwaysUse24HourFormat: true)))));
  }
}

class TimerStateful extends StatefulWidget {
  @override
  TimerState createState() => TimerState();
}

class TimerState extends State<TimerStateful> {
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  int totalSeconds = 0;
  final _controllerH = TextEditingController();
  final _controllerM = TextEditingController();
  final _controllerS = TextEditingController();
  String displayHours = "";
  String displayMinutes = "";
  String displaySeconds = "";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Timer"),
          ),
          body: new Container(
            padding: const EdgeInsets.all(90),
            alignment: Alignment.center,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  //margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Text(
                    "$displayHours : $displayMinutes : $displaySeconds",
                    style: TextStyle(fontSize: 40),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                      onChanged: (String newValue) {
                        setState(() {
                          hours = int.parse(newValue);
                          displayHours = (hours < 10) ? "0$hours" : "$hours";
                        });
                      },
                      controller: _controllerH,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                        BlacklistingTextInputFormatter(new RegExp(
                            "[2-9][4-9]|[0-9][0-9][0-9]|[3-9][0-9]")),
                      ],
                      decoration: InputDecoration(
                        labelText: "Hours",
                        border: OutlineInputBorder(),
                      )),
                ),
                Expanded(
                  //margin: const EdgeInsets.fromLTRB(0, 50, 0, 50),
                  child: TextFormField(
                      onChanged: (String newValue) {
                        setState(() {
                          minutes = int.parse(newValue);
                          displayMinutes =
                              (minutes < 10) ? "0$minutes" : "$minutes";
                        });
                      },
                      controller: _controllerM,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                        BlacklistingTextInputFormatter(
                            new RegExp("[6-9][0-9]|[0-9][0-9][0-9]"))
                      ],
                      decoration: InputDecoration(
                        labelText: "Minutes",
                        border: OutlineInputBorder(),
                      )),
                ),
                Expanded(
                  child: TextFormField(
                      onChanged: (String newValue) {
                        setState(() {
                          seconds = int.parse(newValue);
                          displaySeconds =
                              (hours < 10) ? "0$seconds" : "$seconds";
                        });
                      },
                      controller: _controllerS,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                        BlacklistingTextInputFormatter(
                            new RegExp("[6-9][0-9]|[0-9][0-9][0-9]"))
                      ],
                      decoration: InputDecoration(
                        labelText: "Seconds",
                        border: OutlineInputBorder(),
                      )),
                ),
                Container(
                  //margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: RaisedButton(
                    child: Text("Start timer"),
                    onPressed: () {
                      setState(() {
                        startTimer();
                        _controllerH.text = "";
                        _controllerM.text = "";
                        _controllerS.text = "";
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void initState() {
    _controllerH.addListener(() {
      final text = _controllerH.text.toLowerCase();
      _controllerH.value = _controllerH.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    _controllerM.addListener(() {
      final text = _controllerM.text.toLowerCase();
      _controllerM.value = _controllerM.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    _controllerS.addListener(() {
      final text = _controllerS.text.toLowerCase();
      _controllerS.value = _controllerS.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    super.initState();

    displayHours = (hours < 10) ? "0$hours" : "$hours";
    displayMinutes = (minutes < 10) ? "0$minutes" : "$minutes";
    displaySeconds = (hours < 10) ? "0$seconds" : "$seconds";
  }

  void dispose() {
    _controllerH.dispose();
    _controllerM.dispose();
    _controllerS.dispose();
    super.dispose();
  }

  void startTimer() {
    totalSeconds = seconds + minutes * 60 + hours * 60 * 60;
    print("$totalSeconds seconds");
  }
}

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

void bluetoothSearch() {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  // Start scanning
  flutterBlue.startScan(timeout: Duration(seconds: 4));

// Listen to scan results
  var subscription = flutterBlue.scanResults.listen((scanResult) {
    for (ScanResult result in scanResult) {
      var device = result.device;
      if (device.name == "FrogAlarm") {
        device.connect();
        print('${device.name} connected!');
        flutterBlue.stopScan();
        break;
      }
    }
  });

// Stop scanning
  flutterBlue.stopScan();
}
