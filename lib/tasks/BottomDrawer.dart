import 'package:flutter/material.dart';
import 'Task.dart';
import 'TaskList.dart';
import 'ItemModal.dart';
import '../TimeKeeper.dart';
import '../theme.dart';

class BottomDrawer extends StatefulWidget {
  BottomDrawer({Key key, @required this.callback}) : super(key: key);

  final Function callback;

  @override
  _BottomDrawerState createState() => _BottomDrawerState(callback: callback);
}

class _BottomDrawerState extends State<BottomDrawer> {
  _BottomDrawerState({Key key, @required this.callback}) : super();

  final Function callback;
  Color newColor = newTaskLight;

  TaskList _taskList;

  @override
  Widget build(BuildContext context) {
    if (TimeKeeper.of(context) != null) {
      final time = TimeKeeper.of(context).time;
      _taskList = TimeKeeper.of(context).taskList;
      _taskList.maxTime = time; 
    }
    // this is the component that allows dragging up and down
    return DraggableScrollableSheet(
        initialChildSize: 0.2,
        minChildSize: 0.2,
        maxChildSize: 0.5,
        builder: (context, scrollController) {
          // scroll view for items in the drawer
          return SingleChildScrollView(
              physics:
                  ClampingScrollPhysics(), // supposed to stop from ever scrolling past bounds
              controller: scrollController,
              child: Column(children: <Widget>[
                // drag tab
                Container(
                  height: 24,
                  width: 64,
                  decoration: BoxDecoration(
                      color:  Theme.of(context).backgroundColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20))),
                  // drag tab icon
                  child: Container(
                    child: Icon(
                      Icons.drag_handle,
                      size: 32,
                      // color: dragTabIconColor,
                    ),
                  ),
                ),

                // holds the list of items
                Container(
                    height: (MediaQuery.of(context).size.height * 0.5) - 64,
                    width: MediaQuery.of(context).size.width,
                    color: Theme.of(context).backgroundColor,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.1,
                          vertical: 16),
                      itemCount: _taskList.getLength(),
                      itemBuilder: (context, index) {
                        Task task = _taskList.getTaskAt(index);
                        return GestureDetector(
                            child: Card(
                                color: Theme.of(context).cardColor,
                                child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                getCardBorder(task),
                                getCardBody(task),
                              ],
                            )),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ItemModal(
                                      task: task,
                                      totalDuration: _taskList.maxTime,
                                      taskDuration: task.time,
                                      timeChecker: _taskList.isTimeValid,
                                      color: (task.isNew
                                          ? _taskList.newItemColor
                                          : _taskList.defaultColor),
                                      onUpdate: updateCard,
                                      onDelete: deleteCard,
                                    );
                                  });
                            });
                      },
                      separatorBuilder: (context, index) {
                        return Container(height: 4, width: 0);
                      },
                    ))
              ]));
        });
  }

  // left tab border
  Widget getCardBorder(Task task) {
    return Container(
      width: 4,
      height: 48,
      decoration: BoxDecoration(
        color: task.color,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
      ),
    );
  }

  // creates the main section of the card
  Widget getCardBody(Task task) {
    return Expanded(
        child: ListTile(
      dense: true,
      leading: task.isNew
          // add icon for the "new item" card
          ? Icon(Icons.add_circle, size: 24, color: newColor)
          // icon for completed/uncompleted status
          : IconButton(
              icon: Icon(
                  task.completed
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 24,
                  color: task.color),
              onPressed: () {
                return updateCard(
                    task: task, isComplete: (task.completed ? false : true));
              }),
      title: Text(task.title, style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color, fontSize: 15)),
    ));
  }

  void updateCard(
      {Task task, bool isComplete, Duration newTime, String newTitle}) {
    if (_taskList.getTaskAt(_taskList.getLength() - 1) == task) {
      _taskList.createAddButton();
    }
    setState(() {
      _taskList.updateTask(
          task: task,
          title: newTitle,
          newTime: newTime,
          isComplete: isComplete);
      this.widget.callback(_taskList);
    });
  }

  void deleteCard(Task task) {
    setState(() {
      _taskList.deleteTask(task); 
      this.widget.callback(_taskList);
    });
  }
}
