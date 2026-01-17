class LabourModel {
  final int id;
  final int projectId;
  final String name;
  final double dailyRate;
  final int totalDays;

  LabourModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.dailyRate,
    required this.totalDays,
  });
}
