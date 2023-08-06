import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight, _deviceWidth;
  String? _newTaskContent;
  Box? _box;

  _HomePageState();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    debugPrint("input value: $_newTaskContent");
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: _deviceHeight * 0.15,
            title: Text(
              "Taskly",
              style: TextStyle(fontSize: 25.0),
            ),
          ),
          body: _tasksView(),
          floatingActionButton: _addTaskButton()),
    );
  }

  Widget _tasksView() {
    return FutureBuilder(
      future: Hive.openBox('tasks'),
      // future: Future.delayed(
      //   Duration(seconds: 2),
      // ),
      builder: (BuildContext _context, AsyncSnapshot _snapshot) {
        if (_snapshot.hasData) {
          // if (_snapshot.connectionState == ConnectionState.done) {
          _box = _snapshot.data;
          return _tasksList();
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _tasksList() {
    List tasks = _box!.values.toList();
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        var task = Task.fromMap(tasks[index]);
        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
              decoration: task.done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            // DateTime.now().toString(),
            task.timestamp.toString(),
          ),
          // trailing: !tasks[index]['done']
          trailing: !task.done
              ? Icon(
                  Icons.check_box_outline_blank_outlined,
                  color: Colors.red,
                )
              : Icon(
                  Icons.check_box_outlined,
                  color: Colors.red,
                ),
          onTap: () {
            task.done = !task.done;
            _box!.putAt(index, task.toMap());
            setState(() {});
          },
          onLongPress: () {
            _box!.deleteAt(index);
            setState(() {});
          },
        );
      },
      itemCount: tasks.length,
    );
    // Task _newTask =
    //     Task(content: "Eat pizza", timestamp: DateTime.now(), done: false);
    // _box?.add(_newTask.toMap());
    // Task _newTask =
    //     Task(content: "Eat pizza", timestamp: DateTime.now(), done: false);
    // _box?.add(_newTask.toMap());
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopup,
      child: Icon(Icons.add),
    );
  }

  void _displayTaskPopup() {
    showDialog(
        context: context,
        builder: (BuildContext _context) {
          return AlertDialog(
            title: Text("Add new Task!"),
            content: TextField(
              onSubmitted: (_value) {
                if (_newTaskContent != null) {
                  var _task = Task(
                      content: _newTaskContent!,
                      timestamp: DateTime.now(),
                      done: false);
                  _box!.add(_task.toMap());
                  setState(() {
                    _newTaskContent = null;
                    Navigator.pop(context);
                  });
                }
              },
              onChanged: (_value) {
                setState(() {
                  _newTaskContent = _value;
                });
              },
            ),
          );
        });
  }
}
