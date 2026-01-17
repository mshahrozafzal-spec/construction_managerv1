import '../models/expense_model.dart';

class ExpenseRepository {
  final List<ExpenseModel> _expenses = [];

  List<ExpenseModel> getExpensesByProject(int projectId) {
    return _expenses.where((e) => e.projectId == projectId).toList();
  }

  void addExpense(ExpenseModel expense) {
    _expenses.add(expense);
  }
}
