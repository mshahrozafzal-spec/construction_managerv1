import 'package:construction_manager/data/local/db_helper.dart';
// Updated import - now matches the renamed file
import 'package:construction_manager/data/models/expense_model.dart';

class ExpenseRepository {
  final DBHelper dbHelper;

  ExpenseRepository({DBHelper? dbHelper}) : dbHelper = dbHelper ?? DBHelper();

  Future<int> addExpense(ExpenseModel expense) async {
    return await dbHelper.insertExpense(expense.toMap());
  }

  Future<List<ExpenseModel>> getAllExpenses({int? projectId}) async {
    List<Map<String, dynamic>> expenses;

    if (projectId != null) {
      expenses = await dbHelper.getExpensesByProject(projectId);
    } else {
      expenses = await dbHelper.getAllExpenses();
    }

    return expenses.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  Future<List<ExpenseModel>> getExpensesByProject(int projectId) async {
    return getAllExpenses(projectId: projectId);
  }

  Future<int> updateExpense(ExpenseModel expense) async {
    if (expense.id == null) return 0;
    return await dbHelper.updateExpense(expense.id!, expense.toMap());
  }

  Future<int> deleteExpense(int id) async {
    return await dbHelper.deleteExpense(id);
  }

  Future<Map<String, double>> getExpensesByCategory({int? projectId}) async {
    final expenses = await getAllExpenses(projectId: projectId);
    final Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      final currentTotal = categoryTotals[expense.category] ?? 0.0;
      categoryTotals[expense.category] = currentTotal + expense.amount;
    }

    return categoryTotals;
  }

  Future<double> getTotalExpenses({int? projectId}) async {
    final expenses = await getAllExpenses(projectId: projectId);
    double total = 0.0;
    for (var expense in expenses) {
      total += expense.amount;
    }
    return total;
  }
}
