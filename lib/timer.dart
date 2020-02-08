import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'debug.dart';
import 'package:numberpicker/numberpicker.dart';

class TimerStateful extends StatefulWidget {
  @override
  TimerStateless createState() => TimerStateless();
}

String displayHours = "";
String displayMinutes = "";
String displaySeconds = "";

class TimerStateless extends State<TimerStateful> {
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  int totalSeconds = 0;
  final _controllerH = TextEditingController();
  final _controllerM = TextEditingController();
  final _controllerS = TextEditingController();

  bool timerActive = false;
  IconData buttonIcon = Icons.play_arrow;

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
                  clocka(context),
                  FloatingActionButton(
                    child: Icon(buttonIcon, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        if (!timerActive) {
                          startTimer();
                        } else {
                          stopTimer();
                        }
                      });
                    },
                  ),
                ],
              ),
            )));
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
    displaySeconds = (seconds < 10) ? "0$seconds" : "$seconds";
  }

  void dispose() {
    _controllerH.dispose();
    _controllerM.dispose();
    _controllerS.dispose();
    super.dispose();
  }

  Timer t;

  void startTimer() {
    setState(() {
      timerActive = true;
      buttonIcon = Icons.pause;
      _controllerH.text = "";
      _controllerM.text = "";
      _controllerS.text = "";
    });

    totalSeconds = seconds + minutes * 60 + hours * 60 * 60;
    setFrogTimer(hours, minutes, seconds);
    t = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (totalSeconds != 0) {
          print("$totalSeconds seconds");
          totalSeconds -= 1;

          hours = totalSeconds ~/ 3600;
          minutes = (totalSeconds % 3600) ~/ 60;
          seconds = totalSeconds % 60;

          displayHours = (hours < 10) ? "0$hours" : "$hours";
          displayMinutes = (minutes < 10) ? "0$minutes" : "$minutes";
          displaySeconds = (seconds < 10) ? "0$seconds" : "$seconds";
        } else {
          timerDone();
        }
      });
    });
  }

  void stopTimer() {
    setState(() {
      t.cancel();
      timerActive = false;
      buttonIcon = Icons.play_arrow;
    });
  }

  void timerDone() {
    print("TIMER DONE");
    animController.forward();
    Timer(Duration(seconds: 7), () {
      animController.stop();
    });
    stopTimer();

    //FROG LOGIC
  }

  clocka(context) {
    var theme = Theme.of(context);

    if (timerActive) {
      return BlinkingTextAnimation();
    } else {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(children: [
              new NumberPicker.integer(
                  initialValue: hours,
                  itemExtent: 60,
                  listViewWidth: 150,
                  minValue: 0,
                  maxValue: 23,
                  zeroPad: true,
                  infiniteLoop: true,
                  onChanged: (val) => setState(() {
                        hours = val.toInt();
                      })),
              Text(
                "Hours",
                style: TextStyle(color: theme.disabledColor, fontSize: 10),
              )
            ]),
            Column(children: [
              new NumberPicker.integer(
                  initialValue: minutes,
                  itemExtent: 60,
                  listViewWidth: 150,
                  minValue: 0,
                  maxValue: 59,
                  zeroPad: true,
                  infiniteLoop: true,
                  onChanged: (val) => setState(() {
                        minutes = val.toInt();
                      })),
              Text(
                "Minutes",
                style: TextStyle(color: theme.disabledColor, fontSize: 10),
              )
            ]),
            Column(children: [
              new NumberPicker.integer(
                  initialValue: seconds,
                  itemExtent: 60,
                  listViewWidth: 150,
                  minValue: 0,
                  maxValue: 59,
                  zeroPad: true,
                  infiniteLoop: true,
                  onChanged: (val) => setState(() {
                        seconds = val.toInt();
                      })),
              Text(
                "Seconds",
                style: TextStyle(color: theme.disabledColor, fontSize: 10),
              )
            ]),
          ]);
    }
  }
}

class BlinkingTextAnimation extends StatefulWidget {
  @override
  _BlinkingAnimationState createState() => _BlinkingAnimationState();
}

AnimationController animController;

class _BlinkingAnimationState extends State<BlinkingTextAnimation>
    with SingleTickerProviderStateMixin {
  Animation<Color> animation;

  initState() {
    super.initState();

    animController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    final CurvedAnimation curve =
        CurvedAnimation(parent: animController, curve: Curves.linear);

    animation =
        ColorTween(begin: Colors.black, end: Colors.white).animate(curve);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) {
          return new Container(
            child: Text("$displayHours : $displayMinutes : $displaySeconds",
                style: TextStyle(color: animation.value, fontSize: 40)),
          );
        });
  }

  dispose() {
    animController.dispose();
    super.dispose();
  }
}
