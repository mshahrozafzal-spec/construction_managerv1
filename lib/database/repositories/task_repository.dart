// lib/database/repositories/task_repository.dart
import 'package:construction_manager/database/db_helper.dart';
import 'package:construction_manager/database/models/task.dart';

class TaskRepository {
  final DBHelper dbHelper;

  TaskRepository({DBHelper? dbHelper}) : dbHelper = dbHelper ?? DBHelper();

  Future<int> addTask(Task task) async {
    return await dbHelper.insertTask(task.toMap());
  }

  Future<List<Task>> getAllTasks({int? projectId}) async {
    // Changed from dbHelper.getTasks() to dbHelper.getTasks()
    final tasks = await dbHelper.getTasks();
    List<Task> taskList = tasks.map((map) => Task.fromMap(map)).toList();

    if (projectId != null) {
      taskList = taskList.where((task) => task.projectId == projectId).toList();
    }

    return taskList;
  }

  Future<List<Task>> getTasksByProject(int projectId) async {
    return getAllTasks(projectId: projectId);
  }

  Future<int> updateTask(Task task) async {
    if (task.id == null) return 0;
    return await dbHelper.updateTask(task.id!, task.toMap());
  }

  Future<int> deleteTask(int id) async {
    return await dbHelper.deleteTask(id);
  }
}