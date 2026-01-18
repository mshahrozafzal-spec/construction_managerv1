import 'package:flutter/material.dart';

class LaborDetailScreen extends StatefulWidget {
  final dynamic LaborModel; // Replace 'dynamic' with your LaborModel model type

  const LaborDetailScreen({Key? key, required this.LaborModel}) : super(key: key);

  @override
  State<LaborDetailScreen> createState() => _LaborDetailScreenState();
}

class _LaborDetailScreenState extends State<LaborDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.LaborModel.name ?? 'LaborModel Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add your LaborModel detail widgets here
            Text('LaborModel ID: ${widget.LaborModel.id}'),
            Text('Name: ${widget.LaborModel.name}'),
            Text('Phone: ${widget.LaborModel.phone}'),
            Text('Rate: \$${widget.LaborModel.rate?.toStringAsFixed(2)}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
