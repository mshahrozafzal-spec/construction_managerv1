import 'package:construction_manager/data/local/db_helper.dart';
// Updated import - now matches the renamed file
import 'package:construction_manager/data/models/task_model.dart';

class TaskRepository {
  final DBHelper dbHelper;

  TaskRepository({DBHelper? dbHelper}) : dbHelper = dbHelper ?? DBHelper();

  Future<int> addTask(TaskModel task) async {
    return await dbHelper.insertTask(task.toMap());
  }

  Future<List<TaskModel>> getAllTasks({int? projectId}) async {
    List<Map<String, dynamic>> tasks;

    if (projectId != null) {
      tasks = await dbHelper.getTasksByProject(projectId);
    } else {
      tasks = await dbHelper.getTasks();
    }

    return tasks.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<List<TaskModel>> getTasksByProject(int projectId) async {
    return getAllTasks(projectId: projectId);
  }

  Future<int> updateTask(TaskModel task) async {
    if (task.id == null) return 0;
    return await dbHelper.updateTask(task.id!, task.toMap());
  }

  Future<int> deleteTask(int id) async {
    return await dbHelper.deleteTask(id);
  }
}
