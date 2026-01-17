// lib/database/repositories/expense_repository.dart
import 'package:construction_manager/database/db_helper.dart';
import 'package:construction_manager/database/models/expense.dart';

class ExpenseRepository {
  final DBHelper dbHelper;

  ExpenseRepository({DBHelper? dbHelper}) : dbHelper = dbHelper ?? DBHelper();

  Future<int> addExpense(Expense expense) async {
    return await dbHelper.insertExpense(expense.toMap());
  }

  Future<List<Expense>> getAllExpenses({int? projectId}) async {
    final expenses = await dbHelper.getAllExpenses();
    List<Expense> expenseList = expenses.map((map) => Expense.fromMap(map)).toList();

    if (projectId != null) {
      expenseList = expenseList.where((expense) => expense.projectId == projectId).toList();
    }

    return expenseList;
  }

  Future<List<Expense>> getExpensesByProject(int projectId) async {
    return getAllExpenses(projectId: projectId);
  }

  Future<int> updateExpense(Expense expense) async {
    if (expense.id == null) return 0;
    return await dbHelper.updateExpense(expense.id!, expense.toMap());
  }

  Future<int> deleteExpense(int id) async {
    return await dbHelper.deleteExpense(id);
  }

  // Get expenses by category - FIXED
  Future<Map<String, double>> getExpensesByCategory({int? projectId}) async {
    final expenses = await getAllExpenses(projectId: projectId);
    final Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      final currentTotal = categoryTotals[expense.category] ?? 0.0;
      categoryTotals[expense.category] = currentTotal + expense.amount;
    }

    return categoryTotals;
  }

  // Get total expenses - FIXED
  Future<double> getTotalExpenses({int? projectId}) async {
    final expenses = await getAllExpenses(projectId: projectId);
    double total = 0.0;
    for (var expense in expenses) {
      total += expense.amount;
    }
    return total;
  }
}