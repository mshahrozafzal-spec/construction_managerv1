import 'package:flutter/material.dart';
import 'package:construction_manager/data/repositories/labor_repository.dart';
import 'package:construction_manager/data/repositories/attendance_repository.dart';

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
        final laborMaps = labors.map((LaborModel) => LaborModel.toMap()).toList();
        setState(() {
          _laborFuture = Future.value(laborMaps);
        });
      });
    } else {
      _laborRepository.getAllLabors().then((labors) {
        final laborMaps = labors.map((LaborModel) => LaborModel.toMap()).toList();
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
        title: const Text('LaborModel Report'),
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
          for (var LaborModel in labors) {
            totalMonthlyWage += LaborModel['monthly_wage'] as double? ?? 0.0;
            totalAdvance += LaborModel['total_advance'] as double? ?? 0.0;
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
                              const Text('Total LaborModel'),
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

              // LaborModel list
              Expanded(
                child: ListView.builder(
                  itemCount: labors.length,
                  itemBuilder: (context, index) {
                    final LaborModel = labors[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(LaborModel['name'] as String? ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Role: ${LaborModel['role'] ?? 'N/A'}'),
                            Text('Status: ${LaborModel['status'] ?? 'N/A'}'),
                            Text('Monthly Wage: \$${(LaborModel['monthly_wage'] as double? ?? 0.0).toStringAsFixed(2)}'),
                            Text('Advance: \$${(LaborModel['total_advance'] as double? ?? 0.0).toStringAsFixed(2)}'),
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
