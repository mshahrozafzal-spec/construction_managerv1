import 'package:flutter/material.dart';
import 'package:construction_manager/data/local/db_helper.dart';
import 'package:construction_manager/data/models/task_model.dart';
import 'package:construction_manager/data/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final DBHelper dbHelper;
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  TaskModel? _selectedTask;

  TaskProvider({required this.dbHelper});

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  TaskModel? get selectedTask => _selectedTask;

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
      print('Error loading tasks by ProjectModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(TaskModel TaskModel) async {
    try {
      final id = await _repository.addTask(TaskModel);
      final newTask = TaskModel.copyWith(id: id);
      _tasks.add(newTask);
      notifyListeners();
    } catch (e) {
      print('Error adding TaskModel: $e');
    }
  }

  Future<void> updateTask(TaskModel TaskModel) async {
    try {
      await _repository.updateTask(TaskModel);
      final index = _tasks.indexWhere((t) => t.id == TaskModel.id);
      if (index != -1) {
        _tasks[index] = TaskModel;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating TaskModel: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _repository.deleteTask(id);
      _tasks.removeWhere((TaskModel) => TaskModel.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting TaskModel: $e');
    }
  }
}
