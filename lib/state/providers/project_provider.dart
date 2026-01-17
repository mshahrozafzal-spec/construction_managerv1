// lib/state/providers/project_provider.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/database/db_helper.dart';
import 'package:construction_manager/database/models/project.dart';
import 'package:construction_manager/database/repositories/project_repository.dart';

class ProjectProvider extends ChangeNotifier {
  final DBHelper dbHelper;
  List<Project> _projects = [];
  bool _isLoading = false;
  Project? _selectedProject;

  ProjectProvider({required this.dbHelper}) {
    _repository = ProjectRepository(dbHelper: dbHelper);
  }

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  Project? get selectedProject => _selectedProject;

  late final ProjectRepository _repository;

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      _projects = await _repository.getAllProjects();
    } catch (e) {
      print('Error loading projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProject(Project project) async {
    try {
      final id = await _repository.addProject(project);
      final newProject = project.copyWith(id: id);
      _projects.add(newProject);
      notifyListeners();
    } catch (e) {
      print('Error adding project: $e');
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _repository.updateProject(project);
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating project: $e');
    }
  }

  Future<void> deleteProject(int id) async {
    try {
      await _repository.deleteProject(id);
      _projects.removeWhere((project) => project.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting project: $e');
    }
  }

  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }
}