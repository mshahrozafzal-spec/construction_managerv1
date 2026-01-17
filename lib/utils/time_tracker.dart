// lib/utils/time_tracker.dart
import 'package:construction_manager/database/db_helper.dart';

class TimeTracker {
  final DBHelper dbHelper;

  TimeTracker(this.dbHelper);

  Future<double> calculateEstimatedHours({
    required DateTime startDate,
    required DateTime endDate,
    double dailyWorkHours = 8.0,
    bool excludeWeekends = true,
  }) async {
    final workingDays = await dbHelper.calculateWorkingDays(
      startDate,
      endDate,
      excludeWeekends: excludeWeekends,
    );

    return workingDays * dailyWorkHours;
  }
}