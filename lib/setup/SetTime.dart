import 'package:flutter/material.dart';
import '../timer/durationPicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dto/ControllerDTO.dart';
import '../presets/PresetsModal.dart';

class SetTime extends StatefulWidget {

  SetTime();
  
  @override
  _SetTimeState createState() => new _SetTimeState();
}

class _SetTimeState extends State<SetTime> {
  Duration _duration = Duration.zero;
  DateTime _endTime = new DateTime.now();

  @override
  Widget build(BuildContext context) {
    final ControllerDTO dto = ModalRoute.of(context).settings.arguments;
    return new Scaffold(
      appBar: dto.controller.getSetupAppBar("Set Timer"),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
                child: getEndTimeString(
                    Theme.of(context).textTheme.bodyText2.color)),
            // the set time picker
            DurationPicker(
              duration: _duration,
              onChange: (val) {
                this.setState(() => _duration = val);
                setEndTime();
                // TO DO: check for time passing every thirty seconds 
              },
              snapToMins: 1.0,
            ),
            // choose from presets
            SizedBox(
                width: 140,
                child: RaisedButton(
                    color: Theme.of(context).primaryColorLight,
                    padding: EdgeInsets.all(14.0),
                    child: Row(
                      // Replace with a Row for horizontal icon + text
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Icon(Icons.timer, color: Colors.white),
                        Text("Presets",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(fontSize: 18, color: Colors.white))
                      ],
                    ),
                    onPressed: () => showPresetOptions(
                      dto.controller.timeUpdateCallback, 
                      dto.controller.taskUpdateCallback
                    ))),
            // the accept and cancel buttons
            ButtonBar(
              alignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              buttonPadding: EdgeInsets.fromLTRB(30, 10, 30, 10),
              children: <Widget>[
                FlatButton(
                  child: Text("Accept", style: TextStyle(fontSize: 20)),
                  onPressed: (isValidTime())
                      ? () {
                          // access callback passed by SetupController to go to AddTasks
                          dto.controller.setTime(_duration);
                          dto.controller.next("/AddTasks");
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void setEndTime() {
    if (_duration != Duration.zero) {
      _endTime = DateTime.now().add(_duration);
    }
  }

  RichText getEndTimeString(Color color) {
    String timeMarker;
    String result = "";
    // String result = "Ends at: ";
    if (_endTime.hour > 12) {
      timeMarker = "pm";
      result += (_endTime.hour - 12).toString();
    } else {
      timeMarker = "am";
      result += _endTime.hour.toString();
    }
    result += ":" + _endTime.minute.toString().padLeft(2, '0') + timeMarker;
    // Makes "Ends at: " normal weight and the end time bolded
    var text = new RichText(
      text: new TextSpan(
          style: new TextStyle(
            fontSize: 22.0,
            color: color,
          ),
          children: <TextSpan>[
            new TextSpan(text: 'Ends at: '),
            new TextSpan(
                text: '$result',
                style: new TextStyle(fontWeight: FontWeight.bold)),
          ]),
    );
    return text;
  }

  // checks if there is any time on the clock
  bool isValidTime() => (_duration > Duration.zero && _duration != null);

  void showPresetOptions(Function durationCallback, Function taskListCallback) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final presetDuration = await showDialog(
        context: context,
        builder: (context) {
          return PresetsModal(
              durationCallback: durationCallback,
              taskListCallback: taskListCallback,
              prefs: prefs);
        }) as Duration;
    if (presetDuration != null) {
      setState(() {
        _duration = presetDuration;
        setEndTime();
      });
      Navigator.pop(context);
    }
  }
}
