import 'package:flutter/material.dart';
import 'package:construction_manager/database/repositories/labor_repository.dart';
import 'package:construction_manager/database/repositories/attendance_repository.dart';

class LaborReportScreen extends StatefulWidget {
  final int? projectId;

  const LaborReportScreen({super.key, this.projectId});

  @override
  State<LaborReportScreen> createState() => _LaborReportScreenState();
}

class _LaborReportScreenState extends State<LaborReportScreen> {
  late Future<List<Map<String, dynamic>>> _laborFuture;
  final LaborRepository _laborRepository = LaborRepository();
  final AttendanceRepository _attendanceRepository = AttendanceRepository();

  @override
  void initState() {
    super.initState();
    _loadLabors();
  }

  void _loadLabors() {
    if (widget.projectId != null) {
      _laborRepository.getLaborsByProject(widget.projectId!).then((labors) {
        // Convert Labors to List<Map<String, dynamic>>
        final laborMaps = labors.map((labor) => labor.toMap()).toList();
        setState(() {
          _laborFuture = Future.value(laborMaps);
        });
      });
    } else {
      _laborRepository.getAllLabors().then((labors) {
        final laborMaps = labors.map((labor) => labor.toMap()).toList();
        setState(() {
          _laborFuture = Future.value(laborMaps);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Labor Report'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _laborFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final labors = snapshot.data ?? [];

          // Calculate totals
          double totalMonthlyWage = 0;
          double totalAdvance = 0;
          for (var labor in labors) {
            totalMonthlyWage += labor['monthly_wage'] as double? ?? 0.0;
            totalAdvance += labor['total_advance'] as double? ?? 0.0;
          }

          return Column(
            children: [
              // Summary cards
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                labors.length.toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Total Labor'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '\$${totalMonthlyWage.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Monthly Wage'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Labor list
              Expanded(
                child: ListView.builder(
                  itemCount: labors.length,
                  itemBuilder: (context, index) {
                    final labor = labors[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(labor['name'] as String? ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Role: ${labor['role'] ?? 'N/A'}'),
                            Text('Status: ${labor['status'] ?? 'N/A'}'),
                            Text('Monthly Wage: \$${(labor['monthly_wage'] as double? ?? 0.0).toStringAsFixed(2)}'),
                            Text('Advance: \$${(labor['total_advance'] as double? ?? 0.0).toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}