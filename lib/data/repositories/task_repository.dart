import '../models/task_model.dart';

class TaskRepository {
  final List<TaskModel> _tasks = [];

  Future<List<TaskModel>> getTasksByProject(int projectId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _tasks.where((t) => t.projectId == projectId).toList();
  }

  Future<void> addTask(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _tasks.add(task);
  }

  void updateTask(TaskModel task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
  }

  void deleteTask(int id) {
    _tasks.removeWhere((t) => t.id == id);
  }
}