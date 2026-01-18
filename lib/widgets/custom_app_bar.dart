import 'package:flutter/material.dart';

class ExpenseCard extends StatelessWidget {
  final String title;
  final String amount;
  ExpenseCard({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        title: Text(title),
        subtitle: Text("Amount: $amount"),
        trailing: Icon(Icons.more_vert),
      ),
    );
  }
}

