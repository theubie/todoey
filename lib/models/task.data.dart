import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todoey/models/task.dart';

class TaskData extends ChangeNotifier {
  //For storing and retrieving between sessions
  final _box = GetStorage(); // list of maps gets stored here
  late List _storageList = [];

  TaskData() {
    //Retrieve our data.
    _restoreTasks();
  }

  final List<Task> _tasks = [
    Task(name: 'Buy Milk'),
    Task(name: 'Buy Eggs'),
    Task(name: 'Buy Bread'),
  ];

  UnmodifiableListView<Task> get tasks {
    return UnmodifiableListView(_tasks);
  }

  int get taskCount {
    return _tasks.length;
  }

  void addTask(taskName) {
    _tasks.add(Task(name: taskName));

    //Store our tasks
    _storeTasks();

    //Notify our listeners
    notifyListeners();
  }

  void updateTask(Task task) {
    task.toggleDone();
    _storeTasks();
    notifyListeners();
  }

  void deleteTask(Task task) {
    _tasks.remove(task);
    _storeTasks();
    notifyListeners();
  }

  void _storeTasks() {
    //Clear the storageMap
    _storageList.clear();

    //Loop through all our tasks and add them to the storageMap
    var index = 0;
    for (var element in _tasks) {
      final storageMap = {}; // temporary map that gets added to storage
      final nameKey = 'name$index';
      final isDoneKey = 'isDone$index';

      // adding task properties to temporary map

      storageMap[nameKey] = element.name;
      storageMap[isDoneKey] = element.isDone;

      _storageList.add(storageMap); // adding temp map to storageList
      index++;
    }
    _box.write('tasks', _storageList); // adding list of maps to storage
  }

  void _restoreTasks() {
    _storageList = _box.read('tasks') ?? []; // initializing list from storage

    String nameKey, isDoneKey;

    //Clear the tasks list
    _tasks.clear();

    // looping through the storage list to parse out Task objects from maps
    for (int i = 0; i < _storageList.length; i++) {
      final map = _storageList[i];
      // index for retrieval keys accounting for index starting at 0

      nameKey = 'name$i';
      isDoneKey = 'isDone$i';

      // recreating Task objects from storage
      final task = Task(name: map[nameKey], isDone: map[isDoneKey]);

      _tasks.add(task); // adding Tasks back to your normal Task list
    }
  }
}
