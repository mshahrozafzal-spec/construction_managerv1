class ExpenseModel {
  final int id;
  final int projectId;
  final String title;
  final double amount;
  final DateTime date;

  ExpenseModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.amount,
    required this.date,
  });
}
