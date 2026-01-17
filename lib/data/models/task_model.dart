class TaskModel {
  final int id;
  final int projectId;
  final String name;
  final String status; // e.g., Pending, In Progress, Completed
  final int progress; // 0-100
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.status,
    required this.progress,
    required this.createdAt,
  });
}
