import '../models/labour_model.dart';

class LabourRepository {
  final List<LabourModel> _labours = [];

  List<LabourModel> getLaboursByProject(int projectId) {
    return _labours.where((l) => l.projectId == projectId).toList();
  }

  void addLabour(LabourModel labour) {
    _labours.add(labour);
  }
}