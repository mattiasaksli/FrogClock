import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/timer.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'dart:convert';

import 'debug.dart';

const appName = 'FrogAlarm';
const PrimaryColor = Colors.lightGreen;

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      home: TabsStateful(),
      theme: ThemeData(
        primaryColor: PrimaryColor,
      ),
      supportedLocales: [
        const Locale('en'), // English
      ],
    );
  }
}

//class PageViewController extends StatelessWidget {
//  final pageController = PageController();
//
//  @override
//  Widget build(BuildContext context) {
//    return PageView(
//      controller: pageController,
//      children: <Widget>[AlarmStateful(), TimerStateful(), DebugStateful()],
//    );
//  }
//}

class TabsStateful extends StatefulWidget {
  @override
  TabsState createState() => TabsState();
}

class TabsState extends State<TabsStateful> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 4,
      child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              isScrollable: false,
              tabs: [
                Tab(icon: Icon(Icons.device_unknown,
                  color: Color.fromARGB(0, 0, 0, 0),)),
                Tab(icon: Icon(Icons.access_alarms)),
                Tab(icon: Icon(Icons.timer)),
                Tab(icon: Icon(Icons.device_unknown,
                color: Color.fromARGB(0, 0, 0, 0),))
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              DebugStateful(),
              AlarmStateful(),
              TimerStateful(),
              DebugStateful()
            ],
          )
      ),
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
    return Scaffold(
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
      ),
    );
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
