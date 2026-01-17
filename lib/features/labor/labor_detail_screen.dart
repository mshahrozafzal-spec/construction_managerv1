import 'package:flutter/material.dart';

class LaborDetailScreen extends StatefulWidget {
  final dynamic labor; // Replace 'dynamic' with your Labor model type

  const LaborDetailScreen({Key? key, required this.labor}) : super(key: key);

  @override
  State<LaborDetailScreen> createState() => _LaborDetailScreenState();
}

class _LaborDetailScreenState extends State<LaborDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.labor.name ?? 'Labor Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add your labor detail widgets here
            Text('Labor ID: ${widget.labor.id}'),
            Text('Name: ${widget.labor.name}'),
            Text('Phone: ${widget.labor.phone}'),
            Text('Rate: \$${widget.labor.rate?.toStringAsFixed(2)}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}