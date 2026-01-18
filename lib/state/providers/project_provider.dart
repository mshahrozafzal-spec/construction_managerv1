// lib/state/providers/project_provider.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/data/local/db_helper.dart';
import 'package:construction_manager/data/models/project_model.dart';
import 'package:construction_manager/data/repositories/project_repository.dart';

class ProjectProvider extends ChangeNotifier {
  final DBHelper dbHelper;
  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  ProjectModel? _selectedProject;

  ProjectProvider({required this.dbHelper}) {
    _repository = ProjectRepository(dbHelper: dbHelper);
  }

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  ProjectModel? get selectedProject => _selectedProject;

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

  Future<void> addProject(ProjectModel ProjectModel) async {
    try {
      final id = await _repository.addProject(ProjectModel);
      final newProject = ProjectModel.copyWith(id: id);
      _projects.add(newProject);
      notifyListeners();
    } catch (e) {
      print('Error adding ProjectModel: $e');
    }
  }

  Future<void> updateProject(ProjectModel ProjectModel) async {
    try {
      await _repository.updateProject(ProjectModel);
      final index = _projects.indexWhere((p) => p.id == ProjectModel.id);
      if (index != -1) {
        _projects[index] = ProjectModel;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating ProjectModel: $e');
    }
  }

  Future<void> deleteProject(int id) async {
    try {
      await _repository.deleteProject(id);
      _projects.removeWhere((ProjectModel) => ProjectModel.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting ProjectModel: $e');
    }
  }

  void selectProject(ProjectModel? ProjectModel) {
    _selectedProject = ProjectModel;
    notifyListeners();
  }
}
