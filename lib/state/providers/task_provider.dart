import 'package:flutter/material.dart';
import 'package:construction_manager/database/db_helper.dart';
import 'package:construction_manager/database/models/task.dart';
import 'package:construction_manager/database/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final DBHelper dbHelper;
  List<Task> _tasks = [];
  bool _isLoading = false;
  Task? _selectedTask;

  TaskProvider({required this.dbHelper});

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  Task? get selectedTask => _selectedTask;

  final TaskRepository _repository = TaskRepository();

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _repository.getAllTasks();
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTasksByProject(int projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _repository.getTasksByProject(projectId);
    } catch (e) {
      print('Error loading tasks by project: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final id = await _repository.addTask(task);
      final newTask = task.copyWith(id: id);
      _tasks.add(newTask);
      notifyListeners();
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _repository.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _repository.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }
}