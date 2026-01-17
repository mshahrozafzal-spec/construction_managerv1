// lib/database/repositories/project_repository.dart
import 'package:construction_manager/database/db_helper.dart';
import 'package:construction_manager/database/models/project.dart';

class ProjectRepository {
  final DBHelper dbHelper;

  ProjectRepository({DBHelper? dbHelper}) : dbHelper = dbHelper ?? DBHelper();

  Future<int> addProject(Project project) async {
    return await dbHelper.insertProject(project.toMap());
  }

  Future<List<Project>> getAllProjects() async {
    final projects = await dbHelper.getProjects();
    return projects.map((map) => Project.fromMap(map)).toList();
  }

  Future<int> updateProject(Project project) async {
    if (project.id == null) return 0;
    return await dbHelper.updateProject(project.id!, project.toMap());
  }

  Future<int> deleteProject(int id) async {
    return await dbHelper.deleteProject(id);
  }
}